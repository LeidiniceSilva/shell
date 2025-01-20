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
  subreg = getenv("s")
  rdir = getenv("rdir") + "/" ; e.g., /marconi_work/ICT23_ESP/clu/CORDEX/ERA5/
  dirp = getenv("hdir") + "/" ; e.g., /marconi_work/ICT23_ESP/clu/CORDEX/ERA5/NoTo-EastAsia/
  ;--
  outdir = dirp + "plots/txt_files/"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; end of inputs ;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  var1 = (/"tas", "tasmax", "tasmin", "pr", "pr_frq", "pr_int"/)
;  obs1 = (/"CRU", "CRU", "CRU", "GPCC", "GPCC", "GPCC"/)
;  res1 = (/"0.5", "0.5", "0.5", "0.25", "0.25", "0.25"/)
  obs1 = (/"CRU", "CRU", "CRU", "GPCC", "CPC", "CPC"/)
  res1 = (/"0.5", "0.5", "0.5", "0.25", "0.1", "0.1"/)
  nv1 = dimsizes(var1)
  var2 = (/"p99"/) ; add t35 later
  obs2 = (/"CPC"/);, "CPC"/)
  res2 = (/"0.1"/);, "0.5"/)
  nv2 = dimsizes(var2)
  
  ;-- season (vars)
  seasons = (/"DJF","MAM","JJA","SON"/)
  nseason = dimsizes(seasons)

  ;-- output var
  ar = new((/nseason, nv1+nv2/), "float")
  ao = new((/nseason, nv1+nv2/), "float")

  ;------------------------
  ; mean values
  ;------------------------
  ;-- loop over var1
  do i = 0, nv1 - 1
	   
	   var = var1(i)
	   this_o = obs1(i)
	   this_r = res1(i)

	   ;-- loop over season
	   do j = 0, nseason - 1

		  this_s = seasons(j)

		  ;-- fname
		  if var.eq."pr_frq" .or. var.eq."pr_int"
			  ; pr_frq_CPC_2000-2009_DJF_EastAsia_0.1.nc
			  ; EastAsia_pr_frq_2000-2009_DJF_EastAsia_0.1.nc
			  ofname = rdir+"obs/"+var+"_"+this_o+"_"+yr+"_"+this_s+\
					"_"+snum+"_"+this_r+".nc"
			  rfname = rdir+conf+"-"+snum+"/plots/"+snum+"_"+var+\
				"_"+yr+"_"+this_s+"_"+snum+"_"+this_r+".nc"
				;if snum .eq. "NorthAmerica" then
				;  ofname = rdir+"obs/"+var+"_"+this_o+"_"+yr+"_"+this_s+\
				;		"_"+snum+"_"+this_r+".nc"
				;  rfname = rdir+conf+"-"+snum+"/plots/"+snum+"_"+var+\
				;	"_"+yr+"_"+this_s+"_"+"_"+this_r+".nc"
				;end if
		  else
			  ; pr_GPCC_2000-2009_DJF_mean_EastAsia_0.25.nc
			  ; EastAsia_pr_2000-2009_DJF_mean_EastAsia_0.25.nc
			  ofname = rdir+"obs/"+var+"_"+this_o+"_"+yr+"_"+this_s+\
					"_mean_"+snum+"_"+this_r+".nc"
			  rfname = rdir+conf+"-"+snum+"/plots/"+snum+"_"+var+\
				"_"+yr+"_"+this_s+"_mean_"+snum+"_"+this_r+".nc"
		  end if
		  ; EAS-GPCC_mask.nc
		  mfname = rdir+conf+"-"+snum+"/plots/"+subreg+"-"+this_o+"_mask.nc"
		  ;print(ofname+"")
		  ;print(rfname+"")
		  ;print(mfname+"")
		  ;return

		  ;-- read file
		  of = addfile(ofname, "r")
		  rf = addfile(rfname, "r")
		  mf = addfile(mfname, "r")

		  ;-- read var
		  if ( var .eq. "pr_frq" .or. var .eq. "pr_int" ) then
			vo := of->pr(0,0,:,:)
			vr := rf->pr(0,0,:,:)
		  else if var .eq. "pr"
			vo := of->pr(0,:,:)
			vr := rf->pr(0,:,:)
		  else
		    vo := of->$var$(0,:,:)
			vr := rf->$var$(0,0,:,:)
		  end if
		  end if

		  ;-- unit conversion for pr_int, mm/year to mm/day
		  if vo@units .eq. "mm/yr" then
			  vo = vo/365
		  end if
		  if vr@units .eq. "mm/yr" then
			  vr = vr/365
		  end if

		  ;-- apply mask
		  m := mf->mask
		  ;printVarSummary(m)
		  ;printVarSummary(vo)
		  vom := mask(vo, m, 1)
		  vrm := mask(vr, m, 1)

		  vom = where(ismissing(vrm), vom@_FillValue, vom)
		  vrm = where(ismissing(vom), vrm@_FillValue, vrm)

		  ;-- lat and weight
		  xlat := of->lat
		  w := cos(xlat*get_d2r(1.0))

		  ;-- calc area-weighted spatial average
		  ao(j, i) = wgt_areaave_Wrap(vom, w, 1.0, 0)
		  ar(j, i) = wgt_areaave_Wrap(vrm, w, 1.0, 0)
	   end do
  end do

  ;------------------------
  ; extreme values
  ;------------------------
  ;-- loop over var1
  do i = 0, nv2 - 1
	   
	   var = var2(i)
	   this_o = obs2(i)
	   this_r = res2(i)

	  ;-- fname
	  if var.eq."p99"
		;  if snum .eq. "Australasia"
		;	  yr = "2000-2001"
		;  end if
		  if snum .eq. "Europe"
			  ; regrid_p99_EOBS_1980-2010.nc
			  this_o = "EOBS"
		  end if
		  ; regrid_p99_CPC_2000-2009.nc
		  ofname = rdir+conf+"-"+snum+"/plots/regrid_"+var+"_"+this_o+"_"+yr+".nc"
		  ; regrid_p99_NoTo-EastAsia_2000-2009.nc
		  rfname = rdir+conf+"-"+snum+"/plots/regrid_"+var+"_"+conf+"-"+snum+"_"+yr+".nc"
	  else
		  ofname = rdir+"obs/"+var+"_"+this_o+"_"+yr+"_"+this_s+\
				"_mean_"+snum+"_"+this_r+".nc"
		  rfname = rdir+conf+"-"+snum+"/plots/"+snum+"_"+var+\
			"_"+yr+"_"+this_s+"_mean_"+snum+"_"+this_r+".nc"
	  end if
	  if snum .eq. "Europe"
		  mfname = rdir+conf+"-"+snum+"/plots/"+subreg+"-"+this_o+"_mask.nc"
	  else
		  mfname = rdir+conf+"-"+snum+"/plots/"+subreg+"-CRU_mask.nc"
	  end if
	  ;print(ofname+"")
	  ;print(rfname+"")
	  ;print(mfname+"")
	  ;return

	  ;-- read file
	  of = addfile(ofname, "r")
	  rf = addfile(rfname, "r")
	  mf = addfile(mfname, "r")

	  ;-- read var
	  if ( var .eq. "p99" ) then
		vo := of->pr(0,:,:)
		vr := rf->pr(0,:,:)
	  else
		vo := of->$var$(0,:,:)
		vr := rf->$var$(0,0,:,:)
	  end if

	  ;-- apply mask
	  m := mf->mask
	  ;printVarSummary(m)
	  ;printVarSummary(vo)
	  vom := mask(vo, m, 1)
	  vrm := mask(vr, m, 1)

	  vom = where(ismissing(vrm), vom@_FillValue, vom)
	  vrm = where(ismissing(vom), vrm@_FillValue, vrm)

	  ;-- lat and weight
	  xlat := of->lat
	  w := cos(xlat*get_d2r(1.0))

	  ;-- calc area-weighted spatial average
	  ao(0, nv1 + i) = wgt_areaave_Wrap(vom, w, 1.0, 0)
	  ar(0, nv1 + i) = wgt_areaave_Wrap(vrm, w, 1.0, 0)
  end do

  ;------------------------
  ; write txt
  ;------------------------
  ;-- write to txt
  ao@_FillValue = -999.0
  ar@_FillValue = -999.0

  ;-- print to check value
  ;printVarSummary(ao)
  print(ao + ", " + ar)
  
  M = nv1 + nv2
  fWidth = 12    ; specify the format width
  fDec   = 4     ; specify the number to the right of decimal point
  fmtx   = M + "f" + fWidth + "." + fDec              ; fmtx="50f10.3"

  ;-- output files
  opt = True
  ;outp = dirp+"plots/"

  outn = snum+"_pixels_"+subreg+"_obs_"+yr+".txt"
  opt@fout = outn
  write_matrix(ao, fmtx, opt)
  ;system("mv " + outn + " " + outp + outn)
  system("mv " + outn + " " + outdir + outn)
  
  outn = snum+"_pixels_"+subreg+"_mod_"+yr+".txt"
  opt@fout = outn
  write_matrix(ar, fmtx, opt)
  ;system("mv " + outn + " " + outp + outn)
  system("mv " + outn + " " + outdir + outn)
end
