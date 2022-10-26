%%% created by RB on 11.06.2021

% Fig. 9g -  histograms of opto-index for each cell type and PDFs

if totalStim == 6
    titleFig9g = {'PDF OI 100% visual stim. +/- photostim. Ampl2',...
        'PDF OI 100% visual stim. +/- photostim. Ampl3',...
        'PDF OI 100% visual stim. +/- photostim. Ampl4',...
        'PDF OI 100% visual stim. +/- photostim. Ampl5',...
        'PDF OI 100% visual stim. +/- photostim. Ampl6',...
        'PDF OI 0% visual stim. +/- photostim. Ampl2',...
        'PDF OI 0% visual stim. +/- photostim. Ampl3',...
        'PDF OI 0% visual stim. +/- photostim. Ampl4',...
        'PDF OI 0% visual stim. +/- photostim. Ampl5',...
        'PDF OI 0% visual stim. +/- photostim. Ampl6'};
    
    saveFig9g = {'PDFOI100Ampl2.fig', 'PDFOI100Ampl3.fig',...
        'PDFOI100Ampl4.fig', 'PDFOI100Ampl5.fig',...
        'PDFOI100Ampl6.fig',...
        'PDFOI0Ampl2.fig', 'PDFOI0Ampl3.fig',...
        'PDFOI0Ampl4.fig', 'PDFOI0Ampl5.fig',...
        'PDFOI0Ampl6.fig'};
elseif totalStim == 1
    titleFig9g = {'PDF OI 100% visual stim. +/- photostim. Ampl2',...
        'PDF OI 100% visual stim. +/- photostim. Ampl3',...
        'PDF OI 50% visual stim. +/- photostim. Ampl2',...
        'PDF OI 50% visual stim. +/- photostim. Ampl3',...
        'PDF OI 25% visual stim. +/- photostim. Ampl2',...
        'PDF OI 25% visual stim. +/- photostim. Ampl3',...
        'PDF OI 12% visual stim. +/- photostim. Ampl2',...
        'PDF OI 12% visual stim. +/- photostim. Ampl3',...
        'PDF OI 0% visual stim. +/- photostim. Ampl2',...
        'PDF OI 0% visual stim. +/- photostim. Ampl3'};
    
    saveFig9g = {'PDFOI100Ampl2.fig', 'PDFOI100Ampl3.fig',...
        'PDFOI50Ampl2.fig', 'PDFOI50Ampl3.fig',...
        'PDFOI25Ampl2.fig', 'PDFOI25Ampl3.fig',...
        'PDFOI12Ampl2.fig', 'PDFOI20Ampl3.fig',...
        'PDFOI0Ampl2.fig', 'PDFOI0Ampl3.fig'};
end

for cond = (1:2:totalConds)
    for stim = 2:totalStim
        excUnits = iUnitsFilt &  classUnitsAll == 1;
        inhUnits = iUnitsFilt &  classUnitsAll == 2;
        binEdges = 0.25;
        edges = [-1:binEdges:1];
      
        f = figure('Renderer', 'painters', 'Position', [680 558 320 420]);     
     
        yyaxis right
        plot(OIvalues,squeeze(distOIndexAllStimAmplExc((cond+1)/2, stim,:)), '-g'); hold on
        plot(OIvalues,squeeze(distOIndexAllStimAmplInh((cond+1)/2, stim,:)), '-r');
        ylabel('prob. dens. func.'); 
        
        yyaxis left
        histogram(OIndexAllStimAmpl((cond+1)/2,excUnits, stim),edges, 'FaceColor', 'g'); hold on
        histogram(OIndexAllStimAmpl((cond+1)/2,inhUnits, stim),edges, 'FaceColor', 'r');
        
        
        yl = ylim;
        if pOIndexAllStimAmplExcInh((cond+1)/2, stim) <= 0.001
        %             pStars = '***';
            text(0, yl(2)*0.98, '***','FontSize',14,  'HorizontalAlignment','center')
        elseif pOIndexAllStimAmplExcInh((cond+1)/2, stim) <= 0.01
        %             pStars = '**';
            text(0, yl(2)*0.98, '**','FontSize',14, 'HorizontalAlignment','center')
        elseif pOIndexAllStimAmplExcInh((cond+1)/2, stim) <= 0.05
        %             pStars = '*';
            text(0, yl(2)*0.98, '*','FontSize',14, 'HorizontalAlignment','center')
        end

        xlabel('Opto-index'); 
        ylabel('% unit count'); 
        ax = gca;
        set(ax, 'FontSize',fs);
        set(ax, 'TickDir', 'out');
        xticks([-1:2*binEdges:1]);
        background = get(gcf, 'color');
        grid on
        grid minor
        box off
%         view([90 -90])
        title(titleFig9g{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))},'FontSize',18);
        if saveFigs == true
            savefig(strcat(savePath, saveFig9g{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))}));
        end

    end
end


