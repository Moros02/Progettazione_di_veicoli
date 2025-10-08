function [y,XFit,YFit]=fitting_regression(xdata,ydata,xarray)
% dai in input dati x, dati y dal database ed un array di valori x entro
% cui vuoi stimati i dati.
p=polyfit(xdata,ydata,1);
y=polyval(p,xarray);
    
XFit=linspace(min(xdata),max(xdata),100);
YFit=polyval(p,XFit);
end