#!/bin/bash
#SBATCH -N 1 ##--ntasks-per-node=20 #--mem=63G ##esp1
#SBATCH -t 4:00:00
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=jciarlo@ictp.it
#SBATCH -p bdw_all_serial
{
set -eo pipefail
CDO(){
  cdo -O -L -f nc4 -z zip $@
}
q=$3 
[[ $q = day ]] && i=1 || i=0.1
cpdf(){
  mn=$1 ; mx=$2 ; fin=$3 ; fout=$4
  CDO -b F32 fldsum -timsum -gec,-1000 $fin ${fout}_cnt.nc
  vv=pr
  set +e
  nc=$( ncdump -v $vv ${fout}_cnt.nc | tail -2 | head -1 | cut -d' ' -f3 )
  set -e
  CDO -b F32 divc,$nc -fldsum -histcount,$( echo $( seq $mn $i $mx ) | sed 's/ /,/g' ) $fin $fout
  rm ${fout}_cnt.nc
}

f1=$1 ; f2=$2

rf1=$( basename $f1 .nc )_mm.nc
rf2=$( basename $f2 .nc )_mm.nc
#CDO mulc,86400 $f1 $rf1
#CDO mulc,86400 $f2 $rf2

qmin=quick_${q}_min.nc
qmax=quick_${q}_max.nc
CDO ensmin -fldmin -timmin $f1 -fldmin -timmin $f2 $qmin
CDO ensmax -fldmax -timmax $f1 -fldmax -timmax $f2 $qmax

min=$( ncdump -v pr $qmin | tail -2 | head -1 | cut -d';' -f1 )
max=$( ncdump -v pr $qmax | tail -2 | head -1 | cut -d';' -f1 )
rm $qmin $qmax
echo $min $max

#[[ $max -gt 1000 ]] && max=1000
#max=1000

of1=$( basename $f1 .nc )_pdf.nc
of2=$( basename $f2 .nc )_pdf.nc

echo $min $max

cpdf $min $max $f1 $of1
cpdf $min $max $f2 $of2
#rm $rf1 $rf2

}
