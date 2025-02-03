#!/bin/bash

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

# var="clt pr tas"
var="pr tas"
#var="clt"
for v in $var; do
	for y in `seq ${fyr} ${lyr}`; do
		ff=$dir1/${v}_${y}.nc
		[[ ! -f $ff ]] && CDO -b f32 mergetime $dir0/$y/${v}_${y}_*.nc $ff
	done

	yf=$dir1/$v.era5.mon.1950-2023.nc
	ff=$( eval ls $dir1/${v}_????.nc )
	CDO -b f32 mergetime $ff $yf
	
	rm $dir1/${v}_*.nc
done

}
