inputo	= addfile("/home/ejkim/tempest_260604/input/orog_era5.nc","r")
orog0	= inputo->orog(0,:,:)	; time=1, lat, lon
lato	= inputo->latitude
lono	= inputo->longitude

inputv	= addfile("/home/ejkim/tempest_260604/input/v10_era5_6hr_1-5Jan2020.nc","r")
var0	= inputv->v10
latv	= inputv->latitude
lonv	= inputv->longitude
time0	= var0&valid_time

orog1	= linint2_Wrap(lono,lato,orog0,True,lonv,latv,0)

orog2	= new(dimsizes(var0),double)

do t	= 0, dimsizes(time0)-1

orog2(t,:,:)	= orog1

end do

copy_VarCoords(var0,orog2)

orog2!0	= "time"

system("rm -f /home/ejkim/tempest_260604/input/orog_era5_6hr_1-5Jan2020.nc")
output	= addfile("/home/ejkim/tempest_260604/input/orog_era5_6hr_1-5Jan2020.nc","c")
output->orog	= orog2

exit
