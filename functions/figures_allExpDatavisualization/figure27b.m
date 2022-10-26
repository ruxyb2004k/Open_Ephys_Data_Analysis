%%% Fig. 27b (1x) : similar to fig 26d, but for each individual unit
%%% reproduction of fig 8di(2) from eLife 2020 (average amplitude of normalized and baseline subtr traces)


if totalStim == 1
    titleFig27b = {'All units - Norm. amplitude to 100% visual stim. in the same group'};

    saveFig27b = {'meanNormAmplTo100SameGroupAllUnits.fig'};

    
    n = ceil(sqrt(sum(iUnitsFilt & baseSelect)));
    figure;
    i = 1;
    for unit = find(iUnitsFilt & baseSelect)
        subplot(n,n,i)
        
        min_hist1 = -0.2;
        ax = gca;
        hold on
        
        xFit = linspace(min(contrasts0/100), max(contrasts0/100), 1000);
        
        plot(contrasts,allStimAmplNormTracesBaseSubtr(1:2:totalConds-2, unit),'Marker','o','LineWidth', 3, 'Color', C(1,:), 'LineStyle', 'none'); hold on
        %     errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr(1:2:totalConds-2, unit),STEMallStimAmplNormTracesBaseSubtr(1:2:totalConds-2), 'Color', C(1,:), 'LineStyle', 'none');
        fit0NormV = fitNakaRushton1([contrasts/100 0],allStimAmplNormTracesBaseSubtr(1:2:totalConds, unit));
        yFit0NormV = nakaRushton(xFit, fit0NormV); % Get the estimated yFit value for each of those 1000 new x locations.
        plot(xFit*100, yFit0NormV, 'Color', C(1,:), 'LineWidth', 2); % Plot fitted line.
        
        plot(contrasts,allStimAmplNormTracesBaseSubtr(2:2:totalConds-2, unit),'Marker','o','LineWidth', 3, 'Color', C(2,:), 'LineStyle', 'none'); hold on
        %     errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr(2:2:totalConds-2),STEMallStimAmplNormTracesBaseSubtr(2:2:totalConds-2), 'Color', C(2,:), 'LineStyle', 'none');
        fit0NormVph = fitNakaRushton1([contrasts/100 0],allStimAmplNormTracesBaseSubtr(2:2:totalConds, unit));
        yFit0NormVph = nakaRushton(xFit, fit0NormVph); % Get the estimated yFit value for each of those 1000 new x locations.
        plot(xFit*100, yFit0NormVph, '--', 'Color', C(2,:), 'LineWidth', 2); % Plot fitted line.
        
        plot(contrasts,allStimAmplNormTracesBaseSubtr(totalConds+2:2:2*totalConds-2, unit),'Marker','o','LineWidth', 3, 'Color', C(totalConds+2,:), 'LineStyle', 'none'); hold on
        %     errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr(totalConds+2:2:2*totalConds-2),STEMallStimAmplNormTracesBaseSubtr(totalConds+2:2:2*totalConds-2), 'Color', C(totalConds+2,:), 'LineStyle', 'none');
        fit0NormVphSph = fitNakaRushton1([contrasts/100 0],[allStimAmplNormTracesBaseSubtr(totalConds+2:2:2*totalConds-2, unit); 0]);
        yFit0NormVphSph = nakaRushton(xFit, fit0NormVphSph); % Get the estimated yFit value for each of those 1000 new x locations.
        plot(xFit*100, yFit0NormVphSph, '--', 'Color', C(totalConds+2,:), 'LineWidth', 2); % Plot fitted line.
        
        
        title(unit, 'Color', EIColor(classUnitsAll(unit)), 'Fontsize', 8);
        xticks(flip(contrasts))
        
        i = i+1;
    end
    
    xlabel('Contrast')
    
    
    max_hist1 = max(max(allStimAmplNormTracesBaseSubtr))*1.5;
    
    ylabel('Norm. ampl.');
    
    set(ax, 'TickDir', 'out');
    % set(ax,'YLim',[min_hist1 max_hist1]);
    % set(ax,'FontSize',fs)
    % title(titleFig27b,'FontSize',18);
    background = get(gcf, 'color');
    xticks(flip(contrasts))
    
    if saveFigs == true
        savefig(strcat(savePath, saveFig27b{1}));
        saveas(gcf, strcat(savePath, saveFig27b{1}(1:end-3), 'png'));
    end
end