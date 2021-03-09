%% Fig. 25b (1x) : reproduction of fig 5bi from eLife 2020 (average amplitude of normalized and baseline subtr traces)

if totalStim == 6
    titleFig25b = {'Normalized amplitude of base-subtr traces'};
    saveFig25b = {'meanAmplNormTracesBaseSubtr100.fig'};
% elseif totalStim == 1
%     titleFig25b = {'Normalized amplitude to 100% visual stim. without photostim.'};
% 
%     saveFig25b = {'meanNormAmplTo100.fig'};
end

cond = 1;
figure

ax = gca;
hold on
conds = [1,2,6];
if totalStim == 6
    for cond = conds
        plot((1:totalStim),meanAllStimAmplNormTracesBaseSubtr100(cond, :),'Marker','.','LineWidth', 3, 'Color', C(cond,:)); hold on
        errorbar((1:totalStim),meanAllStimAmplNormTracesBaseSubtr100(cond,:),STEMallStimAmplNormTracesBaseSubtr100(cond,:), 'Color', C(cond,:));
    
        if cond ~= 1
            for stim = 1:totalStim
                p_temp =  pAllStimAmplNormTracesBaseSubtr100(cond/2, stim);
                y = min(meanAllStimAmplNormTracesBaseSubtr100(cond, stim)+STEMallStimAmplNormTracesBaseSubtr100(cond, stim));
                if p_temp <= 0.001
                    text(stim, y-0.25*sign(y),'***','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                elseif p_temp <= 0.01
                    text(stim, y-0.25*sign(y),'**','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                elseif p_temp <= 0.05
                    text(stim, y-0.25*sign(y),'*','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                end
            end
        end
    end
    xlabel('Stim #')
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);  
% elseif totalStim == 1 % copied from fig 6b and not midfied yet
%     plot((1:totalConds/2-1),meanNormAllStimAmpl100(1:2:end-2, :),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
%     plot((1:totalConds/2-1),meanNormAllStimAmpl100(2:2:end-2, :),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
%     xlabel('Contrast');
%     xticks(1:totalConds/2-1);
%     xticklabels({'100%', '50%', '25%', '12%'});
%     set(ax,'XLim',[0.8 totalConds/2-1+0.2],'FontSize',fs);
%     errorbar((1:totalConds/2-1),meanNormAllStimAmpl100(1:2:end-2, :),STEMnormAllStimAmpl100(1:2:end-2,:), 'Color', C(1,:)); hold on
%     errorbar((1:totalConds/2-1),meanNormAllStimAmpl100(2:2:end-2, :),STEMnormAllStimAmpl100(2:2:end-2,:), 'Color', C(2,:)); hold on
%     for cond = 1:2:totalConds-2
%         p_temp =  pNormAllStimAmpl100((cond+1)/2);
%         y = max(meanNormAllStimAmpl100(cond:cond+1)+STEMnormAllStimAmpl100(cond:cond+1));
%         if p_temp <= 0.001
%             text((cond+1)/2, y+0.05*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
%         elseif p_temp <= 0.01
%             text((cond+1)/2, y+0.05*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
%         elseif p_temp <= 0.05
%             text((cond+1)/2, y+0.05*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
%         end
%     end  
%     
end
max_hist1 = max(max(meanAllStimAmplNormTracesBaseSubtr100))*1.5;

ylabel('Norm. ampl.');

set(ax, 'TickDir', 'out');
set(ax,'YLim',[-0.2 max_hist1]);
set(ax,'FontSize',fs)
set(ax,'FontSize',fs)
title(titleFig25b,'FontSize',18);
background = get(gcf, 'color');

     
if saveFigs == true
    savefig(strcat(savePath, saveFig25b{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig25b{1}(1:end-3), 'png'));
    
end

