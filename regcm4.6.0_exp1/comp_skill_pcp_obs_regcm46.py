# -*- coding: utf-8 -*-

""" Compute skill precipitation of RegCM4.6.0 model and obs.

functions:
    pc_bias: percentage bias
    apb    : absolute percent bias
    rmse   : root mean square error
    mae    : mean absolute error
    bias   : mean bias error
    NS     : Nash-Sutcliffe Coefficient
    L      : likelihood estimation
    correl : correlation

"""

__author__ = "Leidinice Silva"
__email__  = "leidinicesilvae@gmail.com"
__date__   = "05/18/2018"
__description__ = " Compute skill precipitation of RegCM4.6.0 model and obs "


import netCDF4
import datetime
import numpy as np
import pandas as pd
import scipy.stats as ss
import scipy.stats as st
import matplotlib.pyplot as plt

from matplotlib import pyplot
from matplotlib.font_manager import FontProperties
from PyFuncemeClimateTools import PlotMaps as pm
from hidropy.utils.hidropy_utils import create_path


def filter_nan(s, o):
    data = np.array([s.flatten(), o.flatten()])
    data = np.transpose(data)
    data = data[~np.isnan(data).any(1)]
    return data[:, 0], data[:, 1]


def pc_bias(s, o):
    s, o = filter_nan(s, o)
    return 100.0 * sum(s - o) / sum(o)


def apb(s, o):
    s, o = filter_nan(s, o)
    return 100.0 * sum(abs(s - o)) / sum(o)


def rmse(s, o):
    s, o = filter_nan(s, o)
    return np.sqrt(np.mean((s - o) ** 2))


def mae(s, o):
    s, o = filter_nan(s, o)
    return np.mean(abs(s - o))


def bias(s, o):
    s, o = filter_nan(s, o)
    return np.mean(s - o)


def nash(s, o):
    s, o = filter_nan(s, o)
    return 1 - sum((s - o) ** 2) / sum((o - np.mean(o)) ** 2)


def l(s, o, N=5):
    s, o = filter_nan(s, o)
    return np.exp(-N * sum((s - o) ** 2) / sum((o - np.mean(o)) ** 2))


def correlation(s, o):
    s, o = filter_nan(s, o)
    if s.size == 0:
        corr = np.NaN
    else:
        corr = np.corrcoef(o, s)[0, 1]
    return corr


def gamma_correction(s, o, fcst):

    sim = np.sort(s)
    alpha_mod, loc_mod, beta_mod = ss.gamma.fit(sim, loc=0)
    obs = np.sort(o)
    alpha_obs, loc_obs, beta_obs = ss.gamma.fit(obs, loc=0)

    correc_fcst = []
    for i in fcst:
        prob = ss.gamma.cdf(i, alpha_mod, scale=beta_mod)
        correc_fcst.append(ss.gamma.ppf(prob, alpha_obs, scale=beta_obs))
    return correc_fcst


def _checkdims(model, obs):
    if not model.ndim == obs.ndim:
        print('Dims are not equals!')
        exit(1)


def compute_pearson(model, obs, **kwargs):

    method = kwargs.pop('method', '3d')  # 1d or 3d
    if method == '1d':
        corr, pvalue = st.pearsonr(model, obs)
        return corr

    elif method == '3d':

        _checkdims(model, obs)
        timelen = float(obs.shape[0])

        obs_mean = np.nanmean(obs, axis=0)
        obs_std = np.nanstd(obs, axis=0)

        model_mean = np.nanmean(model, axis=0)
        model_std = np.nanstd(model, axis=0)

        x1 = (obs - obs_mean)/obs_std
        y1 = (model - model_mean)/model_std

        xymult = x1 * y1
        xysum = np.nansum(xymult, axis=0)
        corr = xysum/timelen
        return corr
    else:
        print('--- Funcao ClimateStats.compute_pearson ---')
        print('--- Erro nos dados de entrada!---\nSaindo...')
        exit(1)


# Open netCDF4 model and obd file
arq1 = '/vol3/nice/output/xxxxxxxxxxxxxxxxxxxxxxxxxx.nc'.format(link, paramet, grad)
data1 = netCDF4.Dataset(arq1)
variable1 = data1.variables['precip'][:]
lat = data1.variables['lat'][:]
lon = data1.variables['lon'][:]

arq2 = '/vol3/nice/obs/pr_Amon_CRU-TS3.22_observation_197901-201312.nc'.format(link)
data2 = netCDF4.Dataset(arq2)
variable2 = data2.variables['pr'][:]
lat = data2.variables['lat'][:]
lon = data2.variables['lon'][:]

