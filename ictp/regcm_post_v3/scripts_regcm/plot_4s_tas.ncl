loadscript(getenv("scrdir")+"/"+"trimPNG.ncl")

begin
;*************************
; read in data
;*************************

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; read env variables     ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  snam = "ERA5"
  snum = getenv("snum")
  conf = getenv("conf")
  yr   = getenv("ys")
  var  = getenv("var")
  obs0 = getenv("obs")
  obsg = getenv("res")
  dirp = getenv("hdir") + "/"
  diro = getenv("rdir") + "/obs/" 

  look = getenv("look")    

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; end of inputs ;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;-- directory
  outp = dirp+"images/"
  system("mkdir -p "+outp)
  snumT  = conf+"-"+snum

  ;-- obs
  obs = str_split(obs0, " ")
  gobs = str_split(obsg, " ")
  nobs = dimsizes(obs)
  if nobs .gt. 1
	  tstr = "_all"
  else
	  tstr = "_" + obs
  end if
  if ( look.eq."model" ) then
    nobs = 1
  end if
  
  ;-- season
  seasons = (/"DJF","MAM","JJA","SON"/)
  tseas = "4s"
  if ( tseas.eq."4s" ) then
    s0 = 0
    sn = 3
    ds = 4
  end if

  ;-- variable, name, unit
  if var .eq. "pr" then
	  vnam = "Precipitation"
	  unit = "mm/day"
  end if
  if var .eq. "tas" then
	  vnam = "Temperature"
	  unit = "~F34~0~F~C"
  end if
  if var .eq. "tasmax" then
	  vnam = "Maximum T."
	  unit = "~F34~0~F~C"
  end if
  if var .eq. "tasmin" then
	  vnam = "Minimum T."
	  unit = "~F34~0~F~C"
  end if
  if var .eq. "clt" then
	  vnam = "T.Cloud Fr."
	  unit = "%"
  end if
  if var .eq. "snw" then
	  vnam = "Surface LWE Snow"
	  unit = "mm"
  end if

  ;-- plotting
  np=0
  outn   = snum+"_model_mean_"+tseas+"_"+var+tstr+"_"+yr
  wks = gsn_open_wks("png",outp+outn)
  plot = new(nobs*ds,graphic)

  ; calc colorbar range
  v_max0 = new(ds, "float")
  v_min0 = new(ds, "float")
  do ss=s0, sn
    seas = seasons(ss)
	filh = dirp+"/"+"plots/"+var+"_RegCM_"+yr+"_"+ seas+"_mean.nc"
	a = addfile(filh,"r")
	if ( var .eq. "pr" .or. var .eq. "clt" .or. var .eq. "snw" ) then
	  v := a->$var$(0,:,:)
	else
	  v := a->$var$(0,0,:,:)
	end if
	opt   = False
	stata = stat_dispersion(v, opt)
	v_max0(ss) = stata(27)
	v_min0(ss) = stata(22)
  end do
  print(v_max0+", "+v_min0)
  v_max = round(max(v_max0), 0)
  v_min = round(min(v_min0), 0)

  ;-- plot
  do ss=s0, sn
    seas = seasons(ss)
    plot2 = new(ds,graphic)

    do oo = 0, nobs - 1
		this_obs = obs(oo)
        this_res = gobs(oo)

		;; Opening RegCM5
		; tas_RegCM_2000-2001_DJF_mean.nc
		if ( look .eq. "model" ) then
			filh = dirp+"/"+"plots/"+var+"_RegCM_"+yr+"_"+ seas+"_mean.nc"
		end if
		if ( look .eq. "obs" ) then
		  if ( this_obs .eq. "HIRES" ) then
			res_dec := str_split(this_res,".")
			res_dec := res_dec(1)
			obdir = "/marconi_work/ICT23_ESP/jciarlo0/obs/eur-hires/"
			dnam = snum
			if ( snum.eq."Europe" ) then
			  dnam = "EUR"
			end if
			if ( snum.eq."WMediterranean" ) then
			  dnam = "Medi3"
			end if 
			filh = obdir+var+"_mean_"+seas+"_EUR-HiRes_day_"+dnam+res_dec+"grid.nc"
		  else
			obdir = diro
			filh = obdir+var+"_"+this_obs+"_"+yr+"_"+seas+"_mean_"+snum+"_"+this_res+".nc"
		  end if
		end if
		a = addfile(filh,"r")
		if ( var .eq. "pr" .or. var .eq. "clt" .or. var .eq. "snw" ) then
		  v := a->$var$(0,:,:)
		else
		  v := a->$var$(0,0,:,:)
		end if
		if ( look .eq. "obs" .and. this_obs .eq. "HIRES" ) then
		  xlat := a->xlat
		  xlon := a->xlon
		  v@lat2d = xlat
		  v@lon2d = xlon
		else if ( look .eq. "model" ) then
		  xlat := a->xlat
		  xlon := a->xlon
		  v@lat2d = xlat
		  v@lon2d = xlon
		else
		  xlat := a->lat
		  xlon := a->lon
		end if
		end if
		dims = dimsizes(xlat)
		nlat = dims(0)
		dims = dimsizes(xlon)
		nlon = dims(0)

		if ( snum .eq. "Australasia" .or. snum .eq. "EastAsia" ) then
		  xlon = where(xlon.lt.0,xlon+360,xlon)
		end if

		;***********************
		; plot
		;***********************

		res            = True                    ; plot mods desired
		res@gsnDraw             = False              ; don't draw yet
		res@gsnFrame            = False              ; don't advance frame yet

		res@mpLimitMode       = "LatLon"            ; choose range of map
		if ( look .eq. "obs" .and. this_obs .eq. "HIRES" ) then
		  res@mpMinLatF = min(xlat)
		  res@mpMinLonF = min(xlon)
		  res@mpMaxLatF = max(xlat)
		  res@mpMaxLonF = max(xlon)
		  res@tfDoNDCOverlay         = False     ; do not transform
		else if ( look .eq. "model" ) then
		  res@mpMinLatF = min(xlat)
		  res@mpMinLonF = min(xlon)
		  res@mpMaxLatF = max(xlat)
		  res@mpMaxLonF = max(xlon)
		  res@tfDoNDCOverlay         = False     ; do not transform
		else
		  res@mpMinLatF = xlat(0)
		  res@mpMinLonF = xlon(0)
		  res@mpMaxLatF = xlat(nlat-1)
		  res@mpMaxLonF = xlon(nlon-1)
		  res@tfDoNDCOverlay         = True      ; do not transform
		end if 
		end if 

		res@cnFillOn               = True      ; color plot desired
		res@cnLinesOn              = False       ; no contour lines
		res@cnLineLabelsOn         = False
		res@mpFillOn               = False

		res@mpGeophysicalLineColor = "black"     ; color of continental outlines
		res@mpPerimOn              = True      ; draw box around map
		res@mpGridLineDashPattern  = 5         ; lat/lon lines as dashed

		res@gsnAddCyclic           = False     ; regional data don't add

		res@pmTickMarkDisplayMode  = "Always"  ;
		res@mpGridAndLimbOn        = False               ; turn on grid lines

		res@lbLabelBarOn        = False
		res@tmYROn = False            ; Turn off right tickmarks.
		res@tmXTOn = False            ; Turn off top tickmarks.
		res@tmYLOn = False
		res@tmXBOn = False

		res@cnLevelSelectionMode = "ManualLevels"
		res@cnMinLevelValF  = v_min
		res@cnMaxLevelValF  = v_max
		res@cnLevelSpacingF = 2.
		cmap = read_colormap_file("GMT_seis")
		cmap = cmap(::-1, :)
		;res@cnLevelSelectionMode   = "ExplicitLevels"
		;res@cnLevels      := (/.5,1,2,4,6,8,10,12,14,16,18/)  
		if ( var.eq."pr" ) then
		  ;cmap = read_colormap_file("cmocean_tempo")  ;("GSFC_landsat_udf_density")
		  offsetR = -0.0008
		  offsetL = offsetR
		  offsetRe = 0.00
		  offsetLe = 0.013
		else if ( var.eq."clt" ) then
		  ;res@cnLevels := (/-50,-40,-30,-20,-10,10,20,30,40,50/) ; "%"
		  ;cmap = read_colormap_file("CBR_drywet")
		  offsetR = 0.010
		  offsetL = 0.00
		  offsetRe = offsetR
		  offsetLe = offsetR
		else if ( var.eq."snw" ) then
		  ;res@cnLevels := (/-250,-100,-50,-25,-10,10,25,50,100,250/) ; "mm"
		  ;cmap = read_colormap_file("CBR_drywet")
		  offsetR = 0.010
		  offsetL = 0.00
		  offsetRe = offsetR
		  offsetLe = offsetR
		else
		  ;cmap = read_colormap_file("CBR_coldhot")
		  offsetR = 0.010
		  offsetL = 0.00
		  offsetRe = offsetR
		  offsetLe = offsetR
		end if
		end if
		end if
		res@cnFillPalette = cmap
		res@gsnRightString    = seas+" "+var

		res@gsnLeftStringOrthogonalPosF  = offsetL
		res@gsnRightStringOrthogonalPosF = offsetR
			if ( look.eq."obs" ) then
			  res@gsnLeftString     = this_obs 
			end if
			if ( look.eq."model" ) then
			  res@gsnLeftString     = snam+"_RCM"
			end if
		plot(np) = gsn_csm_contour_map(wks,v,res)
		np=np+1
    end do
  end do

  ;---------------------------------------------
  ; create panel
  ;---------------------------------------------
  pres                  = True
  pres@gsnPanelLabelBar = True
  pres@lbOrientation =   "vertical"
  pres@lbLabelFontHeightF   = 0.01
  pres@lbTitleFontHeightF   = 0.01             ; make title smaller
  pres@lbTitleString    = unit
  pres@lbTitlePosition      = "Top"
  pres@gsnMaximize = True
  pres@gsnPanelRight  = 0.97
  pres@gsnScale = True

  if ( look.eq."model" ) then
    gsn_panel(wks,plot,(/ds,1/),pres)
  else
    gsn_panel(wks,plot,(/ds,nobs/),pres)
  end if
  trimPNG(outp+outn+".png")

end
