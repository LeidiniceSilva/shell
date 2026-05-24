#!/usr/bin/env python3
import h5py
import numpy as np
from netCDF4 import Dataset
from datetime import datetime, timedelta
import os

def imerg_hdf5_to_nc(hdf5_file, nc_file):
    """Converte IMERG HDF5 para NetCDF"""
    
    print(f"Convertendo {hdf5_file}...")
    
    with h5py.File(hdf5_file, 'r') as h5f:
        # Acessar o grupo Grid
        grid = h5f['/Grid']
        
        # Ler as variáveis principais
        lat = grid['lat'][:]  # latitude
        lon = grid['lon'][:]  # longitude
        time = grid['time'][:]  # tempo em segundos desde 2000-01-01
        time_bnds = grid['time_bnds'][:]
        
        # Variáveis de precipitação
        precipitation = grid['precipitation'][:]
        precipitation_uncal = grid['precipitationUncal'][:] if 'precipitationUncal' in grid else None
        precipitation_quality = grid['precipitationQualityIndex'][:] if 'precipitationQualityIndex' in grid else None
        random_error = grid['randomError'][:] if 'randomError' in grid else None
        prob_liq = grid['probabilityLiquidPrecipitation'][:] if 'probabilityLiquidPrecipitation' in grid else None
        
        # Variáveis intermediárias (opcionais)
        ir_precip = None
        mw_precip = None
        mw_precip_source = None
        ir_influence = None
        
        if 'Intermediate' in grid:
            inter = grid['Intermediate']
            ir_precip = inter['IRprecipitation'][:] if 'IRprecipitation' in inter else None
            mw_precip = inter['MWprecipitation'][:] if 'MWprecipitation' in inter else None
            mw_precip_source = inter['MWprecipSource'][:] if 'MWprecipSource' in inter else None
            ir_influence = inter['IRinfluence'][:] if 'IRinfluence' in inter else None
        
        # Criar arquivo NetCDF
        with Dataset(nc_file, 'w', format='NETCDF4') as nc:
            
            # Copiar atributos globais
            for attr_name, attr_value in h5f.attrs.items():
                try:
                    setattr(nc, attr_name, str(attr_value))
                except:
                    pass
            
            # Criar dimensões
            nc.createDimension('lat', len(lat))
            nc.createDimension('lon', len(lon))
            nc.createDimension('time', len(time))
            nc.createDimension('nv', 2)  # para boundaries
            
            # Adicionar variável de latitude
            lat_var = nc.createVariable('lat', 'f4', ('lat',))
            lat_var[:] = lat
            lat_var.units = 'degrees_north'
            lat_var.long_name = 'Latitude'
            lat_var.standard_name = 'latitude'
            
            # Adicionar variável de longitude
            lon_var = nc.createVariable('lon', 'f4', ('lon',))
            lon_var[:] = lon
            lon_var.units = 'degrees_east'
            lon_var.long_name = 'Longitude'
            lon_var.standard_name = 'longitude'
            
            # Adicionar variável de tempo
            time_var = nc.createVariable('time', 'f8', ('time',))
            time_var[:] = time
            time_var.units = 'seconds since 2000-01-01 00:00:00'
            time_var.long_name = 'Time'
            time_var.standard_name = 'time'
            time_var.calendar = 'standard'
            
            # Boundaries de tempo
            time_bnds_var = nc.createVariable('time_bnds', 'f8', ('time', 'nv'))
            time_bnds_var[:] = time_bnds
            
            # Variável de precipitação calibrada (principal)
            precip_var = nc.createVariable('precipitation', 'f4', ('time', 'lat', 'lon'), 
                                          fill_value=-9999.0, zlib=True, complevel=4)
            precip_var[:] = precipitation
            precip_var.units = 'mm/hr'
            precip_var.long_name = 'Precipitation (calibrated)'
            precip_var.standard_name = 'precipitation_rate'
            precip_var.coordinates = 'lat lon'
            
            # Adicionar metadados
            if 'precipitation' in grid.attrs:
                for attr_name, attr_value in grid['precipitation'].attrs.items():
                    setattr(precip_var, attr_name, str(attr_value))
            
            # Precipitação não calibrada
            if precipitation_uncal is not None:
                precip_uncal_var = nc.createVariable('precipitation_uncalibrated', 'f4', 
                                                    ('time', 'lat', 'lon'), fill_value=-9999.0)
                precip_uncal_var[:] = precipitation_uncal
                precip_uncal_var.units = 'mm/hr'
                precip_uncal_var.long_name = 'Precipitation (uncalibrated)'
            
            # Índice de qualidade
            if precipitation_quality is not None:
                quality_var = nc.createVariable('precipitation_quality_index', 'f4', 
                                               ('time', 'lat', 'lon'), fill_value=-9999.0)
                quality_var[:] = precipitation_quality
                quality_var.units = '1'
                quality_var.long_name = 'Precipitation Quality Index'
                quality_var.valid_range = (0, 100)
            
            # Erro aleatório
            if random_error is not None:
                error_var = nc.createVariable('random_error', 'f4', ('time', 'lat', 'lon'), 
                                             fill_value=-9999.0)
                error_var[:] = random_error
                error_var.units = 'mm/hr'
                error_var.long_name = 'Random Error'
            
            # Probabilidade de precipitação líquida
            if prob_liq is not None:
                prob_var = nc.createVariable('probability_liquid_precipitation', 'f4', 
                                            ('time', 'lat', 'lon'), fill_value=-9999.0)
                prob_var[:] = prob_liq
                prob_var.units = '1'
                prob_var.long_name = 'Probability of Liquid Precipitation'
            
            # Variáveis intermediárias (opcionais - comentar se não quiser)
            if ir_precip is not None:
                ir_var = nc.createVariable('IR_precipitation', 'f4', ('time', 'lat', 'lon'))
                ir_var[:] = ir_precip
                ir_var.units = 'mm/hr'
                ir_var.long_name = 'Infrared Precipitation'
            
            if mw_precip is not None:
                mw_var = nc.createVariable('MW_precipitation', 'f4', ('time', 'lat', 'lon'))
                mw_var[:] = mw_precip
                mw_var.units = 'mm/hr'
                mw_var.long_name = 'Microwave Precipitation'
            
            # Extrair data do nome do arquivo
            import re
            match = re.search(r'(\d{4})(\d{2})(\d{2})', hdf5_file)
            if match:
                year, month, day = match.groups()
                nc.title = f'IMERG {type} Precipitation {year}-{month}-{day}'
                nc.history = f'Created from IMERG V07B HDF5 on {datetime.now().isoformat()}'
    
    print(f"✓ Convertido: {nc_file}")

