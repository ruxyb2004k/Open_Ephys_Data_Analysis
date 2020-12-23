%%% created by RB on 23.12.2020

% Fig 11b (2x): Opto-index indivdual data points with average and errorbars - comparison combined baselines between before and during photostim. 

if totalStim == 1
    titleFig11b = {'Opto-index combined +/- photostim. Base2',...
        'Opto-index combined +/- photostim. Base3'};
    
    saveFig11b = {'OptoindexScatterplotCombBase2.fig', 'OptoindexScatterplotCombBase3.fig'};
    cond = 2;
    for stim =2:3
        figure
        ax = gca;
        hold on
        for unitInd = 1:totalBaseSelectUnits
            unit = baseSelectUnits(unitInd);
            plot(1, OIndexAllStimBaseComb(cond,unit, stim), 'Marker','o','MarkerSize',20,'Color', C_units(baseSelectUnits(unitInd),:));
        end
        scatter((1.1), meanOIndexAllStimBaseComb(cond,stim), 200, '+', 'k', 'LineWidth', 2); hold on
        
        ylabel('Opto-index','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'XLim',[0.8 1.2],'YLim', [-1 1],'FontSize',24);
        title(titleFig11b{stim-1},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        errorbar((1.1),meanOIndexAllStimBaseComb(cond,stim),STEMOIndexAllStimBaseComb(cond, stim),'.k','LineWidth',2);
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig11b{stim-1}));
        end
    end
end