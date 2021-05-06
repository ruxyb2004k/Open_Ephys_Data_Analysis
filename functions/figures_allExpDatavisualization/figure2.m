%%% created by RB on 23.12.2020

% Fig 2 (2x): Norm average of time courses evoked activity 100% contrast and spontaneous activity

if totalStim == 6
    titleFig2 = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig2 = {'meanNormTC100All.fig','meanNormTC0All.fig'};
elseif totalStim == 1
    titleFig2 = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '50% visual stim. vs 50% visual + photostim. all cells norm', ...
    '25% visual stim. vs 25% visual + photostim. all cells norm', ...
    '12% visual stim. vs 12% visual + photostim. all cells norm', ...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig2 = {'meanNormTC100All.fig', 'meanNormTC50All.fig','meanNormTC25All.fig','meanNormTC12All.fig','meanNormTC0All.fig'};
end
for cond = (1:2:totalConds)
    figure
    ax = gca;
    hold on
    plot((plotBeg:bin:plotEnd), meanNormTraceFreqAll(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((plotBeg:bin:plotEnd), meanNormTraceFreqAll(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on

    max_hist1 = 1.5 * max(max(meanNormTraceFreqAll(cond:cond+1,:)));
    min_hist = -0.5;
    xlabel('Time [sec]');
    ylabel('Norm. avg. sp. freq.');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig2{(cond+1)/2});
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
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAll(cond,:),STEMnormTraceFreqAll(cond,:), {'Color', C(1,:)}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAll(cond+1,:),STEMnormTraceFreqAll(cond+1,:), {'Color', C(2,:)}); hold on
    if saveFigs == true
        savefig(strcat(savePath, saveFig2{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig2{(cond+1)/2}(1:end-3), 'png'));
    end
end