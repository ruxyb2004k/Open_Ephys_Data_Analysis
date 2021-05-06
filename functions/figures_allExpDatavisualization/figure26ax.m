%% Fig 26a: reproduction of fig 8a from eLife 2020 (average of baseline-subtracted and norm traces )

if totalStim == 1
    titleFig26ax = {'Norm. traces after initial baseline subtr. - adjusted'};
    saveFig26ax = {'meanNormBaseSubtr100AllAdj.fig'};

    max_hist1 = 1.5 * max(max(meanNormTracesBaseSubtr100Adj));
    min_hist = 1.5 * min(min(meanNormTracesBaseSubtr100Adj));
    fact = 1;
    figure
    subplot(6,1,1:2)
    ax = gca;
    for cond = (1:2:totalConds)
        
        plot((plotBeg:bin:plotEnd), meanNormTracesBaseSubtr100Adj(cond,:),'LineWidth', 3, 'Color', C(cond,:)); hold on
        shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTracesBaseSubtr100Adj(cond,:),STEMnormTracesBaseSubtr100Adj(cond,:), {'Color', C(cond,:)}); hold on
%         xlabel('Time [sec]');
    end    
    set(ax,'xtick',[]);
    set(gca, 'XColor', 'w');
    box off
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    %     ylabel('Norm spike freq. (Hz)');
    set(ax, 'TickDir', 'out');
    
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs);
    
    x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
    for i = (1:totalStim)
        h2 = line('XData',x(i,:),'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
    end
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    set(gca, 'XColor', 'w');
    set(gca,'XTick',[]);
    yticks([0 1])
    set(gca, 'YMinorTick','on');
    
    if saveFigs ~= true
        title(titleFig26ax);
    end
    
    subplot(6,1,3:4)
    ax = gca;
    for cond = (2:2:totalConds)
        
        plot((plotBeg:bin:plotEnd), meanNormTracesBaseSubtr100Adj(cond,:),'LineWidth', 3, 'Color', C(cond,:)); hold on
        shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTracesBaseSubtr100Adj(cond,:),STEMnormTracesBaseSubtr100Adj(cond,:), {'Color', C(cond,:)}); hold on

    end
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    % set(ax,'xtick',[ceil(-plotBeg):2:floor(plotEnd)]) % set major ticks
    set(ax, 'TickDir', 'out');
    ylabel('Norm. sp. freq. (Hz)');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs);
    
    % background = get(gcf, 'color');
    %set(gcf,'color','white');
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

   
    
    subplot(6,1,5:6)
    ax = gca;
    for cond = (totalConds+2:2:totalConds*2-2)
        
        plot((plotBeg:bin:plotEnd), meanNormTracesBaseSubtr100Adj(cond,:),'LineWidth', 3, 'Color', C(cond,:)); hold on
        shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTracesBaseSubtr100Adj(cond,:),STEMnormTracesBaseSubtr100Adj(cond,:), {'Color', C(cond,:)}); hold on

    end
    %         xlabel('Time [sec]');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    % set(ax,'xtick',[ceil(-plotBeg):2:floor(plotEnd)]) % set major ticks
    set(ax, 'TickDir', 'out');
    
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs);
    %     title(titleFig25a);
    % background = get(gcf, 'color');
    %set(gcf,'color','white');
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
    xlabel('Time [sec]');
    yticks([0 1])
    set(gca, 'YMinorTick','on');
    if saveFigs == true
        savefig(strcat(savePath, saveFig26ax{1}));
        title('');
        saveas(gcf, strcat(savePath, saveFig26ax{1}(1:end-3), 'png'));
    end

end