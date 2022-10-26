%% Fig. 25dx (1x) : bar plot of magnitude, related to fig 5biii from eLife 2020 (average magnitude of normalized and baseline subtr traces)

if totalStim == 6
    titleFig25dx = {'Normalized magnitude of base-subtr traces'};
    saveFig25dx = {'meanMagnNormTracesBaseSubtr100Bar.fig'};
% elseif totalStim == 1
%     titleFig25dx= {'Normalized amplitude to 100% visual stim. without photostim.'};
% 
%     saveFig25dx = {'meanNormAmplTo100.fig'};
end

cond = 1;
figure

ax = gca;
hold on
conds = [1,2];
if totalStim == 6
    stims = [1,4]; % [1,4]
    
    barYval = meanAllStimMagnNormTracesBaseSubtr100(cond:cond+1,stims);
    barYval = barYval(:);
    
    b25dx =bar(1:2*numel(stims), barYval(:), 'EdgeColor', 'none', 'BarWidth', 0.6); hold on
    b25dx.FaceColor = 'flat';
    b25dx.CData(1,:) = C(1,:);
    b25dx.CData(2,:) = C(2,:);
    b25dx.CData(3,:) = C(1,:);
    b25dx.CData(4,:) = C(2,:);
    errorbar([1:2:numel(stims)*2],barYval([1:2:numel(stims)*2]),STEMallStimMagnNormTracesBaseSubtr100(cond,stims), '.','Color', C(cond,:),'LineWidth', 2); hold on
    errorbar([2:2:numel(stims)*2],barYval([2:2:numel(stims)*2]),STEMallStimMagnNormTracesBaseSubtr100(cond+1,stims),'.','Color', C(cond+1,:),'LineWidth', 2); hold on
    
    for stim = stims
        p_temp =  pAllStimMagnNormTracesBaseSubtr100(cond, stim);
        y = max(max(meanAllStimMagnNormTracesBaseSubtr100(conds, stims)+STEMallStimMagnNormTracesBaseSubtr100(conds, stims)))*1.1;
        yf = 0.95;
        x = find(stims==stim)*2;
        if p_temp <= 0.001
            text(x-0.5, y,'***','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
            h1 = line([x-1 x],[y*0.98 y*0.98]);
            set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp <= 0.01
            text(x-0.5, y,'**','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
            h1 = line([x-1 x],[y*0.98 y*0.98]);
            set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp <= 0.05
            text(x-0.5, y,'*','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
            h1 = line([x-1 x],[y*0.98 y*0.98]);
        end
        
    end
    

    set(ax,'XLim',[0.4 4+0.6],'FontSize',fs);
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
max_hist1 = max(max(meanAllStimMagnNormTracesBaseSubtr100))*1.5;

h1 = line([2.7 4.3], [max_hist1 max_hist1]);
set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines

ylabel('Magnitude (normalized)');
set(ax,'xtick',[1:4]) % set major ticks
xticklabels({'V(#1)', 'V_p_h(#1)', 'V(#4)', 'V_p_h(#4)'})
set(ax, 'TickDir', 'out');
set(ax,'YLim',[0 max_hist1]);
set(ax,'FontSize',fs-6)
title(titleFig25dx,'FontSize',18);
background = get(gcf, 'color');


if saveFigs == true
    savefig(strcat(savePath, saveFig25dx{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig25dx{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig25dx{1}(1:end-4)), 'epsc');
end

