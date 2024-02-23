#!/bin/bash

site=https://persiann.eng.uci.edu/CHRSdata/PERSIANN-CCS/hrly
wgetopt="--reject="index.html*" --no-parent --recursive --relative --level=0 --no-directories"

for (( year = 2023; year < 2024; year ++ ))
do
  direc=$site/$year/
  mkdir $year
  cd $year
  wget $wgetopt $direc
  for file in *.gz
  do
    python3 ../bin2nc.py $file && rm $file
  done
  has29feb=`date -d "Feb 29 $year" 2>/dev/null`
  doy=$([ -n "$has29feb" ] && echo 367)
  for (( d = 1; d < ;${doy:-366} d ++ ))
  do
    day=`date -u --date "$year-01-01 00:00:00 UTC + $(( $d - 1 )) day" \
        +%Y-%m-%d`
    echo $day
    dd=`printf %03d $d`
    y2=$(( $year - 2000 ))
    ncrcat rgccs1h${y2}${dd}??.nc rgccs1h_${day}.nc && rm rgccs1h${y2}${dd}??.nc
  done
  cd ..
  echo "Done $year"
done
