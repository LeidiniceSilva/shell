loadscript(getenv("scrdir")+"/"+"trimPNG.ncl")

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
  vars   = (/"pr","tas"/)
  vnames = (/"precipitation","temperature"/)
  ulist  = (/"mm/day","~F34~0~F~C"/)
  nvars = dimsizes(vars)

  if ( snum.eq."Europe" ) then
    obsns = (/"EOBS","EOBS"/)
  else if ( snum.eq."SEEurope" .or. snum.eq."Medi3" .or. snum.eq."Medi" .or. snum.eq."Mediterranean" ) then
    obsns = (/"mask","EOBS"/)
  else
    obsns = (/"CPC","CRU"/)
  end if
  end if

  r4 = "off"
  if ( snum.eq."Europe" ) then
    regs  = (/"MED","NEU","WCE"/)
    regns = (/"Mediterranean","N.Europe","C.Europe"/)
  end if
  if ( snum.eq."NorthAmerica") then
    regs  = (/"NWN","NEN","WNA","CNA","ENA","NCA"/)
    regns = (/"N.W.North-America","N.E.North-America","W.North-America","C.North-America","E.North-America","N.Central-America"/)
  end if
  if ( snum.eq."CentralAmerica") then
    regs  = (/"NCA","SCA","CAR"/)
    regns = (/"N.Central-America","S.Central-America","Caribbean"/)
  end if
  if ( snum.eq."SouthAmerica") then
    regs  = (/"NWS","NSA","SAM","NES","SES","SWS","SSA"/)
    regns = (/"N.W.South-America","N.South-America","South-American-Monsoon","N.E.South-America","S.E.South-America","S.W.South-America","S.South-America"/)
  end if
  if ( snum.eq."Africa") then
    regs  = (/"MDG","ESAF","WSAF","NEAF","SEAF","CAF","WAF","SAH","ARP"/)
    regns = (/"Madagascar","E.S.Africa","W.S.Africa","N.E.Africa","S.E.Africa","Central Africa","West Africa","Sahara","Arabian-Peninsula"/)
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
  end if
  if ( snum.eq."Australasia") then
    regs  = (/"NAU","CAU","EAU","SAU","NZ"/)
    regns = (/"N.Australia","C.Australia","E.Australia","S.Australia","New-Zealand"/)
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
  if ( snum.eq."Mediterranean" .or. snum.eq."Medi3" ) then
    regs  = (/"CARPAT", "EURO4M", "RdisaggH", "GRIPHO", "COMEPHORE"/) ;"SPAIN02"
    regns = regs
    r4 = "off"
  end if
