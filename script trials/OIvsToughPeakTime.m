%%% plot and fit OI of baseline vs trough-peak time 

cond=1;
figure
xdata = cellMetricsAll.troughPeakTime;
ydata = OIndexAllStimBase(2,:,3);
scatter(xdata, ydata); hold on
idx = ~(isnan(xdata) | isnan(ydata));
[fitline1, gof] = fit(xdata(idx)', ydata(idx)', 'poly1');
plot(fitline1);
coeffs1(cond,:) = coeffvalues(fitline1);
legend off
set(ax,'FontSize',24);

background = get(gcf, 'color');
set(gcf,'color','white'); hold on
lim = max(xdata);
text(lim*0.5, lim*0.95, [num2str(round(coeffs1(cond,1),2)),'*x + ',num2str(round(coeffs1(cond,2),2)) ] ,'FontSize',10, 'HorizontalAlignment','center');

xlabel('Trough-peak time (ms)')
ylabel('OI base stim 3')