# all months run the list
year_sim = np.nanmean(np.nanmean(variable1[:, :, :], axis=1), axis=1)
year_obs = np.nanmean(np.nanmean(variable2[:, :, :], axis=1), axis=1)

um_sim = year_sim[0:12]
dois_sim = year_sim[12:24]
tres_sim = year_sim[24:36]
quatro_sim = year_sim[36:48]
cinco_sim = year_sim[48:60]
seis_sim = year_sim[60:72]
sete_sim = year_sim[72:84]
oito_sim = year_sim[84:96]
nove_sim = year_sim[96:108]
dez_sim = year_sim[108:120]
onze_sim = year_sim[120:132]
doze_sim = year_sim[132:144]
treze_sim = year_sim[144:156]
quatorze_sim = year_sim[156:168]
quize_sim = year_sim[168:180]
dezeseis_sim = year_sim[180:192]
dezesete_sim = year_sim[192:204]
dezoito_sim = year_sim[204:216]
dezenove_sim = year_sim[216:228]
vinte_sim = year_sim[228:240]
vinte_um_sim = year_sim[240:252]
vinte_dois_sim = year_sim[252:264]
vinte_tres_sim = year_sim[264:276]
vinte_quatro_sim = year_sim[276:288]
vinte_cinco_sim = year_sim[288:300]
vinte_seis_sim = year_sim[300:312]
vinte_sete_sim = year_sim[312:324]
vinte_oito_sim = year_sim[324:336]
vinte_nove_sim = year_sim[336:348]
trinta_sim = year_sim[348:360]
trinta_um_sim = year_sim[360:372]

um_obs = np.nanmean(year_obs[0:12])
dois_obs = np.nanmean(year_obs[12:24])
tres_obs = np.nanmean(year_obs[24:36])
quatro_obs = np.nanmean(year_obs[36:48])
cinco_obs = np.nanmean(year_obs[48:60])
seis_obs = np.nanmean(year_obs[60:72])
sete_obs = np.nanmean(year_obs[72:84])
oito_obs = np.nanmean(year_obs[84:96])
nove_obs = np.nanmean(year_obs[96:108])
dez_obs = np.nanmean(year_obs[108:120])
onze_obs = np.nanmean(year_obs[120:132])
doze_obs = np.nanmean(year_obs[132:144])
treze_obs = np.nanmean(year_obs[144:156])
quatorze_obs = np.nanmean(year_obs[156:168])
quize_obs = np.nanmean(year_obs[168:180])
dezeseis_obs = np.nanmean(year_obs[180:192])
dezesete_obs = np.nanmean(year_obs[192:204])
dezoito_obs = np.nanmean(year_obs[204:216])
dezenove_obs = np.nanmean(year_obs[216:228])
vinte_obs = np.nanmean(year_obs[228:240])
vinte_um_obs = np.nanmean(year_obs[240:252])
vinte_dois_obs = np.nanmean(year_obs[252:264])
vinte_tres_obs = np.nanmean(year_obs[264:276])
vinte_quatro_obs = np.nanmean(year_obs[276:288])
vinte_cinco_obs = np.nanmean(year_obs[288:300])
vinte_seis_obs = np.nanmean(year_obs[300:312])
vinte_sete_obs = np.nanmean(year_obs[312:324])
vinte_oito_obs = np.nanmean(year_obs[324:336])
vinte_nove_obs = np.nanmean(year_obs[336:348])
trinta_obs = np.nanmean(year_obs[348:360])
trinta_um_obs = np.nanmean(year_obs[360:372])

year_clim_sim = [um_sim, dois_sim, tres_sim, quatro_sim, cinco_sim, seis_sim, sete_sim, oito_sim, nove_sim, dez_sim,
                 onze_sim, doze_sim, treze_sim, quatorze_sim, quize_sim, dezeseis_sim, dezesete_sim, dezoito_sim,
                 dezenove_sim, vinte_sim, vinte_um_sim, vinte_dois_sim, vinte_tres_sim, vinte_quatro_sim,
                 vinte_cinco_sim, vinte_seis_sim, vinte_sete_sim, vinte_oito_sim, vinte_nove_sim, trinta_sim,
                 trinta_um_sim]

year_clim_obs = [um_obs, dois_obs, tres_obs, quatro_obs, cinco_obs, seis_obs, sete_obs, oito_obs, nove_obs, dez_obs,
                 onze_obs, doze_obs, treze_obs, quatorze_obs, quize_obs, dezeseis_obs, dezesete_obs, dezoito_obs,
                 dezenove_obs, vinte_obs, vinte_um_obs, vinte_dois_obs, vinte_tres_obs, vinte_quatro_obs,
                 vinte_cinco_obs, vinte_seis_obs, vinte_sete_obs, vinte_oito_obs, vinte_nove_obs, trinta_obs,
                 trinta_um_obs]

