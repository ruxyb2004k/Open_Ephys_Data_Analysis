%% Figure 22: traces of visual evoked - sponateneous activity
 
if totalStim == 6
    titleFig22 = {'100% visual stim. vs 100% visual + photostim. (spont. subtr.)'};

    saveFig22 = {'meanEvMinusSpontTC100All.fig'};
elseif totalStim == 1
    titleFig22 = {'100% visual stim. vs 100% visual + photostim. (spont. subtr.)',...
    '50% visual stim. vs 50% visual + photostim. (spont. subtr.)', ...
    '25% visual stim. vs 25% visual + photostim. (spont. subtr.)', ...
    '12% visual stim. vs 12% visual + photostim. (spont. subtr.)'};

    saveFig22 = {'meanEvMinusSpontTC100All.fig', 'meanEvMinusSpontTC50All.fig','meanEvMinusSpontTC25All.fig','meanEvMinusSpontTC12All.fig'};
end

for cond = (1:2:totalConds-2)
    figure
    ax = gca;
    hold on   
    plot((plotBeg:bin:plotEnd), meanMagnCondDiff(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    plot((plotBeg:bin:plotEnd), meanMagnCondDiff(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on


    max_hist1 = 1.2 * max(max(meanMagnCondDiff(cond:cond+1,:)));
    min_hist = 1.2 * min(min(meanMagnCondDiff(cond:cond+1,:)));;
    xlabel('Time [sec]');
    ylabel('Norm. average spike freq.');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig22{(cond+1)/2});
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
%     shadedErrorBar1((plotBeg:bin:plotEnd),meanMagnCondDiff(cond,:),STEMmagnCondDiff(cond,:), {'Color', C(1,:)}); hold on
%     shadedErrorBar1((plotBeg:bin:plotEnd),meanMagnCondDiff(cond+1,:),STEMmagnCondDiff(cond+1,:), {'Color', C(2,:)}); hold on
    if saveFigs == true
        savefig(strcat(savePath, saveFig22{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig22{(cond+1)/2}(1:end-3), 'png'));
    end
end
