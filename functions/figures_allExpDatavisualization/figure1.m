%%% created by RB on 23.12.2020

% Fig 1 (2x): average of time courses evoked activity 100% contrast and spontaneous activity

if totalStim == 6
    titleFig1 = {'100% visual stim. vs 100% visual + photostim. all cells',...
    '0% visual stim. vs 0% visual + photostim. all cells'};
    saveFig1 = {'meanTC100All.fig', 'meanTC0All.fig'};
elseif totalStim == 1
    titleFig1 = {'100% visual stim. vs 100% visual + photostim. all cells',...
    '50% visual stim. vs 50% visual + photostim. all cells', ...
    '25% visual stim. vs 25% visual + photostim. all cells', ...
    '12% visual stim. vs 12% visual + photostim. all cells', ...
    '0% visual stim. vs 0% visual + photostim. all cells'};

    saveFig1 = {'meanTC100All.fig', 'meanTC50All.fig','meanTC25All.fig','meanTC12All.fig','meanTC0All.fig'};
end
max_hist1 = 1.5 * max(max(meanTraceFreqAll(1:2,:)));

for cond = (1:2:totalConds)
    figure
    ax = gca;
    hold on
    plot((plotBeg:bin:plotEnd), meanTraceFreqAll(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((plotBeg:bin:plotEnd), meanTraceFreqAll(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    
%     max_hist1 = 1.5 * max(max(meanTraceFreqAll(cond:cond+1,:)));
    min_hist = 0;
    
    xlabel('Time [sec]');
    ylabel('Avg. spike freq. (Hz)');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    % set(ax,'xtick',[ceil(-plotBeg):2:floor(plotEnd)]) % set major ticks
    set(ax, 'TickDir', 'out');
    % set(ax,'xtick',[]);
    % set(gca, 'XColor', 'w');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs);
    title(titleFig1{(cond+1)/2}); 
    % background = get(gcf, 'color');
    %set(gcf,'color','white');
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
    shadedErrorBar1((plotBeg:bin:plotEnd),meanTraceFreqAll(cond,:),STEMtraceFreqAll(cond,:), {'Color', C(1,:)}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanTraceFreqAll(cond+1,:),STEMtraceFreqAll(cond+1,:), {'Color', C(2,:)}); hold on
    if saveFigs == true
        savefig(strcat(savePath, saveFig1{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig1{(cond+1)/2}(1:end-3), 'png'));
    end
end
