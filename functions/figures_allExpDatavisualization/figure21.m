%%% created by RB on 23.12.2020

% Fig 21 (1x): Norm combined traces to the combined baseline (prev fig 20, short)

if totalStim == 1
    titleFig21 = {'Normalized Combined contrasts to- with or without photostim. all cells'};
    
    saveFig21 = {'meanNormTCComb.fig'};
    
    cond = 1;
    figure
    ax = gca;
    hold on
    plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllComb(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllComb(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    
    % max_hist1 = 1.2 * max(max(meanNormTraceFreqAllComb(cond:cond+1,:)));
    max_hist1 = 3;
    min_hist = -0;
    xlabel('Time [sec]');
    ylabel('Norm. average spike freq.');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig21{1});
    h1 = line(sessionInfoAll.optStimInterval,[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    fact = 0.95;
    x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
    if cond < totalConds-1
        h2 = line('XData',x,'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
    end
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllComb(cond,:),STEMnormTraceFreqAllComb(cond,:), {'Color', C(1,:)}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllComb(cond+1,:),STEMnormTraceFreqAllComb(cond+1,:), {'Color', C(2,:)}); hold on
    if saveFigs == true
        savefig(strcat(savePath, saveFig21{1}));
    end
end
