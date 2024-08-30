#!/bin/bash

#################
##### input #####
#################

# email and domain
email="mda_silv@ictp.it"
gcm="ERA5"
config="ERA5"
domain="CSAM-3"

# base directory to the data (in which folders are arranged as: ${base}/$gcm/${config}-${domain})
base=/marconi/home/userexternal/mdasilva/user/mdasilva/CORDEX

# working directory (where the log files are located)
hdir=/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_exp/cordex

# start and end year(s)
yr0=2003
yr1=2003
# start and end month(s)
mn0=7
mn1=12

# other inputs for pycordexer
experiment="evaluation"
ensemble="r1i1p1f1"
notes="None"
output="."
proc=40 # 20
regcm_release=5
regcm_version_id=0 # must be an integer

########################
##### end of input #####
########################

# working directory for pycordex (directory to data)
nl="${config}-${domain}"
wdir=${base}/$gcm/$nl

# path to run pycordex scripts (make_acore, make_tier1, make_tier2)
sdir=/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_exp/cordex

########################
##### run pycordex #####
########################

{
set -eo pipefail

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

# loop over years
for year in `seq ${yr0} ${yr1}`; do

	# loop over months
	for month in `seq ${mn0} ${mn1}`; do

		# number of days in month
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

		# check if daily or monthly files
		files=$( eval ls ${wdir}/*ATM*${year}$(printf '%02d' $month)*.nc )
		nf=$( echo $files | wc -w )

		# 
		if [[ $nf = 1 ]]; then # monthly files

			# format date
			idate=${year}$(printf '%02d' $month)01
			echo $idate

			# function to submit
			sub(){
				s=$1 #acore, tier1, or tier2
				em="--mail-user=$email"
				jn=py_${s}_${nl}_${idate}
				o=$hdir/logs/${jn}.o
				e=$hdir/logs/${jn}.e
				sbatch $em -J $jn -o $o -e $e ${sdir}/make_${s}.sh $gcm $config $domain $wdir $idate $email $experiment $ensemble $notes $output $proc $regcm_release $regcm_version_id
			}

			# submit
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
		elif [[ $nf = $days ]]; then # daily files

			# loop over days
			for day in $(seq 1 $days); do

				# format date
				idate=${year}$(printf '%02d' $month)$(printf '%02d' $day)
				echo $idate

				# function to submit
				sub(){
					s=$1 #acore, tier1, or tier2
					em="--mail-user=$email"
					jn=py_${s}_${nl}_${idate}
					o=$hdir/logs/${jn}.o
					e=$hdir/logs/${jn}.e
					sbatch $em -J $jn -o $o -e $e ${sdir}/make_${s}.sh $gcm $config $domain $wdir $idate $email $experiment $ensemble $notes $output $proc $regcm_release $regcm_version_id
				}

				# submit
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
		else # something wrong?
			echo "$nf files in $year-$month, check output files"
		fi
	done
done
}
