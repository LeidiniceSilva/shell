


cdo seldate,1979-01-00T00:00:00,2010-12-31T00:00:00 pre_cru_ts4.01_observation_1901-2016.nc pre_cru_ts4.01_observation_1979-2010.nc
cdo seldate,1979-01-00T00:00:00,2010-12-31T00:00:00 t2m_cru_ts4.01_observation_1901-2016.nc tmp_cru_ts4.01_observation_1979-2010.nc

cdo remapbil,pre_cru_ts4.01_observation_1979-2010.nc pr_amz_neb_regcm_exp1_2001-2005.nc pr_amz_neb_regcm_exp1_int_2001-2005.nc
cdo remapbil,tmp_cru_ts4.01_observation_1979-2010.nc t2m_amz_neb_regcm_exp1_2001-2005.nc t2m_amz_neb_regcm_exp1_int_2001-2005.nc

cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A1.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A2.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A3.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A4.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A5.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A6.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A7.nc
cdo sellonlatbox,30,60,-6,-50 pre_cru_ts4.01_observation_1979-2010.nc pre_amz_neb_cru_ts4.01_observation_1979-2010_A8.nc

cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A1.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A2.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A3.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A4.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A5.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A6.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A7.nc
cdo sellonlatbox,30,60,-6,-50 tmp_cru_ts4.01_observation_1979-2010.nc tmp_amz_neb_cru_ts4.01_observation_1979-2010_A8.nc

















