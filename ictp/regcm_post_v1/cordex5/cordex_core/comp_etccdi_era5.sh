#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J ETCCDI
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Nov 20, 2023'
#__description__ = 'Compute ETCCDI indies using CDO-ECA'

{
set -eo pipefail

CDO(){
  cdo -O -L -f nc4 -z zip $@
}

path_in="/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/ERA5/day"
path_out="/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/postproc/cordex_core"

yinit=1970
yfinal=1971

for yr in $(seq ${yinit} ${yfinal}); do

  echo "Processing year ${yr}"

  # Input files
  tp_in="${path_in}/tp_ERA5_${yr}.nc"
  tp_out="${path_out}/tp_ERA5_${yr}.nc"

  mn2t_in="${path_in}/mn2t_ERA5_${yr}.nc"
  mn2t_out="${path_out}/mn2t_ERA5_${yr}.nc"

  # RX1day (max 1-day prec)
  CDO mulc,1000 ${tp_in} ${tp_out}
  CDO eca_rx1day ${tp_out} ${path_out}/RX1day_eca_ERA5_${yr}.nc

  # TN20 (mn2t > 20°C)
  CDO subc,273.15 ${mn2t_in} ${mn2t_out}
  CDO eca_tr,20 ${mn2t_out} ${path_out}/TN20_eca_ERA5_${yr}.nc

  # Remove converted files
  rm -f ${tp_out} ${mn2t_out}

done

echo "Merging yearly files..."

# Merge years 
CDO mergetime ${path_out}/RX1day_eca_ERA5_*.nc ${path_out}/RX1day_ERA5_${yinit}-${yfinal}.nc
CDO mergetime ${path_out}/TN20_eca_ERA5_*.nc ${path_out}/TN20_ERA5_${yinit}-${yfinal}.nc

# Delete
rm -f ${path_out}/RX1day_eca_ERA5_*.nc
rm -f ${path_out}/TN20_eca_ERA5_*.nc 

echo 
echo "------------------------------- THE END POSTPROCESSING ${DATASET} -------------------------------"

}
