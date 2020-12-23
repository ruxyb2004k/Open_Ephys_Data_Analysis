%%% created by RB on 23.12.2020

% Fig. 5b (1x) : average amplitude

if totalStim == 1
    
    titleFig5b = {'Amplitude visual stim. +/- photostim.'};
    
    saveFig5b = {'meanAmpl.fig'};
    
    figure
    ax = gca;
    hold on
    plot((1:totalConds/2),meanAllStimAmpl(1:2:totalConds),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalConds/2),meanAllStimAmpl(2:2:totalConds),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
    
    max_hist1 = 1.2 *max(meanAllStimAmpl)*1.3;
    min_hist = 0;
    xlabel('Contrast');
    ylabel('Amplitude spike freq. (Hz)');
    set(ax,'XLim',[0.8 totalConds/2+0.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    xticklabels({'100%', '50%', '25%', '12%', '0%'});
    set(ax,'FontSize',fs)
    title(titleFig5b,'FontSize',18);
    background = get(gcf, 'color');
    errorbar((1:totalConds/2),meanAllStimAmpl(1:2:totalConds),STEMallStimAmpl(1:2:totalConds), 'Color', C(1,:)); hold on
    errorbar((1:totalConds/2),meanAllStimAmpl(2:2:totalConds),STEMallStimAmpl(2:2:totalConds), 'Color', C(2,:)); hold on
    for cond = 1:2:totalConds
        p_temp = pAllStimAmpl((cond+1)/2);
        y = max(meanAllStimAmpl(cond:cond+1)+STEMallStimAmpl(cond:cond+1));
        %     text((cond+1)/2, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text((cond+1)/2, y+0.1*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text((cond+1)/2, y+0.1*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text((cond+1)/2, y+0.1*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end
    if saveFigs == true
        savefig(strcat(savePath, saveFig5b{1}));
    end
end    
