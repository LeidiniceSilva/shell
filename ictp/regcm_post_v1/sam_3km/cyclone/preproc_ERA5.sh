#!/bin/sh
#SBATCH -J preproctrack
## This is the maximum time allowed.
#SBATCH -t 24:00:00
## The partition name
#SBATCH -p long
#SBATCH -N 3 --ntasks-per-node=20


path1='/home/netapp-clima-scratch/aandrade/ECyclones/preproc/'
path2=/home/clima-archive5/ERA5/hourly/

mkdir ${path1}data/NAM/

filename='NAM-22'
filename1='NAM-22_ERA5'
anoi=2000
anof=2009
anoii=2000
region='NAM'

#for yyyy in $(seq $anoi $anof); do

    
    #for mm in 01 02 03 04 05 06 07 08 09 10 11 12;do

      #  echo ${yyyy}
        
     #   path2=/home/clima-archive5/ERA5/${yyyy}/
        
    #    echo ${mm}
    
   #     cdo -L -z zip -selhour,00,06,12,18 -remapbil,grid_${region} ${path2}uwnd_${yyyy}_${mm}.nc ${path1}tmp1/ua_${yyyy}_${mm}.nc
    

  #      cdo -L -z zip -selhour,00,06,12,18 -remapbil,grid_${region} ${path2}vwnd_${yyyy}_${mm}.nc ${path1}tmp1/va_${yyyy}_${mm}.nc
    
          
 # done 
#done
         

for yyyy in $(seq $anoi $anof); do

    #cdo -b F64 mergetime ${path1}tmp1/ua_${yyyy}_*.nc ${path1}tmp/ua_${filename}_${yyyy}.nc
    #cdo remapbil,grid_${region} ${path1}tmp/psl_${filename}_${yyyy}.nc ${path1}tmp/psl_${filename1}${yyyy}_remmaped15.nc
	
    #cdo -b F64 mergetime ${path1}tmp1/va_${yyyy}_*.nc ${path1}tmp/va_${filename}_${yyyy}.nc
    #cdo remapbil,grid_${region} ${path1}tmp/psl_${filename}_${yyyy}.nc ${path1}tmp/psl_${filename1}${yyyy}_remmaped15.nc
    for hh in 00 06 12 18; do
        for var in ua va; do
     
            echo ${yyyy}
            echo ${hh}
            echo ${var}
    
            cdo selhour,$hh ${path1}tmp/${var}_${filename}_${yyyy}.nc ${path1}data/NAM/${var}.${yyyy}.${hh}.nc
      done
   done
done




