#!/bin/bash

#
source /leonardo/home/userexternal/ggiulian/modules_gfortran

#
dir0=/leonardo_work/ICT24_ESP/clu/OBS/GPCC
dir1=/leonardo_work/ICT24_ESP/clu/OBS/GPCC

{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

## monthly
#sf=$dir1/precip.gpcc.mon.1891.2020.nc
#ff=$( eval ls $dir0/full_data_monthly_v2022_????_????_025.nc )
#[[ ! -f $sf ]] && CDO mergetime $ff $sf

# daily full_data_daily_v2022_10_1982.nc
sf=$dir1/precip.gpcc.1982.2020.nc
ff=$( eval ls $dir0/full_data_daily_v2022_10_????.nc )
[[ ! -f $sf ]] && CDO mergetime $ff $sf

}
