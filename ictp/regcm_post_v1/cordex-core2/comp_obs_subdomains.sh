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

ref=$1

indices=(RX1day TN20)

regions=(
    NWN NEN WNA CNA
    NCA SCA CAR
    NWS NSA SAM NES SES SWS SSA
    SAH WAF CAF NEAF SEAF ARP WSAF ESAF MDG
    WCA ECA SAS
    ESB RFE EAS TIB
    SEA
    NAU CAU EAU SAU NZ
    MED NEU WCE
)

basedir=/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/cordex_core/${ref}
maskdir=/leonardo/home/userexternal/mdasilva/leonardo_work/Mask/IPCC
outdir=/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/cordex_core/${ref}

for idx in "${indices[@]}"; do

    echo "==== Processing $idx ${ref} ===="

    infile=${basedir}/${idx}/${idx}_${ref}_1970-2022.nc

    tmpdir=${outdir}/${idx}/tmp
    tsdir=${outdir}/${idx}_ts
    maskstore=${outdir}/AR6_masks_${ref}

    mkdir -p "$tmpdir"
    mkdir -p "$tsdir"
    mkdir -p "$maskstore"

    gridfile=$infile

    for reg in "${regions[@]}"; do

        mask_global=${maskdir}/${reg}_mask.nc
        mask_obs=${maskstore}/${reg}_mask_${ref}.nc

        if [[ ! -f "$mask_obs" ]]; then

            echo "Preparing mask for $reg"

            tmpgrid=${maskstore}/grid_${reg}.txt
            mask_fixed=${maskstore}/${reg}_fixed.nc

            CDO griddes "$mask_global" > "$tmpgrid"

            sed -i 's/generic/lonlat/' "$tmpgrid"

            CDO -O setgrid,"$tmpgrid" \
                "$mask_global" \
                "$mask_fixed"

            CDO -O remapnn,"$gridfile" \
                "$mask_fixed" \
                "$mask_obs"

            rm -f "$tmpgrid" "$mask_fixed"

        fi

        tmpfile=${tmpdir}/${idx}_${ref}_${reg}_masked.nc
        outfile=${tsdir}/${idx}_${ref}_${reg}_ts.nc

        echo "Processing $idx | ${ref} | $reg"

        # create masked field
        CDO -O ifthen "$mask_obs" "$infile" "$tmpfile"

        # compute regional mean
        CDO -O fldmean "$tmpfile" "$outfile"

    done

done

echo "==== OBS processing complete ===="

}
