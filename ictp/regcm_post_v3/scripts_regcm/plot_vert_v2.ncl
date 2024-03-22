load "$NCARG_ROOT/lib/ncarg/nclscripts/james/trimPNG.ncl"

begin
;*************************
; read in data
;*************************

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; change inputs manually ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  snum = getenv("snum")
  conf = getenv("conf")
  yr   = getenv("ys")
  hdir = getenv("hdir") + "/"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; end of inputs ;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  snumT  = conf+"-"+snum
  vars   = (/"clw","cli","rh","cl"/)
  vnames = (/"cloud liquid water","cloud ice","relative humidity","cloud fraction"/)
  cfacts = (/1000000.,1000000.,1.,100./)
  ulist  = (/"mg/kg","mg/kg","%","%"/)
  nvars = dimsizes(vars)

  obsn   = "ERA5"
  r4log0 = "F"
  if ( snum.eq."Europe" .or. snum.eq."Europe03" ) then
    regs  = (/"MED","NEU","WCE"/)
    regns = (/"Mediterranean","N.Europe","C.Europe"/)
    r4log0= "T"
  end if
  if ( snum.eq."NorthAmerica") then
    regs  = (/"NWN","NEN","WNA","CNA","ENA","NCA"/)
    regns = (/"N.W.North-America","N.E.North-America","W.North-America","C.North-America","E.North-America","N.Central-America"/)
  end if
  if ( snum.eq."CentralAmerica") then
    regs  = (/"NCA","SCA","CAR"/)
    regns = (/"N.Central-America","S.Central-America","Caribbean"/)
    r4log0= "T"
  end if
  if ( snum.eq."SouthAmerica") then
    regs  = (/"NWS","NSA","SAM","NES","SES","SWS","SSA"/)
    regns = (/"N.W.South-America","N.South-America","South-American-Monsoon","N.E.South-America","S.E.South-America","S.W.South-America","S.South-America"/)
    r4log0= "T"
  end if
  if ( snum.eq."Africa") then
    regs  = (/"MDG","ESAF","WSAF","NEAF","SEAF","CAF","WAF","SAH","ARP"/)
    regns = (/"Madagascar","E.S.Africa","W.S.Africa","N.E.Africa","S.E.Africa","Central Africa","West Africa","Sahara","Arabian-Peninsula"/)
    r4log0= "T"
  end if
  if ( snum.eq."SouthAsia") then
    regs  = (/"WCA","ECA","TIB","SAS","ARP"/)
    regns = (/"W.C.Asia","E.C.Asia","Tibetan-Plateau","S.Asia","Arabian-Peninsula"/)
  end if
  if ( snum.eq."EastAsia") then
    regs  = (/"EAS","RFE","ESB","ECA","TIB"/)
    regns = (/"E.Asia","Russian-Far-East","E.Siberia","E.C.Asia","Tibetan-Plateau"/)
  end if
  if ( snum.eq."SouthEastAsia") then
    regs  = (/"SEA"/)
    regns = (/"SouthEastAsia"/)
    r4log0= "T"
  end if
  if ( snum.eq."Australasia") then
    regs  = (/"NAU","CAU","EAU","SAU","NZ"/)
    regns = (/"N.Australia","C.Australia","E.Australia","S.Australia","New-Zealand"/)
    r4log0= "T"
  end if
  if ( snum.eq."SEEurope" ) then
    regs  = (/"GRIPHO", "COMEPHORE"/)
    regns = regs
    r4 = "off"
  end if
  if ( snum.eq."Medi" ) then
    regs  = (/"CARPAT", "EURO4M", "GRIPHO", "COMEPHORE"/)
    regns = regs
    r4 = "off"
  end if
  if ( snum.eq."Mediterranean" .or. snum.eq."WMediterranean" ) then
    regs  = (/"CARPAT", "EURO4M", "RdisaggH", "GRIPHO", "COMEPHORE"/)  ;"SPAIN02"
    regns = regs
    r4 = "off"
  end if
