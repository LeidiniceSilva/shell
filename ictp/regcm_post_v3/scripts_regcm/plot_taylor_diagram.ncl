load "$NCARG_ROOT/lib/ncarg/nclscripts/james/trimPNG.ncl"
loadscript(getenv("scrdir")+"/"+"taylor_diagram.ncl")

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
  var  = getenv("var")
  obs0 = getenv("obs")
  res0 = getenv("ress")
  subregs0 = getenv("subregs")
  rdir = getenv("rdir") + "/"
  dirp = getenv("hdir") + "/"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; end of inputs ;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;-- subregions (cases)
  subregs = str_split(subregs0, " ")
  nsub = dimsizes(subregs)

  ;-- case settings
  colors = (/"red","blue","green","orange", "darkorchid","cyan","deeppink","green4","lightsalmon4"/)
  markers = (/16, 16, 16, 16, 16, 16, 16, 16, 16/)

  ;-- obs
  obs = str_split(obs0, " ")
  nobs = dimsizes(obs)

  ;-- res
  res = str_split(res0, " ")
  nres = dimsizes(res)
  
  ;-- season (vars)
  seasons = (/"DJF","MAM","JJA","SON"/)
  nseason = dimsizes(seasons)

  ;-- plotting
  outp = dirp+"images/" ;;rdir+"Taylor_diagram/"
  outn   = snum+"_taylor_diagram_"+var+"_"+yr
  wks = gsn_open_wks("png",outp+outn)
  plot = new(nobs,graphic)

  ;-- 
  opt            = True                     ; taylor diagram with options
  opt@Markers    = markers(0:nsub-1)       ; make all "cases" solid fill
  opt@Colors     = colors(0:nsub-1)
  opt@varLabels  = seasons
  opt@varLabelsYloc = 0.65
  opt@caseLabels = subregs
  
  opt@taylorDraw  = False                          ; don't draw
  opt@taylorFrame = False                          ; don't advance frame

  ;-- loop through obs dataset
  do i = 0, nobs - 1

	  this_o = obs(i)
	  this_r = res(i)

	  ;-- ratio and cc
	  ratio = new((/nsub, nseason/), "float")
	  cc = new((/nsub, nseason/), "float")

	  ;-- loop through subregions
	  do j = 0, nsub - 1

		  this_sub = subregs(j)

		  ;-- loop through season
		  do k = 0, nseason - 1

			  this_s = seasons(k)

			  ;-- fname
			  ofname = rdir+"obs/"+var+"_"+this_o+"_"+yr+"_"+this_s+\
			        "_mean_"+snum+"_"+this_r+".nc"
			  rfname = rdir+conf+"-"+snum+"/plots/"+snum+"_"+var+\
			  	"_"+yr+"_"+this_s+"_mean_"+snum+"_"+this_r+".nc"
                          mfname = rdir+conf+"-"+snum+"/plots/"+this_sub+"-"+this_o+"_mask.nc"
			  ;print(ofname+"")
			  ;print(rfname)
                          ;print(mfname+"")
			  
			  ;-- read file
			  of = addfile(ofname, "r")
			  rf = addfile(rfname, "r")
                          mf = addfile(mfname, "r")

			  ;-- read var
			  vo := of->$var$(0,:,:)
			  if ( var .eq. "pr" .or. var .eq. "clt" .or. var .eq. "snw" ) then
			    vr := rf->$var$(0,:,:)
			  else
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

			  ;-- calc taylor stats
			  tstat = taylor_stats(vrm, vom, w, 0)
			  cc(j, k) = tstat(0)
			  ratio(j, k) = tstat(1)
		  end do
	  end do

	  ;-- plot
	  opt@tiMainString = this_o
	  plot(i) = taylor_diagram(wks,ratio,cc,opt)
  end do
  
  ;---------------------------------------------
  ; create panel
  ;---------------------------------------------
  pres                  = True
  pres@gsnMaximize = True
  pres@gsnPanelRight  = 0.97
  pres@gsnScale = True

  if nobs .eq. 1
	  fconf = (/1, 1/)
  else
	  fconf = toint((/ceil(tofloat(nobs)/2), 2/))
  end if

  gsn_panel(wks,plot,fconf,pres)
  trimPNG(outp+outn+".png")

end
