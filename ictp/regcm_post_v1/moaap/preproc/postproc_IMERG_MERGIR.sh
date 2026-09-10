#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__     = 'Leidinice Silva'
#__email__      = 'leidinicesilva@gmail.com'
#__date__       = 'Jan 20, 2026'
#__description__ = 'Merge IMERG & MERGIR in GPM for MOAAP tracking'

CDO(){
  cdo -O -L -f nc4 -z zip "$@"
}

DOMAIN_LIST=("CAR-4" "CSAM-3" "EURR-3")

for DOMAIN in "${DOMAIN_LIST[@]}"; do

    DIR_IN="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/GPM/${DOMAIN}/preproc"
    DIR_OUT="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/paper/dataset/GPM/${DOMAIN}/input"

    cd "${DIR_OUT}" || exit 1
    echo "Processing Output Directory: ${DIR_OUT}"

    for YEAR in $(seq 2000 2009); do

        if [ "${YEAR}" -eq 2000 ]; then
            START_MON=6
        else
            START_MON=1
        fi

        for MON in $(seq -w ${START_MON} 12); do
            echo "Processing ${DOMAIN} ${YEAR} ${MON}"

            INFILE_I="${DIR_IN}/pr_GPM_IMERG_${DOMAIN}_1hr_${YEAR}${MON}.nc"
            INFILE_II="${DIR_IN}/Tb_GPM_MERGIR_${DOMAIN}_1hr_${YEAR}${MON}.nc"

            TMP_TB="Tb_norm_${YEAR}${MON}.nc"
            OUTFILE_I="${DOMAIN}_merged_${YEAR}${MON}.nc"
            OUTFILE_II="${DOMAIN}_grid_${YEAR}${MON}.nc"
            OUTFILE_III="${DOMAIN}_float_${YEAR}${MON}.nc"
            OUTFILE_IV="${DOMAIN}_GPM_1hr_${YEAR}${MON}0100.nc"

            # Normalize time units of Tb to match standard days since 1970-01-01
            CDO settunits,days "${INFILE_II}" "${TMP_TB}"

            # Merge precipitation (pr) and brightness temperature (Tb)
            CDO merge "${INFILE_I}" "${TMP_TB}" "${OUTFILE_I}"

            # Convert grid to 2D curvilinear (creates 'x' and 'y' spatial dimensions)
            CDO setgridtype,curvilinear "${OUTFILE_I}" "${OUTFILE_II}"

            # Cast 'Tb' variable from 16-bit short (I16) to 32-bit float (F32)
            ncap2 -O -s 'Tb=float(Tb);' "${OUTFILE_II}" "${OUTFILE_III}"

            # Assign attributes and set float NaN fill values
            ncatted -O \
              -a units,pr,m,c,"mm hr-1" \
              -a long_name,pr,m,c,"precipitation" \
              -a cell_methods,pr,c,c,"time: sum" \
              -a _FillValue,pr,m,f,NaN \
              -a missing_value,pr,d,, \
              -a units,Tb,m,c,"K" \
              -a long_name,Tb,m,c,"brightness temperature" \
              -a cell_methods,Tb,c,c,"time: point" \
              -a _FillValue,Tb,m,f,NaN \
              -a missing_value,Tb,d,, \
              -a long_name,lat,m,c,"Latitudes, y-coordinate in Cartesian system" \
              -a _FillValue,lat,c,d,NaN \
              -a missing_value,lat,d,, \
              -a long_name,lon,m,c,"Longitudes, x-coordinate in Cartesian system" \
              -a _FillValue,lon,c,d,NaN \
              -a missing_value,lon,d,, \
              "${OUTFILE_III}" "${OUTFILE_IV}"

            # Clean up temporary working files
            rm -f "${TMP_TB}" "${OUTFILE_I}" "${OUTFILE_II}" "${OUTFILE_III}"

        done
    done
done
