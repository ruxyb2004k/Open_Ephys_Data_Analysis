%%% created by RB on 10.06.2021

% Fig. 11f - opto-index bar plot with p value for combined baselines (5x)
if totalStim ==6
    titleFig11f = {'Opto-index comb. Base2 vs Base1 vs Depth',...
    'Opto-index comb. Base3 vs Base1 vs Depth',...
    'Opto-index comb. Base4 vs Base1 vs Depth',...
    'Opto-index comb. Base5 vs Base1 vs Depth',...
    'Opto-index comb. Base6 vs Base1 vs Depth'};

    saveFig11f = {'OptoindexCombBase2.fig', 'OptoindexCombBase3.fig',...
    'OptoindexCombBase4.fig', 'OptoindexCombBase5.fig',...
    'OptoindexCombBase6.fig'};
elseif totalStim == 1
    titleFig11f = {'Opto-index comb. Base2 vs Base1 vs Depth',...
        'Opto-index comb. Base3 vs Base1 vs Depth'};
    
    saveFig11f = {'OptoindexCombBase2Depth.fig', 'OptoindexCombBase3Depth.fig'};
end

cond = 2;
for stim = 2:numel(baseStim)
    figure
    ax = gca;
    hold on
    
    ind = ~isnan(OIndexAllStimBaseComb(cond,:, stim));
    
    scatter(realDepthAll(ind)',OIndexAllStimBaseComb(cond,ind, stim))
    xl= xlim;
    yl= ylim;
    %         c = polyfit(realDepthAll(ind)',OIndexAllStimBaseComb(cond,ind, stim),1);
    lm = fitlm(realDepthAll(ind),OIndexAllStimBaseComb(cond,ind, stim));
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
    title(titleFig11f{stim-1},'FontSize',18);
    if saveFigs == true
        savefig(strcat(savePath, saveFig11f{stim-1}));
    end
end