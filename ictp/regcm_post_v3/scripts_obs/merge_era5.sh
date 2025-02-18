#!/bin/bash

#SBATCH -A ICT23_ESP_1
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Merge
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

source /leonardo/home/userexternal/ggiulian/modules_gfortran

dir0=/leonardo_work/ICT24_ESP/OBS/ERA5/hourly
dir1=/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/ERA5

fyr=2018
lyr=2021

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

var="pr"
for v in $var; do
	for y in `seq ${fyr} ${lyr}`; do
		ff=$dir1/${v}_${y}.nc
		[[ ! -f $ff ]] && CDO -b f32 mergetime $dir0/${v}_${y}_*.nc $ff
	done

	yf=$dir1/tp_ERA5_1hr_2018-2021.nc
	ff=$( eval ls $dir1/${v}_????.nc )
	CDO -b f32 mergetime $ff $yf
	
	rm $dir1/${v}_*.nc
done

}
