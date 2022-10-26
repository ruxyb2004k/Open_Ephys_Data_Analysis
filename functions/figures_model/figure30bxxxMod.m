%%% created by RB on 11.04.2022

% Fig. 30bxxxMod (2x) : Plot line, difference of magnitude between the normalized
% traces  (magn =1 and not peak =1)


titleFig30bxxxMod = {'Magnitude in normalized difference trace'};

saveFig30bxxxMod = {'meanAllStimMagnNormTraceMod.fig'};

xdata = (0:totalConds-1)/(totalConds-1)*100;

figure
ax = gca;
hold on
plot(xdata, meanAllStimMagnNormTracesBaseSubtr100Subtr(:,1), marker,'LineWidth',2,...
    'Color',cCreCellType(1,:), 'MarkerSize',18);    hold on %,'MarkerFaceColor',cCreCellType(1,:)
plot(xdata, meanAllStimMagnNormTracesBaseSubtr100Subtr(:,2), marker,'LineWidth',2,...
    'Color',cCreCellType(2,:), 'MarkerSize',18);    hold on % ,'MarkerFaceColor',cCreCellType(2,:)

line([0 totalConds-1]/(totalConds-1)*100, [0 0], 'Color', [.5 .5 .5 ])
xlabel('% units with activated 5-HT_2_A ');
ylabel('\Delta Magnitude (norm.) ');
set(ax,'XLim', [-5 100],'YLim',[-1 0.5],'FontSize',fs-4);
set(ax,'xtick',(0:totalConds-1)/(totalConds-1)*100) % set major ticks
set(ax, 'TickDir', 'out');
title(titleFig30bxxxMod{1});
background = get(gcf, 'color');

if saveFigs == true
    savefig(strcat(savePath, saveFig30bxxxMod{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig30bxxxMod{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig30bxxxMod{1}(1:end-4)), 'epsc');
end