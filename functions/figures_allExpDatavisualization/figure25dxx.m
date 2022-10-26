%% Fig. 25dxx (1x) : bar plot of magnitude, related to fig 5biii from eLife 2020 (average magnitude of normalized and baseline subtr traces)

if totalStim == 6
    titleFig25dxx = {'Normalized magnitude of base-subtr traces'};
    saveFig25dxx = {'meanMagnNormTracesBaseSubtr100Bar.fig'};
% elseif totalStim == 1
%     titleFig25dx= {'Normalized amplitude to 100% visual stim. without photostim.'};
% 
%     saveFig25dx = {'meanNormAmplTo100.fig'};
end

cond = 1;
f = figure('Renderer', 'painters', 'Position', [680 558 360 420]); % left bottom width height

ax = gca;
hold on
conds = [1,2];
if totalStim == 6
    stims = [4];
    
    barYval = meanAllStimMagnNormTracesBaseSubtr100(cond:cond+1,stims);
    barYval = barYval(:);
    
    b25dxx =bar(1:2, barYval(:), 'EdgeColor', 'none', 'BarWidth', 0.6); hold on
    b25dxx.FaceColor = 'flat';
    b25dxx.CData(1,:) = C(1,:);
    b25dxx.CData(2,:) = C(2,:);
%     b25dxx.CData(3,:) = C(1,:);
%     b25dxx.CData(4,:) = C(2,:);
    errorbar([1],barYval([1]),STEMallStimMagnNormTracesBaseSubtr100(cond,stims), '.','Color', C(cond,:),'LineWidth', 2); hold on
    errorbar([2],barYval([2]),STEMallStimMagnNormTracesBaseSubtr100(cond+1,stims),'.','Color', C(cond+1,:),'LineWidth', 2); hold on
    
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
            set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        end

    end
    

    set(ax,'XLim',[0.4 2+0.6],'FontSize',fs);
end
max_hist1 = max(max(meanAllStimMagnNormTracesBaseSubtr100))*1.5;
max_hist1 = 1.2;
h1 = line([0.7 2.3], [max_hist1 max_hist1]);
set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines

ylabel('Magnitude (norm. to 1st resp.)');
set(ax,'xtick',[1:2]) % set major ticks
xticklabels({'V(#4)', 'V_p_h(#4)'})
set(ax, 'TickDir', 'out');
set(ax,'YLim',[0 max_hist1]);
set(ax,'FontSize',fs-6)
title(titleFig25dxx,'FontSize',18);
background = get(gcf, 'color');


if saveFigs == true
    savefig(strcat(savePath, saveFig25dxx{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig25dxx{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig25dxx{1}(1:end-4)), 'epsc');
end

