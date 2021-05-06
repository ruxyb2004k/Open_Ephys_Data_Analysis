%% Fig. 26d (1x) : reproduction of fig 8di(2) from eLife 2020 (average amplitude of normalized and baseline subtr traces)

if totalStim == 1
    titleFig26d = {'Normalized amplitude to 100% visual stim. in the same group'};

    saveFig26d = {'meanNormAmplTo100SameGroup.fig'};

    figure
    min_hist1 = -0.2;
    ax = gca;
    hold on
    
    xFit = linspace(min(contrasts0/100), max(contrasts0/100), 1000);
        
    plot(contrasts,meanAllStimAmplNormTracesBaseSubtr(1:2:totalConds-2),'Marker','o','LineWidth', 3, 'Color', C(1,:), 'LineStyle', 'none'); hold on
    errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr(1:2:totalConds-2),STEMallStimAmplNormTracesBaseSubtr(1:2:totalConds-2),'Color', C(1,:), 'LineStyle', 'none');
    fit0NormV = fitNakaRushton1([contrasts/100 0],meanAllStimAmplNormTracesBaseSubtr(1:2:totalConds));    
    yFit0NormV = nakaRushton(xFit, fit0NormV); % Get the estimated yFit value for each of those 1000 new x locations.
    plot(xFit*100, yFit0NormV,'Color', C(1,:), 'LineWidth', 2); % Plot fitted line.   
    
    plot(contrasts,meanAllStimAmplNormTracesBaseSubtr(2:2:totalConds-2),'Marker','o','LineWidth', 3, 'Color', C(2,:), 'LineStyle', 'none'); hold on
    errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr(2:2:totalConds-2),STEMallStimAmplNormTracesBaseSubtr(2:2:totalConds-2), 'Color', C(2,:), 'LineStyle', 'none');
    fit0NormVph = fitNakaRushton1([contrasts/100 0],meanAllStimAmplNormTracesBaseSubtr(2:2:totalConds));    
    yFit0NormVph = nakaRushton(xFit, fit0NormVph); % Get the estimated yFit value for each of those 1000 new x locations.
    plot(xFit*100, yFit0NormVph,  '--','Color', C(2,:), 'LineWidth', 2); % Plot fitted line.   

    plot(contrasts,meanAllStimAmplNormTracesBaseSubtr(totalConds+2:2:2*totalConds-2),'Marker','o','LineWidth', 3, 'Color', C(totalConds+2,:), 'LineStyle', 'none'); hold on
    errorbar(contrasts,meanAllStimAmplNormTracesBaseSubtr(totalConds+2:2:2*totalConds-2),STEMallStimAmplNormTracesBaseSubtr(totalConds+2:2:2*totalConds-2),'Color', C(totalConds+2,:), 'LineStyle', 'none');
    fit0NormVphSph = fitNakaRushton1([contrasts/100 0],[meanAllStimAmplNormTracesBaseSubtr(totalConds+2:2:2*totalConds-2); 0]);    
    yFit0NormVphSph = nakaRushton(xFit, fit0NormVphSph); % Get the estimated yFit value for each of those 1000 new x locations.
    plot(xFit*100, yFit0NormVphSph, '--','Color', C(totalConds+2,:),'LineWidth', 2); % Plot fitted line.
    
    
    for cond = (2:2:totalConds-2)
        p_temp =  pAllStimAmplNormTracesBaseSubtr(cond/2);
        y = min(meanAllStimAmplNormTracesBaseSubtr(cond)-STEMallStimAmplNormTracesBaseSubtr(cond));
        min_hist1 = min(y+0.25*sign(y), min_hist1);
        if p_temp <= 0.001
            text(contrasts(cond/2)+2, y-0.25*sign(y),'***','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(contrasts(cond/2)+2, y-0.25*sign(y),'**','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(contrasts(cond/2)+2, y-0.25*sign(y),'*','FontSize',10, 'Color', C(cond,:), 'HorizontalAlignment','center');
        end
        
    end
    for cond = (totalConds+2:2:2*totalConds-2)
        p_temp =  pAllStimAmplNormTracesBaseSubtr(cond/2);
        y = min(meanAllStimAmplNormTracesBaseSubtr(cond)+STEMallStimAmplNormTracesBaseSubtr(cond));
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

max_hist1 = max(max(meanAllStimAmplNormTracesBaseSubtr))*1.5;

ylabel('Norm. ampl.');

set(ax, 'TickDir', 'out');
set(ax,'YLim',[min_hist1 max_hist1]);
set(ax,'FontSize',fs)
set(ax,'FontSize',fs)
title(titleFig26d,'FontSize',18);
background = get(gcf, 'color');
xticks(flip(contrasts))
% grid on;
% set(gca, 'XScale', 'log')
% xlim([1,100]);

if saveFigs == true
    savefig(strcat(savePath, saveFig26d{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig26d{1}(1:end-3), 'png'));
    
end
