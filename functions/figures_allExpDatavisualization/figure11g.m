%%% created by RB on 11.06.2021

% Fig. 11g -  histograms of combined baseline opto-index for each cell type and PDFs

if totalStim == 6
    titleFig11g = {'PDF OI +/- photostim. comb Base2',...
        'PDF OI +/- photostim. comb Base3',...
        'PDF OI +/- photostim. comb Base4',...
        'PDF OI +/- photostim. comb Base5',...
        'PDF OI +/- photostim. comb Base6'};
    
    saveFig11g = {'PDFOICombBase2.fig', 'PDFOICombBase3.fig',...
        'PDFOICombBase4.fig', 'PDFOICombBase5.fig',...
        'PDFOICombBase6.fig'};

elseif totalStim == 1
    titleFig11g = {'PDF OI +/- photostim. comb Base2',...
        'PDF OI +/- photostim. comb Base3'};
    
    saveFig11g = {'PDFOICombBase2.fig', 'PDFOIBase3.fig'};
end

    
cond = 2;
for stim = 2:numel(baseStim)
    excUnits = iUnitsFilt &  classUnitsAll == 1;
    inhUnits = iUnitsFilt &  classUnitsAll == 2;
    binEdges = 0.25;
    edges = [-1:binEdges:1];
    
    f = figure('Renderer', 'painters', 'Position', [680 558 320 420]);
    
    yyaxis right
    plot(OIvalues,squeeze(distOIndexAllStimBaseCombExc(cond, stim,:)), '-g'); hold on
    plot(OIvalues,squeeze(distOIndexAllStimBaseCombInh(cond, stim,:)), '-r');
    ylabel('prob. dens. func.');
    
    yyaxis left
    histogram(OIndexAllStimBaseComb(cond,excUnits, stim),edges, 'FaceColor', 'g'); hold on
    histogram(OIndexAllStimBaseComb(cond,inhUnits, stim),edges, 'FaceColor', 'r');
    
    
    yl = ylim;
    if pOIndexAllStimBaseCombExcInh(cond, stim) <= 0.001
        %             pStars = '***';
        text(0, yl(2)*0.98, '***','FontSize',14,  'HorizontalAlignment','center')
    elseif pOIndexAllStimBaseCombExcInh(cond, stim) <= 0.01
        %             pStars = '**';
        text(0, yl(2)*0.98, '**','FontSize',14, 'HorizontalAlignment','center')
    elseif pOIndexAllStimBaseCombExcInh(cond, stim) <= 0.05
        %             pStars = '*';
        text(0, yl(2)*0.98, '*','FontSize',14, 'HorizontalAlignment','center')
    end
    
    xlabel('Opto-index');
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
    %         view([90 -90])
    title(titleFig11g{stim-1},'FontSize',18);
    if saveFigs == true
        savefig(strcat(savePath, saveFig11g{stim-1}));
    end
    
end



