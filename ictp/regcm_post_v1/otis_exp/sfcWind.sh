#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J sfcWind
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Sept 24, 2025'
#__description__ = 'Posprocessing the RegCM5 output with CDO'

EXP=$1
DOMAIN=$2
DATE=$3
INROOT="/leonardo/home/userexternal/mdasilva/leonardo_work/Otis_exp/exps/${EXP}/domain_${DOMAIN}"

# Loop through all experiment subfolders
for EXPDIR in "$INROOT"/*/; do
    # Extract experiment name (strip trailing slash)
    EXPNAME=$(basename "$EXPDIR")
    
    echo "-------- Computing surface wind for: $EXPNAME --------"
    
    # Define input file paths
    UAS_FILE="${EXPDIR}uas_${EXPNAME}_${DATE}.nc"
    VAS_FILE="${EXPDIR}vas_${EXPNAME}_${DATE}.nc"
    
    # Define output file path (same directory as input)
    OUTPUT_FILE="${EXPDIR}sfcWind_${EXPNAME}_${DATE}.nc"
    
    # Check if input files exist
    if [ -f "$UAS_FILE" ] && [ -f "$VAS_FILE" ]; then
        echo "  Computing surface wind for $EXPNAME..."
        
        # Compute wind speed: sqrt(uas^2 + vas^2)
        cdo -P 10 chname,uas,sfcWind -sqrt -add -sqr "$UAS_FILE" -sqr "$VAS_FILE" "$OUTPUT_FILE"
        
        echo "  Output saved to: $OUTPUT_FILE"
    else
        echo "  Warning: Input files not found for $EXPNAME"
        [ ! -f "$UAS_FILE" ] && echo "    Missing: $UAS_FILE"
        [ ! -f "$VAS_FILE" ] && echo "    Missing: $VAS_FILE"
    fi
done

echo "-------- Computation Complete --------"
