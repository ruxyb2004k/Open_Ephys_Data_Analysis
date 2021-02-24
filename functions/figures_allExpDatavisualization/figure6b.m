%%% created by RB on 23.12.2020

% Fig. 6b (1x) : average normalized amplitude

if totalStim == 6
    titleFig6b = {'Normalized amplitude to 100% visual stim. without photostim.'};

    saveFig6b = {'meanNormAmplTo100.fig'};
elseif totalStim == 1
    titleFig6b = {'Normalized amplitude to 100% visual stim. without photostim.'};

    saveFig6b = {'meanNormAmplTo100.fig'};
end

cond = 1;
figure

ax = gca;
hold on
if totalStim == 6
    plot((1:totalStim),meanNormAllStimAmpl100(1, :),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalStim),meanNormAllStimAmpl100(2, :),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on    
    xlabel('Stim #')
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);
    errorbar((1:totalStim),meanNormAllStimAmpl100(1,:),STEMnormAllStimAmpl100(1,:), 'Color', C(1,:)); hold on
    errorbar((1:totalStim),meanNormAllStimAmpl100(2,:),STEMnormAllStimAmpl100(2,:), 'Color', C(2,:)); hold on
    for stim = 1:totalStim
        p_temp =  pNormAllStimAmpl100((cond+1)/2, stim);
        y = max(meanNormAllStimAmpl100(cond:cond+1, stim)+STEMnormAllStimAmpl100(cond:cond+1, stim));
        if p_temp <= 0.001
            text(stim, y+0.05*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(stim, y+0.05*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(stim, y+0.05*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end  
elseif totalStim == 1
    plot((1:totalConds/2-1),meanNormAllStimAmpl100(1:2:end-2, :),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalConds/2-1),meanNormAllStimAmpl100(2:2:end-2, :),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
    xlabel('Contrast');
    xticks(1:totalConds/2-1);
    xticklabels({'100%', '50%', '25%', '12%'});
    set(ax,'XLim',[0.8 totalConds/2-1+0.2],'FontSize',fs);
    errorbar((1:totalConds/2-1),meanNormAllStimAmpl100(1:2:end-2, :),STEMnormAllStimAmpl100(1:2:end-2,:), 'Color', C(1,:)); hold on
    errorbar((1:totalConds/2-1),meanNormAllStimAmpl100(2:2:end-2, :),STEMnormAllStimAmpl100(2:2:end-2,:), 'Color', C(2,:)); hold on
    for cond = 1:2:totalConds-2
        p_temp =  pNormAllStimAmpl100((cond+1)/2);
        y = max(meanNormAllStimAmpl100(cond:cond+1)+STEMnormAllStimAmpl100(cond:cond+1));
        if p_temp <= 0.001
            text((cond+1)/2, y+0.05*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text((cond+1)/2, y+0.05*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text((cond+1)/2, y+0.05*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end  
    
end
    max_hist1 = max(max(meanNormAllStimAmpl100))*1.2;
    
    ylabel('Normalized amplitude');
    
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[-0.2 max_hist1]);
    set(ax,'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig6b,'FontSize',18);
    background = get(gcf, 'color');

     
if saveFigs == true
    savefig(strcat(savePath, saveFig6b{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig6b{1}(1:end-3), 'png'));
    
end