loadscript(getenv("scrdir")+"/"+"trimPNG.ncl")

;---------------------------------------------
; Plotting p99
;---------------------------------------------
;
;This section is where you control certain inputs such as the domain name, experiment name, year 
;as well as the input and output directories

  snum = getenv("snum")
  conf = getenv("conf")
  yr   = getenv("ys")
  hdir = getenv("hdir") + "/"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; end of inputs ;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  snumT  = conf+"-"+snum
  dirp = hdir+"plots/"
  outp = hdir+"images/"

  snumT  = conf+"-"+snum
  if ( snum.eq."Europe" .or. snum.eq."Europe03" .or. snum.eq."WMediterranean" ) then
    obs = "EOBS"
    ;obs = "EUR-HiRes"
  else
    obs = "CPC"
  end if

  ln="lon"
  lt="lat"
  r4 = "off"
  if ( snum.eq."WMediterranean" .or. snum.eq."Europe" ) then
    r4 = "off"
    ln = "xlon"
    lt = "xlat"
  end if
  if ( snumT.eq."MPI-Europe" .or. snumT.eq."ERA5-Europe" ) then
    r4 = "off"
  end if

;---Read in netCDF file MODELS
  regcm5in = addfile(dirp+"regrid_p99_"+snumT+"_"+yr+".nc","r")
  if ( r4.eq."on" ) then
    regcm4in = addfile(dirp+"regrid_p99_RegCM4_"+snum+"_"+yr+".nc","r")
  end if
  obsin    = addfile(dirp+"regrid_p99_"+obs+"_"+yr+".nc","r")

;---Read in observed data
  p99_obs = obsin->pr(:,:,:)
;---------------------------------------------
; Read in REGCM5
;---------------------------------------------
  p99_rgcm5 = regcm5in->pr(:,:,:)
  lon = regcm5in->$ln$
  lat = regcm5in->$lt$
  if ( ln.eq."xlon" ) then
    dims = dimsizes(lat)
    nlat = dims(1)
    nlon = dims(0)
  else
    nlon = dimsizes(lon)
    nlat = dimsizes(lat)
  end if
;---------------------------------------------
; Read in REGCM4
;---------------------------------------------
  if ( r4.eq."off" ) then
    p99_rgcm5@_FillValue = -9999.
    p99_rgcm4=p99_rgcm5@_FillValue
  else
    p99_rgcm4=regcm4in->pr(:,:,:)
  end if
;--------------------------------------------
  diffpr_rgcm5 = p99_rgcm5 - p99_obs
  if ( r4.eq."off" ) then
    diffpr_rgcm4 = p99_rgcm5@_FillValue
  else
    diffpr_rgcm4 = p99_rgcm4 - p99_obs
  end if
;---------------------------------------------
; start graphics
;---------------------------------------------
  system("mkdir -p "+outp)
  outn = snumT+"_P99_"+yr
  wks = gsn_open_wks("png",outp+outn)
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
  plot = new(5,graphic)

  res            = True                    ; plot mods desire
  res@gsnDraw             = False          ; don't draw yet
  res@gsnFrame            = False          ; don't advance frame yet
  
  res@mpLimitMode       = "LatLon"         ; choose range of map
  if ( ln.eq."xlon" ) then
    p99_obs@lat2d = lat
    p99_obs@lon2d = lon
    p99_rgcm5@lat2d = lat
    p99_rgcm5@lon2d = lon
    diffpr_rgcm5@lat2d = lat
    diffpr_rgcm5@lon2d = lon
    res@mpLimitMode       = "LatLon"           ; choose range of map
    res@mpMaxLatF = max(lat)
    res@mpMinLatF = min(lat)
    res@mpMaxLonF = max(lon)
    res@mpMinLonF = min(lon)    
;   res@mpLeftCornerLatF  = lat(0,0)
;   res@mpLeftCornerLonF  = lon(0,0)
;   res@mpRightCornerLatF = lat(nlon-1,nlat-1)
;   res@mpRightCornerLonF = lon(nlon-1,nlat-1)
    res@tfDoNDCOverlay      = False
  else
    res@mpMinLatF = lat(0)
    res@mpMinLonF = lon(0)
    res@mpMaxLatF = lat(nlat-1)
    res@mpMaxLonF = lon(nlon-1)
    res@tfDoNDCOverlay      = True
  end if

  res@cnFillOn            = True               ; turn on color   
  res@cnLinesOn           = False              ; no contour lines
  res@cnLineLabelsOn      = False              ; no line labels
  res@mpFillOn               = False

  res@mpGeophysicalLineColor = "black"   ; color of continental outlines
  res@mpPerimOn              = True      ; draw box around map
  res@mpGridLineDashPattern  = 5         ; lat/lon lines as dashed

  res@gsnAddCyclic           = False     ; regional data don't add

  res@pmTickMarkDisplayMode  = "Always"  ;
  res@mpGridAndLimbOn        = False     ; turn on grid lines

  res@mpDataBaseVersion    = "MediumRes"

  res@lbOrientation =   "vertical"
  res@lbLabelFontHeightF   = 0.01
  res@lbTitleFontHeightF   = 0.02        ; make title smaller
  ;res@lbTitleString    = "~S~o~N~C"
  res@lbTitleString    = "mm/day"
  res@lbTitlePosition      = "Top"
  res@tmYROn = False            ; Turn off right tickmarks.
  res@tmXTOn = False            ; Turn off top tickmarks.

  res@cnLevelSelectionMode   = "ExplicitLevels"
  res@cnLevels               = (/1,2,3,4,5,10,20,30,40,50,60,70,80,90/) ; "mm/day"

 
  res@gsnRightString  = "daily P99"
  res@gsnLeftString   = "CPC"
  plot(0) = gsn_csm_contour_map(wks,p99_obs(0,:,:),res)  ; create the plot

  res@gsnLeftString   = "REGCM5 ERA"
  plot(1) = gsn_csm_contour_map(wks,p99_rgcm5(0,:,:),res)  ; create the plot
  
  res@gsnLeftString   = "REGCM4 ERA"
  if ( r4.eq."on" ) then
    plot(2) = gsn_csm_contour_map(wks,p99_rgcm4(0,:,:),res)  ; create the plot
  end if

  res@cnFillPalette       = "MPL_BrBG"      ; set color map
  res@cnLevelSelectionMode   = "ExplicitLevels"
  res@gsnLeftString   = conf+"-"+snum+" vs "+obs
  res@cnLevels       := (/-50,-40,-30,-20,-10,-5,5,10,20,30,40,50/)
  plot(3) = gsn_csm_contour_map(wks,diffpr_rgcm5(0,:,:),res)  ; create the plot


  res@cnFillPalette       = "MPL_BrBG"      ; set color map
  res@cnLevelSelectionMode   = "ExplicitLevels"
  res@cnLevels        := (/-50,-40,-30,-20,-10,-5,5,10,20,30,40,50/)
  res@gsnLeftString   = conf+"-"+snum+" vs "+obs
  if ( r4.eq."on" ) then
    plot(4) = gsn_csm_contour_map(wks,diffpr_rgcm4(0,:,:),res)  ; create the plot
  end if

;---------------------------------------------
; create panel
;---------------------------------------------

  pres             = True
  pres@gsnMaximize = True 
  gsn_panel(wks,plot(3:4),(/2,1/),pres)

  trimPNG(outp+outn+".png")
