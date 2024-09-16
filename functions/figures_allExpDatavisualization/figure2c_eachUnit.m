%%% created by RB on 23.12.2020

% Fig 2c (2x): Norm average of time courses evoked activity 100% contrast and spontaneous activity

if totalStim == 6
    titleFig2c_e = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig2c_e = {'meanNormTC100Allsubtr_eachUnit.fig','meanNormTC0Allsubtr_eachUnit.fig'};
elseif totalStim == 1
    titleFig2c_e = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '50% visual stim. vs 50% visual + photostim. all cells norm', ...
    '25% visual stim. vs 25% visual + photostim. all cells norm', ...
    '12% visual stim. vs 12% visual + photostim. all cells norm', ...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig2c_e = {'meanNormTC100Allsubtr.fig', 'meanNormTC50Allsubtr.fig','meanNormTC25Allsubtr.fig','meanNormTC12Allsubtr.fig','meanNormTC0Allsubtr.fig'};
end

ki = 4;
kj = 5;

for cond = (1:2:totalConds-2)%(1:2:totalConds-2)
    
    for k = 1:size(normTraceFreqAllAdj,2)
        if mod(k, ki*kj) == 1
            figure('Position', [100,100,2000,1500])
        end
        subplot(ki,kj,mod(k-1,ki*kj)+1)
        
        ax = gca;
        hold on
        %     plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllAdj(cond,:),'LineWidth', 3, 'Color', C(cond,:)); hold on
        %     plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllAdj(cond+1,:),'LineWidth', 3, 'Color', C(cond+1,:)); hold on
        
        
        if cond == totalConds-1
            max_hist1 = 2.5;%1.5 * max(max(meanNormTraceFreqAllAdj(cond:cond+1,:)));
        else
            max_hist1 =1.5;
        end
        min_hist = -0.2;
        if cond == totalConds-1
            min_hist = -0.5;
        end
        
        %ylabel('Firing rate (normalized)');
        set(ax,'XLim',[plotBeg plotEnd])%,'FontSize',fs);
        set(ax, 'TickDir', 'out');
        set(ax,'YLim',[min_hist max_hist1])%,'FontSize',fs)
        %set(ax,'FontSize',fs)
        %     title(titleFig2c{(cond+1)/2});
        title(k);
        h1 = line(sessionInfoAll.optStimInterval,[max_hist1 max_hist1]);
        set(h1,'Color',[0.25 0.61 1] ,'LineWidth',1);% Set properties of lines
        fact = 0.95;
        x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
        for i = (1:totalStim)
            if cond < totalConds-1
                h2 = line('XData',x(i,:),'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
                set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',1);% Set properties of lines
            end
        end
        set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
        plot((plotBeg:bin:plotEnd),squeeze(normTraceFreqAllAdj(cond,k,:)), 'LineWidth', 1,'Color', C(cond,:)); hold on
        plot((plotBeg:bin:plotEnd),squeeze(normTraceFreqAllAdj(cond+1,k,:)),'LineWidth', 1,'Color', C(cond+1,:)); hold on
        
        set(gca,'xtick',[])
        set(gca,'XColor', 'none')
        
        xlabel('Time (s)');
        %set(ax,'FontSize',fs);
        set(ax,'XLim',[plotBeg plotEnd]);%,'FontSize',fs);
        axis tight
        yl= ylim;
        set(ax, 'TickDir', 'out');
        %set(ax,'ytick',[ceil(yl(1)*10)/10, floor(yl(2)*10)/10]) % didn't try it yet - set major ticks
        %     set(ax,'YMinorTick','On')
        %     set(ax,'YMinorTick','Off')
        %     ax.YMinorTick = 'off'
        if mod(k, ki*kj) == 0
            if saveFigs == true
                savefig(strcat(savePath, saveFig2c_e{(cond+1)/2}(1:end-4), num2str(k),'.fig'));
            end
        end
        
    end
end