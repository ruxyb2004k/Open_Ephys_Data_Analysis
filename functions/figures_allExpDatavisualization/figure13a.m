%%% created by RB on 23.12.2020

% Fig. 13a (1x) : average amplitude - baseline
titleFig13a = {'Amplitude - baseline +/- photostim.'};

saveFig13a = {'meanAmplMinusBase.fig'};
if totalStim ==6 
    figure
    ax = gca;
    hold on
    for cond = 1:totalConds-2
        plot((1:totalStim),meanAmplMinusBase(cond,1:totalStim),'Marker','.','LineWidth', 3, 'Color', C(cond,:)); hold on
    end
    max_hist1 = 1.2 *max(max(meanAmplMinusBase))*1.3;
    xlabel('Stim#');
    ylabel('Ampl-base spike freq. (Hz)');
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    xticks([1:totalStim]);
    set(ax,'YLim',[-0.5 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig13a,'FontSize',18);
    background = get(gcf, 'color');
    for cond = 1:totalConds-2
        errorbar((1:totalStim),meanAmplMinusBase(cond,1:totalStim),STEMamplMinusBase(cond,1:totalStim), 'Color', C(cond,:)); hold on
    end

elseif totalStim ==1
    figure
    ax = gca;
    hold on
    plot((1:totalConds/2-1),meanAmplMinusBase(1:2:totalConds-2),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalConds/2-1),meanAmplMinusBase(2:2:totalConds-2),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
    
    max_hist1 = 1.2 *max(meanAmplMinusBase)*1.3;
    xlabel('Contrast');
    ylabel('Ampl-base spike freq. (Hz)');
    set(ax,'XLim',[0.8 totalConds/2-1+0.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    xticklabels({'100%', '50%', '25%', '12%'});
    set(ax,'YLim',[-0.5 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig13a,'FontSize',18);
    background = get(gcf, 'color');
    errorbar((1:totalConds/2-1),meanAmplMinusBase(1:2:totalConds-2),STEMamplMinusBase(1:2:totalConds-2), 'Color', C(1,:)); hold on
    errorbar((1:totalConds/2-1),meanAmplMinusBase(2:2:totalConds-2),STEMamplMinusBase(2:2:totalConds-2), 'Color', C(2,:)); hold on

end
if saveFigs == true
    savefig(strcat(savePath, saveFig13a{1}));
end