; if ( snum.eq."SEEurope" .or. snum.eq."CiSc" .or. snum.eq."Medi" .or. snum.eq."Mediterranean" ) then
;   regs  = (/"FullDom"/)
;   regns = (/snum/)
;   r4 = "off"
; end if
  nregs = dimsizes(regs)

  if ( snum.eq."Europe" ) then
      r4 = "off"
      r4log0 = "F"
  end if

  dirp = hdir+"vert/"
  outp = hdir+"images/"
  system("mkdir -p "+outp)

  focus  = "yr"
  fsup = ""
  if ( focus.ne."yr" ) then
    fsup = "_"+focus
  end if

  seasons = (/"DJF","MAM","JJA","SON"/)
  nseas = dimsizes(seasons)

  do ii=0, nvars-1
    var  = vars(ii)
    vnam = vnames(ii)
    unit = ulist(ii)
    cfac = cfacts(ii)

    r4log = r4log0
    if ( r4log0.eq."T" .and. var.eq."cli" ) then
      r4log = "F"
    end if

    outn  = snum+"_vert_srex_"+focus+"_"+var+"_"+yr
    wks   = gsn_open_wks("png",outp+outn)
    plots = new((/nregs*nseas/),graphic)
    dum  := new((/nregs,6/),graphic)
    np=0

    ;; find common max for panel
    if ( np.eq.0 ) then
      tmax = 0.
      do rr=0, nregs-1
        sr  = regs(rr)
        do ss=0, nseas-1
          seas = seasons(ss)
          filh = dirp+var+"_RegCM5_"+sr+"_"+yr+"_"+seas+"_profile.nc"
          newa = addfile(filh,"r")
          vara = newa->$var$(0,:,0,0)*cfac
          vmax = max(vara)
          if ( vmax.gt.tmax ) then
            tmax = vmax
          end if
          filo = dirp+var+"_"+obsn+"_"+sr+"_"+yr+"_"+seas+"_profile.nc"
          newo = addfile(filo,"r")
          varo = newo->$var$(0,:,0,0)*cfac
          vmax = max(varo)
          delete(vara)
          delete(newa)
          delete(filh)
          if ( vmax.gt.tmax ) then
            tmax = vmax
          end if
        end do
      end do
      tmax5 = ceil(tmax/5)*5.
    end if

    do rr=0, nregs-1
      sr  = regs(rr)
      srn = regns(rr)

      do ss=0, nseas-1
        seas = seasons(ss)

        ;;=== Read obs data
        filo = dirp+var+"_"+obsn+"_"+sr+"_"+yr+"_"+seas+"_profile.nc"
        newo = addfile(filo,"r")
        varo = newo->$var$(0,:,0,0)*cfac
        alto = tofloat(newo->level) ;; mbar (hPa)

        if ( r4log.eq."T" ) then
          ;=== Read regcm4 data
          fil4 = dirp+var+"_RegCM4_"+sr+"_"+yr+"_"+seas+"_profile.nc"
          newb = addfile(fil4,"r")
          varb = newb->$var$(0,:,0,0)*cfac
          altb = tofloat(newb->plev)
        end if
 
        ;=== Read regcm5 data
        filh = dirp+var+"_RegCM5_"+sr+"_"+yr+"_"+seas+"_profile.nc"
        newa = addfile(filh,"r")
        vara = newa->$var$(0,:,0,0)*cfac
        alta = tofloat(newa->plev) ;; hPa

        ;=== Merge data into one variable
        dimo = dimsizes(varo)
        if ( r4log.eq."T" ) then
          dim4 = dimsizes(varb)
        else
          dim4 = 0
        end if
        dim5 = dimsizes(vara)
        dimt = dimo + dim4 + dim5

        avar = new((/3,dimt/),"float")
        aalt = new((/3,dimt/),"float")
        avar(0,0:dimo-1) = (/varo(:)/)
        aalt(0,0:dimo-1) = (/alto(:)/)
        if ( r4log.eq."T" ) then
          avar(1,dimo:dimo+dim4-1) = (/varb(:)/)
          aalt(1,dimo:dimo+dim4-1) = (/altb(:)/)
        end if
        avar(2,dimo+dim4:dimo+dim4+dim5-1) = (/vara(:)/)
        aalt(2,dimo+dim4:dimo+dim4+dim5-1) = (/alta(:)/)

    ;---------------------------------------------
    ; start graphics
    ;---------------------------------------------

        col1 = "black"
        col2 = "red"
        col3 = "blue"
    ;
    ; Create three curves with different start and end X values and of 
    ; different lengths. Use random_uniform to generate dummy Y values.
    ;
        ;---Set resources common to all three plots
        res                   = True
        res@gsnDraw           = False
        res@gsnFrame          = False
        res@gsnMaximize       = True   ; Maximize size of each plot

        res@xyLineThicknessF := (/1.,1.,1./)     ; Thicken the lines
        res@xyDashPatterns   := (/1,0,0/)
        res@xyLineColors     := (/col1,col2,col3/)

        res@gsnPaperOrientation = "portrait"
        res@gsnMaximize         = True

        res@tmXTOn               = False                ; Turn off x-axis (top) major ticks
        res@tmYROn               = False                ; Turn off y-axis (right) major ticks
        res@trYReverse           = True
        res@trXMinF = -0.1
        res@trXMaxF =  tmax5

        res@gsnLeftString     = ""
        res@gsnRightString    = seas
        res@gsnCenterString   = srn 

        rr1 = rr+1
        xstr = False
        if ( rr1.eq.nregs ) then
          xstr = True
        end if
        if ( nregs.gt.5 .and. nregs.le.8 .and. rr1.eq.4 ) then
          xstr = True
        end if
        if ( nregs.gt.8 ) then
          if ( rr1.eq.3 .or. rr1.eq.6 ) then
            xstr = True
          end if
        end if
        if ( xstr.eq.True ) then
          res@tiXAxisString     = vnam+" ("+unit+")"
        else
          res@tiXAxisString     = " "
        end if
        if ( ss.eq.0 ) then
          res@tiYAxisString     = "pressure level (hPa)"
        else
          res@tiYAxisString     = " "
        end if

        plots(np) = gsn_csm_xy (wks,avar,aalt,res)
        delete(avar)
        delete(aalt)

    ;*****************************************************
    ; Manually create and attach legend
    ;*****************************************************
        res_text                    = True              ; text mods desired
        res_text@txFontHeightF      = 0.025             ; change text size
        res_text@txJust             = "CenterLeft"      ; text justification

        res_lines    = True
        res_lines@gsLineThicknessF  = 1.
        res_lines@gsLineDashPattern = 2
        res_lines@gsLineColor       = col1

        xa = 0.66*tmax5  ; 0.02
        xb = 0.78*tmax5  ; 0.10
        xc = 0.80*tmax5  ; 0.12
        ya = 50.
        dy = 50.

        legend = "F"
        if ( np.eq.0 ) then
          legend = "T"
        end if
        if ( nregs.gt.5 .and. nregs.lt.9 ) then
          if ( np.eq.(4*nseas) ) then
            legend = "T"
          end if
        end if
        if ( nregs.gt.8 ) then
          if ( np.eq.(3*nseas) ) then
            legend = "T"
          end if
          if ( np.eq.(6*nseas) ) then
            legend = "T"
          end if
        end if     
        if ( legend.eq."T" ) then
  
          xl = (/xa,xb/)
          xt = xc
          yl = (/ya,ya/)
          yt = yl(0)
          dum(rr,0) = gsn_add_polyline(wks,plots(np),xl,yl,res_lines)
          dum(rr,1) = gsn_add_text(wks,plots(np),obsn,xt,yt,res_text)  ; add text
          res_lines@gsLineDashPattern = 0

          if ( r4log.eq."T" ) then
            yl = yl+dy
            yt = yt+dy
            res_lines@gsLineColor       = col2
            dum(rr,2) = gsn_add_polyline(wks,plots(np),xl,yl,res_lines)
            dum(rr,3) = gsn_add_text(wks,plots(np),"RegCM4*",xt,yt,res_text)  ; add text
          end if

          yl = yl+dy
          yt = yt+dy
          res_lines@gsLineColor       = col3
          dum(rr,4) = gsn_add_polyline(wks,plots(np),xl,yl,res_lines)
          dum(rr,5) = gsn_add_text(wks,plots(np),"RegCM5",xt,yt,res_text)  ; add text

        end if

        np = np+1
        delete(res)
      end do
    end do

  ;************************************************
  ; create panel
  ;************************************************
    resP                = True                ; modify the panel plot
    resP@gsnFrame       = True 
    resP@gsnMaximize    = True
    resP@gsnPanelBottom = 0.01
    resP@gsnPanelRight  = 0.99  
 
    if ( nregs.le.5 ) then
      gsn_panel(wks,plots,(/nregs,nseas/),resP)               ; now draw as one plot
   ;  frame(wks)
      trimPNG(outp+outn+".png")
    else
      if ( nregs.le.8 ) then
        gsn_panel(wks,plots(0:(4*nseas)-1),(/4,nseas/),resP)
        system("mv "+outp+outn+".png "+outp+outn+"_1.png")
        trimPNG(outp+outn+"_1.png")

        gsn_panel(wks,plots((4*nseas):(nregs*nseas)-1),(/4,nseas/),resP)
        system("mv "+outp+outn+".000002.png "+outp+outn+"_2.png")
        trimPNG(outp+outn+"_2.png")
      else
        gsn_panel(wks,plots(0:(3*nseas)-1),(/3,nseas/),resP)
        system("mv "+outp+outn+".png "+outp+outn+"_1.png")
        trimPNG(outp+outn+"_1.png")

        gsn_panel(wks,plots((3*nseas):(6*nseas)-1),(/3,nseas/),resP)
        system("mv "+outp+outn+".000002.png "+outp+outn+"_2.png")
        trimPNG(outp+outn+"_2.png")

        gsn_panel(wks,plots((6*nseas):(nregs*nseas)-1),(/3,nseas/),resP)
        system("mv "+outp+outn+".000003.png "+outp+outn+"_3.png")
        trimPNG(outp+outn+"_3.png")
      end if
    end if
  end do


end
