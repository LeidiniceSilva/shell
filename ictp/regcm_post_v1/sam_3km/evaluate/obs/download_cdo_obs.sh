#!/bin/bash

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

late=ftp://jsimpson.pps.eosdis.nasa.gov/data/imerg/late/
final=ftp://jsimpson.pps.eosdis.nasa.gov/data/imerg/late/

type=HHR
ver=V07A
ftp0=${final}/`echo $ver | cut -c1-3`

dir=/home/mda_silv/scratch/GPM

cd ${dir}
echo ${dir}

mod=0000
for year in `seq -w 2018 2018`; do
	for mon in `seq -w 02 04`; do
	
		case ${mon} in
			01|03|05|07|08|10|12)
				days=31
				;;
			04|06|09|11)
				days=30
				;;
			02)
				if is_leap_year ${year}; then
					days=29
				else
					days=28
				fi
				;;
		esac
		
		for day in `seq -w 01 ${days}`; do
			for hour in `seq -w 00 23`; do
				for min in 00 30 ; do
					
					date=${year}${mon}${day}		
					start=${hour}${min}
					end=`date -d "$start today +29 minutes" +%H%M`
					mins=`printf "%04d\n" $mod`
					
					ftp=${ftp0}/${year}/${mon}/${day}/imerg
					file=3B-${type}.MS.MRG.3IMERG.${year}${mon}${day}-S${start}00-E${end}59.${mins}.${ver}.HDF5 
			    
			 		fl="precipitation_SAM_GPM_3B-HHR_${year}${mon}${day}_${mins}_V07A.nc"
				   	if [ ! -f "$fl" ]; then
					echo ${fl}
			        	wget --user="tompkins@ictp.it" --password='tompkins@ictp.it'  ${ftp}/${file} -O ${dir}/${file}
			        	fi
					mod=`expr $mod + 30`
				done
			done
		done
	done
done

