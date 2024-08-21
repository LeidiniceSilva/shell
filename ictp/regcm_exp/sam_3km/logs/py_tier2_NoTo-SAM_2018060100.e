INFO - MainProcess: Execution started
INFO - Subordinate 1: Saving variable cape
INFO - Subordinate 2: Saving variable cin
INFO - Subordinate 3: Saving variable li
INFO - Subordinate 4: Saving variable evspsblpot
ERROR - Subordinate 2: Error elaborating variable cin:
Traceback (most recent call last):
  File "/marconi/home/userexternal/ggiulian/RegCM-5.0.0/Tools/Scripts/pycordexer/pycordexer.py", line 318, in execute_var_chain_wrapper
    execute_var_chain(
  File "/marconi/home/userexternal/ggiulian/RegCM-5.0.0/Tools/Scripts/pycordexer/pycordexer.py", line 398, in execute_var_chain
    raise VariableFailed(
VariableFailed: This software has not found a viable action to elaborate the variable "cin" from file /marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/NoTo-SAM/SAM-3km_SRF.2018060100.nc.

ERROR - Subordinate 1: Error elaborating variable cape:
Traceback (most recent call last):
  File "/marconi/home/userexternal/ggiulian/RegCM-5.0.0/Tools/Scripts/pycordexer/pycordexer.py", line 318, in execute_var_chain_wrapper
    execute_var_chain(
  File "/marconi/home/userexternal/ggiulian/RegCM-5.0.0/Tools/Scripts/pycordexer/pycordexer.py", line 398, in execute_var_chain
    raise VariableFailed(
VariableFailed: This software has not found a viable action to elaborate the variable "cape" from file /marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/NoTo-SAM/SAM-3km_SRF.2018060100.nc.

ERROR - Subordinate 3: Error elaborating variable li:
Traceback (most recent call last):
  File "/marconi/home/userexternal/ggiulian/RegCM-5.0.0/Tools/Scripts/pycordexer/pycordexer.py", line 318, in execute_var_chain_wrapper
    execute_var_chain(
  File "/marconi/home/userexternal/ggiulian/RegCM-5.0.0/Tools/Scripts/pycordexer/pycordexer.py", line 398, in execute_var_chain
    raise VariableFailed(
VariableFailed: This software has not found a viable action to elaborate the variable "li" from file /marconi/home/userexternal/mdasilva/user/mdasilva/SAM-3km/NoTo-SAM/SAM-3km_SRF.2018060100.nc.

INFO - Subordinate 4: Writing on file ./CMIP6/DD/SAM/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5/0/1hr/evspsblpot/evspsblpot_SAM_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5_0_1hr_201806010100-201807010000.nc
INFO - Subordinate 4: Finished writing on file ./CMIP6/DD/SAM/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5/0/1hr/evspsblpot/evspsblpot_SAM_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5_0_1hr_201806010100-201807010000.nc
INFO - Subordinate 4: Writing on file ./CMIP6/DD/SAM/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5/0/day/evspsblpot/evspsblpot_SAM_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5_0_day_20180601-20180630.nc
INFO - Subordinate 4: Finished writing on file ./CMIP6/DD/SAM/ICTP/ERA5/evaluation/r1i1p1f1/RegCM5/0/day/evspsblpot/evspsblpot_SAM_ERA5_evaluation_r1i1p1f1_ICTP_RegCM5_0_day_20180601-20180630.nc
INFO - Subordinate 4: Variable evspsblpot saved using action number 0
ERROR - MainProcess: Some variables have not been correctly saved!
