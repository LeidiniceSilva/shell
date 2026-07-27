#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J ETCCDI
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

domains=(SAM-11)

indices=(TN20 RX1day)

basedir=/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/cordex_core/RegCM
maskdir=/leonardo/home/userexternal/mdasilva/leonardo_work/Mask/IPCC
outdir=/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/cordex_core/RegCM

for dom in "${domains[@]}"; do

echo "==== DOMAIN $dom ===="

[[ $dom = NAM-22 ]] && subregs="NWN NEN WNA CNA ENA"   #NCA
[[ $dom = CAM-22 ]] && subregs="NCA SCA CAR"
[[ $dom = SAM-11 ]] && subregs="NWS NSA SAM NES SES SWS SSA"
[[ $dom = AFR-22 ]] && subregs="SAH WAF CAF NEAF SEAF ARP WSAF ESAF MDG"
[[ $dom = WAS-22 ]] && subregs="WCA ECA SAS" #TIB ARP
[[ $dom = EAS-22 ]] && subregs="ESB RFE ECA TIB EAS"
[[ $dom = SEA-22 ]] && subregs="SEA"
[[ $dom = AUS-22 ]] && subregs="NAU CAU EAU SAU NZ"
[[ $dom = EUR-11 ]] && subregs="MED NEU WCE"

for idx in "${indices[@]}"; do

indir=${basedir}/${dom}/${idx}
outts=${outdir}/${dom}/${idx}_ts
maskstore=${outdir}/${dom}/AR6_masks
tmpdir=${outdir}/${dom}/${idx}_tmp

mkdir -p "$outts"
mkdir -p "$maskstore"
mkdir -p "$tmpdir"

for infile in ${indir}/${idx}_RegCM_Nor_1970-2024.nc; do

file=$(basename "$infile")
member=${file#${idx}_}
member=${member%_1970-2024.nc}

# Extract RCM name (1rd field)
rcm=$(echo $member | cut -d'_' -f1)

echo "Member: $member"
echo "RCM grid: $rcm"

for reg in $subregs; do

	mask_global=${maskdir}/${reg}_mask.nc
	mask_rcm=${maskstore}/${reg}_${rcm}.nc

	# Create remapped mask only if it doesn't exist
	if [[ ! -f $mask_rcm ]]; then

		echo "Creating mask for $reg on grid $rcm"

		tmpgrid=${maskstore}/grid_${reg}.txt
		mask_fixed=${maskstore}/${reg}_fixed.nc

		CDO griddes $mask_global > $tmpgrid
		sed -i 's/generic/lonlat/' $tmpgrid

		CDO -O setgrid,$tmpgrid $mask_global $mask_fixed
		CDO -O remapnn,$infile $mask_fixed $mask_rcm

		rm -f $tmpgrid $mask_fixed

	fi
        tmpfile=${tmpdir}/${idx}_${member}_${reg}_masked.nc
	outfile=${outts}/${idx}_${member}_${reg}_ts.nc

	echo "Processing: $idx | $member | $reg"

	#cdo -O fldmean -selyear,1970/2020 -setctomiss,1e20 -ifthen $mask_rcm $infile $outfile
	#create masked field
	CDO -O -setctomiss,1e20 -ifthen $mask_rcm $infile $tmpfile

	# compute regional mean
	CDO -O fldmean -selyear,1970/2024 $tmpfile $outfile

	done
done
done
done

echo "==== COMPLETE ===="

}

