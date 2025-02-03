load "$NCARG_ROOT/lib/ncarg/nclscripts/james/trimPNG.ncl"
loadscript(getenv("scrdir")+"/"+"panel_two_sets.ncl")

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
  ; u
  u_lev = (/ \
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 1000 hPa
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 925
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 850
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 700
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 600
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 500
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 400
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 300
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 250
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 200
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 150
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /)\ ; 100
  	/)
  ; v
  v_lev = (/ \
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 1000 hPa
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 925
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 850
	(/-10,-5,-3,-2,-1,1,2,3,5,10 /), \ ; 700
	(/-12,-6,-3,-2,-1,1,2,3,6,12 /), \ ; 600
	(/-15,-10,-5,-2,-1,1,2,5,10,15 /), \ ; 500
	(/-20,-15,-10,-5,-1,1,5,10,15,20 /), \ ; 400
	(/-25,-15,-10,-5,-1,1,5,10,15,20 /), \ ; 300
	(/-25,-15,-10,-5,-1,1,5,10,15,25 /), \ ; 250
	(/-25,-15,-10,-5,-1,1,5,10,15,20 /), \ ; 200
	(/-25,-15,-10,-5,-1,1,5,10,15,25 /), \ ; 150
	(/-15,-10,-5,-2,-1,1,2,5,10,15 /)\ ; 100
  	/)
  ; q
  qmax = (/8, 8, 8, 5, 2.5, 1, 1, 0.4, 0.15, 0.05, 0.01, 0.001/)
  qstp = (/2, 2, 2, 1, 0.5, 0.2, 0.2, 0.1, 0.03, 0.01, 0.002, 0.0002/)
; if ( snum.eq."Europe" .or. snum.eq."Medi3" .or. snum.eq."SEEurope" .or. snum.eq."Medi" .or. snum.eq."Mediterranean" ) then
;   qmax = qmax/4.
;   qstp = qstp/4.
; end if

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
  vname = (/"ua", "va", "hus"/)
  ncol = dimsizes(vname)

  ;-- plotting
  outn   = snum+"_quv_bias_"+plev+"hPa_"+yr
  wks = gsn_open_wks("png",outp+outn)
  plot = new(ncol*ds,graphic)

  ;-- loop over seasons
  np = 0
  do ss=s0, sn
    seas = seasons(ss)

	;-- loop through variables
	do i = 0, dimsizes(vname) - 1
		var = vname(i)

		;-- variable, name, unit
		if var .eq. "ua" then
		    vnam = "Zonal Wind"
			onam = "uwnd"
		    unit = "m/s"
		end if
		if var .eq. "va" then
		    vnam = "Meridional Wind"
			onam = "vwnd"
		    unit = "m/s"
		end if
		if var .eq. "hus" then
		    vnam = "Specific Humidity"
			onam = "qhum"
		    unit = "kg/kg"
		end if

		;-- open ERA5 file
		ofname = dirp+"/quv/" + onam + "_ERA5_"+yr+"_"+seas+"_mean_0.25.nc"
		of = addfile(ofname, "r")
		lev1 = of->level
		lev_id1 = ind(lev1 .eq. plev)
		vo = of->$var$(0, lev_id1, :, :)

		;-- open RegCM5 file
		rfname = dirp+"/quv/" + var + "_RegCM5_"+yr+"_"+seas+"_mean_0.25.nc"
		rf = addfile(rfname, "r")
		lev2 = rf->plev
		lev_id2 = ind(lev2 .eq. plev)
		vr = rf->$var$(0, lev_id2, :, :)

		;-- calc difference
		vd = vr - vo

		;-- lat lon
		xlat := of->lat
		xlon := of->lon
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

		if np .ge. 9
			res@lbLabelBarOn        = True
		    res@lbLabelFontHeightF   = 0.02
		    res@lbTitleFontHeightF   = 0.02
		    res@lbTitlePosition      = "Right"
		    res@lbTitleDirection = "Across"
			res@lbBoxMinorExtentF = 0.2
		else
			res@lbLabelBarOn        = False
		end if
		res@tmYROn = False            ; Turn off right tickmarks.
		res@tmXTOn = False            ; Turn off top tickmarks.
		res@tmYLOn = False
		res@tmXBOn = False

		if var .eq. "ua" then
		  res@cnLevelSelectionMode   = "ExplicitLevels"
		  ; res@cnLevels      := (/-8,-6,-4,-2,-1,1,2,4,6,8/) ; "m/s"
		  res@cnLevels := rm_single_dims(u_lev(lev_id2, :))
		  cmap = read_colormap_file("CBR_coldhot")
		  res@lbTitleString = "m/s"
		end if

		if var .eq. "va" then
		  res@cnLevelSelectionMode   = "ExplicitLevels"
		  ; res@cnLevels      := (/-8,-6,-4,-2,-1,1,2,4,6,8/) ; "m/s"
		  res@cnLevels := rm_single_dims(v_lev(lev_id2, :))
		  cmap = read_colormap_file("CBR_coldhot")
		  res@lbTitleString = "m/s"
		end if

		if var .eq. "hus" then
		  vd = vd*1000
		  ; res@cnLevelSelectionMode   = "ExplicitLevels"
		  ; res@cnLevels := (/-8,-5,-3,-2,-1,1,2,3,5,8/) ; "1000 kg/kg"
		  res@cnLevelSelectionMode = "ManualLevels"
		  res@cnMinLevelValF  = -qmax(lev_id2)
		  res@cnMaxLevelValF  = qmax(lev_id2)
		  res@cnLevelSpacingF = qstp(lev_id2)
		  cmap = read_colormap_file("CBR_drywet")
		  res@lbTitleString = "1e-3 kg/kg"
		end if

		offsetR = 0.010
		offsetL = 0.00
		offsetRe = offsetR
		offsetLe = offsetR
		res@cnFillPalette = cmap
		res@gsnRightString    = plev + " hPa " + vname(i) + " " + seas

		res@gsnLeftStringOrthogonalPosF  = offsetL
		res@gsnRightStringOrthogonalPosF = offsetR
		res@gsnLeftString     = snam+"_RCM - ERA5" 
		plot(np) = gsn_csm_contour_map(wks,vd,res)
		np=np+1
	end do
  end do

  ;---------------------------------------------
  ; create panel
  ;---------------------------------------------
  pres                      = True
  pres@gsnPanelLabelBar = False
  pres@gsnMaximize = True
  pres@gsnPanelBottom = 0.08

  gsn_panel(wks, plot, (/ds,ncol/), pres)
  trimPNG(outp+outn+".png")
end
