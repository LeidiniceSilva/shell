#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 09, 2023'
#__description__ = 'Download CMIP6 files'

# center 
#~ center_list=( 'CCCma' 'CSIRO-ARCCSS' 'MIROC' 'MPI-M' 'MRI' 'NCAR' 'NERC' 'NOAA-GFDL' )
center_list=( 'NOAA-GFDL' )

# experiment 
exp_list=( 'faf-heat' 'faf-passiveheat' 'faf-stress' )

# frequency
freq=( 'Omon' )

# variable
var_list=( 'so' 'thetao' )

type=( 'gn' )

for center in ${center_list[@]}; do
	for exp in ${exp_list[@]}; do
		for var in ${var_list[@]}; do
		
			if [ ${center} == 'CCCma' ]
			then
			model=( 'CanESM5' )
			member=( 'r1i1p2f1' )
			grid=( 'gn' )
			dt=( 'v20190429' )
			dt_0=( '555001-556012' )
			dt_1=( '556101-557012' )
			dt_2=( '557101-558012' )
			dt_3=( '558101-559012' )
			dt_4=( '559101-560012' )
			dt_5=( '560101-561012' )
			dt_6=( '561101-562012' )
			dt_7=( '562101-563012' )
			dt_8=( '563101-564012' )
			dt_9=( '564101-565012' )

			elif [ ${center} == 'CSIRO-ARCCSS' ]
			then
			model=( 'ACCESS-CM2' )
			member=( 'r1i1p1f1' )
			grid=( 'gn' )
			dt=( 'v20191210' )
			dt_0=( '095001-095912' )
			dt_1=( '096001-096912' )
			dt_2=( '097001-097912' )
			dt_3=( '098001-098912' )
			dt_4=( '099001-099912' )
			dt_5=( '100001-100912' )
			dt_6=( '101001-101912' )

			elif [ ${center} == 'MIROC' ]
			then
			model=( 'MIROC6' )
			member=( 'r1i1p1f1' )
			grid=( 'gn' )
			dt=( 'v20190311' )
			dt_0=( '320001-320912' )
			dt_1=( '321001-321912' )
			dt_2=( '322001-322912' )
			dt_3=( '323001-323912' )
			dt_4=( '324001-324912' )
			dt_5=( '325001-325912' )
			dt_6=( '326001-326912' )

			elif [ ${center} == 'MPI-M' ]
			then
			model=( 'MPI-ESM1-2-HR' )
			member=( 'r1i1p1f1' )
			grid=( 'gn' )
			dt=( 'v20191231' )
			dt_0=( '185001-185412' )
			dt_1=( '185501-185912' )
			dt_2=( '186001-186412' )
			dt_3=( '186501-186912' )
			dt_4=( '187001-187412' )
			dt_5=( '187501-187912' )
			dt_6=( '188001-188412' )
			dt_7=( '188501-188912' )
			dt_8=( '189001-189412' )
			dt_9=( '189501-189912' )
			dt_10=( '190001-190412' )
			dt_11=( '190501-190912' )
			dt_12=( '191001-191412' )
			dt_13=( '191501-191912' )

			elif [ ${center} == 'MRI' ]
			then
			model=( 'MRI-ESM2-0' )
			member=( 'r1i1p1f1' )
			grid=( 'gr' )
			dt=( 'v20191125' )
			dt_0=( '185001-191912' )

			elif [ ${center} == 'NCAR' ]
			then
			model=( 'CESM2' )
			member=( 'r1i1p1f1' )
			grid=( 'gn' )
			if [ ${exp} == 'faf-heat' ]
			then
			dt=( 'v20200428' )
			dt_0=( '050101-055712' )
			elif [ ${exp} == 'faf-passiveheat' ]
			then
			dt=( 'v20200610' )
			dt_0=( '050101-057012' )
			else
			dt=( 'v20200428' )
			dt_0=( '050101-058112' )
			fi

			elif [ ${center} == 'NERC' ]
			then
			model=( 'HadGEM3-GC31-LL' )
			member=( 'r1i1p1f2' )
			grid=( 'gn' )
			if [ ${exp} == 'faf-heat' ]
			then
			dt=( 'v20210407' )
			dt_0=( '185001-189912' )
			dt_1=( '190001-191912' )
			elif [ ${exp} == 'faf-passiveheat' ]
			then
			dt=( 'v20210325' )
			dt_0=( '185001-189912' )
			dt_1=( '190001-191912' )
			else
			dt=( 'v20210519' )
			dt_0=( '185001-189912' )
			dt_1=( '190001-191912' )
			fi
			
			else
			model=( 'GFDL-ESM2M' )
			member=( 'r1i1p1f1' )
			grid=( 'gn' )
			dt=( 'v20180701' )
			dt_0=( '010101-012012' )
			dt_1=( '012101-014012' )
			dt_2=( '014101-016012' )
			dt_3=( '016101-017012' )
			fi

			# Path to save file
			PATH="/afs/ictp.it/home/m/mda_silv/Documents/CMIP6/${model}/${exp}/${var}"
			cd ${PATH}
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_0}.nc
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_1}.nc
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_2}.nc
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_3}.nc	 
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_4}.nc	
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_5}.nc	
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_6}.nc
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_7}.nc	
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_8}.nc	
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_9}.nc
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_10}.nc
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_11}.nc
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_12}.nc
			/usr/bin/wget -nc -c -nd https://data.ceda.ac.uk/badc/cmip6/data/CMIP6/FAFMIP/${center}/${model}/${exp}/${member}/${freq}/${var}/${grid}/${dt}/${var}_${freq}_${model}_${exp}_${member}_${grid}_${dt_13}.nc
			
		done 
	done
done
         
