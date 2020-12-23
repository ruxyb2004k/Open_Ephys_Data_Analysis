%%% created by RB on 23.12.2020

% Fig. 3 (2x) : average baseline frequency 

if totalStim ==6
    titleFig3 = {'Baseline frequency 100% visual stim. vs 100% visual + photostim. all cells',...
    'Baseline frequency 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig3 = {'meanBaseline100.fig','meanBaseline0.fig'};
elseif totalStim == 1
    titleFig3 = {'Baseline frequency 100% visual stim. vs 100% visual + photostim. all cells',...
    'Baseline frequency 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Baseline frequency 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Baseline frequency 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Baseline frequency 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig3 = {'meanBaseline100.fig', 'meanBaseline50.fig','meanBaseline25.fig','meanBaseline12.fig','meanBaseline0.fig'};
end

for cond = (1:2:totalConds)
    figure
    ax = gca;
    hold on
    plot((1:numel(baseStim)),meanAllStimBase(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:numel(baseStim)),meanAllStimBase(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    min_hist = 0;
    max_hist1 = 1.2 *max(max(meanAllStimBase(cond:cond+1,:)))*1.3;
    xlabel('Stim#');
    ylabel('Baseline spike freq. (Hz)');
    set(ax,'XLim',[0.8 numel(baseStim)+0.2],'FontSize',fs);
%     set(gca,'FontSize',fs, 'XTickLabel',{'1','2', '3','4','5','6'},'XTick',[1 2 3 4 5 6]);
    set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig3{(cond+1)/2});
    background = get(gcf, 'color');
    h1 = line([1.7 4.3],[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    errorbar((1:numel(baseStim)),meanAllStimBase(cond,:),STEMallStimBase(cond,:), 'Color', C(1,:)); hold on
    errorbar((1:numel(baseStim)),meanAllStimBase(cond+1,:),STEMallStimBase(cond+1,:), 'Color', C(2,:)); hold on
    
    for stim = 1:totalStim
        p_temp =  pAllStimBase((cond+1)/2,stim,2);
        y = max(meanAllStimBase(cond:cond+1,stim)+STEMallStimBase(cond:cond+1,stim));
%         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text(stim, y+0.1*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(stim, y+0.1*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(stim, y+0.1*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end    
    if saveFigs == true
        savefig(strcat(savePath, saveFig3{(cond+1)/2}));
    end
end