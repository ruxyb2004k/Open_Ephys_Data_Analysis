%%% created by RB on 23.12.2020

% Figure 16c base1 vs base3 combined

if totalStim == 1
    titleFig16c = {'Base1 vs base3 no photostim', 'Base1 vs base3 with photostim'};
    
    saveFig16c = {'Base1base3NoPh.fig', 'Base1base3Ph.fig'};
    
    for cond =1:2 % 1= non-photostimulated combined baselines; 2= non-photostimulated combined baselines
        figure;
        ax=axes;
        for unit = 1:size(allStimBaseComb,2)
            plot(allStimBaseComb(cond, unit,1), allStimBaseComb(cond, unit,3), 'LineStyle', 'none', 'Marker','o','MarkerSize',20,'Color', C_units(unit,:)); hold on
            text(allStimBaseComb(cond, unit,1), allStimBaseComb(cond, unit,3), num2str(unit) ,'FontSize',10, 'Color', C_units(unit,:), 'HorizontalAlignment','center');
        end
        idx = isnan(allStimBaseComb(cond, :,1)) | isnan(allStimBaseComb(cond, :,3));
        fitline3 = fit(squeeze(allStimBaseComb(cond, ~idx,1))', squeeze(allStimBaseComb(cond, ~idx,3))', 'poly1');
        plot(fitline3);
        coeffs3(cond,:) = coeffvalues(fitline3);
        legend off
        xlabel('Base 1 spike freq. [Hz]','FontSize',24);
        ylabel('Base 3 spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig16c{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        lim = max(max(max(allStimBaseComb(cond, :,:))));
        text(lim*0.5, lim*0.95, [num2str(round(coeffs3(cond,1),2)),'*x + ',num2str(round(coeffs3(cond,2),2)) ] ,'FontSize',10, 'HorizontalAlignment','center');
        h1 = line([0 lim],[0 lim]); % diagonal line
        set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig16c{cond}));
        end
    end
end    