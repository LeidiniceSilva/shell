#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '01/26/19'
#__description__ = 'Posprocessing the RegCM4.6.0 model data with CDO'
 

echo
echo "--------------- INIT POSPROCESSING CMIP5 MODELS ----------------"

# Variables list
var_list=('tas')     

# Models list
model_list=( 'BCC-CSM1.1' 'BCC-CSM1.1M' 'BNU-ESM' 'CanESM2' 'CMCC-CM' 'CMCC-CMS' 'CNRM-CM5' 'CSIRO-ACCESS-1' 'CSIRO-ACCESS-3' 'CSIRO-MK36' 'EC-EARTH' 'FIO-ESM' 'GFDL-ESM2G' 'GFDL-ESM2M' 'GISS-E2-H-CC' 'GISS-E2-H' 'GISS-E2-R-CC' 'GISS-E2-R' 'HadGEM2-AO' 'HadGEM2-CC' 'HadGEM2-ES' 'INMCM4' 'IPSL-CM5A-LR' 'IPSL-CM5A-MR' 'IPSL-CM5B-LR' 'LASG-FGOALS-G2' 'LASG-FGOALS-S2' 'MIROC5' 'MIROC-ESM-CHEM' 'MIROC-ESM' 'MPI-ESM-LR' 'MPI-ESM-MR' 'MRI-CGCM3' 'NCAR-CCSM4' 'NCAR-CESM1-BGC' 'NCAR-CESM1-CAM5' 'NorESM1-ME' 'NorESM1-M')    

for var in ${var_list[@]}; do
    for model in ${model_list[@]}; do

	path="/vol3/disco1/nice/cmip_data/cmip5_hist/cmip5_hist_pr-tas"
	cd ${path}
	
	echo
	echo ${path}

	# Experiment name
	exp=( 'historical_r1i1p1' ) 

	# Init date and final date
	ini_date=$( ls ${path_models}${var}_Amon_${model}_${exp}*.nc | sed -n '1p' | cut -d '_' -f 6 | cut -d '-' -f 1 )
	end_date=$( ls ${path_models}${var}_Amon_${model}_${exp}*.nc | sed -n "${fl_nbr}p" | cut -d '_' -f 6 | cut -d '-' -f 2 )
	
	echo
	echo "Posprocessing file:" ${var}"_Amon_"${model}"_"${exp}"_"${ini_date}"-"${end_date} 

	echo
	echo "1. Select date: 197512-200511"
	cdo seldate,1975-12-00T00:00:00,2005-11-30T00:00:00 ${var}_Amon_${model}_${exp}_${ini_date}-${end_date} ${var}_Amon_${model}_${exp}_197512-200511.nc
	
	echo
	echo "2. Convert unit: mm and DegC"
	#cdo mulc,86400 ${var}_Amon_${model}_${exp}_197512-200511.nc ${var}_Amon_${model}_${exp}_197512-200511_unit.nc
	cdo addc,-273.15 ${var}_Amon_${model}_${exp}_197512-200511.nc ${var}_Amon_${model}_${exp}_197512-200511_unit.nc
	
	echo
	echo "3. Interpolate area: r720x360"
	cdo remapbil,r720x360 ${var}_Amon_${model}_${exp}_197512-200511_unit.nc ${var}_Amon_${model}_${exp}_197512-200511_unit_newgrid.nc
	
	echo
	echo "4. Convert calendar: standard"
	cdo setcalendar,standard ${var}_Amon_${model}_${exp}_197512-200511_unit_newgrid.nc ${var}_Amon_${model}_${exp}_197512-200511_unit_newgrid_stddate.nc

	echo
	echo "5. Select new area: amz_neb (-85,-15,-20,10)"
	cdo sellonlatbox,-85,-15,-20,10 ${var}_Amon_${model}_${exp}_197512-200511_unit_newgrid_stddate.nc ${var}_amz_neb_Amon_${model}_${exp}_197512-200511_unit_newgrid_stddate.nc
	
	echo
	echo "6. Creating sea mask"
	cdo -f nc -remapnn,${var}_amz_neb_Amon_${model}_${exp}_197512-200511_unit_newgrid_stddate.nc -gtc,0 -topo ${var}_${model}_seamask.nc
	cdo ifthen ${var}_${model}_seamask.nc ${var}_amz_neb_Amon_${model}_${exp}_197512-200511_unit_newgrid_stddate.nc ${var}_amz_neb_Amon_${model}_${exp}_197512-200511.nc
	
	echo 
	echo "7. Deleting file"

	rm ${var}_Amon_${model}_${exp}_197512-200511.nc
	rm ${var}_Amon_${model}_${exp}_197512-200511_unit.nc
	rm ${var}_Amon_${model}_${exp}_197512-200511_unit_newgrid.nc
	rm ${var}_Amon_${model}_${exp}_197512-200511_unit_newgrid_stddate.nc
	rm ${var}_amz_neb_Amon_${model}_${exp}_197512-200511_unit_newgrid_stddate.nc
	rm ${var}_${model}_seamask.nc

    done
done

echo
echo "--------------- THE END POSPROCESSING MODEL ----------------"

