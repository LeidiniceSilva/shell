#!/bin/bash

DOMAIN="small"
INROOT="/leonardo/home/userexternal/mdasilva/leonardo_work/Otis_exp/exps_v1/domain_${DOMAIN}"

# Loop through all experiment subfolders
for EXPDIR in "$INROOT"/*/; do
    # Extract experiment name (strip trailing slash)
    EXPNAME=$(basename "$EXPDIR")
    
    echo "-------- Computing surface wind for: $EXPNAME --------"
    
    # Define input file paths
    UAS_FILE="${EXPDIR}uas_${EXPNAME}_2023101900.nc"
    VAS_FILE="${EXPDIR}vas_${EXPNAME}_2023101900.nc"
    
    # Define output file path (same directory as input)
    OUTPUT_FILE="${EXPDIR}sfcWind_${EXPNAME}_2023101900.nc"
    
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
