%%% created by RB on 21.04.2021

% Fig. 11e -  histograms of opto-index of combined baselines for each cell type

if totalStim == 6
    titleFig1e = {'Histogram OI visual stim. +/- photostim. Comb Base2',...
        'Histogram OI visual stim. +/- photostim. Comb Base3',...
        'Histogram OI visual stim. +/- photostim. Comb Base4',...
        'Histogram OI visual stim. +/- photostim. Comb Base5',...
        'Histogram OI visual stim. +/- photostim. Comb Base6'};
    
    saveFig11e = {'HistOICombBase2.fig', 'HistOICombBase3.fig',...
        'HistOICombBase4.fig', 'HistOICombBase5.fig',...
        'HistOICombBase6.fig'};
elseif totalStim == 1
    titleFig11e = {'Histogram OI visual stim. +/- photostim. Comb Base2',...
        'Histogram OI visual stim. +/- photostim. Comb Base3'};
    
    saveFig11e = {'HistOICombBase2.fig', 'HistOICombBase3.fig'};
end

cond = 2;
for stim = 2:numel(baseStim)
    excUnits = iUnitsFilt &  classUnitsAll == 1;
    inhUnits = iUnitsFilt &  classUnitsAll == 2;
    binEdges = 0.25;
    edges = [-1:binEdges:1];
    
    f = figure('Renderer', 'painters', 'Position', [680 558 320 420]);
    %         f.Position
    [histExc] = histcounts(OIndexAllStimBaseComb(cond,excUnits, stim),edges);
    [histInh] = histcounts(OIndexAllStimBaseComb(cond,inhUnits, stim),edges);
    normHistExc = histExc/sum(histExc)*100;
    normHistInh = histInh/sum(histInh)*100;
    
    plot(edges(1:end-1)+(edges(2)-edges(1))/2, normHistExc, '.-g'); hold on
    plot(edges(1:end-1)+(edges(2)-edges(1))/2, normHistInh, '.-r')
    xlabel('Opto-index');
    %         ylabel('Unit count');
    ylabel('% unit count');
    ax = gca;
    set(ax, 'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'FontSize',fs)
    xticks([-1:2*binEdges:1]);
    background = get(gcf, 'color');
    grid on
    grid minor
    box off
    view([90 -90])
    line([0,0],[0,100], 'Color','black','LineStyle','--')
    title(titleFig11e{stim-1},'FontSize',18);
    if saveFigs == true
        savefig(strcat(savePath, saveFig11e{stim-1}));
        title('');
        saveas(gcf, strcat(savePath, saveFig11e{stim-1}(1:end-3), 'png'));
    end
    
end
