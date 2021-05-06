function F=Naka(x,xdata)
    F=x(1).* ((xdata.^x(2))./(x(3).^x(2)+xdata.^x(2)))+x(4);
return