slurmstepd: error: couldn't chdir to `/leonardo_work/ICT24_ESP/mdasilva/CORDEX5/ERA5/ERA5-CSAM-3': No such file or directory: going to /tmp instead
slurmstepd: error: couldn't chdir to `/leonardo_work/ICT24_ESP/mdasilva/CORDEX5/ERA5/ERA5-CSAM-3': No such file or directory: going to /tmp instead
INFO - MainProcess: Execution started
Traceback (most recent call last):
  File "/leonardo/home/userexternal/ggiulian/RegCM-CORDEX5/Tools/Scripts/pycordexer/pycordexer.py", line 469, in <module>
    sys_exit(main())
             ~~~~^^
  File "/leonardo/home/userexternal/ggiulian/RegCM-CORDEX5/Tools/Scripts/pycordexer/pycordexer.py", line 439, in main
    procs = save_vars(
        datafile,
    ...<12 lines>...
        output_dir
    )
  File "/leonardo/home/userexternal/ggiulian/RegCM-CORDEX5/Tools/Scripts/pycordexer/pycordexer.py", line 251, in save_vars
    with Dataset(datafile, 'r') as ncf:
         ~~~~~~~^^^^^^^^^^^^^^^
  File "src/netCDF4/_netCDF4.pyx", line 2521, in netCDF4._netCDF4.Dataset.__init__
  File "src/netCDF4/_netCDF4.pyx", line 2158, in netCDF4._netCDF4._ensure_nc_success
FileNotFoundError: [Errno 2] No such file or directory: '/leonardo/home/userexternal/mdasilva/leonardo_work/CORDEX5/ERA5/ERA5-CSAM-3/*_SRF.20000130*.nc'
