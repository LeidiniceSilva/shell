#!/bin/sh

#SBATCH -J preproctrack
## This is the maximum time allowed.
#SBATCH -t 24:00:00
## The partition name
#SBATCH -p long
#SBATCH -N 2 --ntasks-per-node=20


path='/home/netapp-clima-scratch/aandrade/ECyclones/preproc/data/'
#path2=/home/clima-archive5/ERA5/hourly/

mkdir ${path1}/data/SAM/

filename='SAM-22'
filename1='SAM-22_ERA5'
anoi=2000
anof=2009


for yyyy in $(seq $anoi $anof); do
    for hh in 00 06 12 18; do
    	   

           echo ${hh}
           echo ${yyyy}

          cdo remapbil,grid_SAM ${path}SAM/ua.${yyyy}.${hh}.nc ${path}/ua.${yyyy}.${hh}.nc
	  cdo remapbil,grid_SAM ${path}SAM/va.${yyyy}.${hh}.nc ${path}va/${yyyy}.${hh}.nc
          cdo remapbil,grid_SAM ${path}SAM/psl.${yyyy}.${hh}.nc ${path}psl.${yyyy}.${hh}.nc     
   
 done
done
 






