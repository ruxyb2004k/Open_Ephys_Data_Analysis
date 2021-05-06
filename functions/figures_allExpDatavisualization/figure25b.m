%% Fig. 25b (1x) : reproduction of fig 5bi from eLife 2020 (average amplitude of normalized and baseline subtr traces)

if totalStim == 6
    titleFig25b = {'Normalized amplitude of base-subtr traces'};
    saveFig25b = {'meanAmplNormTracesBaseSubtr100.fig'};
    
    figure
    
    ax = gca;
    hold on
    conds = [1,2,6];
    
    for cond = conds
        plot((1:totalStim),meanAllStimAmplNormTracesBaseSubtr100(cond, :),'Marker','.','LineWidth', 3, 'Color', C(cond,:)); hold on
        errorbar((1:totalStim),meanAllStimAmplNormTracesBaseSubtr100(cond,:),STEMallStimAmplNormTracesBaseSubtr100(cond,:), 'Color', C(cond,:));
        
        if cond ~= 1
            for stim = 1:totalStim
                p_temp =  pAllStimAmplNormTracesBaseSubtr100(cond/2, stim);
                y = min(meanAllStimAmplNormTracesBaseSubtr100(conds, stim)-STEMallStimAmplNormTracesBaseSubtr100(conds, stim));
                if p_temp <= 0.001
                    text(stim, y-0.2*sign(y)*cond/5,'***','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                elseif p_temp <= 0.01
                    text(stim, y-0.2*sign(y)*cond/5,'**','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                elseif p_temp <= 0.05
                    text(stim, y-0.2*sign(y)*cond/5,'*','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                end
            end
        end
    end
    xlabel('Stim #')
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);
    
    max_hist1 = max(max(meanAllStimAmplNormTracesBaseSubtr100))*1.5;
    
    ylabel('Norm. ampl.');
    set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[-0.2 max_hist1]);
    set(ax,'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig25b,'FontSize',18);
    background = get(gcf, 'color');
    h1 = line([1.7 4.3], [max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    
    if saveFigs == true
        savefig(strcat(savePath, saveFig25b{1}));
        title('');
        saveas(gcf, strcat(savePath, saveFig25b{1}(1:end-3), 'png'));
        
    end
end
