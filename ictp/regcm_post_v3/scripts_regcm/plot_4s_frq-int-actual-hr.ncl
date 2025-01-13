load "$NCARG_ROOT/lib/ncarg/nclscripts/james/trimPNG.ncl"

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
  indx = getenv("indx")

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
  if indx .eq. "frq" then
          vnam = "Hourly Precipitation frequency"
          unit = "wet hrs/yr"
  end if
  if indx .eq. "int" then
          vnam = "Hourly Precipitation Intensity"
          unit = "mm/yr"
  end if

  ;-- plotting
  np=0
  outn   = snum+"_"+look+"_"+indx+"_1hr_"+tseas+"_"+var+tstr+"_"+yr
  wks = gsn_open_wks("png",outp+outn)
  plot = new(nobs*ds,graphic)

  do ss=s0, sn
    seas = seasons(ss)
    plot2 = new(ds,graphic)

    do oo = 0, nobs - 1
  	this_obs = obs(oo)
        this_res = gobs(oo)

  	;; Opening RegCM5
        if ( look .eq. "model" ) then
          filh = dirp+"/plots/"+snum+"_"+var+"_1hr_"+indx+"_"+yr+"_"+ \
                 seas+".nc"
        end if
        if ( look .eq. "obs" ) then
          filh = diro+var+"_"+indx+"_"+this_obs+"_1hr_"+yr+"_"+ \
                 seas+"_"+snum+"_"+this_res+".nc"
        end if
  	a = addfile(filh,"r")
  	v := a->$var$(0,:,:)
        if ( look.eq."model" ) then
          xlat := a->xlat
          xlon := a->xlon
          v@lat2d = xlat
          v@lon2d = xlon
        else
    	  xlat := a->lat
    	  xlon := a->lon
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
        if ( look.eq."model" ) then
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

  	res@cnLevelSelectionMode   = "ExplicitLevels"
        if ( indx.eq."frq" ) then
                res@cnLevels      := (/20,40,60,80,100,125,150,175,200,250/)
        end if
        if ( indx.eq."int" ) then
                res@cnLevels      := (/50,100,200,300,400,500,600,700,800,900/)
        end if
  	if ( var.eq."pr" ) then
  	  cmap = read_colormap_file("cmocean_tempo")  ;("GSFC_landsat_udf_density")
  	  offsetR = -0.0008
  	  offsetL = offsetR
  	  offsetRe = 0.00
  	  offsetLe = 0.013
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
