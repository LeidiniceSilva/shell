#!/bin/bash

#SBATCH -A ICT26_ESP
#SBATCH -p dcgp_usr_prod
#SBATCH -N 1
#SBATCH --ntasks-per-node=112
#SBATCH -t 1-00:00:00
#SBATCH -J Postproc
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mda_silv@ictp.it

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.com'
#__date__        = 'Jan 20, 2026'
#__description__ = 'Download GPM-IMERG'

base_url="https://dap.ceda.ac.uk/badc/gpm/data/GPM-IMERG-v7"
type="HHR"
ver="V07B"

dir="/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/GPM_IMERG"
cd "$dir"

is_leap_year() {
    year=$1
    (( (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) ))
}

for year in $(seq 2003 2009); do

  for mon in $(seq -w 01 12); do

    case $mon in
      01|03|05|07|08|10|12) days=31 ;;
      04|06|09|11) days=30 ;;
      02) is_leap_year $year && days=29 || days=28 ;;
    esac

    for day in $(seq -w 01 $days); do

      doy=$(python3 -c "import datetime; print(datetime.date(${year},${mon#0},${day#0}).timetuple().tm_yday)")
      doy=$(printf "%03d" $doy)

      for counter in $(seq 0 30 1410); do

        start_hour=$((counter / 60))
        start_min=$((counter % 60))
        start=$(printf "%02d%02d" $start_hour $start_min)

        end_min=$((counter + 29))
        end_hour=$((end_min / 60))
        end_min=$((end_min % 60))
        end=$(printf "%02d%02d" $end_hour $end_min)

        mins=$(printf "%04d" "$counter")

        file="3B-${type}.MS.MRG.3IMERG.${year}${mon}${day}-S${start}00-E${end}59.${mins}.${ver}.HDF5"
        url="${base_url}/${year}/${doy}/${file}"

        echo "Path $url"

        if [ ! -f "$dir/${year}/$file" ]; then
          wget -q --show-progress "$url" -O "$dir/${year}/$file"
        fi

      done
    done
  done
done

echo "Done."
