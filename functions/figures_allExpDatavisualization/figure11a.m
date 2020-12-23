%%% created by RB on 23.12.2020

% Fig. 11a - opto-index bar plot with p value for combined baselines (5x)
if totalStim ==6
    titleFig11a = {'Opto-index +/- photostim. comb. Base2 vs Base1',...
    'Opto-index +/- photostim. comb. Base3 vs Base1',...
    'Opto-index +/- photostim. comb. Base4 vs Base1',...
    'Opto-index +/- photostim. comb. Base5 vs Base1',...
    'Opto-index +/- photostim. comb. Base6 vs Base1'};

    saveFig11a = {'OptoindexBarplotCombBase2.fig', 'OptoindexBarplotCombBase3.fig',...
    'OptoindexBarplotCombBase4.fig', 'OptoindexBarplotCombBase5.fig',...
    'OptoindexBarplotCombBase6.fig'};
elseif totalStim == 1
    titleFig11a = {'Opto-index +/- photostim. comb. Base2 vs Base1',...
        'Opto-index +/- photostim. comb. Base3 vs Base1'};
    
    saveFig11a = {'OptoindexBarplotCombBase2.fig', 'OptoindexBarplotCombBase3.fig'};
end

cond = 2;
for stim = 2:numel(baseStim)
    figure
    ax = gca;
    hold on
    b = bar((1:totalUnits),sortOIndexAllStimBaseComb(cond,:, stim));
    b.FaceColor = 'flat';
    for unit = 1:totalBaseSelectUnits
        if classUnitsAll(indexOIndexAllStimBaseComb(cond,unit, stim)) == 1
            b.CData(unit,:) = [0 1 0];
        elseif classUnitsAll(indexOIndexAllStimBaseComb(cond,unit, stim)) == 2
            b.CData(unit,:) = [1 0 0];
        end
        y = sortOIndexAllStimBaseComb(cond,unit, stim);%
        p_temp = pSuaBaseCombAll(indexOIndexAllStimBaseComb(cond,unit, stim), stim);
%         text(unit, y+0.1*sign(y), num2str(p_temp),'FontSize',5, 'HorizontalAlignment','center');
%         text(unit, y-0.1*sign(y), [num2str(indexOIndexAllStimBaseComb(cond, unit, stim)) ',' num2str(spikeClusterDataAll.goodCodes(indexOIndexAllStimBaseComb(cond,unit, stim)))] ,'FontSize',5, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text(unit, y-0.05*sign(y),'***','FontSize',10, 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(unit, y-0.05*sign(y),'**','FontSize',10, 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(unit, y-0.05*sign(y),'*','FontSize',10, 'HorizontalAlignment','center');
        end
    end
    xlabel('Unit no.');
    ylabel('Opto-index');% (B+ph - B-ph)/(B+ph + B-ph)');
    set(ax,'XLim',[0.5 totalBaseSelectUnits+0.5],'YLim', [-1 1],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    %     % set(ax,'xtick',[]);
    %     % set(gca, 'XColor', 'w');
    set(ax,'FontSize',fs)
    title(titleFig11a{stim-1},'FontSize',18);
    background = get(gcf, 'color');
    if saveFigs == true
        savefig(strcat(savePath, saveFig11a{stim-1}));
    end
end