#!/bin/bash

#SBATCH --account             CMPNS_ictpclim
#SBATCH --job-name            CSAM-3_MERGE
#SBATCH --mail-type           FAIL
#SBATCH --mail-user           ggiulian@ictp.it
#SBATCH --nodes               1
#SBATCH --ntasks-per-node     1
#SBATCH --partition           dcgp_usr_prod
#SBATCH --time                12:00:00

source $HOME/modules_new

ff="1hr 3hr 6hr day"
y=$1
yy=$1
m=`printf "%02d" $2`
mp1=$(( $2 + 1 ))
if [ $mp1 -eq 13  ]
then
  mp1=1
  yy=$(( $yy + 1 ))
fi
mm=`printf "%02d" $mp1`
base=CSAM-3_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5-0_v1-r1

for f in $ff
do
  echo $f
  cd $f
  for d in *
  do
    cd $d
    echo $d $y $m
    nf=`ls ${d}_${base}_${f}_${y}${m}* 2>/dev/null | awk 'END{print NR}'`
    if [ $nf -gt 1 ]
    then
      tmp=${d}_$$_tmp.nc
      ncrcat -h ${d}_${base}_${f}_${y}${m}* $tmp 2> /dev/null
      if [ $? -eq 0 ]; then
        rm ${d}_${base}_${f}_${y}${m}*
        if [ $f == "day" ]
        then
          mv $tmp ${d}_${base}_${f}_${y}${m}01-${yy}${mm}01.nc
        else
          mv $tmp ${d}_${base}_${f}_${y}${m}0100-${yy}${mm}0100.nc
         fi
      else
        rm -f $tmp
      fi
    fi
    cd ..
  done
  cd ..  
done
