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
  plev = toint(getenv("plev"))
  dirp = getenv("hdir") + "/"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; end of inputs ;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;-- check plev
  plev_opt = (/100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000/)
  if_plev = ind(plev_opt .eq. plev)
  if ismissing(if_plev)
	  print("plev options: 100, 150, 200, 250, 300, 400, 500, 600, 700, 850, 925, 1000.")
	  return
  end if

  ;-- range
  vmax1 = (/15.0, 15.0, 15.0, 26.0, 30.0, 45.0, 60.0, 75.0, 80.0, 80.0, 75.0, 50/)
  vmin1 = (/1.0, 1.0, 1.0, 2.0, 2.0, 3.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5/)
  vstp1 = vmin1
  vref1 = (/10.0, 10.0, 10.0, 15.0, 20.0, 25.0, 30.0, 45.0, 45.0, 50.0, 45.0, 35/)
  vmax2 = vmax1/2
  vmin2 = vmin1/2
  vstp2 = vstp1/2
  vref2 = vref1/2

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

  ;-- columns
  cname = (/"ERA5", "RegCM5", "RegCM5 - ERA5"/)
  ncol = dimsizes(cname)

  ;***********************
  ; plot
  ;***********************

  res            = True                    ; plot mods desired
  res@gsnDraw             = False              ; don't draw yet
  res@gsnFrame            = False              ; don't advance frame yet

  res@mpLimitMode       = "LatLon"            ; choose range of map

  res@tfDoNDCOverlay         = True      ; do not transform
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

  offsetR = 0.010
  offsetL = 0.00
  offsetRe = offsetR
  offsetLe = offsetR
  res@gsnLeftStringOrthogonalPosF  = offsetL
  res@gsnRightStringOrthogonalPosF = offsetR

  vcres                     = res
  vcres@vcLevelSelectionMode     = "ManualLevels"
  vcres@lbLabelStride       = 2         ; plot every other colar bar label
  vcres@vcRefAnnoOrthogonalPosF = -1.0
  vcres@vcRefLengthF            = 0.050            ; ref vec length
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017            ; thin out vectors

  ;-- plotting
  outn   = snum+"_uv_"+plev+"hPa_"+yr
  wks = gsn_open_wks("png",outp+outn)
  plots1 = new((ncol - 1)*ds,graphic)
  plots2 = new(ds,graphic)

  ;-- loop over seasons
  do ss=s0, sn
    seas = seasons(ss)

	;-- open ERA5 file
	ufname = dirp+"/quv/uwnd_ERA5_"+yr+"_"+seas+"_mean_0.25.nc"
	vfname = dirp+"/quv/vwnd_ERA5_"+yr+"_"+seas+"_mean_0.25.nc"
	uf = addfile(ufname, "r")
	vf = addfile(vfname, "r")
	lev1 = uf->level
	lev_id1 = ind(lev1 .eq. plev)
	uo = uf->ua(0, lev_id1, :, :)
	vo = vf->va(0, lev_id1, :, :)
	wspdo = wind_speed(uo, vo)

	;-- open RegCM5 file
	ufname = dirp+"/quv/ua_RegCM5_"+yr+"_"+seas+"_mean_0.25.nc"
	vfname = dirp+"/quv/va_RegCM5_"+yr+"_"+seas+"_mean_0.25.nc"
	uf = addfile(ufname, "r")
	vf = addfile(vfname, "r")
	lev2 = uf->plev
	lev_id2 = ind(lev2 .eq. plev)
	ur = uf->ua(0, lev_id2, :, :)
	vr = vf->va(0, lev_id2, :, :)
	wspdr = wind_speed(ur, vr)

	;-- calc difference
	ud = ur - uo
	vd = vr - vo
	wspdd = wind_speed(ud, vd)

	;-- lat lon
  	xlat := uf->lat
  	xlon := uf->lon
  	dims = dimsizes(xlat)
  	nlat = dims(0)
  	dims = dimsizes(xlon)
  	nlon = dims(0)

  	if ( snum .eq. "Australasia" .or. snum .eq. "EastAsia" ) then
  	  xlon = where(xlon.lt.0,xlon+360,xlon)
  	end if
	
	;-- more plot settings
    vcres@mpMinLatF = xlat(0)
    vcres@mpMinLonF = xlon(0)
    vcres@mpMaxLatF = xlat(nlat-1)
    vcres@mpMaxLonF = xlon(nlon-1)
  	vcres@gsnRightString    = plev + " hPa Wind " + seas

	;-- plot ERA
  	cmap = read_colormap_file("precip3_16lev") ; wind_17lev
  	vcres@vcLevelPalette = cmap
    vcres@vcMinLevelValF           = vmin1(lev_id2)
    vcres@vcMaxLevelValF           = vmax1(lev_id2)
    vcres@vcLevelSpacingF          = vstp1(lev_id2)
  	vcres@vcRefMagnitudeF         = vref1(lev_id2)              ; make vectors larger
  	vcres@gsnLeftString     = cname(0)
    plots1(ss*(ncol - 1) + 0)=gsn_csm_vector_scalar_map_ce(wks,uo,vo,wspdo,vcres)

	;-- plot RegCM5
  	vcres@gsnLeftString     = cname(1)
    plots1(ss*(ncol - 1) + 1)=gsn_csm_vector_scalar_map_ce(wks,ur,vr,wspdr,vcres)

	;-- plot difference
    vcres@vcMinLevelValF           = vmin2(lev_id2)
    vcres@vcMaxLevelValF           = vmax2(lev_id2)
    vcres@vcLevelSpacingF          = vstp2(lev_id2)
  	vcres@vcRefMagnitudeF         = vref2(lev_id2)              ; make vectors larger
  	vcres@gsnLeftString     = cname(2)
    plots2(ss)=gsn_csm_vector_scalar_map_ce(wks,ud,vd,wspdd,vcres)
  end do

  ;---------------------------------------------
  ; create panel
  ;---------------------------------------------
  pres                      = True
  pres@lbLabelFontHeightF   = 0.01
  pres@lbTitleFontHeightF   = 0.01             ; make title smaller
  pres@lbTitleString    = "m/s"
  pres@lbTitlePosition      = "Right"
  pres@lbTitleDirection = "Across"
  pres@gsnMaximize = True
  pres1                     = pres
  pres2                     = pres
  pres@gsnPanelTop          = 0.97    ; must set to make room for title

  panel_two_sets(wks,plots1,plots2,(/ds,(ncol - 1)/),(/ds,1/),pres1,pres2,pres)
  trimPNG(outp+outn+".png")
end
