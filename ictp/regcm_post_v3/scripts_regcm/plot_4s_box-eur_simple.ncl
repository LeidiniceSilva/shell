load "trimPNG.ncl"

begin
;*************************
; read in data
;*************************

  tseas = "4s"
  if ( tseas.eq."4s" ) then
    s0 = 0
    sn = 3
    ds = 4
  end if
  ncol = 1

  conf = "NoTo"
  ;snum   = "Africa"
  ;snum   = "Australasia"
  ;snum   = "CentralAmerica"
  ;snum   = "EastAsia"
  snum   = "Europe"
  ;snum   = "NorthAmerica"
  ;snum   = "SouthAmerica"
  ;snum   = "SouthAsia"
  ;snum   = "SouthEastAsia"
  snam   = "ERA5"

  snamT  = conf+"-"+snum
  vars   = (/"pr","tas","tasmax","tasmin","clt"/)
  vnames = (/"Precipitation","Temperature","Maximum T.","Minimum T.","T.Cloud Fr."/)
  ulist  = (/"mm/day","~F34~0~F~C","~F34~0~F~C","~F34~0~F~C","%"/)

  yr     = "2000-2001"
  seasons = (/"DJF","MAM","JJA","SON"/)

  dirp = "/marconi_scratch/userexternal/jciarlo0/ERA5/"+snamT+"/"
  outp = dirp+"images/"
  system("mkdir -p "+outp)

  plot = new((ncol)*ds,graphic)

  do ii=0, 4
    np=0
    var = vars(ii)
    outn   = snum+"_bias_"+tseas+"_"+var
    wks = gsn_open_wks("png",outp+outn)

    do ss=s0, sn
      seas = seasons(ss)
      vnam = vnames(ii)
      unit = ulist(ii)

      ;; Opening RegCM5
      filh = dirp+"/"+"plots/"+snum+"_"+var+"_"+yr+"_"+seas+"_bias.nc"
      a = addfile(filh,"r")
      if ( var .eq. "pr" .or. var .eq. "clt" ) then
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

      ; find lon of bot-left corner
      i=0
      j=0
      do while(i.le.nlon-1)
        if ( .not.ismissing(v(j,i)) ) then  
          res@mpMinLonF = xlon(i)
          bl = i
          i = nlon
        else
          i=i+1
          if (i.eq.nlon-1) then
            i=0
            j=j+1
          end if
        end if
      end do

      ; find lon of bot-right corner
      i=0+(nlon/2) 
      j=0
      do while(i.le.nlon-1)
        if ( .not.ismissing(v(j,i)) ) then
          res@mpMaxLonF = xlon(i)
          br = i
          i = nlon
        else
          i=i+1
          if ( i.eq.nlon-1 ) then
            i=0+(nlon/2)
            j=j+1
          end if
        end if
      end do

      ; find max lat of bot curve
      i=bl
      j=0
      k=0 ; look for largest value
      do while (j.le.nlat-1)
        if (.not.ismissing(v(j,i))) then
          k1 = j
          if (k1.ge.k) then
            k = k1
            i = i+1
            j = 0
          else
            res@mpMinLatF = xlat(k)
            j = nlat
          end if
        else
          j = j+1
        end if
      end do

      res@mpLimitMode       = "LatLon"            ; choose range of map
;     res@mpMinLatF = xlat(0)
;     res@mpMinLonF = xlon(0)
      res@mpMaxLatF = xlat(nlat-1)
;     res@mpMaxLonF = xlon(nlon-1)

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

    ; res@tfDoNDCOverlay         = True      ; do not transform
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
        cmap = read_colormap_file("CBR_drywet")
        obs = "MSWEP"
        offsetR = -0.0008
        offsetL = offsetR
        offsetRe = 0.00
        offsetLe = 0.013
      else if ( var.eq."clt" ) then
        res@cnLevels    := (/-50,-40,-30,-20,-10,10,20,30,40,50/) ; "%"
        cmap = read_colormap_file("CBR_drywet")
        obs = "CRU"
        offsetR = 0.010
        offsetL = 0.00
        offsetRe = offsetR
        offsetLe = offsetR
      else
        cmap = read_colormap_file("CBR_coldhot")
        obs = "CRU"
        offsetR = 0.010
        offsetL = 0.00
        offsetRe = offsetR
        offsetLe = offsetR
      end if
      end if
      res@cnFillPalette = cmap
      res@gsnRightString    = seas+" "+var

      res@gsnLeftStringOrthogonalPosF  = offsetL
      res@gsnRightStringOrthogonalPosF = offsetR
      res@gsnLeftString     = snam+"_RCM - "+obs 
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
    gsn_panel(wks,plot,(/ds,ncol/),pres)

    trimPNG(outp+outn+".png")

  end do

end
