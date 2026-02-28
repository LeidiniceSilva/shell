import xarray as xr
import metpy.xarray           
from metpy.units import units

# Stefan–Boltzmann constant
sigma = 5.670374419e-8 * units('W / m^2 / K^4')

ds = xr.open_dataset("/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/CSAM-3/rlut_CSAM-3_RAD.2000010200_new.nc")

# Emissivity
emis = 0.97

# Attach units
lwup = ds['rlut'] * units('W/m^2')

# Compute brightness temperature
Tb = (lwup / (emis * sigma))**0.25

# correct conversion
Tb = Tb.metpy.convert_units('kelvin')

# Save to dataset
ds['Tb'] = Tb
ds['Tb'].attrs = {
    'long_name': 'Brightness temperature',
    'units': 'K',
    'emissivity': emis,
    'method': 'Stefan-Boltzmann inversion'
}

ds['Tb_C'] = (ds['Tb'] - 273.15 * units.kelvin).metpy.convert_units('degC')
ds['Tb_C'].attrs['units'] = 'degC'
ds['Tb_C'].attrs['long_name'] = 'Brightness temperature'

out_dir = "/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/CSAM-3/Tb/"
out = f"{out_dir}/Tb_CSAM-3_SRF.2000010200.nc"

# Save only Tb (as you already do)
ds[['Tb']].to_netcdf(out)

