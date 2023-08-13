%%% created by RB on 23.12.2020

% Fig. 4d (2x) : Median normalized baseline 

if totalStim == 6
    titleFig4d = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
        'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig4d = {'boxplotNormBaseline100.fig','boxplotNormBaseline0.fig'};
elseif totalStim ==1
    titleFig4d = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
    'Normalized baseline 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Normalized baseline 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Normalized baseline 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig4d = {'boxplotNormBaseline100.fig', 'boxplotNormBaseline50.fig','boxplotNormBaseline25.fig','boxplotNormBaseline12.fig','boxplotNormBaseline0.fig'};
end
stim = 4;
fw = 0.8;
xval = [1,2];
xval_ticks = [1.5];
C_dark = C- repmat([0.3],size(C));
C_dark(C_dark<0 ) = 0;
for cond = totalConds-1% (1:2:totalConds)
    f = figure('Renderer', 'painters', 'Position', [680 558 260 420]); % left bottom width height
    ax = gca;
    hold on
    yval = squeeze(normAllStimBase(cond:cond+1,:,stim))';
    b4b = boxplot(yval, xval, 'Colors', C(cond:cond+1,:), 'Symbol', 'o','Widths',fw,'Notch', 'off');%'none', 'BarWidth', 1/fw); hold on

    
    box off
    ylabel('Firing rate (norm.) ');
    set(ax,'XLim',[0.4 2/fw],'FontSize',fs);
    set(ax,'xtick',xval) % set major ticks
    set(ax, 'TickDir', 'out');

    title(titleFig4d{(cond+1)/2});
    background = get(gcf, 'color');

    p_temp =  pNormAllStimBase((cond+1)/2,stim,2);
    y= max(yval(:))+ .5;
    yl=ylim;
    ylim([yl(1), y+.2]) %2.2
    %         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
    i=1;
    if p_temp <= 0.001
        text(mean(xval), y,'***','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([xval(i), xval(i+1)],[y*0.98 y*0.98]); 
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    elseif p_temp <= 0.01
        text(mean(xval), y,'**','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([xval(i), xval(i+1)],[y*0.99 y*0.99]); 
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    elseif p_temp <= 0.05
        text(mean(xval), y,'*','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([xval(i), xval(i+1)],[y*0.99 y*0.99]); 
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    else
        text(mean(xval)/fw, y,'n. s.','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([xval(i), xval(i+1)]./fw,[y*0.99 y*0.99]);
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines    
    end
    if cond == 1
        condNames = {'V'; 'Vph'};
        xticklabels({'V', 'V_p_h'})
    elseif cond == totalConds-1
        condNames = {'S'; 'Sph'};
        xticklabels({'S', 'S_p_h'})
    end  

    
    p_temp2 = [p_temp; nan(size(p_temp))];
    med = quantile(yval,0.5)';
    quart1 = quantile(yval,0.25)';
    quart3 = quantile(yval,0.75)';
    min_yval = min(yval)';
    max_yval = max(yval)';

    
    varNames = ["Conditions", "Median", "Q1", "Q3", "Min", "Max", "Pvalue"];
    table_fig = table(string(condNames), med, quart1, quart3, min_yval, max_yval, p_temp2(:) );
    table_fig = renamevars(table_fig, ["Var1", "med", "quart1", "quart3", "min_yval", "max_yval", "Var7"], varNames); 
    
    data1a = normAllStimBase(cond,:,stim);
    data1b = normAllStimBase(cond+1,:,stim);
    data1a = data1a(~isnan(data1a));
    data1b = data1b(~isnan(data1b));
    table_data1 = table(data1a', data1b');
    table_data1 = renamevars(table_data1 , ["Var1", "Var2"], ["S", "Sph"]);

  

    if saveFigs == true
        savefig(strcat(savePath, saveFig4d{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig4d{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig4d{(cond+1)/2}(1:end-4)), 'epsc');
        writetable(table_fig, strcat(savePath, saveFig4d{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','D:K');
        writetable(table_data1, strcat(savePath, saveFig4d{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','A:C')
    end
end