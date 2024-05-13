#!/bin/bash
{
set -eo pipefail

nl=ERA5-EURR3
idate=19990101

gcm=$( echo $nl | cut -d- -f1 )
hdir=/marconi_work/ICT23_ESP/jdeleeuw/EURR-3/
wdir=/marconi_work/ICT23_ESP/jdeleeuw/CORDEX/$gcm/$nl

sub(){
  s=$1 #acore, tier1, or tier2
  jn=py_${s}_${nl}_${idate}
  o=$hdir/logs/${jn}.o
  e=$hdir/logs/${jn}.e
  sbatch -J $jn -o $o -e $e /marconi_work/ICT23_ESP/jdeleeuw/EURR-3/make_${s}.sh $nl $idate
}

cd $wdir
natm=$( ls *ATM.$idate* | wc -l )
nsrf=$( ls *SRF.$idate* | wc -l )
nrad=$( ls *RAD.$idate* | wc -l )
nsts=$( ls *STS.$idate* | wc -l )
echo "$nl $idate: ATM=$natm SRF=$nsrf RAD=$nrad STS=$nsts"
if [ $natm = 1 -a $nsrf = 1 -a $nrad = 1 -a $nsts = 1 ]; then
  sub acore
  sub tier1
  sub tier2
  cd $hdir
else
  echo "no submission - multiple entries for idate"
fi

}
