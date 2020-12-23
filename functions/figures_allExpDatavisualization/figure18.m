%%% created by RB on 23.12.2020

% Fig. 18 : Average normalized combined baseline 

if totalStim == 1
    titleFig18 = {'Normalized combined baselineno photostim. vs with photostim.'};
    
    saveFig18 = {'meanNormBaselineComb.fig'};
    
    figure
    ax = gca;
    hold on
    plot((1:numel(baseStim)),meanNormAllStimBaseComb(1,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:numel(baseStim)),meanNormAllStimBaseComb(2,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    
    min_hist = 0;
    max_hist1 = 1.2 *max(max(meanNormAllStimBaseComb))*1.3;
    xlabel('Stim#');
    ylabel('Normalized baseline ');
    set(ax,'XLim',[0.8 3.2],'FontSize',fs);
    set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig18);
    background = get(gcf, 'color');
    h1 = line([1.7 3.3],[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    errorbar((1:numel(baseStim)),meanNormAllStimBaseComb(1,:),STEMnormAllStimBaseComb(1,:), 'Color', C(1,:)); hold on
    errorbar((1:numel(baseStim)),meanNormAllStimBaseComb(2,:),STEMnormAllStimBaseComb(2,:), 'Color', C(2,:)); hold on
    for stim = 1:numel(baseStim)
        p_temp =  pNormAllStimBaseComb(stim,2);
        y = max(meanNormAllStimBaseComb(:,stim)+STEMnormAllStimBaseComb(:,stim));
        %     text((cond+1)/2, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text(stim, y+0.1*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(stim, y+0.1*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(stim, y+0.1*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end
    if saveFigs == true
        savefig(strcat(savePath, saveFig18{1}));
    end
end    