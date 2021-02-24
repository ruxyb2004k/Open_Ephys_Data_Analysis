%%% created by RB on 23.12.2020

% Figure 16d base1 vs base4 

if totalStim == 6
    titleFig16d = {'Base1 vs base4 100% no photostim', 'Base1 vs base4 100% with photostim',...
        'Base1 vs base4 0% no photostim','Base1 vs base4 0% with photostim'};
    
    saveFig16d = {'Base1base4NoPh100.fig', 'Base1base4Ph100.fig',...
        'Base1base4NoPh0.fig', 'Base1base4Ph0.fig'};
    
    for cond =1:totalConds % 1= non-photostimulated combined baselines; 2= non-photostimulated combined baselines
        figure;
        ax=axes;
        baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;
        for unit = find(baseSelect)% 1:size(allStimBase,2)
            plot(allStimBase(cond, unit,1), allStimBase(cond, unit,4), 'LineStyle', 'none', 'Marker','o','MarkerSize',20,'Color', C_units(unit,:)); hold on
            text(allStimBase(cond, unit,1), allStimBase(cond, unit,4), num2str(unit) ,'FontSize',10, 'Color', C_units(unit,:), 'HorizontalAlignment','center');
        end
        idx = isnan(allStimBase(cond, : ,1)) | isnan(allStimBase(cond, : ,4))| (~baseSelect);
        fitline4 = fit(squeeze(allStimBase(cond, ~idx,1))', squeeze(allStimBase(cond, ~idx,4))', 'poly1');
        plot(fitline4);
        coeffs4(cond,:) = coeffvalues(fitline4);
        legend off
        xlabel('Base 1 spike freq. [Hz]','FontSize',24);
        ylabel('Base 4 spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig16d{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        lim = max(max(max(allStimBase(cond, :,:))));
        text(lim*0.5, lim*0.95, [num2str(round(coeffs4(cond,1),2)),'*x + ',num2str(round(coeffs4(cond,2),2)) ] ,'FontSize',10, 'HorizontalAlignment','center');
        h1 = line([0 lim],[0 lim]); % diagonal line
        set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig16d{cond}));
        end
    end
end    