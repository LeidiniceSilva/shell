#!/bin/bash

#################
##### input #####
#################

# email and domain
email="mda_silv@ictp.it"
gcm="ERA5"
config="NoTo"
domain="SAM"

# base directory to the data (in which folders are arranged as: ${base}/${config}-${domain})
base=/marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km

# working directory (where the log files are located)
hdir=/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_exp/sam_3km

# start and end year(s)
yr0=2018
yr1=2018
# start and end month(s)
mn0=1
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
wdir=${base}/$nl

# path to run pycordex scripts (make_acore, make_tier1, make_tier2)
sdir=/marconi/home/userexternal/mdasilva/github_projects/shell/ictp/regcm_exp/sam_3km

########################
##### run pycordex #####
########################

{

set -eo pipefail

# loop over years
for year in `seq ${yr0} ${yr1}`; do

	# loop over months
	for month in `seq ${mn0} ${mn1}`; do

		# format date
		idate=${year}$(printf '%02d' $month)$(printf '01%02d')
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
done
}
