#!/bin/bash
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}
f=$1
CDO seltimestep,2/5 $f ${f}_tmp.nc
mv ${f}_tmp.nc $f
echo done

}
