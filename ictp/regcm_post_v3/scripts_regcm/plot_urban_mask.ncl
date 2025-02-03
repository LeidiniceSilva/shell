loadscript(getenv("scrdir")+"/"+"trimPNG.ncl")

;---------------------------------------------
; Plotting p99
;---------------------------------------------
;
;This section is where you control certain inputs such as the domain name, experiment name, year 
;as well as the input and output directories

begin

  fname = getenv("f")
  snum = getenv("snum")
;  conf = getenv("conf")
;  yr   = getenv("ys")
  hdir = getenv("hdir") + "/"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; end of inputs ;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  dirp = hdir+"plots/"
  outp = hdir+"images/"

  ln = "xlon"
  lt = "xlat"

  ;-- read CLM45 surface file
  f = addfile(fname, "r")
  urb_2d = f->urb_2d

  ;-- sum
  urb_frac = dim_sum_n_Wrap(urb_2d, 0)

  ;--
  lat = f->$lt$
  lon = f->$ln$
  dims = dimsizes(lat)
  nlat = dims(1)
  nlon = dims(0)

  if ( snum .eq. "Australasia" .or. snum .eq. "EastAsia" ) then
    lon = where(lon.lt.0,lon+360,lon)
  end if

  ;-- check resolution
  rr = abs(lat(20, 20) - lat(20, 21))
  rr_12_diff = abs(rr - 0.11)
  rr_25_diff = abs(rr - 0.22)

  ;-- create urban mask
  if rr_12_diff .lt. rr_25_diff
	  print("12 km resolution")
	  this_frac = 40
  else
	  print("25 km resolution")
	  this_frac = 10
  end if
  urb_mask = where(urb_frac.gt.this_frac, 1, 0)
  urb_mask = where(ismissing(urb_frac), urb_mask@_FillValue, urb_mask)
  copy_VarMeta(urb_frac, urb_mask)
  ;printMinMax(urb_frac, 0)
  ;printMinMax(urb_mask, 0)

;---------------------------------------------
; start graphics
;---------------------------------------------
  system("mkdir -p "+outp)
  outn = "Urban_mask"
  wks = gsn_open_wks("png",outp+outn)
  ;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
  gsn_define_colormap(wks,"precip3_16lev")
  plot = new(2,graphic)

  res            = True                    ; plot mods desire
  res@gsnDraw             = False          ; don't draw yet
  res@gsnFrame            = False          ; don't advance frame yet
  
  urb_frac@lat2d = lat
  urb_frac@lon2d = lon
  urb_mask@lat2d = lat
  urb_mask@lon2d = lon
  res@mpLimitMode       = "LatLon"           ; choose range of map
  res@mpMaxLatF = max(lat)
  res@mpMinLatF = min(lat)
  res@mpMaxLonF = max(lon)
  res@mpMinLonF = min(lon)    
; res@mpLeftCornerLatF  = lat(0,0)
; res@mpLeftCornerLonF  = lon(0,0)
; res@mpRightCornerLatF = lat(nlon-1,nlat-1)
; res@mpRightCornerLonF = lon(nlon-1,nlat-1)
  res@tfDoNDCOverlay      = False

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
  ;res@lbTitleString    = "mm/day"
  res@lbTitleString    = "%"
  res@lbTitlePosition      = "Top"
  res@tmYROn = False            ; Turn off right tickmarks.
  res@tmXTOn = False            ; Turn off top tickmarks.

  res@cnLevelSelectionMode   = "ExplicitLevels"
  ;res@cnLevels               = (/1,2,3,4,5,10,20,30,40,50,60,70,80,90/) ; "mm/day"
  ;res@cnLevels               = (/0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0/) ; frac
  res@cnLevels               = (/0,10,20,30,40,50,60,70,80,90,100/) ; %
 
  res@gsnRightString  = "Urban fraction"
  res@gsnLeftString   = ""
  plot(0) = gsn_csm_contour_map(wks,urb_frac,res)  ; create the plot

  res@cnLevels               := (/0.5/) ; %
  res@lbTitleString    = ""
;  res@cnLevelSelectionMode   = "ManualLevels"
;  res@cnMinLevelValF  = 0.			; set the minimum contour level
;  res@cnMaxLevelValF  = 1.			; set the maximum contour level
;  res@cnLevelSpacingF = 0.5 		; set the interval between contours
  res@gsnRightString  = "Urban mask"
  res@gsnLeftString   = "frac > " + this_frac
  plot(1) = gsn_csm_contour_map(wks,urb_mask,res)  ; create the plot
  
;---------------------------------------------
; create panel
;---------------------------------------------

  pres             = True
  pres@gsnMaximize = True 
  gsn_panel(wks,plot,(/2,1/),pres)

  trimPNG(outp+outn+".png")
end
