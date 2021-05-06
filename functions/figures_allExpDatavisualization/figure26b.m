%% Fig 26b: reproduction of fig 8c from eLife 2020 (average of baseline-subtracted and norm traces to max in their own group )

if totalStim == 1
    titleFig26b = {'Norm. traces to their own group after initial baseline subtr.'};
    saveFig26b = {'meanNormBaseSubtrAll.fig'};

    max_hist1 = 1.5 * max(max(meanNormTracesBaseSubtr));
    min_hist = 1.5 * min(min(meanNormTracesBaseSubtr));
    fact = 1;
    figure
    subplot(2,3,1)
    for cond = (2:2:totalConds)
        ax = gca;
        plot((plotBeg:bin:plotEnd), meanNormTracesBaseSubtr(cond,:), 'LineStyle', '--','LineWidth', 1, 'Color', C(cond,:)); hold on
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
        shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTracesBaseSubtr(cond,:),STEMnormTracesBaseSubtr(cond,:), {'Color', C(cond,:), 'LineStyle', 'none'}); hold on
        box off
    end
    
    subplot(2,3,2)
    for cond = (totalConds+2:2:2*totalConds-2)
        ax = gca;
        plot((plotBeg:bin:plotEnd), meanNormTracesBaseSubtr(cond,:), 'LineStyle', '--', 'LineWidth', 1, 'Color', C(cond,:)); hold on
        shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTracesBaseSubtr(cond,:),STEMnormTracesBaseSubtr(cond,:), {'Color', C(cond,:), 'LineStyle', 'none'}); hold on
        
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
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig26b{1}));
            title('');
            saveas(gcf, strcat(savePath, saveFig26b{1}(1:end-3), 'png'));
        end
    end
    
    title(titleFig26b);
end