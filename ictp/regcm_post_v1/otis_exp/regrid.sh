#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -J Regrid
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=mda_silv@ictp.it

DOMAIN="large"

INROOT="/leonardo/home/userexternal/mdasilva/leonardo_work/Otis_exp/exps/exps_v2/domain_${DOMAIN}"
OUTROOT="/leonardo/home/userexternal/mdasilva/leonardo_work/Otis_exp/exps/exps_v2/domain_${DOMAIN}_regridded"
GRIDFILE="/leonardo/home/userexternal/mdasilva/leonardo_work/Otis_exp/exps/exps_v2/domain_${DOMAIN}/grid"

# Create output root folder if it doesn't exist
if [ ! -d "$OUTROOT" ]; then
    echo "Output root folder '$OUTROOT' not found. Creating it..."
    mkdir -p "$OUTROOT"
fi

# Loop through all experiment subfolders
for EXPDIR in "$INROOT"/*/; do
    # Extract experiment name (strip trailing slash)
    EXPNAME=$(basename "$EXPDIR")

    echo "-------- Processing experiment: $EXPNAME --------"

    # Create output subfolder
    OUTDIR="$OUTROOT/$EXPNAME"
    mkdir -p "$OUTDIR"

    # Loop through all NetCDF files in this experiment folder
    for FILE in "$EXPDIR"/*.nc; do
        # Skip if no .nc files exist
        [ -e "$FILE" ] || continue

        FILENAME=$(basename "$FILE")
        OUTFILE="$OUTDIR/$FILENAME"

        echo "  Regridding $FILENAME..."

        # Run CDO bilinear remapping
        cdo -P 10 remapbil,"$GRIDFILE" "$FILE" "$OUTFILE"
    done
done

echo "-------- Regridding Complete --------"