# all jan run the list in shape
jan_sim = variable1[0::12][:, :, :]
# calculate jan climatology one value
jan_mean_sim = np.nanmean(jan_sim)
# mean of jan for year 31 values
jan_yr_sim = np.nanmean(np.nanmean(jan_sim, axis=1), axis=1)

feb_sim = variable1[1::12][:, :, :]
feb_mean_sim = np.nanmean(feb_sim)
feb_yr_sim = np.nanmean(np.nanmean(feb_sim, axis=1), axis=1)

mar_sim = variable1[2::12][:, :, :]
mar_mean_sim = np.nanmean(mar_sim)
mar_yr_sim = np.nanmean(np.nanmean(mar_sim, axis=1), axis=1)

apr_sim = variable1[3::12][:, :, :]
apr_mean_sim = np.nanmean(apr_sim)
apr_yr_sim = np.nanmean(np.nanmean(apr_sim, axis=1), axis=1)

may_sim = variable1[4::12][:, :, :]
may_mean_sim = np.nanmean(may_sim)
may_yr_sim = np.nanmean(np.nanmean(may_sim, axis=1), axis=1)

jun_sim = variable1[5::12][:, :, :]
jun_mean_sim = np.nanmean(jun_sim)
jun_yr_sim = np.nanmean(np.nanmean(jun_sim, axis=1), axis=1)

jul_sim = variable1[6::12][:, :, :]
jul_mean_sim = np.nanmean(jul_sim)
jul_yr_sim = np.nanmean(np.nanmean(jul_sim, axis=1), axis=1)

aug_sim = variable1[7::12][:, :, :]
aug_mean_sim = np.nanmean(aug_sim)
aug_yr_sim = np.nanmean(np.nanmean(aug_sim, axis=1), axis=1)

sep_sim = variable1[8::12][:, :, :]
sep_mean_sim = np.nanmean(sep_sim)
sep_yr_sim = np.nanmean(np.nanmean(sep_sim, axis=1), axis=1)

oct_sim = variable1[9::12][:, :, :]
oct_mean_sim = np.nanmean(oct_sim)
oct_yr_sim = np.nanmean(np.nanmean(oct_sim, axis=1), axis=1)

nov_sim = variable1[10::12][:, :, :]
nov_mean_sim = np.nanmean(nov_sim)
nov_yr_sim = np.nanmean(np.nanmean(nov_sim, axis=1), axis=1)

dec_sim = variable1[11::12][:, :, :]
dec_mean_sim = np.nanmean(dec_sim)
dec_yr_sim = np.nanmean(np.nanmean(dec_sim, axis=1), axis=1)

############################################################
jan_obs = variable2[0::12][:, :, :]
jan_mean_obs = np.nanmean(jan_obs)
jan_yr_obs = np.nanmean(np.nanmean(jan_obs, axis=1), axis=1)

feb_obs = variable2[1::12][:, :, :]
feb_mean_obs = np.nanmean(feb_obs)
feb_yr_obs = np.nanmean(np.nanmean(feb_obs, axis=1), axis=1)

mar_obs = variable2[2::12][:, :, :]
mar_mean_obs = np.nanmean(mar_obs)
mar_yr_obs = np.nanmean(np.nanmean(mar_obs, axis=1), axis=1)

apr_obs = variable2[3::12][:, :, :]
apr_mean_obs = np.nanmean(apr_obs)
apr_yr_obs = np.nanmean(np.nanmean(apr_obs, axis=1), axis=1)

may_obs = variable2[4::12][:, :, :]
may_mean_obs = np.nanmean(may_obs)
may_yr_obs = np.nanmean(np.nanmean(may_obs, axis=1), axis=1)

jun_obs = variable2[5::12][:, :, :]
jun_mean_obs = np.nanmean(jun_obs)
jun_yr_obs = np.nanmean(np.nanmean(jun_obs, axis=1), axis=1)

jul_obs = variable2[6::12][:, :, :]
jul_mean_obs = np.nanmean(jul_obs)
jul_yr_obs = np.nanmean(np.nanmean(jul_obs, axis=1), axis=1)

aug_obs = variable2[7::12][:, :, :]
aug_mean_obs = np.nanmean(aug_obs)
aug_yr_obs = np.nanmean(np.nanmean(aug_obs, axis=1), axis=1)

