%%% Fig. 27a (1x) : similar to fig 26c, but for each individual unit
%%% reproduction of fig 8di(1) from eLife 2020 (average amplitude of normalized and baseline subtr traces)


if totalStim == 1
    titleFig27a = {'All units - Norm. amplitude to 100% visual stim. without photostim.'};

    saveFig27a = {'meanNormAmplTo100AllUnits.fig'};

    
    n = ceil(sqrt(sum(iUnitsFilt & baseSelect)));
    figure;
    i = 1;
    for unit = find(iUnitsFilt & baseSelect)
        subplot(n,n,i)
        
        min_hist1 = -0.2;
        ax = gca;
        hold on
        
        xFit = linspace(min(contrasts0/100), max(contrasts0/100), 1000);
        
        plot(contrasts,allStimAmplNormTracesBaseSubtr100(1:2:totalConds-2, unit),'Marker','o','LineWidth', 3, 'Color', C(1,:), 'LineStyle', 'none'); hold on
        %     errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr100(1:2:totalConds-2, unit),STEMallStimAmplNormTracesBaseSubtr100(1:2:totalConds-2), 'Color', C(1,:), 'LineStyle', 'none');
        fit0Norm100V = fitNakaRushton1([contrasts/100 0],allStimAmplNormTracesBaseSubtr100(1:2:totalConds, unit));
        yFit0Norm100V = nakaRushton(xFit, fit0Norm100V); % Get the estimated yFit value for each of those 1000 new x locations.
        plot(xFit*100, yFit0Norm100V, 'Color', C(1,:), 'LineWidth', 2); % Plot fitted line.
        
        plot(contrasts,allStimAmplNormTracesBaseSubtr100(2:2:totalConds-2, unit),'Marker','o','LineWidth', 3, 'Color', C(2,:), 'LineStyle', 'none'); hold on
        %     errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr100(2:2:totalConds-2),STEMallStimAmplNormTracesBaseSubtr100(2:2:totalConds-2), 'Color', C(2,:), 'LineStyle', 'none');
        fit0Norm100Vph = fitNakaRushton1([contrasts/100 0],allStimAmplNormTracesBaseSubtr100(2:2:totalConds, unit));
        yFit0Norm100Vph = nakaRushton(xFit, fit0Norm100Vph); % Get the estimated yFit value for each of those 1000 new x locations.
        plot(xFit*100, yFit0Norm100Vph, 'Color', C(2,:), 'LineWidth', 2); % Plot fitted line.
        
        plot(contrasts,allStimAmplNormTracesBaseSubtr100(totalConds+2:2:2*totalConds-2, unit),'Marker','o','LineWidth', 3, 'Color', C(totalConds+2,:), 'LineStyle', 'none'); hold on
        %     errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr100(totalConds+2:2:2*totalConds-2),STEMallStimAmplNormTracesBaseSubtr100(totalConds+2:2:2*totalConds-2), 'Color', C(totalConds+2,:), 'LineStyle', 'none');
        fit0Norm100VphSph = fitNakaRushton1([contrasts/100 0],[allStimAmplNormTracesBaseSubtr100(totalConds+2:2:2*totalConds-2, unit); 0]);
        yFit0Norm100VphSph = nakaRushton(xFit, fit0Norm100VphSph); % Get the estimated yFit value for each of those 1000 new x locations.
        plot(xFit*100, yFit0Norm100VphSph, 'Color', C(totalConds+2,:), 'LineWidth', 2); % Plot fitted line.
        
        
        title(unit, 'Color', EIColor(classUnitsAll(unit)), 'Fontsize', 8);
        xticks(flip(contrasts))
        
        i = i+1;
    end
    
    xlabel('Contrast')
    
    
    max_hist1 = max(max(allStimAmplNormTracesBaseSubtr100))*1.5;
    
    ylabel('Norm. ampl.');
    
    set(ax, 'TickDir', 'out');
    % set(ax,'YLim',[min_hist1 max_hist1]);
    % set(ax,'FontSize',fs)
    % title(titleFig27a,'FontSize',18);
    background = get(gcf, 'color');
    xticks(flip(contrasts))
    
    if saveFigs == true
        savefig(strcat(savePath, saveFig27a{1}));
        saveas(gcf, strcat(savePath, saveFig27a{1}(1:end-3), 'png'));
    end
end