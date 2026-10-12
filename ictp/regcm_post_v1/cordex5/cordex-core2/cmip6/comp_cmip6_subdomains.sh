#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J ETCCDI
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

set -eo pipefail

# Wrapper for CDO with custom default options
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

indices=(RX1day RR1 TXx TN20)
gcm="NorESM2-MM" # EC-Earth3-Veg  MPI-ESM1-2-HR  NorESM2-MM

basedir="/home/mda_silv/scratch/CORDEX-CORE2/CMIP6/${gcm}"
maskdir="/home/mda_silv/scratch/CORDEX-CORE2/Mask/IPCC"
outdir="/home/mda_silv/scratch/CORDEX-CORE2/CMIP6/${gcm}"

maskstore="${outdir}/AR6_masks"
mkdir -p "$maskstore"

for idx in "${indices[@]}"; do

  infile="${basedir}/${idx}/${idx}_${gcm}_1970-2024.nc"
  tmpdir="${outdir}/${idx}_tmp"
  tsdir="${outdir}/${idx}_ts"

  mkdir -p "$tmpdir"
  mkdir -p "$tsdir"

  for reg in "${regions[@]}"; do
    echo "Processing region: ${reg}..."

    mask_global="${maskdir}/${reg}_mask.nc"
    mask_cmip6="${maskstore}/${reg}_mask_cmip6.nc"
    tmpgrid="${maskstore}/grid_${reg}.txt"
    mask_fixed="${maskstore}/${reg}_fixed.nc"

    if [ ! -f "$mask_cmip6" ]; then

      CDO griddes "$mask_global" > "$tmpgrid"
      sed -i 's/generic/lonlat/' "$tmpgrid"

      CDO setgrid,"$tmpgrid" "$mask_global" "$mask_fixed" 
      CDO remapnn,"$infile" "$mask_fixed" "$mask_cmip6"
      
    fi

    maskedfile="${tmpdir}/${idx}_${reg}_masked.nc"
    CDO ifthen "$mask_cmip6" "$infile" "$maskedfile"

    outfile="${tsdir}/${idx}_${reg}_ts.nc"
    CDO fldmean "$maskedfile" "$outfile"

  done

done

echo "Processing complete."


