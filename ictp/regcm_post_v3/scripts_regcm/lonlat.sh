#!/bin/bash
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}

ll(){
  lat=$1
  lon=$2
  inf=$3
  outf=$( basename $inf .nc )_latlon_${lat}_${lon}.nc

  CDO remapnn,lon=${lon}_lat=${lat} $inf $outf
}

f=$1

ll 42.294 9.345 $f
ll 44.262 3.875 $f
ll 46.856 4.826 $f
ll 47.062 1.030 $f 

}
