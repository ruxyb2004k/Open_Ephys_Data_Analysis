%%% created by RB on 23.12.2020

% Fig. 13c (1x) : average amplitude - baseline on normalized traces

titleFig13c = {'Amplitude - baseline +/- photostim. from norm trace'};

saveFig13c = {'meanAmplMinusBaseNormTrace.fig'};

if totalStim == 6
    figure
    ax = gca;
    hold on
    for cond = 1:totalConds-2
        plot((1:totalStim),meanAmplMinusBaseNormTrace(cond,1:totalStim),'Marker','.','LineWidth', 3, 'Color', C(cond,:)); hold on
    end
    max_hist1 = 1.2 *max(max(meanAmplMinusBaseNormTrace))*1.3;
    xlabel('Stim#');
    ylabel('Amplitude-baseline spike freq. (Hz)');
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[-2.5 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig13a,'FontSize',18);
    background = get(gcf, 'color');
    for cond= 1:totalConds-2
        errorbar((1:totalStim),meanAmplMinusBaseNormTrace(cond,1:totalStim),STEMamplMinusBaseNormTrace(cond,1:totalStim), 'Color', C(cond,:)); hold on
    end

elseif totalStim ==1
    
    figure
    ax = gca;
    hold on
    plot((1:totalConds/2-1),meanAmplMinusBaseNormTrace(1:2:totalConds-2),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalConds/2-1),meanAmplMinusBaseNormTrace(2:2:totalConds-2),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
    
    max_hist1 = 1.2 *max(meanAmplMinusBaseNormTrace)*1.3;
    xlabel('Condition (contrast)');
    ylabel('Normalized amplitude-baseline');
    set(ax,'XLim',[0.8 totalConds/2-1+0.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[-0.5 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig13c,'FontSize',18);
    background = get(gcf, 'color');
    errorbar((1:totalConds/2-1),meanAmplMinusBaseNormTrace(1:2:totalConds-2),STEMamplMinusBaseNormTrace(1:2:totalConds-2), 'Color', C(1,:)); hold on
    errorbar((1:totalConds/2-1),meanAmplMinusBaseNormTrace(2:2:totalConds-2),STEMamplMinusBaseNormTrace(2:2:totalConds-2), 'Color', C(2,:)); hold on
end
if saveFigs == true
    savefig(strcat(savePath, saveFig13c{1}));
end