sep_obs = variable2[8::12][:, :, :]
sep_mean_obs = np.nanmean(sep_obs)
sep_yr_obs = np.nanmean(np.nanmean(sep_obs, axis=1), axis=1)

oct_obs = variable2[9::12][:, :, :]
oct_mean_obs = np.nanmean(oct_obs)
oct_yr_obs = np.nanmean(np.nanmean(oct_obs, axis=1), axis=1)

nov_obs = variable2[10::12][:, :, :]
nov_mean_obs = np.nanmean(nov_obs)
nov_yr_obs = np.nanmean(np.nanmean(nov_obs, axis=1), axis=1)

dec_obs = variable2[11::12][:, :, :]
dec_mean_obs = np.nanmean(dec_obs)
dec_yr_obs = np.nanmean(np.nanmean(dec_obs, axis=1), axis=1)

# For plot climatology
clim_sim = np.array([jan_mean_sim, feb_mean_sim, mar_mean_sim, apr_mean_sim, may_mean_sim, jun_mean_sim, jul_mean_sim,
                     aug_mean_sim, sep_mean_sim, oct_mean_sim, nov_mean_sim, dec_mean_sim])
clim_obs = np.array([jan_mean_obs, feb_mean_obs, mar_mean_obs, apr_mean_obs, may_mean_obs, jun_mean_obs, jul_mean_obs,
                     aug_mean_obs, sep_mean_obs, oct_mean_obs, nov_mean_obs, dec_mean_obs])

# Calculate statistics indices
pc_bias_jan = pc_bias(jan_yr_sim, jan_yr_obs)
pc_bias_feb = pc_bias(feb_yr_sim, feb_yr_obs)
pc_bias_mar = pc_bias(mar_yr_sim, mar_yr_obs)
pc_bias_apr = pc_bias(apr_yr_sim, apr_yr_obs)
pc_bias_may = pc_bias(may_yr_sim, may_yr_obs)
pc_bias_jun = pc_bias(jun_yr_sim, jun_yr_obs)
pc_bias_jul = pc_bias(jul_yr_sim, jul_yr_obs)
pc_bias_aug = pc_bias(aug_yr_sim, aug_yr_obs)
pc_bias_sep = pc_bias(sep_yr_sim, sep_yr_obs)
pc_bias_oct = pc_bias(oct_yr_sim, oct_yr_obs)
pc_bias_nov = pc_bias(nov_yr_sim, nov_yr_obs)
pc_bias_dec = pc_bias(dec_yr_sim, dec_yr_obs)

apb_jan = apb(jan_yr_sim, jan_yr_obs)
apb_feb = apb(feb_yr_sim, feb_yr_obs)
apb_mar = apb(mar_yr_sim, mar_yr_obs)
apb_apr = apb(apr_yr_sim, apr_yr_obs)
apb_may = apb(may_yr_sim, may_yr_obs)
apb_jun = apb(jun_yr_sim, jun_yr_obs)
apb_jul = apb(jul_yr_sim, jul_yr_obs)
apb_aug = apb(aug_yr_sim, aug_yr_obs)
apb_sep = apb(sep_yr_sim, sep_yr_obs)
apb_oct = apb(oct_yr_sim, oct_yr_obs)
apb_nov = apb(nov_yr_sim, nov_yr_obs)
apb_dec = apb(dec_yr_sim, dec_yr_obs)

rmse_jan = rmse(jan_yr_sim, jan_yr_obs)
rmse_feb = rmse(feb_yr_sim, feb_yr_obs)
rmse_mar = rmse(mar_yr_sim, mar_yr_obs)
rmse_apr = rmse(apr_yr_sim, apr_yr_obs)
rmse_may = rmse(may_yr_sim, may_yr_obs)
rmse_jun = rmse(jun_yr_sim, jun_yr_obs)
rmse_jul = rmse(jul_yr_sim, jul_yr_obs)
rmse_aug = rmse(aug_yr_sim, aug_yr_obs)
rmse_sep = rmse(sep_yr_sim, sep_yr_obs)
rmse_oct = rmse(oct_yr_sim, oct_yr_obs)
rmse_nov = rmse(nov_yr_sim, nov_yr_obs)
rmse_dec = rmse(dec_yr_sim, dec_yr_obs)

