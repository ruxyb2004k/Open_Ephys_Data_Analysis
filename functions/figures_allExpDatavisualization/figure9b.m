%%% created by RB on 23.12.2020

% Fig 9b (5x): Opto-index indivdual data points with average and errorbars - comparison evoked responses between before and during photostim. 

if totalStim ==6
    titleFig9b = {'Opto-index 100% visual stim. +/- photostim. Ampl1',...
        'Opto-index 100% visual stim. +/- photostim. Ampl2',...
        'Opto-index 100% visual stim. +/- photostim. Ampl3',...
        'Opto-index 100% visual stim. +/- photostim. Ampl4',...
        'Opto-index 100% visual stim. +/- photostim. Ampl5',...
        'Opto-index 100% visual stim. +/- photostim. Ampl6'};
    
    saveFig9b = {'OptoindexIndivData100Ampl1.fig', 'OptoindexIndivData100Ampl2.fig','OptoindexIndivData100Ampl3.fig', 'OptoindexIndivData100Ampl4.fig','OptoindexIndivData100Ampl5.fig', 'OptoindexIndivData100Ampl6.fig',};
    
    cond = 1;
    for stim = 1:totalStim
        figure
        ax = gca;
        hold on
        for unit = 1:totalUnits
            plot(1, OIndexAllStimAmpl((cond+1)/2,unit,stim), 'Marker','o','MarkerSize',20,'Color', C_units(unit,:));
        end
        scatter((1.1), meanOIndexAllStimAmpl((cond+1)/2,stim), 200, '+', 'k', 'LineWidth', 2); hold on
        
        ylabel('Opto-index','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'XLim',[0.8 1.2],'YLim', [-1 1],'FontSize',24);
        title(titleFig9b{stim},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        errorbar((1.1),meanOIndexAllStimAmpl((cond+1)/2,stim),STEMOIndexAllStimAmpl((cond+1)/2,stim),'.k','LineWidth',2);
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig9b{stim}));
        end
    end
elseif totalStim == 1
    titleFig9b = {'Opto-index 100% visual stim. +/- photostim.',...
        'Opto-index 50% visual stim. +/- photostim.', ...
        'Opto-index 25% visual stim. +/- photostim.', ...
        'Opto-index 12% visual stim. +/- photostim.', ...
        'Opto-index 0% visual stim. +/- photostim.'};
    
    saveFig9b = {'OptoindexIndivData100.fig', 'OptoindexIndivData50.fig','OptoindexIndivData25.fig','OptoindexIndivData12.fig','OptoindexIndivData0.fig'};
    
    for cond = (1:2:totalConds)
        figure
        ax = gca;
        hold on
        for unit = 1:totalUnits
            plot(1, OIndexAllStimAmpl((cond+1)/2,unit), 'Marker','o','MarkerSize',20,'Color', C_units(unit,:));
        end
        scatter((1.1), meanOIndexAllStimAmpl((cond+1)/2), 200, '+', 'k', 'LineWidth', 2); hold on
        
        ylabel('Opto-index','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'XLim',[0.8 1.2],'YLim', [-1 1],'FontSize',24);
        title(titleFig9b{(cond+1)/2},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        errorbar((1.1),meanOIndexAllStimAmpl((cond+1)/2),STEMOIndexAllStimAmpl((cond+1)/2),'.k','LineWidth',2);
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig9b{(cond+1)/2}));
        end
    end
end