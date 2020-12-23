%%% created by RB on 23.12.2020

% Figure 19a ampl1 vs ampl4 

if totalStim == 6
    titleFig19a = {'Ampl1 vs ampl4 100% no photostim', 'Ampl1 vs ampl4 100% with photostim'};
    
    saveFig19a = {'Ampl1ampl4NoPh100_1.fig', 'Ampl1ampl4Ph100_1.fig'};
    
    for cond =1:totalConds-2
        figure;
        ax=axes;
        for unit = 1:totalUnits
            if classUnitsAll(unit) == 1
                plot((1:2),[allStimAmpl(cond, unit,1), allStimAmpl(cond, unit,4)], 'LineStyle', '-', 'Marker','^','MarkerSize',20,'Color','g'); hold on
            elseif classUnitsAll(unit) == 2
                plot((1:2),[allStimAmpl(cond, unit,1), allStimAmpl(cond, unit,4)], 'LineStyle', '-', 'Marker','o','MarkerSize',20,'Color','r'); hold on
            end
            text(2.2, allStimAmpl(cond, unit,4), num2str(unit) ,'FontSize',10, 'Color', C_units(unit,:), 'HorizontalAlignment','center');
        end
        
        legend off
        set(gca, 'XTick', 1:2, 'XTickLabels', {'Ampl1', 'Ampl4'});
        set(gca, 'YScale', 'log');
        xlim([0 3]);
        ylabel('Spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig19a{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig19a{cond}));
        end
    end
end

