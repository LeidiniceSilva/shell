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
  indx = getenv("indx")
  th = "0.1"

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
  if indx .eq. "frq" then
	  vnam = "Hourly Precipitation frequency"
	  unit = "%"
  end if
  if indx .eq. "int" then
	  vnam = "Hourly Precipitation Intensity"
          unit = "mm/hr"
  end if

  ;-- plotting
  np=0
  outn   = snum+"_bias_"+tseas+"_pr-"+indx+tstr+"_1hr_"+yr+"_th"+th
  wks = gsn_open_wks("png",outp+outn)
  plot = new(nobs*ds,graphic)

  do ss=s0, sn
    seas = seasons(ss)
    plot2 = new(ds,graphic)

    do oo = 0, nobs - 1
  	this_obs = obs(oo)

  	;; Opening RegCM5
  	filh = dirp+"/"+"plots/"+snum+"_"+var+"_1hr_"+indx+"_"+yr+"_"+ \
               seas+"_bias_"+this_obs+"_th"+th+".nc"
  	a = addfile(filh,"r")
  	v := a->$var$(0,0,:,:)
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
        if ( indx.eq."frq" ) then
           res@cnLevels      := (/-25,-20,-15,-10,-5,-1,1,5,10,15,20,25./)
        end if
        if ( indx.eq."int" ) then
           res@cnLevels      := (/-1,-.8,-.6,-.4,-.2,-.1,.1,.2,.4,.6,.8,1/)
        end if
  	if ( var.eq."pr" ) then
  	  cmap = read_colormap_file("NEO_div_vegetation_c")
  	  offsetR = -0.0008
  	  offsetL = offsetR
  	  offsetRe = 0.00
  	  offsetLe = 0.013
  	end if
  	res@cnFillPalette = cmap
  	res@gsnRightString    = seas+" hourly "+var+" ("+indx+", th"+th+")"

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
