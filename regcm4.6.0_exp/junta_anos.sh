##############
y=1981
while [ $y -le 1981 ]
do 
cdo mergetime SRF.$y.01.nc SRF.$y.02.nc SRF.$y.03.nc SRF.$y.04.nc SRF.$y.05.nc SRF.$y.06.nc SRF.$y.07.nc SRF.$y.08.nc SRF.$y.09.nc SRF.$y.10.nc SRF.$y.11.nc SRF.$y.12.nc SRF.$y.nc
y=`expr $y + 1`
done
##############
x=1981
while [ $x -le 1981 ]
do 
cdo selname,tpr SRF.$x.nc SRF.TPR.$x.nc 
x=`expr $x + 1`
done
##############
z=1981
while [ $z -le 1981 ]
do 
cdo selname,t2m SRF.$z.nc SRF.T2M.$z.nc 
z=`expr $z + 1`
done
##############
cdo mergetime SRF.TPR.1981.nc SRF.TPR.1982.nc SRF.TPR.1983.nc SRF.TPR.1984.nc SRF.TPR.1985.nc SRF.TPR.1986.nc SRF.TPR.1987.nc SRF.TPR.1988.nc SRF.TPR.1989.nc SRF.TPR.1990.nc SRF.TPR.1991.nc SRF.TPR.1992.nc SRF.TPR.1993.nc SRF.TPR.1994.nc SRF.TPR.1995.nc SRF.TPR.1996.nc SRF.TPR.1997.nc SRF.TPR.1998.nc SRF.TPR.1999.nc SRF.TPR.2000.nc SRF.TPR.2001.nc SRF.TPR.2002.nc SRF.TPR.2003.nc SRF.TPR.2004.nc SRF.TPR.2005.nc SRF.TPR.2006.nc SRF.TPR.2007.nc SRF.TPR.2008.nc SRF.TPR.2009.nc SRF.TPR.2010.nc SRF.TPR.nc
##############
cdo mergetime SRF.T2M.1981.nc SRF.T2M.1982.nc SRF.T2M.1983.nc SRF.T2M.1984.nc SRF.T2M.1985.nc SRF.T2M.1986.nc SRF.T2M.1987.nc SRF.T2M.1988.nc SRF.T2M.1989.nc SRF.T2M.1990.nc SRF.T2M.1991.nc SRF.T2M.1992.nc SRF.T2M.1993.nc SRF.T2M.1994.nc SRF.T2M.1995.nc SRF.T2M.1996.nc SRF.T2M.1997.nc SRF.T2M.1998.nc SRF.T2M.1999.nc SRF.T2M.2000.nc SRF.T2M.2001.nc SRF.T2M.2002.nc SRF.T2M.2003.nc SRF.T2M.2004.nc SRF.T2M.2005.nc SRF.T2M.2006.nc SRF.T2M.2007.nc SRF.T2M.2008.nc SRF.T2M.2009.nc SRF.T2M.2010.nc SRF.T2M.nc
##############

 
