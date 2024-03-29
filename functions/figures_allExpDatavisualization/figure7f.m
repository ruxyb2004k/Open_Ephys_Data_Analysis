%%% created by RB on 10.06.2021

% Fig. 7f - opto-index for baselines vs cell depth (10x)

if totalStim == 6
    titleFig7f = {'Opto-index 100% visual stim. Base2 vs depth',...
        'Opto-index 100% visual stim. Base3 vs depth',...
        'Opto-index 100% visual stim. Base4 vs depth',...
        'Opto-index 100% visual stim. Base5 vs depth',...
        'Opto-index 100% visual stim. Base6 vs depth',...
        'Opto-index 0% visual stim. Base2 vs depth',...
        'Opto-index 0% visual stim. Base3 vs depth',...
        'Opto-index 0% visual stim. Base4 vs depth',...
        'Opto-index 0% visual stim. Base5 vs depth',...
        'Opto-index 0% visual stim. Base6 vs depth'};
    
    saveFig7f = {'Optoindex100Base2Depth.fig', 'Optoindex100Base3Depth.fig',...
        'Optoindex100Base4Depth.fig', 'Optoindex100Base5Depth.fig',...
        'Optoindex100Base6Depth.fig',...
        'Optoindex0Base2Depth.fig', 'Optoindex0Base3Depth.fig',...
        'Optoindex0Base4Depth.fig', 'Optoindex0Base5Depth.fig',...
        'Optoindex0Base6Depth.fig'};
elseif totalStim == 1
    titleFig7f = {'Opto-index 100% visual stim. Base2 vs depth',...
        'Opto-index 100% visual stim. Base3 vs depth',...
        'Opto-index 50% visual stim. Base2 vs depth',...
        'Opto-index 50% visual stim. Base3 vs depth',...
        'Opto-index 25% visual stim. Base2 vs depth',...
        'Opto-index 25% visual stim. Base3 vs depth',...
        'Opto-index 12% visual stim. Base2 vs depth',...
        'Opto-index 12% visual stim. Base3 vs depth',...
        'Opto-index 0% visual stim. Base2 vs depth',...
        'Opto-index 0% visual stim. Base3 vs depth'};
    
    saveFig7f = {'Optoindex100Base2Depth.fig', 'Optoindex100Base3Depth.fig',...
        'Optoindex50Base2Depth.fig', 'Optoindex50Base3Depth.fig',...
        'Optoindex25Base2Depth.fig', 'Optoindex25Base3Depth.fig',...
        'Optoindex12Base2Depth.fig', 'Optoindex20Base3Depth.fig',...
        'Optoindex0Base2Depth.fig', 'Optoindex0Base3Depth.fig'};
end

for cond = (1:2:totalConds)
    for stim = 2:numel(baseStim)
        figure
        ax = gca;
        hold on
        ind = ~isnan(OIndexAllStimBase((cond+1)/2,:, stim));
        
        scatter(realDepthAll(ind)',OIndexAllStimBase((cond+1)/2,ind, stim))
        xl= xlim;
        yl= ylim;
%         c = polyfit(realDepthAll(ind)',OIndexAllStimBase((cond+1)/2,ind, stim),1);
        lm = fitlm(realDepthAll(ind),OIndexAllStimBase((cond+1)/2,ind, stim));
        d = table2array(lm.Coefficients);
        c = flip(d(:,1))';
        text(xl(2)*0.9, yl(2)*0.9, ['y = ' num2str(round(c(1),4)) '*x + ' num2str(round(c(2),2))],'FontSize',18, 'HorizontalAlignment','right');
        text(xl(2)*0.9, yl(2)*0.8, ['R-sq = ' num2str(round(lm.Rsquared.Ordinary,2))],'FontSize',18, 'HorizontalAlignment','right');

        y_est = polyval(c, [xl(1) xl(2)]);
        % Add trend line to plot
        hold on
        plot(xl,y_est,'r--','LineWidth',2)
        hold off

        xlabel('Depth (um)');
        ylabel('Opto-index');% (B+ph - B-ph)/(B+ph + B-ph)');

        set(ax,'FontSize',fs)
        background = get(gcf, 'color');
        title(titleFig7f{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))},'FontSize',18);
        if saveFigs == true
            savefig(strcat(savePath, saveFig7f{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))}));
        end

    end
end
