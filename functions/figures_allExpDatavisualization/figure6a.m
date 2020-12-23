%%% created by RB on 23.12.2020

% Fig. 6a (5x) : average normalized amplitude

if totalStim == 1
    titleFig6a = {'Normalized amplitude 100% visual stim. +/- photostim.',...
        'Normalized amplitude 50% visual stim. +/- photostim.', ...
        'Normalized amplitude 25% visual stim. +/- photostim.', ...
        'Normalized amplitude 12% visual stim. +/- photostim.', ...
        'Normalized amplitude 0% visual stim. +/- photostim.'};
    
    saveFig6a = {'meanNormAmpl100.fig', 'meanNormAmpl50.fig','meanNormAmpl25.fig','meanNormAmpl12.fig','meanNormAmpl0.fig'};
    
    for cond = (1:2:totalConds)
        figure
        ax = gca;
        hold on
        plot(1,meanNormAllStimAmpl(cond),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
        plot(1,meanNormAllStimAmpl(cond+1),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
        max_hist1 = 1.2 *max(meanNormAllStimAmpl(cond:cond+1))*1.3;
        xlabel('Contrast');
        ylabel('Normalized amplitude');
        set(ax,'XLim',[0.8 1.2],'FontSize',fs);
        set(ax, 'TickDir', 'out');
%         set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
        set(ax,'FontSize',fs)
        title(titleFig6a{(cond+1)/2},'FontSize',18);
        background = get(gcf, 'color');
        errorbar((1),meanNormAllStimAmpl(cond),STEMnormAllStimAmpl(cond), 'Color', C(1,:)); hold on
        errorbar((1),meanNormAllStimAmpl(cond+1),STEMnormAllStimAmpl(cond+1), 'Color', C(2,:)); hold on
        if saveFigs == true
            savefig(strcat(savePath, saveFig6a{(cond+1)/2}));
        end
    end
end