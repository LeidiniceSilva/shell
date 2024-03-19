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
  var  = "pr" 
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
	  unit = "%"
  end if

  ;-- plotting
  np=0
  outn   = snum+"_bias_"+tseas+"_"+var+"pct"+tstr+"_"+yr
  wks = gsn_open_wks("png",outp+outn)
  plot = new(nobs*ds,graphic)

  do ss=s0, sn
    seas = seasons(ss)
    plot2 = new(ds,graphic)

    do oo = 0, nobs - 1
  	this_obs = obs(oo)

  	;; Opening RegCM5
  	filh = dirp+"/"+"plots/"+snum+"_"+var+"pct_"+yr+"_"+ \
               seas+"_bias_"+this_obs+".nc"
  	a = addfile(filh,"r")
  	v := a->$var$(0,:,:)
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
      	res@cnLevels      := (/-100,-80,-60,-40,-20,-10,10,20,40,60,80,100/) ; "%"
  	cmap = read_colormap_file("MPL_BrBG")
  	offsetR = -0.0008
  	offsetL = offsetR
  	offsetRe = 0.00
  	offsetLe = 0.013
  	res@cnFillPalette = cmap
  	res@gsnRightString    = seas+" "+var

  	res@gsnLeftStringOrthogonalPosF  = offsetL
  	res@gsnRightStringOrthogonalPosF = offsetR
  	res@gsnLeftString     = snam+"_RCM - "+this_obs 
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
