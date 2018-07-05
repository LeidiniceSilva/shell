#!/bin/bash

#__author__      = 'Leidinice Silva'
#__email__       = 'leidinicesilva@gmail.br'
#__date__        = '07/03/18'
#__description__ = 'Creating an Image Frame with ImageMagick'
 

cd /vol3/nice/results

for MON in jan feb mar apr may jun jul aug sep oct nov dec; do

        echo "Data: Precipitation - ${MON}"

	convert \( pre_amz_neb_regcm46_exp1_${MON}_2001_2005_clim.jpeg pre_amz_neb_regcm46_exp2_${MON}_2001_2005_clim.jpeg pre_amz_neb_cmap_obs_${MON}_2001_2005_clim.jpeg +append \) -background white -append "pre_${MON}_clim_regcm_exp_obs.jpeg"
	
        echo "Data: Temperature 2m -${MON}"

	convert \( t2m_amz_neb_regcm46_exp1_${MON}_2001_2005_clim.jpeg t2m_amz_neb_regcm46_exp2_${MON}_2001_2005_clim.jpeg t2m_amz_neb_ncep_ncar_rea_${MON}_2001_2005_clim.jpeg +append \) -background white -append "t2m_${MON}_clim_regcm_exp_obs.jpeg"

done	




