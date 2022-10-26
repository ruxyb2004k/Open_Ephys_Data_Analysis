%% created by RB on 08.04.2022

% Fig. 4bModelx (2x) : Average normalized baseline 

titleFig4bModx = {'Normalized photostim spontaneous interval'};
    
saveFig4bModx = {'meanNormPhotostimBaseMod_x.fig'};

xdata = (0:totalConds-1)/(totalConds-1)*100;

marker1 = '.-';
marker2 = '.-';
ms = 50
if strcmp(char(exps), 'ActivatingBoth')
    cCreCellType(1,:) = [0 0 255]/255;% exc
    cCreCellType(2,:) = [0 0 255]/255;% inh
    ms = 18;
    marker1 = '^-';
    marker2 = 'o-';
end

figure
ax = gca;
line([0 totalConds-1]/(totalConds-1)*100, [1 1],'Color',[.2 .2 .2],'LineStyle','--'); hold on
if ~strcmp(char(exps), 'ActivatingBoth')
    line([0 totalConds-1]/(totalConds-1)*100, [lineBaseExc lineBaseExc],'Color',cCreCellType(1,:),'LineStyle','--','LineWidth',2);
    line([0 totalConds-1]/(totalConds-1)*100, [lineBaseInh lineBaseInh],'Color',cCreCellType(2,:),'LineStyle','--','LineWidth',2);
else
    line([0 totalConds-1]/(totalConds-1)*100, [lineBase lineBase],'Color',cCreCellType(1,:),'LineStyle','--','LineWidth',2);
end
plot(xdata, meanNormAllStimPhoto(:,1), marker1, 'LineWidth',2,...
    'Color',cCreCellType(1,:), 'MarkerSize',ms);    hold on %,'MarkerFaceColor',cCreCellType(1,:)
plot(xdata, meanNormAllStimPhoto(:,2), marker2, 'LineWidth',2,...
    'Color',cCreCellType(2,:), 'MarkerSize',ms);    hold on % ,'MarkerFaceColor',cCreCellType(2,:)
xlabel('% units with activated 5-HT_2_A ');
ylabel('Firing rate (norm.) ');
set(ax,'XLim', [-5 100], 'YLim',[0.5 1.8],'FontSize',fs-4);
set(ax,'xtick',(0:totalConds-1)/(totalConds-1)*100) % set major ticks
set(ax, 'TickDir', 'out');

set(ax,'ytick',[0.5 1 1.5]) % set major ticks
title(titleFig4bModx);
background = get(gcf, 'color');
box off

if saveFigs == true
    savefig(strcat(savePath, saveFig4bModx{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig4bModx{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig4bModx{1}(1:end-4)), 'epsc');
end
