%% created by RB on 08.04.2022

% Fig. 4bModel (2x) : Average normalized baseline 

titleFig4bMod = {'Normalized photostim spontaneous interval'};
    
saveFig4bMod = {'meanNormPhotostimBaseMod.fig'};

xdata = (0:totalConds-1)/(totalConds-1)*100;

figure
ax = gca;
plot(xdata, meanNormAllStimPhoto(:,1), marker,'LineWidth',2,...
    'Color',cCreCellType(1,:), 'MarkerSize',18);    hold on %,'MarkerFaceColor',cCreCellType(1,:)
plot(xdata, meanNormAllStimPhoto(:,2), marker,'LineWidth',2,...
    'Color',cCreCellType(2,:), 'MarkerSize',18);    hold on % ,'MarkerFaceColor',cCreCellType(2,:)
xlabel('% units with activated 5-HT_2_A ');
ylabel('Firing rate (norm.) ');
set(ax,'XLim', [-5 100], 'YLim',[0.4 1.8],'FontSize',fs-4);
set(ax,'xtick',(0:totalConds-1)/(totalConds-1)*100) % set major ticks
set(ax, 'TickDir', 'out');
line([0 totalConds-1]/(totalConds-1)*100, [1 1],'Color',[.2 .2 .2],'LineStyle','--');
title(titleFig4bMod);
background = get(gcf, 'color');
box off

if saveFigs == true
    savefig(strcat(savePath, saveFig4bMod{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig4bMod{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig4bMod{1}(1:end-4)), 'epsc');
end
