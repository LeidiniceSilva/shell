#!/bin/bash
#SBATCH -o logs/rcm5_SLURM.out
#SBATCH -e logs/rcm5_SLURM.err
#SBATCH -N 4 ##--ntasks-per-node=20 #--mem=63G ##esp1
#SBATCH -t 24:00:00
#SBATCH -J EUR-R5
#SBATCH -A ICT23_ESP
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=jciarlo@ictp.it
#SBATCH --qos=qos_prio
#SBATCH -p skl_usr_prod
{
set -eo pipefail

module purge
source /marconi/home/userexternal/ggiulian/STACK22/env2022

nl=$1
lucas=true #flag to use LUCAS land use files
#listn=false #flag for pycordex listener

nlgcm=$( dirname $nl | cut -d. -f2 | cut -d_ -f1 )
#[[ $nlgcm = ERA5-WMediterranean ]] && bin=gbin || bin=bin
bin=bin

#if [ $listn = true ]; then
#  pybin=/marconi/home/userexternal/ggiulian/STACK22/bin/python3
#  PYCORDEX=/marconi/home/userexternal/ggiulian/regcm-core/Tools/Scripts/pycordexer
#  mail="coppolae@ictp.it"
#  dom=$( basename $nl | cut -d_ -f1 | cut -d- -f2 )
#  [[ $dom = Europe ]] && domain="EUR-11"
#  gcm=$( basename $nl | cut -d_ -f1 | cut -d- -f1 | cut -d. -f2 )
#  [[ $gcm = ERA5 ]] && global_model="ECMWF-ERA5"
#  [[ $gcm = MPI ]] && global_model="MPI-ESM1-2-HR"
#  experiment="historical"
#  [[ $gcm = ERA5 ]] && experiment="evaluation"
#  ensemble="r1i1p1f1"
#  notes='Archived on model native grid'
#
#  pidfile=logs/pycordexer_${SLURM_JOB_NAME}.pid
#  clrfile=logs/cordex_listener_${SLURM_JOB_NAME}.txt
#  $pybin $PYCORDEX/cordex_listener.py --namelist_file $nl --daemon -p $pidfile \
#           -l $clrfile --mail $mail --domain $domain --global-model $global_model \
#           --experiment $experiment --ensemble $ensemble --notes "$notes"
#fi

#echo $nlgcm
#if [ $nlgcm = ERA5-WMediterranean ]; then
##  [[ $lucas = true ]] && suffix=CLM45_SKL_DYNPFT || suffix=CLM45_SKL
#  suffix=DEBUG_CLM45_DYNPFT
#else
  [[ $lucas = true ]] && suffix=NETCDF4_HDF5_CLM45_SKL_DYNPFT || suffix=NETCDF4_HDF5_CLM45_SKL
#fi
echo "#~# mpirun ./$bin/regcmMPI$suffix $nl #~#"

echo "## Using $bin $suffix ##"
mpirun ./$bin/regcmMPI$suffix $nl

#clsfile=logs/cordex_listener_stop_${SLURM_JOB_NAME}.txt
#[[ $listn = true ]] && $pybin $PYCORDEX/cordex_listener_stop.py -p $pidfile -l $clsfile 
#echo "regcm script done"

}
