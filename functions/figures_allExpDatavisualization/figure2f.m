%%% created by RB on 23.12.2020

% Fig 2f (2x): Norm average of time courses evoked activity 100% contrast
% and spontaneous activity - single traces

if totalStim == 6
    titleFig2f = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig2f = {'singleTC100Allsame.fig','singleTC0Allsame.fig'};
elseif totalStim == 1
    titleFig2f = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '50% visual stim. vs 50% visual + photostim. all cells norm', ...
    '25% visual stim. vs 25% visual + photostim. all cells norm', ...
    '12% visual stim. vs 12% visual + photostim. all cells norm', ...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig2f = {'singleTC100Allsame.fig', 'singleTC50Allsame.fig','singleTC25Allsame.fig','singleTC12Allsame.fig','singleTC0Allsame.fig'};
end
smooth_span = 7;
for cond = totalConds-1%(1:2:totalConds)%(1:2:totalConds-2)
    y = squeeze(normTraceFreqAllsame(cond+1,:,:));
    y = y(baseSelect,:);
    n = ceil(sqrt(sum(baseSelect)));
    figure('units', 'normalized', 'outerposition', [0 0 1.3 1.3 ])


    for i = 1:size(y,1)
        y_smooth = smooth(y(i,:),smooth_span);
        subplot(n,n,i)
        ax = gca;
        hold on
        plot((plotBeg:bin:plotEnd), y_smooth,'LineWidth', 1, 'Color', 'k'); hold on % cCreCellType)
        if i == 1
            xlabel('Time (s)');
            ylabel('Firing rate (normalized)');
        end    
    
        %plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllsame(cond+1,:),'LineWidth', 3, 'Color', C(cond+1,:)); hold on
%         if cond == totalConds-1
%             max_hist1 = 2.5;%1.5 * max(max(meanNormTraceFreqAllAdj(cond:cond+1,:)));
%         else
%             max_hist1 =1.5;
%         end
        yl = ylim;
        max_hist1 = yl(2);
        min_hist = -0.5;
        if cond == totalConds-1
            min_hist = 0;
        end

        %set(ax,'XLim',[0 plotEnd],'FontSize',fs);
        set(ax,'XLim',[4 13])
        %set(ax, 'TickDir', 'out');
        xticks([0:5:plotEnd]);
        %yticks([min_hist:.5:max_hist1]);
        set(ax,'YLim',[min_hist max_hist1]);%,'FontSize',fs)
        %set(ax,'FontSize',fs)
        %title(titleFig2f{(cond+1)/2});
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
    end
    if saveFigs == true
        savefig(strcat(savePath, saveFig2f{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig2f{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig2f{(cond+1)/2}(1:end-4)), 'epsc');
    end
end