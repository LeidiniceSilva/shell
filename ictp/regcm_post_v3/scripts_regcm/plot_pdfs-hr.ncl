load "$NCARG_ROOT/lib/ncarg/nclscripts/james/trimPNG.ncl"

begin
;*************************
; read in data
;*************************

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; change inputs manually ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  snum = "WMediterranean" ;getenv("snum")
  conf = "ERA5"           ;getenv("conf")
  yr   = "1995-1999"      ;getenv("ys")
  hdir = "/marconi_work/ICT23_ESP/jciarlo0/WMD03/"+conf+"/"+conf+"-"+snum+"/" ;getenv("hdir") + "/"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; end of inputs ;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  snumT  = conf+"-"+snum
  vars   = (/"pr"/)
  vnames = (/"hourly precipitation"/)
  ulist  = (/"mm/hr"/)
  nvars = dimsizes(vars)

  if ( snum.eq."Europe" .or. snum.eq."Europe03" ) then
    obsns = (/"EOBS","EOBS"/)
  else if ( snum.eq."WMediterranean" ) then
    obsns = (/"mask"/)
  else
    obsns = (/"CPC"/)
  end if
  end if

  if ( snum.eq."Europe" .or. snum.eq."Europe03" ) then
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
; if ( snum.eq."SEEurope" .or. snum.eq."Medi" ) then
;   regs  = (/"GRIPHO", "COMEPHORE"/)
;   regns = regs
; end if
  if ( snum.eq."WMediterranean" ) then
    regs  = (/"GRIPHO"/) ;;(/"RdisaggH", "GRIPHO"/) ;, "COMEPHORE"/) ;"SPAIN02"
    regns = regs
  end if
; if (  snum.eq."Mediterranean" ) then
;   regs  = (/"FullDom"/)
;   regns = (/snum/)
; end if
  r4 = "off"
  nregs = dimsizes(regs)

  if ( snum.eq."WMediterranean" ) then
    cp = True
    r4 = "off"
    pdom = "EUR-11"
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

    outn   = snum+"_pdf_1hr_srex_"+focus+"_"+var+"_"+yr
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
     filo = dirp+var+"_1hr_"+obsn+"_"+sr+"_"+yr+fsup+"_pdf.nc"
     ao = addfile(filo,"r")
     vo := ao->$var$(0,:,0,0)
     bo := ao->bin(:)

     ;; Opening RegCM4
     film = dirp+var+"_RegCM4_"+sr+"_"+yr+fsup+"_pdf.nc"
     if ( r4.eq."on" ) then
       am = addfile(film,"r")
       vm := am->$var$(0,:,0,0)
       bm := am->bin(:)
     else
       vm := vo@_FillValue
       bm := bo
     end if

     ;; Opening Parent RegCM5
     if ( cp.eq.True ) then
       filp =  dirp+var+"_1hr_Parent_"+sr+"_"+yr+fsup+"_pdf.nc"
       ap = addfile(filp,"r")
       vp := ap->$var$(0,:,0,0)
       bp := ap->bin(:)
     else
       vp := vo@_FillValue
       bp := bo
     end if

     ;; Opening RegCM5
     filh = dirp+var+"_1hr_RegCM5_"+sr+"_"+yr+fsup+"_pdf.nc"
     aa = addfile(filh,"r")
     va := aa->$var$(0,:,0,0)
     ba := aa->bin(:)
 
     minv = min((/bo(0),bm(0),bp(0),ba(0)/))
     obins = dimsizes(vo)
     mbins = dimsizes(vm)
     pbins = dimsizes(vp)
     abins = dimsizes(va)
     maxv = max((/bo(obins-1),bm(mbins-1),bp(pbins-1),ba(abins-1)/))

     nbins := max((/obins,mbins,pbins,abins/)) 
     allpdfs = new((/4,nbins/),double)
     allpdfs(0,0:obins-1) = vo
     allpdfs(1,0:mbins-1) = vm
     allpdfs(2,0:pbins-1) = vp
     allpdfs(3,0:abins-1) = va
     delete(vo)
     delete(vm)
     delete(vp)
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
       res@xyLineThicknessF  = (/3,3,3,3/)     ; Thicken the lines
       res@xyDashPatterns    = (/1,0,0,0/)
       res@xyLineColors      = (/"black","red","red","blue"/)
       dmx = maxv*0.2
       res@trYMinF = 0.
       res@trYMaxF = maxy*1.5
     end if

     if ( var.eq."pr" ) then
       res@xyMarkLineMode    = "Markers"
       res@xyMarkers         = (/16,16,16,16/)
       res@xyMarkerColors    = (/"black","red","red","blue"/)
       res@xyMarkerSizeF     = 0.0050
       res@trYLog            = True
       res@trXLog            = True
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

     bins = where(bins.eq.0.,bins@_FillValue,bins)   
     res@trXMinF = 1. ;minv
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
       xN =  0.30*(maxv+dmx)
       xT =  0.34*(maxv+dmx)
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
     if ( r4.eq."on" .or. cp.eq.True ) then
       rlabel = "RegCM4"
       if ( cp.eq.True ) then
         rlabel = pdom
       end if
       if ( var.eq."pr" ) then
        res_mark@gsMarkerColor     = "red"
        dum(np,2) = gsn_add_polymarker(wks,plots(np),xN,yN,res_mark)
       else
         res_line@gsLineColor       = "red"
         dum(np,2) = gsn_add_polyline(wks,plots(np),(/x0,xN/),(/yN,yN/),res_line)
       end if
       dum(np,3) = gsn_add_text(wks,plots(np),rlabel,xT,yN,res_text)

       yN = yN-dY2
     end if
     
     blabel = "RegCM5"
     if ( cp.eq.True ) then
       if ( snum.eq."WMediterranean" ) then
         blabel = "WMD-03"
       else
         blabel = snum
       end if
     end if
     if ( var.eq."pr" ) then
      res_mark@gsMarkerColor     = "blue"
      dum(np,4) = gsn_add_polymarker(wks,plots(np),xN,yN,res_mark)
     else
       res_line@gsLineColor       = "blue"
       dum(np,4) = gsn_add_polyline(wks,plots(np),(/x0,xN/),(/yN,yN/),res_line)
     end if
     dum(np,5) = gsn_add_text(wks,plots(np),blabel,xT,yN,res_text)

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
