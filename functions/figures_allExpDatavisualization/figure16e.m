%%% created by RB on 23.12.2020

% Figure 16e base1 vs base4 

if totalStim == 6
    titleFig16e = {'Base1 vs base4 100% no photostim', 'Base1 vs base4 100% with photostim',...
        'Base1 vs base4 0% no photostim','Base1 vs base4 0% with photostim'};
    
    saveFig16e = {'Base1base4NoPh100_1.fig', 'Base1base4Ph100_1.fig',...
        'Base1base4NoPh0_1.fig', 'Base1base4Ph0_1.fig'};
    
    for cond =1:totalConds
        figure;
        ax=axes;
        for unit = 1:size(allStimBase,2)
            if classUnitsAll(unit) == 1
                plot((1:2),[allStimBase(cond, unit,1), allStimBase(cond, unit,4)], 'LineStyle', '-', 'Marker','^','MarkerSize',20,'Color','g'); hold on
            elseif classUnitsAll(unit) == 2
                plot((1:2),[allStimBase(cond, unit,1), allStimBase(cond, unit,4)], 'LineStyle', '-', 'Marker','o','MarkerSize',20,'Color','r'); hold on
            end
            text(2.2, allStimBase(cond, unit,4), num2str(unit) ,'FontSize',10, 'Color', C_units(unit,:), 'HorizontalAlignment','center');
        end
        
        legend off
        set(gca, 'XTick', 1:2, 'XTickLabels', {'Base1', 'Base4'});
        %     set(gca, 'YScale', 'log');
        xlim([0 3]);
        ylabel('Spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig16e{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig16e{cond}));
        end
    end
end