load "$NCARG_ROOT/lib/ncarg/nclscripts/james/trimPNG.ncl"

begin
;*************************
; read in data
;*************************

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; read env variables     ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  snum = getenv("snum")
  conf = getenv("conf")
  yr   = getenv("ys")
  var  = getenv("var")
  obs0 = getenv("obs")
  dirp = getenv("hdir") + "/"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; end of inputs ;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;-- directory
  outp = dirp+"images/"
  system("mkdir -p "+outp)
  snumT  = conf+"-"+snum

  ;-- obs
  obs = str_split(obs0, " ")
  nobs = dimsizes(obs)
  if nobs .gt. 1
	  tstr = "_all"
  else
	  tstr = "_" + obs
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
  if var .eq. "rsnl" then
	  vnam = "Net Surface LW"
	  unit = "W m-2"
  end if

  ;-- plotting
  np=0
  outn   = snum+"_bias_"+tseas+"_"+var+tstr+"_"+yr
  wks = gsn_open_wks("png",outp+outn)
  plot = new(nobs*ds,graphic)

  do ss=s0, sn
    seas = seasons(ss)
    plot2 = new(ds,graphic)

    do oo = 0, nobs - 1
  	this_obs = obs(oo)

  	;; Opening RegCM5
  	filh = dirp+"/"+"plots/"+snum+"_"+var+"_"+yr+"_"+ \
               seas+"_bias_"+this_obs+".nc"
  	a = addfile(filh,"r")
        vdim = dimsizes(a->$var$)
        vddim = dimsizes(vdim)
 ; 	if ( var .eq. "pr" .or. var .eq. "clt" .or. var .eq. "snw" ) then
        if ( vddim.eq.3 ) then     
  	  v := a->$var$(0,:,:)
  	else
  	  v := a->$var$(0,0,:,:)
  	end if
  	xlat := a->lat
  	xlon := a->lon
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
  	res@mpMinLatF = xlat(0)
  	res@mpMinLonF = xlon(0)
  	res@mpMaxLatF = xlat(nlat-1)
  	res@mpMaxLonF = xlon(nlon-1)

  	res@tfDoNDCOverlay         = True      ; do not transform
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
      	res@cnLevels      := (/-8,-6,-4,-2,-1,1,2,4,6,8/) 
  	if ( var.eq."pr" ) then
          res@cnLevels      := (/-8,-6,-4,-2,-.5,.5,2,4,6,8/)
  	  cmap = read_colormap_file("CBR_drywet")
  	  offsetR = -0.0008
  	  offsetL = offsetR
  	  offsetRe = 0.00
  	  offsetLe = 0.013
  	else if ( var.eq."clt" ) then
  	  res@cnLevels := (/-50,-40,-30,-20,-10,10,20,30,40,50/) ; "%"
  	  cmap = read_colormap_file("CBR_drywet")
  	  offsetR = 0.010
  	  offsetL = 0.00
  	  offsetRe = offsetR
  	  offsetLe = offsetR
  	else if ( var.eq."snw" ) then
  	  res@cnLevels := (/-250,-100,-50,-25,-10,10,25,50,100,250/) ; "mm"
  	  cmap = read_colormap_file("CBR_drywet")
  	  offsetR = 0.010
  	  offsetL = 0.00
  	  offsetRe = offsetR
  	  offsetLe = offsetR
  	else if ( var.eq."rsnl" ) then
  	  ;res@cnLevels := (/-250,-100,-50,-25,-10,10,25,50,100,250/) ; "W m-2"
  	  ;res@cnLevels := (/-75,-50,-25,-10,-5,5,10,25,50,75/) ; "W m-2"
  	  res@cnLevels := (/-50,-25,-15,-10,-5,5,10,15,25,50/) ; "W m-2"
  	  cmap = read_colormap_file("CBR_coldhot")
  	  offsetR = 0.010
  	  offsetL = 0.00
  	  offsetRe = offsetR
  	  offsetLe = offsetR
  	else
  	  cmap = read_colormap_file("CBR_coldhot")
  	  offsetR = 0.010
  	  offsetL = 0.00
  	  offsetRe = offsetR
  	  offsetLe = offsetR
  	end if
  	end if
  	end if
  	end if
  	res@cnFillPalette = cmap
  	res@gsnRightString    = seas+" "+var

  	res@gsnLeftStringOrthogonalPosF  = offsetL
  	res@gsnRightStringOrthogonalPosF = offsetR
  	res@gsnLeftString     = conf+"-"+snum+" vs "+this_obs 
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

  gsn_panel(wks,plot,(/ds,nobs/),pres)
  trimPNG(outp+outn+".png")

end
