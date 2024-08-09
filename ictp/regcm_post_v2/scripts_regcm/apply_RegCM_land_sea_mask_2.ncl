begin
	;-- env
	fname = getenv("f1")
	mfname = getenv("f2")
	
	;-- fname
	outfname = fname
	;print(outfname+"")

	;-- read file
	f = addfile(fname, "r")
	xlat = f->xlat
	xlon = f->xlon
	crs = f->crs
  	v := f->mask

	mf = addfile(mfname, "r")
	land_mask = mf->mask
	;printMinMax(land_mask, 0)

	;-- apply mask
	;vo = mask(v, land_mask, 2)
	;vo = mask(v, land_mask, 0)
	vo = where(land_mask .eq. 0, v, 0)

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
	fout->mask = vo
	fout->xlat = xlat
	fout->xlon = xlon
	fout->crs = crs
end
