%% Fig 26a: reproduction of fig 8a from eLife 2020 (average of baseline-subtracted and norm traces )

if totalStim == 1
    titleFig26a = {'Norm. traces after initial baseline subtr.'};
    saveFig26a = {'meanNormBaseSubtr100All.fig'};

    max_hist1 = 1.5 * max(max(meanNormTracesBaseSubtr100));
    min_hist = 1.5 * min(min(meanNormTracesBaseSubtr100));
    fact = 1;
    figure
    subplot(2,3,1)
    for cond = (1:2:totalConds)
        ax = gca;
        plot((plotBeg:bin:plotEnd), meanNormTracesBaseSubtr100(cond,:),'LineWidth', 3, 'Color', C(cond,:)); hold on
        shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTracesBaseSubtr100(cond,:),STEMnormTracesBaseSubtr100(cond,:), {'Color', C(cond,:)}); hold on
        xlabel('Time [sec]');
        ylabel('Norm spike freq. (Hz)');
        %     set(ax,'xtick',[]);
        %     set(gca, 'XColor', 'w');
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
        
    end
    
    subplot(2,3,2)
    for cond = (2:2:totalConds)
        ax = gca;
        plot((plotBeg:bin:plotEnd), meanNormTracesBaseSubtr100(cond,:),'LineWidth', 3, 'Color', C(cond,:)); hold on
        xlabel('Time [sec]');
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
        shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTracesBaseSubtr100(cond,:),STEMnormTracesBaseSubtr100(cond,:), {'Color', C(cond,:)}); hold on
        box off
        
    end
    
    title(titleFig26a);
    
    subplot(2,3,3)
    for cond = (totalConds+2:2:totalConds*2-2)
        ax = gca;
        plot((plotBeg:bin:plotEnd), meanNormTracesBaseSubtr100(cond,:),'LineWidth', 3, 'Color', C(cond,:)); hold on
        xlabel('Time [sec]');
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
        shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTracesBaseSubtr100(cond,:),STEMnormTracesBaseSubtr100(cond,:), {'Color', C(cond,:)}); hold on
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig26a{1}));
            title('');
            saveas(gcf, strcat(savePath, saveFig26a{1}(1:end-3), 'png'));
        end
    end
end