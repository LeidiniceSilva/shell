#!/bin/bash

#SBATCH -A CMPNS_ictpclim
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Mar 15, 2024'
#__description__ = 'Download CMIP6'
 
{
source /leonardo/home/userexternal/ggiulian/modules_gfortran
set -eo pipefail

mdl="HadGEM3-GC31-MM"

if [ ${mdl} == "GFDL-ESM4" ]; then
        mdl_family="NOAA-GFDL"
        exp="historical"
        member="r1i1p1f1"
        type="gr1"
        freq="3hr"
        version="v20190726"
        declare -a YEARS=("201001010300-201501010000")
else #HadGEM3-GC31-MM
        mdl_family="MOHC"
        exp="historical"
        member="r1i1p1f3"
        type="gn"
        freq="6hrPlevPt"
        version="v20200720"
        declare -a YEARS=("199901010600-200001010000" "200001010600-200101010000" "200201010600-200301010000" "200301010600-200401010000" "200401010600-200501010000" "200501010600-200601010000" "200601010600-200701010000" "200701010600-200801010000" "200801010600-200901010000" "200901010600-201001010000")
fi

var_list="psl uas vas"

echo "Starting download"
for var in ${var_list[@]}; do

        base_url="https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/CMIP/${mdl_family}/${mdl}/${exp}/${member}/${freq}/${var}/${type}/${version}"
        dir="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${mdl}/S2R-Vortrack"

        for year in "${YEARS[@]}"; do
		
		filename="${var}_${freq}_${mdl}_${exp}_${member}_${type}_${year}.nc"
                url="${base_url}/${filename}"
                file_dir="/leonardo/home/userexternal/mdasilva/leonardo_work/TRACK-CYCLONE/CORDEX-TF/${mdl}/S2R-Vortrack/${filename}"

                if [ -f "$file_dir" ]; then
                        echo "File exists: ${filename}"
                else
                        echo "Downloading: $filename"
                        wget -P "$dir" ${url}
                fi
        done
done

echo "Finished downloads."
}
