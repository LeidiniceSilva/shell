#!/bin/csh

foreach var ( z300 z500 )

echo $var

cat > make.ncl << EOF

input	= addfile("/home/ejkim/tempest_260604/input/${var}_era5_6hr_1-5Jan2020.nc","r")
var0	= input->z(:,0,:,:)
var0!0	= "time"

system("rm -f /home/ejkim/tempest_260604/input/${var}_era5_6hr_1-5Jan2020_chname.nc")
output	= addfile("/home/ejkim/tempest_260604/input/${var}_era5_6hr_1-5Jan2020_chname.nc","c")
output->${var}	= var0

exit

EOF

ncl make.ncl
rm -f make.ncl

end
