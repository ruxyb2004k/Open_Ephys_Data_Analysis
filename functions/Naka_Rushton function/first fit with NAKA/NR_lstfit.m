function [x,resnorm]=NR_lstfit(Rmax,n,C50,B,ydata)
	cntrst=[6.25 12.5 25 50 100]./100;
    xdata=repmat(cntrst,size(ydata,1),1);
    x0 = [Rmax,n,C50,B];          % Starting guess
    [x,resnorm] = lsqcurvefit(@Naka,x0,xdata,ydata);
return

% param=( 0.0010    0.6909    0.3000    0.0012);
% plot(cntrst,response)