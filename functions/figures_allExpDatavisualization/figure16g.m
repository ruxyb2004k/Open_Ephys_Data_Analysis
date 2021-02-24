%%% created by RB on 04.02.2021
%%% depicts a linear model of the photostim effect on the evoked activity

saveFig16g = {'LMampl1ampl4Ph100.fig'};%modify here if needed
    
figure;
ax = gca;
scatter(x1, y1, 'k', 'LineWidth', 2); hold on
scatter(x2, y2, 'b', 'LineWidth', 2);
fitline1 = fit(x1, y1, 'poly1');
fitline2 = fit(x2, y2, 'poly1');
plot(fitline1, 'k');
plot(fitline2, 'b');
xlim([0 1.1])
ylim([0 1.1])
coeffs1 = coeffvalues(fitline1);
coeffs2 = coeffvalues(fitline2);
lim= max(max(xlim, ylim));
text(lim*0.2, lim*0.85, [num2str(round(coeffs1(1),2)),'*x + ',num2str(round(coeffs1(2), 2)) ] ,'FontSize',18, 'HorizontalAlignment','center');
text(lim*0.2, lim*0.95, [num2str(round(coeffs2(1),2)),'*x + ',num2str(round(coeffs2(2),2)) ] ,'FontSize',18, 'HorizontalAlignment','center', 'Color', 'b');

legend off

h1 = line([0 lim],[0 lim]); % diagonal line
set(h1, 'Color','r','LineWidth',1, 'LineStyle', '--')% Set properties of lines
xlabel('Ampl 1 norm. spike freq.','FontSize',24); %modify here if needed
ylabel('Ampl 4 norm. spike freq','FontSize',24); %modify here if needed
% xlim([0 1])
% ylim([0 1])
set(ax,'FontSize',fs)
if saveFigs == true
    savefig(strcat(savePath, saveFig16g{1}));
    saveas(gcf, strcat(savePath, saveFig16g{1}(1:end-3), 'png'));
end