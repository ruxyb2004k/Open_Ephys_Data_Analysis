%%% created by RB on 23.12.2020

% Fig. 14b (1x) : average normalized amplitude- baseline 

titleFig14b = {'Normalized amplitude to 100% visual stim. without photostim.'};

saveFig14b = {'meanNormAmplTo100.fig'};

figure
ax = gca;
hold on
plot((1:totalConds/2),meanNormAmplMinusBase100(1:2:totalConds),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
plot((1:totalConds/2),meanNormAmplMinusBase100(2:2:totalConds),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
max_hist1 = 1.2 *max(meanNormAmplMinusBase100)*1.3;
min_hist = -0.1;
xlabel('Contrast');
ylabel('Normalized amplitude-baseline');
set(ax,'XLim',[0.8 totalConds/2+0.2],'FontSize',fs);
set(ax, 'TickDir', 'out');
set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
set(ax,'FontSize',fs)
title(titleFig14b,'FontSize',18);
background = get(gcf, 'color');
errorbar((1:totalConds/2),meanNormAmplMinusBase100(1:2:totalConds),STEMnormAmplMinusBase100(1:2:totalConds), 'Color', C(1,:)); hold on
errorbar((1:totalConds/2),meanNormAmplMinusBase100(2:2:totalConds),STEMnormAmplMinusBase100(2:2:totalConds), 'Color', C(2,:)); hold on
if saveFigs == true
    savefig(strcat(savePath, saveFig14b{1}));
end