; if (  snum.eq."Mediterranean" ) then
;   regs  = (/"FullDom"/)
;   regns = (/snum/)
;   r4 = "off"
; end if
  nregs = dimsizes(regs)

  if ( snumT.eq."MPI-Europe" ) then
    r4 = "off"
  end if

  focus  = "yr"

  dirp = hdir+"pdfs/"
  outp = hdir+"images/"
  system("mkdir -p "+outp)

  fsup = ""
  if ( focus.ne."yr" ) then
    fsup = "_"+focus
  end if

  do ii=0, nvars-1
    var = vars(ii)
    vnam = vnames(ii)
    unit = ulist(ii)

    outn   = snum+"_pdf_srex_"+focus+"_"+var+"_"+yr
    wks = gsn_open_wks("png",outp+outn)
    plots = new((/nregs/),graphic)
    dum := new((/nregs,6/),graphic)
    np=0

    do ss=0, nregs-1
     sr  = regs(ss)
     srn = regns(ss)

     obsn = obsns(ii)
     if ( obsn.eq."mask" ) then
       obsn = sr
     end if

     ;; Opening OBS
     filo = dirp+var+"_"+obsn+"_"+sr+"_"+yr+fsup+"_pdf.nc"
     ao = addfile(filo,"r")
     vo := ao->$var$(0,:,0,0)
     bo := ao->bin(:)

     ;; Opening RegCM4
     ;film = dirp+var+"_RegCM4_"+sr+"_"+yr+fsup+"_pdf.nc"
     ;if ( r4.eq."on" ) then
     ;  am = addfile(film,"r")
     ;  vm := am->$var$(0,:,0,0)
     ;  bm := am->bin(:)
     ;else
     ;  vm := vo@_FillValue
     ;  bm := bo
     ;end if

     ;; Opening RegCM5
     filh = dirp+var+"_RegCM5_"+sr+"_"+yr+fsup+"_pdf.nc"
     aa = addfile(filh,"r")
     va := aa->$var$(0,:,0,0)
     ba := aa->bin(:)
 
     minv = min((/bo(0),ba(0)/))
     obins = dimsizes(vo)
     ;mbins = dimsizes(vm)
     abins = dimsizes(va)
     maxv = max((/bo(obins-1),ba(abins-1)/))

     nbins := max((/obins,abins/)) 
     allpdfs = new((/2,nbins/),double)
     allpdfs(0,0:obins-1) = vo
     ;allpdfs(1,0:mbins-1) = vm
     allpdfs(1,0:abins-1) = va
     delete(vo)
     ;delete(vm)
     delete(va)

     bins := ispan(tointeger(minv),tointeger(maxv),1)

     ;***********************
     ; plot
     ;***********************

     res            = True               ; plot mods desired
     res@gsnDraw    = False              ; don't draw yet
     res@gsnFrame   = False              ; don't advance frame yet

     res@tmYROn     = False              ; Turn off right tickmarks.
     res@tmXTOn     = False              ; Turn off top tickmarks.

     maxy = max(allpdfs)
     if ( var.eq."tas" ) then
       res@xyMarkLineMode    = "Lines"
       ;res@xyLineThicknessF  = (/3,3,3/)     ; Thicken the lines
       res@xyLineThicknessF  = (/3,3/)     ; Thicken the lines
       ;res@xyDashPatterns    = (/1,0,0/)
       res@xyDashPatterns    = (/1,0/)
       ;res@xyLineColors      = (/"black","red","blue"/)
       res@xyLineColors      = (/"black","blue"/)
       dmx = maxv*0.2
       res@trYMinF = 0.
       res@trYMaxF = maxy*1.5
     end if

     if ( var.eq."pr" ) then
       res@xyMarkLineMode    = "Markers"
       ;res@xyMarkers         = (/16,16,16/)
       res@xyMarkers         = (/16,16/)
       ;res@xyMarkerColors    = (/"black","red","blue"/)
       res@xyMarkerColors    = (/"black","blue"/)
       res@xyMarkerSizeF     = 0.0050
       res@trYLog            = True
       res@xyComputeYMin     = True
       allpdfs = where(allpdfs.eq.0.,allpdfs@_FillValue,allpdfs)
       dmx = maxv*0.2
       miny = min(allpdfs)
       system("echo "+miny+" | cut -d'e' -f2 > num.t")
       ascr = asciiread("num.t",1,"integer")
       system("rm num.t")
       res@trYMinF = 1.*(10*(ascr-1))
       res@trYMaxF = 1.
       res@gsnCenterStringOrthogonalPosF = -0.01
     end if
   
     res@trXMinF = minv
     res@trXMaxF = maxv+dmx

     res@gsnCenterStringFontHeightF    = 0.02
     res@gsnCenterString               = srn

     res@tmXBLabelFontHeightF = 0.018
     res@tmYLLabelFontHeightF = 0.018
     res@tiXAxisFontHeightF   = 0.02
     res@tiYAxisFontHeightF   = 0.02
     res@tiXAxisString        = vnam+" ("+unit+")"
     res@tiYAxisString        = "frequency (#)"

     res@tiXAxisOn    = True
     res@tmXBLabelsOn = True

     plots(np) = gsn_csm_xy(wks,bins,allpdfs,res)
     delete(allpdfs)
     delete(res)

     ;*****************************************************
     ; Manually create and attach legend
     ;*****************************************************
     res_text                = True              ; text mods desired
     res_text@txFontHeightF  = 0.018             ; change text size
     res_text@txJust         = "CenterLeft"      ; text justification

     if ( np.eq.0 ) then
     if ( var.eq."pr" ) then
       res_mark                = True
       res_mark@gsMarkerIndex  = "dot"
       res_mark@gsMarkerColor  = "black"
       res_mark@gsMarkerSizeF  = 0.025
      ;x0 =  90
       xN =  0.75*(maxv+dmx)
       xT =  0.78*(maxv+dmx)
       yN = 0.5*maxy
       dY = 0.3*maxy
       dY2 = 0.11*maxy
       dY3 = 0.05*maxy
       dum(np,0) = gsn_add_polymarker(wks,plots(np),xN,yN,res_mark)
     end if
     if ( var.eq."tas" ) then
       res_line                   = True
       res_line@gsLineColor       = "black"
       res_line@gsLineThicknessF  = 4
       res_line@gsLineDashPattern = 2
       x0 := minv+((maxv-minv)*0.05)
       xN = minv+((maxv-minv)*0.15)
       xT = minv+((maxv-minv)*0.18)
       yN := 0.94*1.5*maxy
       dY := 0.04*1.5*maxy 
       dY2 := dY
       dY3 := dY
       dum(np,0) = gsn_add_polyline(wks,plots(np),(/x0,xN/),(/yN,yN/),res_line)
       res_line@gsLineDashPattern = 0
     end if
     if ( obsn.eq.sr ) then
       obsn = "HiRes"
     end if
     dum(np,1) = gsn_add_text(wks,plots(np),obsn,xT,yN,res_text)

     yN = yN-dY
     if ( r4.eq."on" ) then
       if ( var.eq."pr" ) then
        res_mark@gsMarkerColor     = "red"
        dum(np,2) = gsn_add_polymarker(wks,plots(np),xN,yN,res_mark)
       else
         res_line@gsLineColor       = "red"
         dum(np,2) = gsn_add_polyline(wks,plots(np),(/x0,xN/),(/yN,yN/),res_line)
       end if
       dum(np,3) = gsn_add_text(wks,plots(np),"RegCM4",xT,yN,res_text)

       yN = yN-dY2
     end if
     if ( var.eq."pr" ) then
      res_mark@gsMarkerColor     = "blue"
      dum(np,4) = gsn_add_polymarker(wks,plots(np),xN,yN,res_mark)
     else
       res_line@gsLineColor       = "blue"
       dum(np,4) = gsn_add_polyline(wks,plots(np),(/x0,xN/),(/yN,yN/),res_line)
     end if
     dum(np,5) = gsn_add_text(wks,plots(np),"RegCM5",xT,yN,res_text)

    end if

    np=np+1

   end do
  
   ;---------------------------------------------
   ; create panel
   ;---------------------------------------------
   pres                  = True
   pres@gsnMaximize = True
   if ( nregs.le.4 ) then
     gsn_panel(wks,plots,(/1,nregs/),pres)
   else
     if ( nregs.le.8 ) then
       if ( nregs.le.6 ) then
         gsn_panel(wks,plots,(/2,3/),pres)
       else
         gsn_panel(wks,plots,(/2,4/),pres)
       end if
     else
       if ( nregs.le.9 ) then
         gsn_panel(wks,plots,(/3,3/),pres)
       else
         gsn_panel(wks,plots,(/3,4/),pres)
       end if
     end if
   end if

   trimPNG(outp+outn+".png")

  end do

end