mae_jan = mae(jan_yr_sim, jan_yr_obs)
mae_feb = mae(feb_yr_sim, feb_yr_obs)
mae_mar = mae(mar_yr_sim, mar_yr_obs)
mae_apr = mae(apr_yr_sim, apr_yr_obs)
mae_may = mae(may_yr_sim, may_yr_obs)
mae_jun = mae(jun_yr_sim, jun_yr_obs)
mae_jul = mae(jul_yr_sim, jul_yr_obs)
mae_aug = mae(aug_yr_sim, aug_yr_obs)
mae_sep = mae(sep_yr_sim, sep_yr_obs)
mae_oct = mae(oct_yr_sim, oct_yr_obs)
mae_nov = mae(nov_yr_sim, nov_yr_obs)
mae_dec = mae(dec_yr_sim, dec_yr_obs)

bias_jan = bias(jan_yr_sim, jan_yr_obs)
bias_feb = bias(feb_yr_sim, feb_yr_obs)
bias_mar = bias(mar_yr_sim, mar_yr_obs)
bias_apr = bias(apr_yr_sim, apr_yr_obs)
bias_may = bias(may_yr_sim, may_yr_obs)
bias_jun = bias(jun_yr_sim, jun_yr_obs)
bias_jul = bias(jul_yr_sim, jul_yr_obs)
bias_aug = bias(aug_yr_sim, aug_yr_obs)
bias_sep = bias(sep_yr_sim, sep_yr_obs)
bias_oct = bias(oct_yr_sim, oct_yr_obs)
bias_nov = bias(nov_yr_sim, nov_yr_obs)
bias_dec = bias(dec_yr_sim, dec_yr_obs)

nash_jan = nash(jan_yr_sim, jan_yr_obs)
nash_feb = nash(feb_yr_sim, feb_yr_obs)
nash_mar = nash(mar_yr_sim, mar_yr_obs)
nash_apr = nash(apr_yr_sim, apr_yr_obs)
nash_may = nash(may_yr_sim, may_yr_obs)
nash_jun = nash(jun_yr_sim, jun_yr_obs)
nash_jul = nash(jul_yr_sim, jul_yr_obs)
nash_aug = nash(aug_yr_sim, aug_yr_obs)
nash_sep = nash(sep_yr_sim, sep_yr_obs)
nash_oct = nash(oct_yr_sim, oct_yr_obs)
nash_nov = nash(nov_yr_sim, nov_yr_obs)
nash_dec = nash(dec_yr_sim, dec_yr_obs)

l_jan = l(jan_yr_sim, jan_yr_sim, N=5)
l_feb = l(feb_yr_sim, feb_yr_obs, N=5)
l_mar = l(mar_yr_sim, mar_yr_obs, N=5)
l_apr = l(apr_yr_sim, apr_yr_obs, N=5)
l_may = l(may_yr_sim, may_yr_obs, N=5)
l_jun = l(jun_yr_sim, jun_yr_obs, N=5)
l_jul = l(jul_yr_sim, jul_yr_obs, N=5)
l_aug = l(aug_yr_sim, aug_yr_obs, N=5)
l_sep = l(sep_yr_sim, sep_yr_obs, N=5)
l_oct = l(oct_yr_sim, oct_yr_obs, N=5)
l_nov = l(nov_yr_sim, nov_yr_obs, N=5)
l_dec = l(dec_yr_sim, dec_yr_obs, N=5)

r_jan = correlation(jan_yr_sim, jan_yr_obs)
r_feb = correlation(feb_yr_sim, feb_yr_obs)
r_mar = correlation(mar_yr_sim, mar_yr_obs)
r_apr = correlation(apr_yr_sim, apr_yr_obs)
r_may = correlation(may_yr_sim, may_yr_obs)
r_jun = correlation(jun_yr_sim, jun_yr_obs)
r_jul = correlation(jul_yr_sim, jul_yr_obs)
r_aug = correlation(aug_yr_sim, aug_yr_obs)
r_sep = correlation(sep_yr_sim, sep_yr_obs)
r_oct = correlation(oct_yr_sim, oct_yr_obs)
r_nov = correlation(nov_yr_sim, nov_yr_obs)
r_dec = correlation(dec_yr_sim, dec_yr_obs)

pc_bias_mon = np.array([pc_bias_jan, pc_bias_feb, pc_bias_mar, pc_bias_apr, pc_bias_may, pc_bias_jun, pc_bias_jul,
                        pc_bias_aug, pc_bias_sep, pc_bias_oct, pc_bias_nov, pc_bias_dec])

apb_mon = np.array([apb_jan, apb_feb, apb_mar, apb_apr, apb_may, apb_jun, apb_jul, apb_aug, apb_sep, apb_oct, apb_nov,
                    apb_dec])

