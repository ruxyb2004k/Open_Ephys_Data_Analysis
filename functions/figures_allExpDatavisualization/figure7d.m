%%% created by RB on 23.12.2020

% Fig 7d (10x): Opto-index indivdual data points with average and errorbars - comparison baselines between before and during photostim. 
% as 7b, but markers for each cell type

titleFig7d = {'Opto-index 100% visual stim. +/- photostim. Base2',...
    'Opto-index 100% visual stim. +/- photostim. Base3',...
    'Opto-index 100% visual stim. +/- photostim. Base4',...
    'Opto-index 100% visual stim. +/- photostim. Base5',...
    'Opto-index 100% visual stim. +/- photostim. Base6',...
    'Opto-index 0% visual stim. +/- photostim. Base2',...
    'Opto-index 0% visual stim. +/- photostim. Base3',...
    'Opto-index 0% visual stim. +/- photostim. Base4',...
    'Opto-index 0% visual stim. +/- photostim. Base5',...
    'Opto-index 0% visual stim. +/- photostim. Base6'};

saveFig7d = {'OptoindexScatterplot100Base2Class.fig', 'OptoindexScatterplot100Base3Class.fig',...
    'OptoindexScatterplot100Base4Class.fig', 'OptoindexScatterplot100Base5Class.fig',...
    'OptoindexScatterplot100Base6Class.fig',...
    'OptoindexScatterplot0Base2Class.fig', 'OptoindexScatterplot0Base3Class.fig',...
    'OptoindexScatterplot0Base4Class.fig', 'OptoindexScatterplot0Base5Class.fig',...
    'OptoindexScatterplot0Base6Class.fig'};

for cond = (1:2:totalConds)
    for stim =2:totalStim
        figure
        ax = gca;
        hold on
        % beeswarm graph
        plotSpread(squeeze(OIndexAllStimBase((cond+1)/2,:, stim))','categoryIdx',classUnitsAll,...
            'categoryMarkers',{'^','o'},'categoryColors',{'g','r'},'spreadWidth', 0.2)
        % regular graph
%         for unit = 1:totalUnits
%             if classUnitsAll(unit) == 1
%                 plot(1, OIndexAllStimBase((cond+1)/2,unit, stim), 'Marker','^','MarkerSize',20,'Color', C_units(unit,:));
%             elseif classUnitsAll(unit) == 2
%                 plot(1, OIndexAllStimBase((cond+1)/2,unit, stim), 'Marker','o','MarkerSize',20,'Color', C_units(unit,:));
%             end
%             text(0.95, OIndexAllStimBase((cond+1)/2,unit, stim), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on
%         end
        scatter((1.1), meanOIndexAllStimBase((cond+1)/2, stim), 200, '+', 'k', 'LineWidth', 2); hold on
        scatter((1.15), meanOIndexAllStimBaseExc((cond+1)/2, stim), 200, '+', 'g', 'LineWidth', 2); hold on
        scatter((1.15), meanOIndexAllStimBaseInh((cond+1)/2, stim), 200, '+', 'r', 'LineWidth', 2); hold on     
        
        ylabel('Opto-index','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'XLim',[0.8 1.2],'YLim', [-1 1],'FontSize',24);
        title(titleFig7d{(cond+1)/2*5+(stim-6)},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        errorbar((1.1),meanOIndexAllStimBase((cond+1)/2, stim),STEMOIndexAllStimBase((cond+1)/2, stim),'.k','LineWidth',2);
        errorbar((1.15),meanOIndexAllStimBaseExc((cond+1)/2, stim),STEMOIndexAllStimBaseExc((cond+1)/2, stim),'.g','LineWidth',2);
        errorbar((1.15),meanOIndexAllStimBaseInh((cond+1)/2, stim),STEMOIndexAllStimBaseInh((cond+1)/2, stim),'.r','LineWidth',2);
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig7d{(cond+1)/2*5+(stim-6)}));
        end
    end
end
