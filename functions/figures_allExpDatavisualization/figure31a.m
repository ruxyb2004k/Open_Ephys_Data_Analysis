%%% created by RB on 23.12.2020

% Fig 31a (2x): Norm average of time courses evoked activity 100% contrast and spontaneous activity

if totalStim == 6
    titleFig31a = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig31a = {'meanNormTC100AllOIsel.fig','meanNormTC0AllOIsel.fig'};
elseif totalStim == 1
    titleFig31a = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '50% visual stim. vs 50% visual + photostim. all cells norm', ...
    '25% visual stim. vs 25% visual + photostim. all cells norm', ...
    '12% visual stim. vs 12% visual + photostim. all cells norm', ...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig31a = {'meanNormTC100AllOIsel.fig', 'meanNormTC50AllOIsel.fig','meanNormTC25AllOIsel.fig','meanNormTC12AllOIsel.fig','meanNormTC0AllOIsel.fig'};
end
for cond = (1:2:totalConds)%(1:2:totalConds-2)
    figure
    ax = gca;
    hold on
%     plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllAdj(cond,:),'LineWidth', 3, 'Color', C(cond,:)); hold on
%     plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllAdjOIpos(cond+1,:),'LineWidth', 3, 'Color', C(cond+1,:)); hold on
%     plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllAdjOIneg(cond+1,:),'LineWidth', 3, 'Color', C(cond+1,:)); hold on
%     plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllAdj(cond+1,:),'LineWidth', 3, 'Color', C(cond+1,:)); hold on
    if cond == totalConds-1
        max_hist1 = 2.5%1.5 * max(max(meanNormTraceFreqAllAdj(cond:cond+1,:)));
    else
        max_hist1 =1.5;
    end    
    min_hist = -0.5;
    if cond == totalConds-1
        min_hist = 0.5;
    end    
    xlabel('Time (s)');
    ylabel('Firing rate (normalized)');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig31a{(cond+1)/2});
    h1 = line(sessionInfoAll.optStimInterval,[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    fact = 0.95;
    x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
    for i = (1:totalStim)  
        if cond < totalConds-1
            h2 = line('XData',x(i,:),'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
            set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
        end
    end
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllAdj(cond,:),STEMnormTraceFreqAllAdj(cond,:), {'LineWidth', 3,'Color', C(cond,:)}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllAdj(cond+1,:),STEMnormTraceFreqAllAdj(cond+1,:), {'LineWidth', 3,'Color', C(cond+1,:), 'LineStyle', ':'}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllAdjOIpos(cond+1,:),STEMnormTraceFreqAllAdj(cond+1,:), {'LineWidth', 3,'Color', C(cond+1,:), 'LineStyle', '-'}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllAdjOIneg(cond+1,:),STEMnormTraceFreqAllAdj(cond+1,:), {'LineWidth', 3,'Color', C(cond+1,:), 'LineStyle', '--'}); hold on

    
    if saveFigs == true
        savefig(strcat(savePath, saveFig31a{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig31a{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig31a{(cond+1)/2}(1:end-4)), 'epsc');
    end
end