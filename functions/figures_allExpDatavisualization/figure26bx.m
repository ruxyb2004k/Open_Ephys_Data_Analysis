%% Fig 26b: reproduction of fig 8c from eLife 2020 (average of baseline-subtracted and norm traces to max in their own group )

if totalStim == 1
    titleFig26bx = {'Norm. traces to their own group after initial baseline subtr. - adjusted'};
    saveFig26bx = {'meanNormBaseSubtrAllAdj.fig'};

    max_hist1 = 1.5 * max(max(meanNormTracesBaseSubtrAdj));
    min_hist = 1.5 * min(min(meanNormTracesBaseSubtrAdj));
    fact = 1;
    figure
    subplot(3,2,3:4)
    ax = gca;
    for cond = (2:2:totalConds)
        
        plot((plotBeg:bin:plotEnd), meanNormTracesBaseSubtrAdj(cond,:), 'LineStyle', '--','LineWidth', 1, 'Color', C(cond,:)); hold on
        shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTracesBaseSubtrAdj(cond,:),STEMnormTracesBaseSubtrAdj(cond,:), {'Color', C(cond,:), 'LineStyle', 'none'}); hold on

    end

    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    % set(ax,'xtick',[ceil(-plotBeg):2:floor(plotEnd)]) % set major ticks
    set(ax, 'TickDir', 'out');
    
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs);
    h1 = line(sessionInfoAll.optStimInterval,[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    fact = 0.95;
    x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
    for i = (1:totalStim)
        h2 = line('XData',x(i,:),'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
    end
    line([plotBeg plotEnd], [0 0], 'Color', [.5 .5 .5 ])
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    box off
    set(gca, 'XColor', 'w');
    set(gca,'XTick',[]);
    yticks([0 1])
    set(gca, 'YMinorTick','on');
    if saveFigs ~= true
        title(titleFig26bx);
    end    

    subplot(3,2,5:6)
    ax = gca;
    for cond = (totalConds+2:2:2*totalConds-2)
        
        plot((plotBeg:bin:plotEnd), meanNormTracesBaseSubtrAdj(cond,:), 'LineStyle', '--', 'LineWidth', 1, 'Color', C(cond,:)); hold on
        
        shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTracesBaseSubtrAdj(cond,:),STEMnormTracesBaseSubtrAdj(cond,:), {'Color', C(cond,:), 'LineStyle', 'none'}); hold on
    end
    xlabel('Time [sec]');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    % set(ax,'xtick',[ceil(-plotBeg):2:floor(plotEnd)]) % set major ticks
    set(ax, 'TickDir', 'out');
    
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs);
    h1 = line(sessionInfoAll.optStimInterval,[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    fact = 0.95;
    x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
    for i = (1:totalStim)
        h2 = line('XData',x(i,:),'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
    end
    line([plotBeg plotEnd], [0 0], 'Color', [.5 .5 .5 ])
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    set(gca, 'YMinorTick','on');
    box off
    yticks([0 1])
    if saveFigs == true
        savefig(strcat(savePath, saveFig26bx{1}));
        title('');
        saveas(gcf, strcat(savePath, saveFig26bx{1}(1:end-3), 'png'));
    end

    

end