# Script para batch conversion
def batch_convert(input_dir, output_dir):
    """Converte todos os arquivos HDF5 do diretório"""
    os.makedirs(output_dir, exist_ok=True)
    
    hdf5_files = [f for f in os.listdir(input_dir) if f.endswith('.HDF5')]
    
    for hdf5_file in hdf5_files:
        input_path = os.path.join(input_dir, hdf5_file)
        output_path = os.path.join(output_dir, hdf5_file.replace('.HDF5', '.nc'))
        
        if os.path.exists(output_path):
            print(f"Pulando {hdf5_file} - já convertido")
            continue
        
        try:
            imerg_hdf5_to_nc(input_path, output_path)
        except Exception as e:
            print(f"Erro ao converter {hdf5_file}: {e}")
            import traceback
            traceback.print_exc()

# Executar
if __name__ == "__main__":
    # Para um único arquivo
    imerg_hdf5_to_nc('3B-HHR.MS.MRG.3IMERG.20010101-S000000-E002959.0000.V07B.HDF5', 'output.nc')
    
    # Para todos os arquivos
    input_directory = "/leonardo/home/userexternal/mdasilva/leonardo_work/MOAAP/GPM/GPM_IMERG"
    output_directory = input_directory + "/netcdf"
    
    batch_convert(input_directory, output_directory)
