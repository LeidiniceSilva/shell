#!/bin/bash

#SBATCH -N 1
#SBATCH -t CORDEX-CORE2
#SBATCH -J FPS-SESA
#SBATCH -p esp
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

set -eo pipefail

CDO() {
  cdo -O -L -f nc4 -z zip "$@"
}

regions=(
  NWN NEN WNA CNA ENA
  NCA SCA CAR
  NWS NSA SAM NES SES SWS SSA
  SAH WAF CAF NEAF SEAF ARP WSAF ESAF MDG
  WCA ECA SAS
  ESB RFE EAS TIB
  SEA
  NAU CAU EAU SAU NZ
  MED NEU WCE
)

indices=(TXx TN20) # RR1 RX1day TN20
dataset="CPC"

basedir="/home/netapp-clima-scratch/mda_silv/CORDEX-CORE2/OBS/${dataset}"
maskdir="/home/mda_silv/scratch/CORDEX-CORE2/Mask/IPCC"
outdir="/home/netapp-clima-scratch/mda_silv/CORDEX-CORE2/OBS/${dataset}"

maskstore="${outdir}/AR6_masks"
mkdir -p "$maskstore"

for idx in "${indices[@]}"; do

  infile="${basedir}/${idx}/${idx}_${dataset}_1979-2024.nc"
  tmpdir="${outdir}/${idx}_tmp"
  tsdir="${outdir}/${idx}_ts"

  mkdir -p "$tmpdir"
  mkdir -p "$tsdir"

  for reg in "${regions[@]}"; do
    echo "Processing region: ${reg}"

    mask_global="${maskdir}/${reg}_mask.nc"
    mask_cpc="${maskstore}/${reg}_mask_cpc.nc"
    tmpgrid="${maskstore}/grid_${reg}.txt"
    mask_fixed="${maskstore}/${reg}_fixed.nc"

    if [ ! -f "$mask_cpc" ]; then

      CDO griddes "$mask_global" > "$tmpgrid"
      sed -i 's/generic/lonlat/' "$tmpgrid"

      CDO setgrid,"$tmpgrid" "$mask_global" "$mask_fixed" 
      CDO remapnn,"$infile" "$mask_fixed" "$mask_cpc"
      
    fi

    maskedfile="${tmpdir}/${idx}_${reg}_masked.nc"
    CDO ifthen "$mask_cpc" "$infile" "$maskedfile"

    outfile="${tsdir}/${idx}_${reg}_ts.nc"
    CDO -O fldmean -selyear,1979/2024 "$maskedfile" "$outfile"

  done

done

echo "Done"
