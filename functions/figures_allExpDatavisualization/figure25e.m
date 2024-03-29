%% Fig. 25e (1x) : related to fig 5biii from eLife 2020 (average magnitude of non-normalized traces)

if totalStim == 6
    titleFig25e = {'Average magnitude of base-subtr traces'};
    saveFig25e = {'meanMagn.fig'};
% elseif totalStim == 1
%     titleFig25d = {'Normalized amplitude to 100% visual stim. without photostim.'};
% 
%     saveFig25d = {'meanNormAmplTo100.fig'};
end

cond = 1;
figure

ax = gca;
hold on
conds = [1,2];
if totalStim == 6
    for cond = conds
        plot((1:totalStim),meanAllStimMagn(cond, :),'Marker','.','LineWidth', 3, 'Color', C(cond,:)); hold on
        errorbar((1:totalStim),meanAllStimMagn(cond,:),STEMallStimMagn(cond,:), 'Color', C(cond,:));
    
        if cond ~= 1
            for stim = 1:totalStim
                p_temp =  pAllStimMagn(cond/2, stim);
                y = min(meanAllStimMagn(conds, stim)-STEMallStimMagn(conds, stim));
                yf = 0.95;
                if p_temp <= 0.001
                    text(stim, y*yf-cond/100,'***','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                elseif p_temp <= 0.01
                    text(stim, y*yf-cond/100,'**','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                elseif p_temp <= 0.05
                    text(stim, y*yf-cond/100,'*','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
                end
            end
        end
    end
    xlabel('Stim #')
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);  
% elseif totalStim == 1 % copied from fig 6b and not modfied yet
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
max_hist1 = max(max(meanAllStimMagn))*1.5;

ylabel('Magnitude (normalized)');
set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
set(ax, 'TickDir', 'out');
set(ax,'YLim',[0 max_hist1]);
set(ax,'FontSize',fs)
set(ax,'FontSize',fs)
title(titleFig25e,'FontSize',18);
background = get(gcf, 'color');

h1 = line([1.7 4.3], [max_hist1 max_hist1]);
set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines

if saveFigs == true
    savefig(strcat(savePath, saveFig25e{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig25e{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig25e{1}(1:end-4)), 'epsc');
end



