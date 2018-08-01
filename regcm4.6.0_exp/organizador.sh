### este script faz uma serie de coisas (na pratica e a juncao dos scripts "invert_leves.sh" e "seleciona_interpola.sh"

### separa apenas algumas variaveis de interesse: u,v,w,t,qv,qc
### gera arquivos .nc a partir dos .ctl
### interpola para niveis regulares de pressao
### inverte os niveis (pois o modelo vem de cima para baixo)
### interpola para uma grade regular de 0.5 por 0.5
### seleciona uma caixa para excluir os efeitos de borda


for ANO in `seq 1981 2010`; do

# for MES in $(seq -f %02g 1 12);do
 for MES in 01 02 03 04 05 06 07 08 09 10 11 12; do

   cdo -f nc import_binary ATM.${ANO}${MES}0100.ctl ATM.${ANO}${MES}0100.nc

   cdo selname,u,v,w,t,qv,qc ATM.${ANO}${MES}0100.nc ATM.${ANO}${MES}.perf1.nc 
   
   cdo intlevel,100,200,300,400,500,600,700,800,850,900,950,1000 ATM.${ANO}${MES}.perf1.nc ATM.${ANO}${MES}.perf.nc
   
   rm -rf ATM.${ANO}${MES}0100.ctl ATM.${ANO}${MES}0100 ATM.${ANO}${MES}.perf1.nc ATM.${ANO}${MES}0100.nc

   ncatted -O -a positive,lev,c,c,"down" -a units,lev,c,c,"millibar" -a long_name,lev,c,c,"Level"  ATM.${ANO}${MES}.perf.nc  ATM.${ANO}${MES}.v.perf.nc
   
   rm -rf ATM.${ANO}${MES}.perf.nc
   
   cdo remapbil,r720x360 ATM.${ANO}${MES}.v.perf.nc ATM.${ANO}${MES}.g.perf.nc 

   rm -rf ATM.${ANO}${MES}.v.perf.nc
   
   cdo sellonlatbox,-85,-15,-20,10 ATM.${ANO}${MES}.g.perf.nc ATM.${ANO}${MES}.nc 
   
   rm -rf ATM.${ANO}${MES}.g.perf.nc
 
 done

done
   