rmse_mon = np.array([rmse_jan, rmse_feb, rmse_mar, rmse_apr, rmse_may, rmse_jun, rmse_jul, rmse_aug, rmse_sep, rmse_oct,
                     rmse_nov, rmse_dec])

mae_mon = np.array([mae_jan, mae_feb, mae_mar, mae_apr, mae_may, mae_jun, mae_jul, mae_aug, mae_sep, mae_oct, mae_nov,
                    mae_dec])

bias_mon = np.array([bias_jan, bias_feb, bias_mar, bias_apr, bias_may, bias_jun, bias_jul, bias_aug, bias_sep, bias_oct,
                    bias_nov, bias_dec])

nash_mon = np.array([nash_jan, nash_feb, nash_mar, nash_apr, nash_may, nash_jun, nash_jul, nash_aug, nash_sep, nash_oct,
                     nash_nov, nash_dec])

L_mon = np.array([l_jan, l_feb, l_mar, l_apr, l_may, l_jun, l_jul, l_aug, l_sep, l_oct, l_nov, l_dec])

r_mon = np.array([r_jan, r_feb, r_mar, r_apr, r_may, r_jun, r_jul, r_aug, r_sep, r_oct, r_nov, r_dec])

djf_sim = dec_yr_sim + jan_yr_sim + feb_yr_sim
mam_sim = mar_yr_sim + apr_yr_sim + may_yr_sim
jja_sim = jun_yr_sim + jul_yr_sim + aug_yr_sim
son_sim = sep_yr_sim + oct_yr_sim + nov_yr_sim

djf_obs = dec_yr_obs + jan_yr_obs + feb_yr_obs
mam_obs = mar_yr_obs + apr_yr_obs + may_yr_obs
jja_obs = jun_yr_obs + jul_yr_obs + aug_yr_obs
son_obs = sep_yr_obs + oct_yr_obs + nov_yr_obs

pc_bias_djf = pc_bias(djf_sim, djf_obs)
pc_bias_mam = pc_bias(mam_sim, mam_obs)
pc_bias_jja = pc_bias(jja_sim, jja_obs)
pc_bias_son = pc_bias(son_sim, son_obs)

apb_djf = apb(djf_sim, djf_obs)
apb_mam = apb(mam_sim, mam_obs)
apb_jja = apb(jja_sim, jja_obs)
apb_son = apb(son_sim, son_obs)

rmse_djf = rmse(djf_sim, djf_obs)
rmse_mam = rmse(mam_sim, mam_obs)
rmse_jja = rmse(jja_sim, jja_obs)
rmse_son = rmse(son_sim, son_obs)

mae_djf = mae(djf_sim, djf_obs)
mae_mam = mae(mam_sim, mam_obs)
mae_jja = mae(jja_sim, jja_obs)
mae_son = mae(son_sim, son_obs)

bias_djf = bias(djf_sim, djf_obs)
bias_mam = bias(mam_sim, mam_obs)
bias_jja = bias(jja_sim, jja_obs)
bias_son = bias(son_sim, son_obs)

nash_djf = nash(djf_sim, djf_obs)
nash_mam = nash(mam_sim, mam_obs)
nash_jja = nash(jja_sim, jja_obs)
nash_son = nash(son_sim, son_obs)

l_djf = l(djf_sim, djf_obs)
l_mam = l(mam_sim, mam_obs)
l_jja = l(jja_sim, jja_obs)
l_son = l(son_sim, son_obs)

r_djf = correlation(djf_sim, djf_obs)
r_mam = correlation(mam_sim, mam_obs)
r_jja = correlation(jja_sim, jja_obs)
r_son = correlation(son_sim, son_obs)

pc_bias_seasonal = np.array([pc_bias_djf, pc_bias_mam, pc_bias_jja, pc_bias_son])
apb_seasonal = np.array([apb_djf, apb_mam, apb_jja, apb_son])
rmse_seasonal = np.array([rmse_djf, rmse_mam, rmse_jja, rmse_son])
mae_seasonal = np.array([mae_djf, mae_mam, mae_jja, mae_son])
bias_seasonal = np.array([bias_djf, bias_mam, bias_jja, bias_apr])
nash_seasonal = np.array([nash_djf, nash_mam, nash_jja, nash_son])
l_seasonal = np.array([l_djf, l_mam, l_jja, l_son])
r_seasonal = np.array([r_djf, r_mam, r_jja, r_son])

# print "month ----> j f m a m j j a s o n d"
# print pc_bias_mon
# print apb_mon
# print rmse_mon
# print mae_mon
# print bias_mon
# print nash_mon
# print L_mon
# print r_mon
#
# print "----------------------------"
#
# print "seasonal ----> djf mam jja son"
# print pc_bias_seasonal
# print apb_seasonal
# print rmse_seasonal
# print mae_seasonal
# print bias_seasonal
# print nash_seasonal
# print l_seasonal
# print r_seasonal

