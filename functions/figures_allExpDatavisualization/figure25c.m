%% Fig. 25c (1x) : reproduction of fig 5bii from eLife 2020 ( average baseline of normalized and baseline subtr traces)

if totalStim == 6
    titleFig25c = {'Normalized baseline of base-subtr traces'};
    saveFig25c = {'meanBaseNormTracesBaseSubtr100.fig'};
% elseif totalStim == 1
%     titleFig25c = {'Normalized amplitude to 100% visual stim. without photostim.'};
% 
%     saveFig25c = {'meanNormAmplTo100.fig'};
end

cond = 1;
figure
min_hist1 = -0.2;
ax = gca;
hold on
conds = [1,2,4,6];
if totalStim == 6
    for cond = conds
        plot((1:totalStim),meanAllStimBaseNormTracesBaseSubtr100(cond, :),'Marker','.','LineWidth', 3, 'Color', C(cond,:)); hold on
        errorbar((1:totalStim),meanAllStimBaseNormTracesBaseSubtr100(cond,:),STEMallStimBaseNormTracesBaseSubtr100(cond,:), 'Color', C(cond,:));
    
        if cond ~= 1
            for stim = 2:totalStim
                p_temp =  pAllStimBaseNormTracesBaseSubtr100(cond/2, stim);
                y = max(meanAllStimBaseNormTracesBaseSubtr100(conds, stim)+STEMallStimBaseNormTracesBaseSubtr100(conds, stim));
                min_hist1 = min(min(min(meanAllStimBaseNormTracesBaseSubtr100(conds, :)-STEMallStimBaseNormTracesBaseSubtr100(conds, :))), min_hist1);
                if p_temp <= 0.001
                    text(stim, y*1.01+cond/100,'***','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                elseif p_temp <= 0.01
                    text(stim, y*1.01+cond/100,'**','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                elseif p_temp <= 0.05
                    text(stim, y*1.01+cond/100,'*','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
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
max_hist1 = max(max(meanAllStimBaseNormTracesBaseSubtr100))*2.5;
line([plotBeg plotEnd], [0 0], 'Color', [.5 .5 .5 ])
ylabel('Norm. baseline');
set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
h1 = line([1.7 4.3], [max_hist1 max_hist1]);
set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines

set(ax, 'TickDir', 'out');
set(ax,'YLim',[min_hist1 max_hist1]);
set(ax,'FontSize',fs)
set(ax,'FontSize',fs)
title(titleFig25c,'FontSize',18);
background = get(gcf, 'color');

     
if saveFigs == true
    savefig(strcat(savePath, saveFig25c{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig25c{1}(1:end-3), 'png'));    
end



