%%% created by RB on 23.12.2020

% Fig. 4 (2x) : Average normalized baseline 

if totalStim == 6
    titleFig4 = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
        'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig4 = {'meanNormBaseline100.fig','meanNormBaseline0.fig'};
elseif totalStim ==1
    titleFig4 = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
    'Normalized baseline 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Normalized baseline 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Normalized baseline 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig4 = {'meanNormBaseline100.fig', 'meanNormBaseline50l.fig','meanNormBaseline25.fig','meanNormBaseline12.fig','meanNormBaseline0.fig'};
end
for cond = (1:2:totalConds)
    figure
    ax = gca;
    hold on
    plot((1:numel(baseStim)),meanNormAllStimBase(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:numel(baseStim)),meanNormAllStimBase(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    
%     min_hist = -1;
    max_hist1 = 1.5;
    xlabel('Stim#');
    ylabel('Normalized baseline ');
    set(ax,'XLim',[0.8 numel(baseStim)+0.2],'FontSize',fs);
    set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig4{(cond+1)/2});
    background = get(gcf, 'color');

    errorbar((1:numel(baseStim)),meanNormAllStimBase(cond,:),STEMnormAllStimBase(cond,:), 'Color', C(1,:)); hold on
    errorbar((1:numel(baseStim)),meanNormAllStimBase(cond+1,:),STEMnormAllStimBase(cond+1,:), 'Color', C(2,:)); hold on
    for stim = 1:totalStim
        p_temp =  pNormAllStimBase((cond+1)/2,stim,2);
        y = max(meanNormAllStimBase(cond:cond+1,stim)+STEMnormAllStimBase(cond:cond+1,stim));
%         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text(stim, y+0.05,'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');%*sign(y)
        elseif p_temp <= 0.01
            text(stim, y+0.05,'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');%*sign(y)
        elseif p_temp <= 0.05
            text(stim, y+0.05,'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');%*sign(y)
        end
    end 
    yl=ylim;
    h1 = line([1.7 4.3],[yl(2)*0.99 yl(2)*0.99]);    
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    if saveFigs == true
        savefig(strcat(savePath, saveFig4{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig4{(cond+1)/2}(1:end-3), 'png'));
    end
end