# path_out = home + "/Documentos/sic_2017/codes/results/"
# if not os.path.exists(path_out):
#     create_path(path_out)
#
# # Box plot anual cicle obs x model
# fig = plt.figure(figsize=(34, 12))
# dates = np.arange(1, 31 + 1)
#
# a = plt.plot(dates, year_clim_obs)
# plt.boxplot(year_clim_sim)
# plt.setp(a, linewidth=2, markeredgewidth=2, marker='+', color='black')
#
# plt.title(u'AnÃ¡lise das precipitaÃ§Ãµes mÃ©dias anuais \n OLAMv.3.3_{0}_{1} x OBS  - 1982_2012'
#           .format(grad, paramet.upper()), fontsize=34, fontweight='bold')
# plt.xlabel(u'Anos', fontsize=34, fontweight='bold')
# plt.ylabel(u'PrecipitaÃ§Ã£o (mm/m)', fontsize=34, fontweight='bold')
#
# objects = [u'1982', u'1983', u'1984', u'1985', u'1986', u'1987', u'1988', u'1989', u'1990', u'1991', u'1992', u'1993',
#            u'1994', u'1995', u'1996', u'1997', u'1998', u'1999', u'2000', u'2001', u'2002', u'2003', u'2004', u'2005',
#            u'2006', u'2007', u'2008', u'2009', u'2010', u'2011', u'2012']
# plt.xticks(dates, objects)
# plt.tick_params(axis='both', which='major', labelsize=20, length=4, width=2, pad=4, labelcolor='k')
#
# font = FontProperties(size=34)
# plt.legend(a, [u'OBS'], loc='best', ncol=1, prop=font)
# plt.savefig(os.path.join(path_out, 'boxplot_anual_obs_sim_{0}_{1}.png'.format(grad, paramet)), dpi=100)


# # Plot anual cicle climatology obs x model
# fig = plt.figure(figsize=(34, 12))
# dates = np.array([datetime.datetime(2014, i, 9) for i in range(1, 13)])
#
# a = plt.plot(dates, clim_sim, dates, clim_obs)
# plt.fill_between(dates, clim_sim, clim_obs, facecolor='slategray', alpha=0.2, interpolate=True)
# l1, l2 = a
# plt.setp(l1, linewidth=4, markeredgewidth=4, marker='+', color='blue')
# plt.setp(l2, linewidth=4, markeredgewidth=4, marker='+', color='red')
#
# plt.title(u'Climatologia Anual de PrecipitaÃ§Ã£o \n OLAMv.3.3_{0}_{1} x OBS - 1982_2012'
#           .format(grad, paramet.upper()), fontsize=34, fontweight='bold')
# plt.xlabel(u'Meses', fontsize=34, fontweight='bold')
# plt.ylabel(u'PrecipitaÃ§Ã£o (mm/m)', fontsize=34, fontweight='bold')
#
# highest_value = max([max(clim_obs)])
# plt.yticks(np.arange(0, highest_value + 50, highest_value/10))
#
# objects = [u'JAN', u'FEV', u'MAR', u'ABR', u'MAI', u'JUN', u'JUL', u'AGO', u'SET', u'OUT', u'NOV', u'DEZ']
# plt.xticks(dates, objects, fontsize=34)
# plt.tick_params(axis='both', which='major', labelsize=34, length=4, width=2, pad=4, labelcolor='k')
#
# font = FontProperties(size=34)
# plt.legend([u'OLAMv.3.3', u'OBS'], loc='best', ncol=2, prop=font)
# plt.savefig(os.path.join(path_out, 'ciclo_anual_obs_sim_{0}_{1}.png'.format(grad, paramet)), dpi=100)

