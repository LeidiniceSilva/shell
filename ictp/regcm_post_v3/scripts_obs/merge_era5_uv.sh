#!/bin/bash

#SBATCH --job-name=merge
#SBATCH -A ICT23_ESP_1
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1 
#SBATCH -t 4:00:00
#SBATCH --ntasks-per-node=108
#SBATCH -o slurm.%j.out # STDOUT
#SBATCH -e slurm.%j.err # STDERR
#SBATCH --mail-type=FAIL

#
source /leonardo/home/userexternal/ggiulian/modules_gfortran

#
dir0=/leonardo_work/ICT24_ESP/OBS/ERA5/monthly
dir1=/leonardo_work/ICT24_ESP/clu/OBS/ERA5/monthly

#
fyr=1950
lyr=2023

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

#var="uas vas uwnd vwnd"
#var="vas uwnd vwnd"
var="vwnd"
#var="uas"

for v in $var; do
	for y in `seq ${fyr} ${lyr}`; do
		ff=$dir1/${v}_${y}.nc
		for month in {01..12}; do
			f0=$dir0/$y/${v}_${y}_${month}.nc
			tmp_f1=$dir1/${v}_${y}_${month}_t1.nc
			tmp_f2=$dir1/${v}_${y}_${month}_t2.nc
			#CDO settaxis,${y}-$month-15,00:00:00,1hour $f0 $tmp_f1
			CDO settaxis,${y}-$month-15,00:00:00,1mon $f0 $tmp_f1
			CDO setreftime,1900-01-01,00:00:00,1hour $tmp_f1 $tmp_f2
			rm $tmp_f1
		done
		[[ ! -f $ff ]] && CDO -b f32 mergetime $dir1/${v}_${y}_*_t2.nc $ff
		rm $dir1/${v}_${y}_*_t2.nc
	done

	yf=$dir1/$v.era5.mon.1950-2023.nc
	ff=$( eval ls $dir1/${v}_????.nc )
	CDO -b f32 mergetime $ff $yf
	
	rm $dir1/${v}_*.nc
done

}
