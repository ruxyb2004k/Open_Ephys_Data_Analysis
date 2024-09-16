%%% created by RB on 23.12.2020

% Fig 2e (2x): Norm average of time courses evoked activity 100% contrast and spontaneous activity

if totalStim == 6
    titleFig2e_e = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
        '0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig2e_e = {'meanNormTC100Allsame_eachUnit.fig','meanNormTC0Allsame_eachUnit.fig'};
elseif totalStim == 1
    titleFig2e_e = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
        '50% visual stim. vs 50% visual + photostim. all cells norm', ...
        '25% visual stim. vs 25% visual + photostim. all cells norm', ...
        '12% visual stim. vs 12% visual + photostim. all cells norm', ...
        '0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig2e_e = {'meanNormTC100Allsame.fig', 'meanNormTC50Allsame.fig','meanNormTC25Allsame.fig','meanNormTC12Allsame.fig','meanNormTC0Allsame.fig'};
end

%n = ceil(sqrt(size(normTraceFreqAllsame,2)));
ki = 4;
kj = 5;

for cond = (totalConds-1)%(1:2:totalConds-2)
    
    for k = 1:size(normTraceFreqAllsame,2)
        if mod(k, ki*kj) == 1
            figure('Position', [100,100,2000,1500])
        end
        subplot(ki,kj,mod(k-1,ki*kj)+1)
        ax = gca;
        hold on
        plot((plotBeg:bin:plotEnd), squeeze(normTraceFreqAllsame(cond,k,:)),'LineWidth', 1, 'Color', C(cond,:)); hold on
        plot((plotBeg:bin:plotEnd), squeeze(normTraceFreqAllsame(cond+1,k,:)),'LineWidth', 1, 'Color', C(cond+1,:)); hold on
        if cond == totalConds-1
            max_hist1 = 3;%1.5 * max(max(meanNormTraceFreqAllAdj(cond:cond+1,:)));
        else
            max_hist1 =1.5;
        end
        min_hist = -0.5;
        if cond == totalConds-1
            min_hist = 0.5;
        end
%         yl = ylim;
%         min_hist = yl(1);
%         max_hist = yl(2);
        %xlabel('Time (s)');
        %ylabel('Firing rate (normalized)');
        set(ax,'XLim',[0 plotEnd])%,'FontSize',fs);
        set(ax, 'TickDir', 'out');
        xticks([0:5:plotEnd]);
        yticks([min_hist:.5:max_hist1]);
        set(ax,'YLim',[min_hist max_hist1])%,'FontSize',fs)
        %set(ax,'FontSize',fs)
        title(k);
        h1 = line(sessionInfoAll.optStimInterval,[max_hist1 max_hist1]);
        set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
        fact = 0.95;
        x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
        for i = (1:totalStim)
            if cond < totalConds-1
                h2 = line('XData',x(i,:),'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
                set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',1);% Set properties of lines
            end
        end
        set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
        
        if mod(k, ki*kj) == 0
            if saveFigs == true
                savefig(strcat(savePath, saveFig2e_e{(cond+1)/2}(1:end-4), num2str(k),'.fig'));
            end
        end
    end
end
