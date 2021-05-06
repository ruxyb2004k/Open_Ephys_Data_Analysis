%% Fig. 26c (1x) : reproduction of fig 8di(1) from eLife 2020 (average amplitude of normalized and baseline subtr traces)

if totalStim == 1
    titleFig26c = {'Normalized amplitude to 100% visual stim. without photostim.'};

    saveFig26c = {'meanNormAmplTo100.fig'};

    figure
    min_hist1 = -0.2;
    ax = gca;
    hold on
    
    xFit = linspace(min(contrasts0/100), max(contrasts0/100), 1000);
        
    plot(contrasts,meanAllStimAmplNormTracesBaseSubtr100(1:2:totalConds-2),'Marker','o','LineWidth', 3, 'Color', C(1,:), 'LineStyle', 'none'); hold on
    errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr100(1:2:totalConds-2),STEMallStimAmplNormTracesBaseSubtr100(1:2:totalConds-2), 'Color', C(1,:), 'LineStyle', 'none');
    fit0Norm100V = fitNakaRushton1([contrasts/100 0],meanAllStimAmplNormTracesBaseSubtr100(1:2:totalConds));    
    yFit0Norm100V = nakaRushton(xFit, fit0Norm100V); % Get the estimated yFit value for each of those 1000 new x locations.
    plot(xFit*100, yFit0Norm100V, 'Color', C(1,:), 'LineWidth', 2); % Plot fitted line.   
    
    plot(contrasts,meanAllStimAmplNormTracesBaseSubtr100(2:2:totalConds-2),'Marker','o','LineWidth', 3, 'Color', C(2,:), 'LineStyle', 'none'); hold on
    errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr100(2:2:totalConds-2),STEMallStimAmplNormTracesBaseSubtr100(2:2:totalConds-2), 'Color', C(2,:), 'LineStyle', 'none');
    fit0Norm100Vph = fitNakaRushton1([contrasts/100 0],meanAllStimAmplNormTracesBaseSubtr100(2:2:totalConds));    
    yFit0Norm100Vph = nakaRushton(xFit, fit0Norm100Vph); % Get the estimated yFit value for each of those 1000 new x locations.
    plot(xFit*100, yFit0Norm100Vph, 'Color', C(2,:), 'LineWidth', 2); % Plot fitted line.   

    plot(contrasts,meanAllStimAmplNormTracesBaseSubtr100(totalConds+2:2:2*totalConds-2),'Marker','o','LineWidth', 3, 'Color', C(totalConds+2,:), 'LineStyle', 'none'); hold on
    errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr100(totalConds+2:2:2*totalConds-2),STEMallStimAmplNormTracesBaseSubtr100(totalConds+2:2:2*totalConds-2), 'Color', C(totalConds+2,:), 'LineStyle', 'none');
    fit0Norm100VphSph = fitNakaRushton1([contrasts/100 0],[meanAllStimAmplNormTracesBaseSubtr100(totalConds+2:2:2*totalConds-2); 0]);    
    yFit0Norm100VphSph = nakaRushton(xFit, fit0Norm100VphSph); % Get the estimated yFit value for each of those 1000 new x locations.
    plot(xFit*100, yFit0Norm100VphSph, 'Color', C(totalConds+2,:), 'LineWidth', 2); % Plot fitted line.
    

    for cond = (2:2:totalConds-2)
        p_temp =  pAllStimAmplNormTracesBaseSubtr100(cond/2);
        y = min(meanAllStimAmplNormTracesBaseSubtr100(cond)-STEMallStimAmplNormTracesBaseSubtr100(cond));
        min_hist1 = min(y-0.25*sign(y), min_hist1);
        if p_temp <= 0.001
            text(contrasts(cond/2), y*0.9- cond/50,'***','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(contrasts(cond/2), y*0.9- cond/50,'**','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(contrasts(cond/2), y*0.9- cond/50,'*','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        end
        
    end
    for cond = (totalConds+2:2:2*totalConds-2)
        p_temp =  pAllStimAmplNormTracesBaseSubtr100(cond/2);
        y = min(meanAllStimAmplNormTracesBaseSubtr100(cond)+STEMallStimAmplNormTracesBaseSubtr100(cond));
        min_hist1 = min(y-0.25*sign(y), min_hist1);
        if p_temp <= 0.001
            text(contrasts((cond-totalConds)/2)+2, y-0.25*sign(y),'***','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(contrasts((cond-totalConds)/2)+2, y-0.25*sign(y),'**','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(contrasts((cond-totalConds)/2)+2, y-0.25*sign(y),'*','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        end
        
    end
end
xlabel('Contrast')


max_hist1 = max(max(meanAllStimAmplNormTracesBaseSubtr100))*1.5;

ylabel('Norm. ampl.');

set(ax, 'TickDir', 'out');
set(ax,'YLim',[min_hist1 max_hist1]);
set(ax,'FontSize',fs)
set(ax,'FontSize',fs)
title(titleFig26c,'FontSize',18);
background = get(gcf, 'color');
xticks(flip(contrasts))
% grid on;
% set(gca, 'XScale', 'log')
% xlim([1,100]);

if saveFigs == true
    savefig(strcat(savePath, saveFig26c{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig26c{1}(1:end-3), 'png'));
    
end

