%%% created by RB on 23.12.2020

% Fig. 9a - opto-index bar plot with p value for amplitudes

if totalStim ==6
    titleFig9a = {'Opto-index 100% visual stim. +/- photostim. Ampl1',...
        'Opto-index 100% visual stim. +/- photostim. Ampl2',...
        'Opto-index 100% visual stim. +/- photostim. Ampl3',...
        'Opto-index 100% visual stim. +/- photostim. Ampl4',...
        'Opto-index 100% visual stim. +/- photostim. Ampl5',...
        'Opto-index 100% visual stim. +/- photostim. Ampl6'};
    
    saveFig9a = {'OptoindexBarplot100Ampl1.fig','OptoindexBarplot100Ampl2.fig','OptoindexBarplot100Ampl3.fig','OptoindexBarplot100Ampl4.fig','OptoindexBarplot100Ampl5.fig','OptoindexBarplot100Ampl6.fig'};

    cond = 1;
    for stim = (1:totalStim)
        figure
        ax = gca;
        hold on
        b = bar((1:totalUnits),sortOIndexAllStimAmpl((cond+1)/2,:,stim), 'EdgeColor', [0 0 0]);
        b.FaceColor = 'flat';
        for unit = 1:totalUnitsFilt
            %         b.CData(unit,:) = C_units(indexOIndexAllStimAmpl((cond+1)/2,unit,stim),:);
            if classUnitsAll(indexOIndexAllStimAmpl((cond+1)/2,unit,stim)) == 1
                b.CData(unit,:) = [0 1 0];
            elseif classUnitsAll(indexOIndexAllStimAmpl((cond+1)/2,unit,stim)) == 2
                b.CData(unit,:) = [1 0 0];
            end
            y = sortOIndexAllStimAmpl((cond+1)/2,unit,stim);
            p_temp = pSuaAll((cond+1)/2,indexOIndexAllStimAmpl((cond+1)/2,unit,stim), stim);
            %         text(unit, y+0.1*sign(y), num2str(p_temp),'FontSize',5, 'HorizontalAlignment','center');
%             text(unit, y-0.1*sign(y), [num2str(indexOIndexAllStimAmpl((cond+1)/2,unit,stim)) ',' num2str(spikeClusterDataAll.goodCodes(indexOIndexAllStimAmpl((cond+1)/2,unit,stim)))] ,'FontSize',5, 'HorizontalAlignment','center');
            if p_temp <= 0.001
                text(unit, y-0.05*sign(y),'***','FontSize',10, 'HorizontalAlignment','center');
            elseif p_temp <= 0.01
                text(unit, y-0.05*sign(y),'**','FontSize',10, 'HorizontalAlignment','center');
            elseif p_temp <= 0.05
                text(unit, y-0.05*sign(y),'*','FontSize',10, 'HorizontalAlignment','center');
            end
        end
        xlabel('Unit no.');
        ylabel('Opto-index');% (Ampl+ph - Ampl-ph)/(Ampl+ph + Ampl-ph)');
        set(ax,'XLim',[0.5 totalUnitsFilt+0.5],'YLim', [-1 1],'FontSize',fs);
        set(ax, 'TickDir', 'out');
        %     % set(ax,'xtick',[]);
        %     % set(gca, 'XColor', 'w');
        set(ax,'FontSize',fs)
        title(titleFig9a{stim},'FontSize',18);
        background = get(gcf, 'color');
        if saveFigs == true
            savefig(strcat(savePath, saveFig9a{stim}));
        end
        
    end
elseif totalStim ==1
    titleFig9a = {'Opto-index 100% visual stim. +/- photostim.',...
    'Opto-index 50% visual stim. +/- photostim.', ...
    'Opto-index 25% visual stim. +/- photostim.', ...
    'Opto-index 12% visual stim. +/- photostim.', ...
    'Opto-index 0% visual stim. +/- photostim.'};

    saveFig9a = {'OptoindexBarplot100Ampl.fig', 'OptoindexBarplot50Ampl.fig','OptoindexBarplot25Ampl.fig','OptoindexBarplot12Ampl.fig','OptoindexBarplot0Ampl.fig'};
    for cond = (1:2:totalConds-2)
        figure
        ax = gca;
        hold on
        b = bar((1:totalUnits),sortOIndexAllStimAmpl((cond+1)/2,:));
        b.FaceColor = 'flat';
        for unit = 1:totalUnits
            %         b.CData(unit,:) = C_units(indexOIndexAllStimAmpl((cond+1)/2,unit,stim),:);
            if classUnitsAll(indexOIndexAllStimAmpl((cond+1)/2,unit)) == 1
                b.CData(unit,:) = [0 1 0];
            elseif classUnitsAll(indexOIndexAllStimAmpl((cond+1)/2,unit)) == 2
                b.CData(unit,:) = [1 0 0];
            end
            y = sortOIndexAllStimAmpl((cond+1)/2,unit);
            p_temp = pSuaAll((cond+1)/2,indexOIndexAllStimAmpl((cond+1)/2,unit));
            %         text(unit, y+0.1*sign(y), num2str(p_temp),'FontSize',5, 'HorizontalAlignment','center');
%                     text(unit, y-0.1*sign(y), [num2str(indexOIndexAllStimAmpl((cond+1)/2,unit)) ',' num2str(spikeClusterDataAll.goodCodes(indexOIndexAllStimAmpl((cond+1)/2,unit)))] ,'FontSize',5, 'HorizontalAlignment','center');
            if p_temp <= 0.001
                text(unit, y-0.05*sign(y),'***','FontSize',10, 'HorizontalAlignment','center');
            elseif p_temp <= 0.01
                text(unit, y-0.05*sign(y),'**','FontSize',10, 'HorizontalAlignment','center');
            elseif p_temp <= 0.05
                text(unit, y-0.05*sign(y),'*','FontSize',10, 'HorizontalAlignment','center');
            end
        end
        xlabel('Unit no.');
        ylabel('Opto-index');
        set(ax,'XLim',[0.5 totalUnitsFilt+0.5+0.5],'YLim', [-1 1],'FontSize',fs);
        set(ax, 'TickDir', 'out');
        %     % set(ax,'xtick',[]);
        %     % set(gca, 'XColor', 'w');
        set(ax,'FontSize',fs)
            title(titleFig9a{(cond+1)/2},'FontSize',18);
        background = get(gcf, 'color');
        if saveFigs == true
            savefig(strcat(savePath, saveFig9a{(cond+1)/2}));
        end
    end
end