begin
	;-- env
	hdir = getenv("hdir")
	ys = getenv("ys")
	n = getenv("n")
	sea = getenv("sea")
	var = getenv("var")
	mfname = getenv("mf")
    ; mof=$pdir/${n}_${v}_${ys}_${s}_mean_masked.nc
	; EAS-22_STS.2000010100.nc
	
	;-- fname
	fname = hdir+"/plots/"+n+"_"+var+"_"+ys+"_"+sea+"_mean.nc"
	outfname = hdir+"/plots/"+n+"_"+var+"_"+ys+"_"+sea+"_mean_masked.nc"
	;print(fname+"")
	;print(outfname+"")

	;-- read file
	f = addfile(fname, "r")
	xlat = f->xlat
	xlon = f->xlon
	crs = f->crs
  	v := f->$var$

	mf = addfile(mfname, "r")
	land_mask = mf->mask

	;-- apply mask
	vo = mask(v, land_mask, 2)

	;-- 
	copy_VarMeta(v, vo)
	;printVarSummary(vo)
	;printMinMax(vo, 0)
	;print("# missing = "+num(ismissing(v)))
	;print("# missing = "+num(ismissing(vo)))

	;--
	print("writing: " + outfname)
	system("/bin/rm -f " + outfname)
	fout = addfile(outfname, "c")
	fout->$var$ = vo
	fout->xlat = xlat
	fout->xlon = xlon
	fout->crs = crs
end