# # Creating anual mobile media mensal data sim vs. obs
# dates = pd.date_range('1982-01-01', '2012-12-31', freq='M')
# OLAM = pd.Series(year_sim, index=dates)
# OBS = pd.Series(year_obs, index=dates)
# obsolam = pd.DataFrame({'OLAMv.3.3': OLAM, 'OBS': OBS})
# pyplot.figure(figsize=(10, 8))
#
# pyplot.subplot(2, 1, 1)
# obsolam['1982':'2012'].plot(ax=pyplot.gca())
# plt.title(u'AnÃ¡lise das precipitaÃ§Ãµes mÃ©dias mensais \n OLAMv.3.3_{0}_{1} x OBS  - 1982_2012'
#           .format(grad, paramet.upper()), fontsize=18, fontweight='bold')
# plt.xlabel(u'Anos', fontweight='bold')
# plt.ylabel(u'PrecipitaÃ§Ã£o (mm/m)', fontweight='bold')
#
# font = FontProperties(size=10)
# plt.legend([u'OLAMv.3.3', u'OBS'], loc='best', ncol=2, prop=font)
#
# pyplot.subplot(2, 1, 2)
# obsolam.plot(kind='scatter', x='OLAMv.3.3', y='OBS', ax=pyplot.gca())
# plt.xlabel(u'OLAMv.3.3 (mm/m)', fontweight='bold')
# plt.ylabel(u'Observado (mm/m)', fontweight='bold')
# plt.savefig(os.path.join(path_out, 'precip_anual_obs_sim_{0}_{1}.png'.format(grad, paramet)), dpi=100)


# # Olam.3.3 corrected analises
# year_olam_cor = gamma_correction(year_sim, year_obs, year_sim)
#
# dates = pd.date_range('1982-01-01', '2012-12-31', freq='M')
# OLAM = pd.Series(year_olam_cor, index=dates)
# OBS = pd.Series(year_obs, index=dates)
# obsolam = pd.DataFrame({'OLAMv.3.3_cor': OLAM, 'OBS': OBS})
# pyplot.figure(figsize=(12, 8))
#
# pyplot.subplot(2, 1, 1)
# obsolam['1982':'2012'].plot(ax=pyplot.gca())
# plt.title(u'AnÃ¡lise das precipitaÃ§Ãµes mÃ©dias mensais \n OLAMv.3.3_{0}_{1}_cor x OBS  - 1982_2012'
#           .format(grad, paramet.upper()), fontsize=20, fontweight='bold')
# plt.xlabel(u'Anos', fontweight='bold')
# plt.ylabel(u'PrecipitaÃ§Ã£o (mm/m)', fontweight='bold')
#
# font = FontProperties(size=10)
# plt.legend([u'OLAMv.3.3', u'OBS'], loc='best', ncol=2, prop=font)
#
# pyplot.subplot(2, 1, 2)
# obsolam.plot(kind='scatter', x='OLAMv.3.3_cor', y='OBS', ax=pyplot.gca())
# plt.xlabel(u'OLAMv.3.3_cor (mm/m)', fontweight='bold')
# plt.ylabel(u'Observado (mm/m)', fontweight='bold')
# plt.savefig(os.path.join(path_out, 'cor_precip_anual_obs_sim_{0}_{1}.png'.format(grad, paramet)), dpi=100)


# # year 2009
# djf_sim_map = dec_sim + jan_sim + feb_sim
# mam_sim_map = mar_sim + apr_sim + may_sim
# jja_sim_map = jun_sim + jul_sim + aug_sim
# son_sim_map = sep_sim + oct_sim + nov_sim
#
# djf_obs_map = dec_obs + jan_obs + feb_obs
# mam_obs_map = mar_obs + apr_obs + may_obs
# jja_obs_map = jun_obs + jul_obs + aug_obs
# son_obs_map = sep_obs + oct_obs + nov_obs
#
# corr_djf = compute_pearson(djf_sim_map, djf_obs_map)
# corr_mam = compute_pearson(mam_sim_map, mam_obs_map)
# corr_jja = compute_pearson(jja_sim_map, jja_obs_map)
# corr_son = compute_pearson(son_sim_map, son_obs_map)
#
# # Check correl for space maps
# cor = ['#2372c9', '#3498ed', '#4ba7ef', '#76bbf3','#93d3f6', '#b0f0f7', '#ffffff', '#fbe78a', '#ff9d37', '#ff5f26',
#        '#ff2e1b', '#ff0219', '#ae000c']
# lev = [-1., -0.8, -0.6, -0.4, -0.2, 0.2, 0.4, 0.6, 0.8, 1.]
#
# fig = plt.figure(figsize=(12, 8))
# fig_title = u'OLAMv.3.3_{0}_{1} x OBS - SON (1982-2012) \n CorrelaÃ§Ã£o de PrecipitaÃ§Ã£o Acumulada'.format(grad, paramet)
# fig_out = (os.path.join(path_out, 'correl_precip_acum_son_1982_2012_{0}_{1}.png'.format(grad, paramet)))
#
# pm.plotmap(corr_son, lat, lon, fig_title=fig_title, fig_name=fig_out, barcolor=cor, barlevs=lev, barinf='both',
#            barloc='right')
# exit()









