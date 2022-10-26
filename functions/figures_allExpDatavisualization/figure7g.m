%%% created by RB on 11.06.2021

% Fig. 7g -  histograms of opto-index for each cell type and PDFs

if totalStim == 6
    titleFig7g = {'PDF OI 100% visual stim. +/- photostim. Base2',...
        'PDF OI 100% visual stim. +/- photostim. Base3',...
        'PDF OI 100% visual stim. +/- photostim. Base4',...
        'PDF OI 100% visual stim. +/- photostim. Base5',...
        'PDF OI 100% visual stim. +/- photostim. Base6',...
        'PDF OI 0% visual stim. +/- photostim. Base2',...
        'PDF OI 0% visual stim. +/- photostim. Base3',...
        'PDF OI 0% visual stim. +/- photostim. Base4',...
        'PDF OI 0% visual stim. +/- photostim. Base5',...
        'PDF OI 0% visual stim. +/- photostim. Base6'};
    
    saveFig7g = {'PDFOI100Base2.fig', 'PDFOI100Base3.fig',...
        'PDFOI100Base4.fig', 'PDFOI100Base5.fig',...
        'PDFOI100Base6.fig',...
        'PDFOI0Base2.fig', 'PDFOI0Base3.fig',...
        'PDFOI0Base4.fig', 'PDFOI0Base5.fig',...
        'PDFOI0Base6.fig'};
elseif totalStim == 1
    titleFig7g = {'PDF OI 100% visual stim. +/- photostim. Base2',...
        'PDF OI 100% visual stim. +/- photostim. Base3',...
        'PDF OI 50% visual stim. +/- photostim. Base2',...
        'PDF OI 50% visual stim. +/- photostim. Base3',...
        'PDF OI 25% visual stim. +/- photostim. Base2',...
        'PDF OI 25% visual stim. +/- photostim. Base3',...
        'PDF OI 12% visual stim. +/- photostim. Base2',...
        'PDF OI 12% visual stim. +/- photostim. Base3',...
        'PDF OI 0% visual stim. +/- photostim. Base2',...
        'PDF OI 0% visual stim. +/- photostim. Base3'};
    
    saveFig7g = {'PDFOI100Base2.fig', 'PDFOI100Base3.fig',...
        'PDFOI50Base2.fig', 'PDFOI50Base3.fig',...
        'PDFOI25Base2.fig', 'PDFOI25Base3.fig',...
        'PDFOI12Base2.fig', 'PDFOI20Base3.fig',...
        'PDFOI0Base2.fig', 'PDFOI0Base3.fig'};
end
fC=0.2; % 0.8 for waveforms
EI_Color = [fC,1-fC,fC; 1,fC,fC];
% EI_Color = [128,255,128; 255,127,127]/255;
for cond = (1:2:totalConds)
    for stim = 2:numel(baseStim)
        excUnits = iUnitsFilt &  classUnitsAll == 1;
        inhUnits = iUnitsFilt &  classUnitsAll == 2;
        binEdges = 0.25;
        edges = [-1:binEdges:1];
      
        f = figure('Renderer', 'painters', 'Position', [680 558 420 420]);     
     
        yyaxis right
        plot(OIvalues,squeeze(distOIndexAllStimBaseExc((cond+1)/2, stim,:)), '-g', 'LineWidth', 3); hold on
        plot(OIvalues,squeeze(distOIndexAllStimBaseInh((cond+1)/2, stim,:)), '-r', 'LineWidth', 3);
        ylabel('Prob. dens. func.'); 
        set(gca,'ycolor', 'k');        
        set(gca,'xcolor', 'k');
        
        yyaxis left
        [N1,~] = histcounts(OIndexAllStimBase((cond+1)/2,excUnits, stim), edges);
        [N2,~] = histcounts(OIndexAllStimBase((cond+1)/2,inhUnits, stim), edges);

        histogram(OIndexAllStimBase((cond+1)/2,excUnits, stim),edges, 'FaceColor', EI_Color(1,:)); hold on
        histogram(OIndexAllStimBase((cond+1)/2,inhUnits, stim),edges, 'FaceColor', EI_Color(2,:));
        
        set(gca, 'ycolor', 'k');
        yl = ylim;
        if pOIndexAllStimBaseExcInh((cond+1)/2, stim) <= 0.001
        %             pStars = '***';
            text(0, yl(2)*0.98, '***','FontSize',fsStars,  'HorizontalAlignment','center')
        elseif pOIndexAllStimBaseExcInh((cond+1)/2, stim) <= 0.01
        %             pStars = '**';
            text(0, yl(2)*0.98, '**','FontSize',fsStars, 'HorizontalAlignment','center')
        elseif pOIndexAllStimBaseExcInh((cond+1)/2, stim) <= 0.05
        %             pStars = '*';
            text(0, yl(2)*0.98, '*','FontSize',fsStars, 'HorizontalAlignment','center')
        end

        xlabel('Opto-index'); 
        ylabel('Unit count'); 
        ax = gca;
        set(ax, 'FontSize',fs);
        set(ax, 'TickDir', 'out');
        set(ax,'FontSize',fs)
        xticks([-1:2*binEdges:1]);
        background = get(gcf, 'color');
        grid off
%         grid on
%         grid minor
        box off
%         view([90 -90])
        line([0,0],[0 max([N1,N2])], 'color', 'k', 'LineWidth', 5)
        title(titleFig7g{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))},'FontSize',18);
        if saveFigs == true
            savefig(strcat(savePath, saveFig7g{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))}));
            title('');
            saveas(gcf, strcat(savePath, saveFig7g{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))}(1:end-3), 'png'));
            saveas(gcf, strcat(savePath, saveFig7g{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))}(1:end-4)), 'epsc');
        end

    end
end


