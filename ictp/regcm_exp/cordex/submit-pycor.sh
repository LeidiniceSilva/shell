#!/bin/bash

{

set -eo pipefail

nl=ERA5-CSAM3
gcm=$( echo $nl | cut -d- -f1 )
hdir=/marconi/home/userexternal/mdasilva/user/mdasilva/CSAM-3/
wdir=/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX/$gcm/$nl

# Function to check the leap year
is_leap_year() {
    year=$1
    if [ $((year % 4)) -eq 0 ]; then
        if [ $((year % 100)) -ne 0 ] || [ $((year % 400)) -eq 0 ]; then
            return 0  # Leap year
        else
            return 1  # Not a leap year
        fi
    else
        return 1  # Not a leap year
    fi
}
    
# List of years
for year in {1999..2009}; do
    for month in {1..12}; do
        case $month in
            1|3|5|7|8|10|12)
                days=31
                ;;
            4|6|9|11)
                days=30
                ;;
            2)
                if is_leap_year $year; then
                    days=29
                else
                    days=28
                fi
                ;;
        esac
        for day in $(seq 1 $days); do
	
	    if [ $month -lt 10 -a $day -lt 10 ]; then
		echo bla
		idate=${year}0${month}0${day}		
	    fi
	    if [ $month -lt 10 -a $day -ge 10 ]; then
		echo bla2
		idate=${year}0${month}${day}
	    fi
	    if [ $month -ge 10 -a $day -lt 10 ]; then
		echo bla3
		idate=${year}${month}0${day}
	    fi	
	    if [ $month -ge 10 -a $day -ge 10 ]; then
		echo bla5
		idate=${year}${month}${day}
	   fi
	   echo $idate

           sub(){
	      s=$1 #acore, tier1, or tier2
	      jn=py_${s}_${nl}_${idate}
	      o=$hdir/logs/${jn}.o
	      e=$hdir/logs/${jn}.e
	      sbatch -J $jn -o $o -e $e /marconi/home/userexternal/mdasilva/user/mdasilva/CSAM-3/make_${s}.sh $nl $idate
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
        done
    done
done

}
