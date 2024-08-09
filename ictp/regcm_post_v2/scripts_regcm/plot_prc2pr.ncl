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
  dirp = getenv("hdir") + "/"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; end of inputs ;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;-- directory
  outp = dirp+"images/"
  system("mkdir -p "+outp)
  snumT  = conf+"-"+snum

  ;-- season
  seasons = (/"DJF","MAM","JJA","SON"/)
  tseas = "4s"
  if ( tseas.eq."4s" ) then
    s0 = 0
    sn = 3
    ds = 4
  end if

  ;-- variable, name, unit
  var = "prc"
  vnam = "Convective:Total Precipitation"
  unit = "#"

  ;-- plotting
  np=0
  outn   = snum+"_prc2pr_"+yr+"_"+tseas+"_"+yr
  wks = gsn_open_wks("png",outp+outn)
  plot = new(ds,graphic)

  do ss=s0, sn
    seas = seasons(ss)

    ;; Opening RegCM5
    filh = dirp+"/"+"plots/"+snum+"_prc2pr_"+yr+"_"+seas+"_mean.nc"
    a = addfile(filh,"r")
    v := a->$var$(0,:,:)

    system("ncdump -h "+filh+" | grep lat | grep double | cut -d' ' -f2 | cut -d'(' -f1 > plot.tmp")
    qdim = asciiread("plot.tmp",(/1/),"string")
    system("rm plot.tmp")
    if ( qdim.eq."lat" ) then
      lt = "lat"
      ln = "lon"
    end if
    if ( qdim.eq."xlat" ) then
      lt = "xlat"
      ln = "xlon"
    end if
    xlat := a->$lt$
    xlon := a->$ln$
    dims = dimsizes(xlat)
    nlat = dims(1)
    nlon = dims(0)

    v@lat2d = xlat
    v@lon2d = xlon

    if ( snum .eq. "Australasia" .or. snum .eq. "EastAsia" ) then
      xlon = where(xlon.lt.0,xlon+360,xlon)
    end if

    ;***********************
    ; plot
    ;***********************

    res            = True                    ; plot mods desired
    res@gsnDraw             = False              ; don't draw yet
    res@gsnFrame            = False              ; don't advance frame yet

    res@mpLimitMode       = "Corners"            ; choose range of map
    res@mpLeftCornerLatF  = xlat(0,0)
    res@mpLeftCornerLonF  = xlon(0,0)
    res@mpRightCornerLatF = xlat(nlon-1,nlat-1)
    res@mpRightCornerLonF = xlon(nlon-1,nlat-1)
 
    dlon = 0.
    dlat = 0.
    if ( snum.eq."SouthAsia" ) then
      dlon = -7.
      dlat = -7.5
    else if ( snum.eq."SouthEastAsia" ) then
      dlon = -2.
      dlat = -5.5
    else if ( snum.eq."EastAsia" ) then
      dlon = -1.
      dlat = -4.
    else if ( snum.eq."Australasia" ) then
      dlon = -5.
      dlat = -5.
    else if ( snum.eq."CentralAmerica" ) then
      dlon = 5.5
      dlat = 5.0
    else if ( snum.eq."Europe" ) then
      dlon = 8.25
      dlat = 1.5
    end if
    end if
    end if
    end if
    end if
    end if

    clon = a@longitude_of_projection_origin
    clat = a@latitude_of_projection_origin
    res@mpCenterLonF        = clon+dlon
    res@mpCenterLatF        = clat+dlat

    res@tfDoNDCOverlay         = False     ; do not transform
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

    res@cnLevelSelectionMode   = "ManualLevels"
    res@cnMinLevelValF  = 0.1			; set the minimum contour level
    res@cnMaxLevelValF  = 1.			; set the maximum contour level
    res@cnLevelSpacingF = 0.1			; set the interval between contours
    cmap = read_colormap_file("NCV_jet")
    res@cnFillPalette = cmap
    res@gsnRightString    = seas+" prc/pr"

    offsetR = -0.0008
    offsetL = offsetR
    res@gsnLeftStringOrthogonalPosF  = offsetL
    res@gsnRightStringOrthogonalPosF = offsetR
    res@gsnLeftString     = snam+"_RCM" 
    plot(np) = gsn_csm_contour_map(wks,v,res)
    np=np+1
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

  if ( ds.lt.4 ) then
    gsn_panel(wks,plot,(/1,ds/),pres)
  else
    gsn_panel(wks,plot,(/2,2/),pres)
  end if
  trimPNG(outp+outn+".png")

end
