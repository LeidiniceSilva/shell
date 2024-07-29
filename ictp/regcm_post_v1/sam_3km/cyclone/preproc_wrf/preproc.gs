function main(args)
pathnc=subwrd(args,1)
pathbin=subwrd(args,2)


*Change the year here
ano=2018
while(ano<=2021)

lon1=-85
lon2=-10
lat1=-58.5
lat2=-1.5


***Open the file
'sdfopen 'pathnc'/PSFC.'ano'.00.nc'  
'sdfopen 'pathnc'/PSFC.'ano'.06.nc'  
'sdfopen 'pathnc'/PSFC.'ano'.12.nc'  
'sdfopen 'pathnc'/PSFC.'ano'.18.nc'  
'sdfopen 'pathnc'/U.'ano'.00.nc' 
'sdfopen 'pathnc'/U.'ano'.06.nc' 
'sdfopen 'pathnc'/U.'ano'.12.nc' 
'sdfopen 'pathnc'/U.'ano'.18.nc' 
'sdfopen 'pathnc'/V.'ano'.00.nc' 
'sdfopen 'pathnc'/V.'ano'.06.nc' 
'sdfopen 'pathnc'/V.'ano'.12.nc' 
'sdfopen 'pathnc'/V.'ano'.18.nc' 


mes=1
i=0
while(mes<=12)
if(mes=1)
tf=i+31
endif


if(mes=2)
   if(ano=1976|ano=1980|ano=1984|ano=1988|ano=1992|ano=1996|ano=2000|ano=2004|ano=2008|ano=2012|ano=2016|ano=2020|ano=2024|ano=2028|ano=2032|ano-2036|ano=2040|ano=2044|ano=2048|ano=2052|ano=2056|ano=2060)
  tf=i+29
  else
  tf=i+28
  endif
endif


if(mes=3)
tf=i+31
endif

if(mes=4)
tf=i+30
endif

if(mes=5)
tf=i+31
endif

if(mes=6)
tf=i+30
endif

if(mes=7)
tf=i+31
endif

if(mes=8)
tf=i+31
endif

if(mes=9)
tf=i+30
endif

if(mes=10)
tf=i+31
endif

if(mes=11)
tf=i+30
endif

if(mes=12)
tf=i+31
endif


*Creatie the output file
if(mes<10)
'set gxout fwrite'
'set fwrite 'pathbin'/ncp.'ano'0'mes'0100'
endif
if(mes>=10)
'set gxout fwrite'
'set fwrite 'pathbin'/ncp.'ano''mes'0100'
endif

while (i<tf)
i=i+1


'set dfile 1'
'set t 'i
'set z 1'
'define pres=PSFC/100'
*'define xp=regrid2(pres,1.5,1.5,bl_p1,'lon1','lat1')'
'd pres'

'set dfile 5'
'set t 'i
'set z 1'
*'define xu=regrid2(U,1.5,1.5,bl_p1,'lon1','lat1')'
'd U'

'set dfile 9'
'set t 'i
'set z 1'
*'define xv=regrid2(V,1.5,1.5,bl_p1,'lon1','lat1')'
'd V'

'set dfile 2'
'set t 'i
'set z 1'
'define pres=PSFC/100'
*'define xp=regrid2(pres,1.5,1.5,bl_p1,'lon1','lat1')'
'd pres'

'set dfile 6'
'set t 'i
'set z 1'
*'define xu=regrid2(U,1.5,1.5,bl_p1,'lon1','lat1')'
'd U'

'set dfile 10'
'set t 'i
'set z 1'
*'define xv=regrid2(V,1.5,1.5,bl_p1,'lon1','lat1')'
'd V'

'set dfile 3'
'set t 'i
'set z 1'
'define pres=PSFC/100'
*'define xp=regrid2(pres,1.5,1.5,bl_p1,'lon1','lat1')'
'd pres'

'set dfile 7'
'set t 'i
'set z 1'
*'define xu=regrid2(U,1.5,1.5,bl_p1,'lon1','lat1')'
'd U'

'set dfile 11'
'set t 'i
'set z 1'
*'define xv=regrid2(V,1.5,1.5,bl_p1,'lon1','lat1')'
'd V'

'set dfile 4'
'set t 'i
'set z 1'
'define pres=PSFC/100'
*'define xp=regrid2(pres,1.5,1.5,bl_p1,'lon1','lat1')'
'd pres'

'set dfile 8'
'set t 'i
'set z 1'
*'define xu=regrid2(U,1.5,1.5,bl_p1,'lon1','lat1')'
'd U'

'set dfile 12'
'set t 'i
'set z 1'
*'define xv=regrid2(V,1.5,1.5,bl_p1,'lon1','lat1')'
'd V'

endwhile
'disable fwrite'
mes=mes+1
endwhile

'close 12'
'close 11'
'close 10'
'close 9'
'close 8'
'close 7'
'close 6'
'close 5'
'close 4'
'close 3'
'close 2'
'close 1'

ano=ano+1

endwhile

'quit'


