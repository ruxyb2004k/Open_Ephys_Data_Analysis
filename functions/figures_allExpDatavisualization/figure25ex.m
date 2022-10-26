%% Fig. 25ex (1x) : bar plot of magnitude, related to fig 5biii from eLife 2020 (average magnitude of non-normalized traces)

if totalStim == 6
    titleFig25ex = {'Normalized magnitude of base-subtr traces'};
    saveFig25ex = {'meanMagnNormTracesBaseSubtr100Bar.fig'};
% elseif totalStim == 1
%     titleFig25dx= {'Normalized amplitude to 100% visual stim. without photostim.'};
% 
%     saveFig25dx = {'meanNormAmplTo100.fig'};
end

cond = 1;
figure

ax = gca;
hold on
conds = [2];
if totalStim == 6
    barYval = meanAllStimMagn(cond:cond+1,stims);
    barYval = barYval(:);
    stims = [1,4];
    b25ex =bar(1:4, barYval(:), 'EdgeColor', 'none', 'BarWidth', 0.6); hold on
    b25ex.FaceColor = 'flat';
    b25ex.CData(1,:) = C(1,:);
    b25ex.CData(2,:) = C(2,:);
    b25ex.CData(3,:) = C(1,:);
    b25ex.CData(4,:) = C(2,:);
    errorbar([1,3],barYval([1,3]),STEMallStimMagn(cond,stims), '.','Color', C(cond,:),'LineWidth', 2); hold on
    errorbar([2,4],barYval([2,4]),STEMallStimMagn(cond+1,stims),'.','Color', C(cond+1,:),'LineWidth', 2); hold on
    
    for stim = stims
        p_temp =  pAllStimMagn(cond, stim);
        y = max(meanAllStimMagn(cond, stims)-STEMallStimMagn(cond, stims));
        yf = 0.95;
        if p_temp <= 0.001
            text(stim, y*yf+cond/100,'***','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(stim, y*yf+cond/100,'**','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(stim, y*yf+cond/100,'*','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
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
max_hist1 = max(max(meanAllStimMagn))*1.5;

ylabel('Magnitude (normalized)');
set(ax,'xtick',[1:4]) % set major ticks
xticklabels({'V(pre)', 'V_p_h(pre)', 'V(post)', 'V_p_h(post)'})
set(ax, 'TickDir', 'out');
set(ax,'YLim',[0 max_hist1]);
set(ax,'FontSize',fs-6)
title(titleFig25ex,'FontSize',18);
background = get(gcf, 'color');


if saveFigs == true
    savefig(strcat(savePath, saveFig25ex{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig25ex{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig25ex{1}(1:end-4)), 'epsc');
end

