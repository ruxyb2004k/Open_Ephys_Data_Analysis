%%% created by RB on 23.12.2020

% Fig. 4c (2x) : Average normalized baseline 

if totalStim == 6
    titleFig4c = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
        'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig4c = {'meanNormBaseline100BarDots.fig','meanNormBaseline0BarDots.fig'};
elseif totalStim ==1
    titleFig4c = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
    'Normalized baseline 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Normalized baseline 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Normalized baseline 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig4c = {'meanNormBaseline100BarDots.fig', 'meanNormBaseline50BarDots.fig','meanNormBaseline25BarDots.fig','meanNormBaseline12BarDots.fig','meanNormBaseline0BarDots.fig'};
end
stim =4;
fw = 1;
xval = [1.15 1.85];
C_dark = C- repmat([0.3],size(C));
C_dark(C_dark<0 ) = 0;
for cond = totalConds-1% (1:2:totalConds)
%     idx = repmat([1/fw 2/fw], numel(normAllStimBase(cond,:, stim)), 1);
    idx = repmat(xval, numel(normAllStimBase(cond,:, stim)), 1);
    idx = idx(:);
    f = figure('Renderer', 'painters', 'Position', [680 558 360 420]); % left bottom width height
    ax = gca;
    hold on
    b4b =bar(xval/fw, meanNormAllStimBase(cond:cond+1,stim), 'EdgeColor', 'none', 'BarWidth', 0.8/fw); hold on
    b4b.FaceColor = 'flat';
    b4b.CData(1,:) = C(cond,:);
    b4b.CData(2,:) = C(cond+1,:);
    
    % beeswarm graph      
    plotSpread(squeeze(normAllStimBase(cond:cond+1,:, stim))','distributionIdx', idx,...
        'categoryIdx',idx, 'categoryMarkers',{'o', 'o'},'categoryColors',C_dark(cond:cond+1,:),'spreadWidth', 0.5)

    errorbar(xval(1)/fw,meanNormAllStimBase(cond,stim),STEMnormAllStimBase(cond,stim), '.','Color', C(cond,:),'LineWidth', 4); hold on
    errorbar(xval(2)/fw,meanNormAllStimBase(cond+1,stim),STEMnormAllStimBase(cond+1,stim),'.','Color', C(cond+1,:),'LineWidth', 4); hold on

    
    %     xlabel('Stim#');
    ylabel('Firing rate (norm.) ');
%     set(ax,'XLim',[0.4 2/fw+0.6],'FontSize',fs);
    set(ax,'XLim',[0.5/fw 2/fw+0.5/fw],'FontSize',fs);
    set(ax,'xtick',xval./fw) % set major ticks
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig4c{(cond+1)/2});
    background = get(gcf, 'color');



    p_temp =  pNormAllStimBase((cond+1)/2,stim,2);
%     y = max(meanNormAllStimBase(cond:cond+1,stim)+STEMnormAllStimBase(cond:cond+1,stim))*1.05;
    y= 6.2;
    yl=ylim;
    ylim([yl(1), 6.3]) %2.2
    %         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
    if p_temp <= 0.001
        text(1.5/fw, y,'***','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line(xval./fw,[y*0.98 y*0.98]); 
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    elseif p_temp <= 0.01
        text(1.5/fw, y,'**','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line(xval./fw,[y*0.99 y*0.99]); 
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    elseif p_temp <= 0.05
        text(1.5/fw, y,'*','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line(xval./fw,[y*0.99 y*0.99]); 
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    end
    if cond == 1
        xticklabels({'V', 'V_p_h'})
    elseif cond == totalConds-1
        xticklabels({'S', 'S_p_h'})
    end  


%     h1 = line([1.7 4.3],[yl(2)*0.99 yl(2)*0.99]);    

    if saveFigs == true
        savefig(strcat(savePath, saveFig4c{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig4c{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig4c{(cond+1)/2}(1:end-4)), 'epsc');
    end
end