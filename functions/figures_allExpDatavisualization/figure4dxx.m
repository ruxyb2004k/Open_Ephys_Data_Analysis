%%% created by RB on 23.12.2020

% Fig. 4dx (2x) : Median normalized baseline 

if totalStim == 6
    titleFig4dxx = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
        'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig4dxx = {'boxplotNormBaseline100_scatLine.fig','boxplotNormBaseline0_scatLine.fig'};
elseif totalStim ==1
    titleFig4dxx = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
    'Normalized baseline 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Normalized baseline 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Normalized baseline 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig4dxx = {'boxplotNormBaseline100_scatLine.fig', 'boxplotNormBaseline50_scatLine.fig','boxplotNormBaseline25_scatLine.fig','boxplotNormBaseline12_scatLine.fig','boxplotNormBaseline0_scatLine.fig'};
end
stim = 4;
fw = 0.8;
xval = [1,2];
xval_ticks = [1.5];
C_dark = C- repmat([0.3],size(C));
C_dark(C_dark<0 ) = 0;
colors = [C(cond,:);cCreCellType];
cond = totalConds-1;
STEMval= STEMnormAllStimBase(cond:cond+1,stim);
for cond = totalConds-1% (1:2:totalConds)
    f = figure('Renderer', 'painters', 'Position', [680 558 260 420]); % left bottom width height
    ax = gca;
    hold on
    yval = squeeze(normAllStimBase(cond:cond+1,:,stim))';
    plot(xval, yval, 'Marker', '.', 'MarkerSize', 20, 'Color', cCreCellType)
    errorbar([0.7,2.3],nanmean(yval,1), STEMval,  'diamond', 'Color', cCreCellType, 'LineWidth', 2);
    box off
    ylabel('Firing rate (norm.) ');
    set(ax,'XLim',[0.4 2/fw],'FontSize',fs);
    set(ax,'xtick',xval) % set major ticks
    set(ax, 'TickDir', 'out');

    title(titleFig4dxx{(cond+1)/2});
    background = get(gcf, 'color');

    p_temp =  pNormAllStimBase((cond+1)/2,stim,2);
    y= max(yval(:))+ .5;
    ylim([0,3.5])
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

    
    data1a = normAllStimBase(cond,:,stim);
    data1b = normAllStimBase(cond+1,:,stim);
    data1a = data1a(~isnan(data1a));
    data1b = data1b(~isnan(data1b));
    table_data1 = table(data1a', data1b');
    table_data1 = renamevars(table_data1 , ["Var1", "Var2"], ["S", "Sph"]);

  


    if saveFigs == true
        savefig(strcat(savePath, saveFig4dxx{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig4dxx{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig4dxx{(cond+1)/2}(1:end-4)), 'epsc');
        writetable(table_fig, strcat(savePath, saveFig4dxx{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','D:K');
        writetable(table_data1, strcat(savePath, saveFig4dxx{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','A:C')
    end
end