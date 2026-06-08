#!/bin/bash

for file in find $1 -name *r0i0p0f0*nc
do
  ncatted -h -a driving_variant_label,global,m,c,'r1i1p1f1' $file
  mkdir -p dirname $file | sed -e 's/r0i0p0f0/r1i1p1f1/'
  mv $file echo $file | sed -e 's/r0i0p0f0/r1i1p1f1/g'
done
