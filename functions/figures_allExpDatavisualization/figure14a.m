%%% created by RB on 23.12.2020

% Fig. 14a (1x) : average normalized amplitude -baseline

if totalStim == 6
    titleFig14a = {'Normalized amplitude 100% visual stim. +/- photostim.'};
    
    saveFig14a = {'meanNormAmpl100.fig'};
      
    figure
    ax = gca;
    hold on
    for cond = 1:totalConds-2
        plot(1:totalStim,meanNormAmplMinusBase(cond, 1:totalStim),'Marker','.','LineWidth', 3, 'Color', C(cond,:)); hold on
    end
    max_hist1 = 1.2 *max(max(meanNormAmplMinusBase))*1.3;
    xlabel('Contrast');
    ylabel('Normalized amplitude-baseline');
    set(ax,'XLim',[0.8 6.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[-1 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig14a{1},'FontSize',18);
    background = get(gcf, 'color');
    for cond = 1:totalConds-2
        errorbar((1:totalStim),meanNormAmplMinusBase(cond,1:totalStim),STEMnormAmplMinusBase(cond,1:totalStim), 'Color', C(cond,:)); hold on
    end
    if saveFigs == true
        savefig(strcat(savePath, saveFig14a{1}));
    end

elseif totalStim == 1
    titleFig14a = {'Normalized amplitude 100% visual stim. +/- photostim.',...
    'Normalized amplitude 50% visual stim. +/- photostim.', ...
    'Normalized amplitude 25% visual stim. +/- photostim.', ...
    'Normalized amplitude 12% visual stim. +/- photostim.', ...
    'Normalized amplitude 0% visual stim. +/- photostim.'};

    saveFig14a = {'meanNormAmpl100.fig', 'meanNormAmpl50.fig','meanNormAmpl25.fig','meanNormAmpl12.fig','meanNormAmpl0.fig'};

    for cond = (1:2:totalConds-2)
        figure
        ax = gca;
        hold on
        plot(1,meanNormAmplMinusBase(cond),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
        plot(1,meanNormAmplMinusBase(cond+1),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
        max_hist1 = 1.2 *max(meanNormAmplMinusBase(cond:cond+1))*1.3;
        xlabel('Contrast');
        ylabel('Normalized amplitude-baseline');
        set(ax,'XLim',[0.8 1.2],'FontSize',fs);
        set(ax, 'TickDir', 'out');
        set(ax,'YLim',[-1 max_hist1],'FontSize',fs)
        set(ax,'FontSize',fs)
        title(titleFig14a{(cond+1)/2},'FontSize',18);
        background = get(gcf, 'color');
        errorbar((1),meanNormAmplMinusBase(cond),STEMnormAmplMinusBase(cond), 'Color', C(1,:)); hold on
        errorbar((1),meanNormAmplMinusBase(cond+1),STEMnormAmplMinusBase(cond+1), 'Color', C(2,:)); hold on
        if saveFigs == true
            savefig(strcat(savePath, saveFig14a{(cond+1)/2}));
        end
    end
end