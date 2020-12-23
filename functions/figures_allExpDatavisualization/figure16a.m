%%% created by RB on 23.12.2020

% Figure 16a base1 vs base2 combined

if totalStim == 1
    titleFig16a = {'Base1 vs base2 no photostim', 'Base1 vs base2 with photostim'};
    
    saveFig16a = {'Base1base2NoPh.fig', 'Base1base2Ph.fig'};
    
    for cond=1:2 % 1= non-photostimulated combined baselines; 2= non-photostimulated combined baselines
        figure;
        ax=axes;
        for unit = 1:size(allStimBaseComb,2)
            plot(allStimBaseComb(cond, unit,1), allStimBaseComb(cond, unit,2), 'Marker','o','MarkerSize',20,'Color', C_units(unit,:)); hold on
            text(allStimBaseComb(cond, unit,1), allStimBaseComb(cond, unit,2), num2str(unit), 'Color', C_units(unit,:), 'FontSize',10, 'HorizontalAlignment','center');  hold on
        end
        idx = isnan(allStimBaseComb(cond, :,1)) | isnan(allStimBaseComb(cond, :,2));
        fitline1 = fit(squeeze(allStimBaseComb(cond, ~idx,1))', squeeze(allStimBaseComb(cond, ~idx,2))', 'poly1');
        plot(fitline1);
        coeffs1(cond,:) = coeffvalues(fitline1);
        legend off
        xlabel('Base 1 spike freq. [Hz]','FontSize',24);
        ylabel('Base 2 spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig16a{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        lim = max(max(max(allStimBaseComb(cond, :,1:2))));
        text(lim*0.5, lim*0.95, [num2str(round(coeffs1(cond,1),2)),'*x + ',num2str(round(coeffs1(cond,2),2)) ] ,'FontSize',10, 'HorizontalAlignment','center');
        h1 = line([0 lim],[0 lim]); % diagonal line
        set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig16a{cond}));
        end
    end
end    