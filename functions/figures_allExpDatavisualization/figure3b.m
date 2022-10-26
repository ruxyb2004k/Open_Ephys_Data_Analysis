%%% created by RB on 24.06.2021

% Fig. 3 (2x) : average baseline frequency 

if totalStim ==6
    titleFig3b = {'Baseline frequency 100% visual stim. vs 100% visual + photostim. all cells',...
    'Baseline frequency 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig3b = {'meanBaseline100Bar.fig','meanBaseline0Bar.fig'};
elseif totalStim == 1
    titleFig3b = {'Baseline frequency 100% visual stim. vs 100% visual + photostim. all cells',...
    'Baseline frequency 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Baseline frequency 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Baseline frequency 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Baseline frequency 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig3b = {'meanBaseline100Bar.fig', 'meanBaseline50Bar.fig','meanBaseline25Bar.fig','meanBaseline12Bar.fig','meanBaseline0Bar.fig'};
end
stim =4;
for cond = (1:2:totalConds)
    figure
    ax = gca;
    hold on
    b3b =bar(1:2, meanAllStimBase(cond:cond+1,stim), 'EdgeColor', 'none', 'BarWidth', 0.6); hold on
    b3b.FaceColor = 'flat';
    b3b.CData(1,:) = C(cond,:);
    b3b.CData(2,:) = C(cond+1,:);
    errorbar(1,meanAllStimBase(cond,stim),STEMallStimBase(cond,stim), '.','Color', C(cond,:),'LineWidth', 2); hold on
    errorbar(2,meanAllStimBase(cond+1,stim),STEMallStimBase(cond+1,stim),'.','Color', C(cond+1,:),'LineWidth', 2); hold on
    %     min_hist = -1;
    max_hist1 = 1.5;
%     xlabel('Stim#');
    ylabel('Firing rate (Hz) ');
    set(ax,'XLim',[0.4 2+0.6],'FontSize',fs);
    set(ax,'xtick',[1:2]) % set major ticks
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig3b{(cond+1)/2});
    background = get(gcf, 'color');



    p_temp =  pAllStimBase((cond+1)/2,stim,2);
    y = max(meanAllStimBase(cond:cond+1,stim)+STEMallStimBase(cond:cond+1,stim))*1.05;
    yl=ylim;
    ylim([yl(1), y])
    %         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
    if p_temp <= 0.001
        text(1.5, y,'***','FontSize',14, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([1 2],[y*0.98 y*0.98]);
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    elseif p_temp <= 0.01
        text(1.5, y,'**','FontSize',14, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([1 2],[y*0.99 y*0.99]);
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    elseif p_temp <= 0.05
        text(1.5, y,'*','FontSize',14, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([1 2],[y*0.99 y*0.99]);
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    end
    if cond == 1
        xticklabels({'V', 'V_p_h'})
    elseif cond == totalConds-1
        xticklabels({'S', 'S_p_h'})
    end            


%     h1 = line([1.7 4.3],[yl(2)*0.99 yl(2)*0.99]);    

    if saveFigs == true
        savefig(strcat(savePath, saveFig3b{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig3b{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig3b{(cond+1)/2}(1:end-4)), 'epsc');
    end
end