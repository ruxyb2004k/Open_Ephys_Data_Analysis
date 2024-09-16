%%% created by RB on 14.02.2023

% Fig 4e: Violin plots of normalized baseline 


if totalStim == 6
    titleFig4e = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
        'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig4e = {'meanNormBaseline100Violin.fig','meanNormBaseline0Violin.fig'};
elseif totalStim ==1
    titleFig4e = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
    'Normalized baseline 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Normalized baseline 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Normalized baseline 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig4e = {'meanNormBaseline100Violin.fig', 'meanNormBaseline50Violin.fig','meanNormBaseline25Violin.fig','meanNormBaseline12Violin.fig','meanNormBaseline0Violin.fig'};
end
stim =4;
fw = 1;
xval = [0.75,1.25];
C_dark = C- repmat([0.3],size(C));
C_dark(C_dark<0 ) = 0;
for cond = totalConds-1% (1:2:totalConds)
    val1 = normAllStimBase(cond,:,stim);
    val2 = normAllStimBase(cond+1,:,stim);
    val1 = val1(~isnan(val1));
    val2 = val2(~isnan(val2));
    
    f = figure('Renderer', 'painters', 'Position', [680 558 280 420]); % left bottom width height
    ax = gca;
    hold on

    vsl = Violin({val1}, 1-0.05, 'HalfViolin','left', 'ViolinColor',{C(cond,:)});
    vsr = Violin({val2}, 1+0.05, 'HalfViolin','right','ViolinColor',{cCreCellType});
    
    %     xlabel('Stim#');
    ylabel('Firing rate (norm.) ');
%     set(ax,'XLim',[0.4 2/fw+0.6],'FontSize',fs);
    set(ax,'XLim',[0.4 1.6],'YLim',[0 3],'FontSize',fs);
    set(gca,'xtick',[], 'ytick',(0:0.5:3))
    set(ax, 'TickDir', 'out');
    set(gca, 'xcolor', 'w');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig4e{(cond+1)/2});
    background = get(gcf, 'color');


    STEMval= STEMnormAllStimBase(cond:cond+1,stim);
    p_temp =  pNormAllStimBase((cond+1)/2,stim,2);
%     y = max(meanNormAllStimBase(cond:cond+1,stim)+STEMnormAllStimBase(cond:cond+1,stim))*1.05;
    y= 2.8;
    yl=ylim;
    ylim([yl(1), y+0.1]) %2.2
    %         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
    i=1;
    if p_temp <= 0.001
        text(mean(xval)/fw, y,'***','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([xval(i), xval(i+1)]./fw,[y*0.98 y*0.98]); 
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    elseif p_temp <= 0.01
        text(mean(xval)/fw, y,'**','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([xval(i), xval(i+1)]./fw,[y*0.99 y*0.99]); 
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    elseif p_temp <= 0.05
        text(mean(xval)/fw, y,'*','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([xval(i), xval(i+1)]./fw,[y*0.99 y*0.99]); 
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
    else
        text(mean(xval)/fw, y,'n. s.','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
        h1 = line([xval(i), xval(i+1)]./fw,[y*0.99 y*0.99]);
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines    
    end
    if cond == 1
        xticklabels({'V', 'V_p_h'})
    elseif cond == totalConds-1
        xticklabels({'S', 'S_p_h'})
    end  
    
    p_temp2 = [p_temp; nan(size(p_temp))];
    varNames = ["FiringRateNorm", "SEM", "Pvalue"];
    
    yval = meanNormAllStimBase(cond:cond+1,stim);
    table_fig = table(yval, STEMval, p_temp2(:) );
    table_fig = renamevars(table_fig, ["yval", "STEMval", "Var3"], varNames); 
      

    table_data1 = table(val1', val2');
    table_data1 = renamevars(table_data1 , ["Var1", "Var2"], ["S", "Sph"]);
   

%     h1 = line([1.7 4.3],[yl(2)*0.99 yl(2)*0.99]);    

    if saveFigs == true
        savefig(strcat(savePath, saveFig4e{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig4e{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig4e{(cond+1)/2}(1:end-4)), 'epsc');
        writetable(table_fig, strcat(savePath, saveFig4e{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','D:G');
        writetable(table_data1, strcat(savePath, saveFig4e{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','A:C')
    end
end