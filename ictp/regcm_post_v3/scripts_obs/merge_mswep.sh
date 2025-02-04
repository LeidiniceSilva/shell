#!/bin/bash

source /leonardo/home/userexternal/ggiulian/modules_gfortran

dir0=/leonardo_work/ICT24_ESP/OBS/MSWEP/monthly
dir1=/leonardo/home/userexternal/mdasilva/leonardo_work/OBS/MSWEP

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

sf=$dir1/mswep.mon.1979-2020.nc
ff=$( eval ls $dir0/??????.nc )
[[ ! -f $sf ]] && CDO mergetime $ff $sf

}
