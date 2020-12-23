%%% created by RB on 23.12.2020

% Fig. 5a (1x) : average amplitude 

if totalStim == 6
    titleFig5a = {'Amplitude 100% visual stim. +/- photostim.',...
        'Amplitude 0% visual stim. +/- photostim.'};
    
    saveFig5a = {'meanAmpl100.fig','meanAmpl0.fig'};
elseif totalStim == 1
    titleFig5a = {'Amplitude 100% visual stim. +/- photostim.',...
    'Amplitude 50% visual stim. +/- photostim.', ...
    'Amplitude 25% visual stim. +/- photostim.', ...
    'Amplitude 12% visual stim. +/- photostim.', ...
    'Amplitude 0% visual stim. +/- photostim.'};

    saveFig5a = {'meanAmpl100.fig', 'meanAmpl50.fig','meanAmpl25.fig','meanAmpl12.fig','meanAmpl0.fig'};
end

for cond = (1:2:totalConds-2)
    figure
    ax = gca;
    hold on
    plot((1:totalStim),meanAllStimAmpl(cond,:),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalStim),meanAllStimAmpl(cond+1,:),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
    max_hist1 = 1.2 *max(max(meanAllStimAmpl(cond:cond+1,:)))*1.3;
    xlabel('Stim#');
    ylabel('Amplitude spike freq. (Hz)');
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);
    set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[0 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig5a{(cond+1)/2},'FontSize',18);
    background = get(gcf, 'color');
    line ([1 10], [0 0], 'Color', [0 0 0]);
    errorbar((1:totalStim),meanAllStimAmpl(cond,:),STEMallStimAmpl(cond,:), 'Color', C(1,:)); hold on
    errorbar((1:totalStim),meanAllStimAmpl(cond+1,:),STEMallStimAmpl(cond+1,:), 'Color', C(2,:)); hold on
    if saveFigs == true
        savefig(strcat(savePath, saveFig5a{(cond+1)/2}));
    end
end