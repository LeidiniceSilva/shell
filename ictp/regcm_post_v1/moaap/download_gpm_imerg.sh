#!/bin/bash

base_url="https://dap.ceda.ac.uk/badc/gpm/data/GPM-IMERG-v7"

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

type=HHR
ver=V07B
dir=/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/GPM_IMERG

cd ${dir}
echo "Working directory: ${dir}"

for year in `seq -w 2001 2001`; do
    for mon in `seq -w 01 12`; do
        
        # Determine days in month
        case ${mon} in
            01|03|05|07|08|10|12) days=31 ;;
            04|06|09|11) days=30 ;;
            02)
                if is_leap_year ${year}; then
                    days=29
                else
                    days=28
                fi
                ;;
        esac
        
        for day in `seq -w 01 ${days}`; do
            # Convert YYYYMMDD to day-of-year (001-366)
            date_str="${year}${mon}${day}"
            doy=$(date -d "${date_str}" +%j)
            folder=$(printf "%03d" ${doy})
            
            # Loop through all 30-minute intervals (48 files per day)
            # Counter goes from 0 to 1410 in steps of 30
            for counter in $(seq 0 30 1410); do
                mins=$(printf "%04d" ${counter})
                
                # Calculate start and end times based on counter
                # Each file covers 30 minutes: start = counter minutes into the day
                start_hour=$((counter / 60))
                start_min=$((counter % 60))
                start=$(printf "%02d%02d" ${start_hour} ${start_min})
                
                # End time is start time + 29 minutes
                total_minutes=$((counter + 29))
                end_hour=$((total_minutes / 60))
                end_min=$((total_minutes % 60))
                end=$(printf "%02d%02d" ${end_hour} ${end_min})
                
                # Construct filename
                file="3B-${type}.MS.MRG.3IMERG.${year}${mon}${day}-S${start}00-E${end}59.${mins}.${ver}.HDF5"
                
                # Construct full URL
                url="${base_url}/${year}/${folder}/${file}"
                
                # Output filename (keep as HDF5 or convert to NetCDF)
                output_file="${file}"
                
                if [ ! -f "${output_file}" ]; then
                    echo "Downloading: ${file}"
                    wget --progress=bar:force "${url}" -O "${dir}/${output_file}"
                    
                    if [ $? -eq 0 ]; then
                        echo "Successfully downloaded: ${output_file}"
                    else
                        echo "Failed to download: ${url}"
                    fi
                else
                    echo "File already exists: ${output_file}"
                fi
            done
        done
    done
done

echo "Download complete!"
