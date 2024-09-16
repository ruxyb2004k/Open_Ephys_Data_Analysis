%%% created by RB on 11.04.2022

% Fig. 30bxxxMod (2x) : Plot line, difference of magnitude between the normalized
% traces  (magn =1 and not peak =1)


titleFig30bxxxModx = {'Magnitude in normalized difference trace'};

saveFig30bxxxModx = {'meanAllStimMagnNormTraceMod_x.fig'};

xdata = (0:totalConds-1)/(totalConds-1)*100;

marker1 = '.-';
marker2 = '.-';
ms = 50;
yl = [-1 0.25];
if strcmp(char(exps), 'ActivatingBoth')|| (contains(char(exps), 'Inh') && contains(char(exps), 'Exc'))
    cCreCellType(1,:) = [0 0 255]/255;% exc
    cCreCellType(2,:) = [0 0 255]/255;% inh
    ms = 18;
    yl = [-1 0.25];
    marker1 = '^-';
    marker2 = 'o-';
end

figure
ax = gca;
hold on
line([0 totalConds-1]/(totalConds-1)*100, [0 0], 'Color', [.5 .5 .5 ])
if ~strcmp(char(exps), 'ActivatingBoth') && ~(contains(char(exps), 'Inh') && contains(char(exps), 'Exc'))
%     line([0 totalConds-1]/(totalConds-1)*100, [lineMagnExc lineMagnExc],'Color',cCreCellType(1,:),'LineStyle','--','LineWidth',2);
%     line([0 totalConds-1]/(totalConds-1)*100, [lineMagnInh lineMagnInh],'Color',cCreCellType(2,:),'LineStyle','--','LineWidth',2);
else
%     line([0 totalConds-1]/(totalConds-1)*100, [lineMagn lineMagn],'Color',cCreCellType(1,:),'LineStyle','--','LineWidth',2);
    rectangle('Position',[0 min(rangeMagn) 100 abs(diff(rangeMagn))], 'FaceColor',[cCreCellType(1,:), 0.3], 'LineStyle', 'none');
    line([0 totalConds-1]/(totalConds-1)*100, [rangeMagn(1) rangeMagn(1)],'Color',cCreCellType(1,:),'LineStyle','--','LineWidth',2);
    line([0 totalConds-1]/(totalConds-1)*100, [rangeMagn(2) rangeMagn(2)],'Color',cCreCellType(1,:),'LineStyle','--','LineWidth',2);
    line([0 totalConds-1]/(totalConds-1)*100, [ownExpMagn(1) ownExpMagn(1)],'Color',[213 94 0]/255,'LineStyle','--','LineWidth',2);
    line([0 totalConds-1]/(totalConds-1)*100, [ownExpMagn(2) ownExpMagn(2)],'Color',[0,114,178]/255,'LineStyle','--','LineWidth',2);
end

plot(xdata, meanAllStimMagnNormTracesBaseSubtr100Subtr(:,1), marker1,'LineWidth',2,...
    'Color',cCreCellType(1,:), 'MarkerSize',ms); hold on%, 'MarkerFaceColor',cCreCellType(1,:)); hold on
plot(xdata, meanAllStimMagnNormTracesBaseSubtr100Subtr(:,2), marker2,'LineWidth',2,...
    'Color',cCreCellType(2,:), 'MarkerSize',ms);    hold on % ,'MarkerFaceColor',cCreCellType(2,:)

set(ax,'ytick',[-1 -0.5 0 0.25]) % set major ticks
xlabel('% units with activated 5-HT_2_A ');
ylabel('\Delta Magnitude (norm.) ');
set(ax,'XLim', [-5 100],'YLim',yl,'FontSize',fs-4);
set(ax,'xtick',(0:totalConds-1)/(totalConds-1)*100) % set major ticks
set(ax, 'TickDir', 'out');
title(titleFig30bxxxModx{1});
background = get(gcf, 'color');

A = allStimMagnNormTracesBaseSubtr100Subtr;
val1 = A(:,classUnitsAll==1)';
val2 = A(:,classUnitsAll==2)';

table_data1 = array2table(val1);
table_data2 = array2table(val2);

allVars1 = 1:width(table_data1);

newNames1 =  string(xdata);

table_data1 = renamevars(table_data1, allVars1, newNames1); % exc
table_data2 = renamevars(table_data2, allVars1, newNames1); % inh


if saveFigs == true
    savefig(strcat(savePath, saveFig30bxxxModx{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig30bxxxModx{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig30bxxxModx{1}(1:end-4)), 'epsc');
    writetable(table_data1, strcat(savePath, saveFig30bxxxModx{1}(1:end-3), 'xlsx'),'Sheet',1)
    writetable(table_data2, strcat(savePath, saveFig30bxxxModx{1}(1:end-3), 'xlsx'),'Sheet',2)
end