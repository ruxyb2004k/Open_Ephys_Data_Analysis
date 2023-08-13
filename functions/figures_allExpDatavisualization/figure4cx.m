%%% created by RB on 23.12.2020

% Fig. 4cx (2x) : Average normalized baseline 

if totalStim == 6
    titleFig4cx = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
        'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig4cx = {'meanNormBaseline100Bar.fig','meanNormBaseline0Bar.fig'};
elseif totalStim ==1
    titleFig4cx = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
    'Normalized baseline 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Normalized baseline 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Normalized baseline 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig4cx = {'meanNormBaseline100Bar.fig', 'meanNormBaseline50Bar.fig','meanNormBaseline25Bar.fig','meanNormBaseline12Bar.fig','meanNormBaseline0Bar.fig'};
end
stim =4;
fw = 1;
xval = [1,1.8]./fw;
xval_ticks = [1.4]/fw;
C_dark = C- repmat([0.3],size(C));
C_dark(C_dark<0 ) = 0;
for cond = totalConds-1% (1:2:totalConds)
    f = figure('Renderer', 'painters', 'Position', [680 558 260 420]); % left bottom width height
    ax = gca;
    hold on
    yval = meanNormAllStimBase(cond:cond+1,stim);
    b4b =bar(xval/fw, yval, 'EdgeColor', 'none', 'BarWidth', 1/fw); hold on
    b4b.FaceColor = 'flat';
    b4b.CData(1,:) = C(cond,:);
    b4b.CData(2,:) = cCreCellType;
    STEMval= STEMnormAllStimBase(cond:cond+1,stim);
    errorbar(xval(1)/fw,yval(1),STEMval(1), '.','Color', C(cond,:),'LineWidth', 3); hold on
    errorbar(xval(2)/fw,yval(2),STEMval(2),'.','Color', cCreCellType,'LineWidth', 3); hold on

    
    %     xlabel('Stim#');
    ylabel('Firing rate (norm.) ');
%     set(ax,'XLim',[0.4 2/fw+0.6],'FontSize',fs);
    set(ax,'XLim',[0.5/fw 2/fw+0.5/fw],'FontSize',fs);
    set(ax,'xtick',xval./fw) % set major ticks
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig4cx{(cond+1)/2});
    background = get(gcf, 'color');



    p_temp =  pNormAllStimBase((cond+1)/2,stim,2);
%     y = max(meanNormAllStimBase(cond:cond+1,stim)+STEMnormAllStimBase(cond:cond+1,stim))*1.05;
    y= 2.2;
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
    table_fig = table(yval, STEMval, p_temp2(:) );
    table_fig = renamevars(table_fig, ["yval", "STEMval", "Var3"], varNames); 
    
    data1a = normAllStimBase(cond,:,stim);
    data1b = normAllStimBase(cond+1,:,stim);
    data1a = data1a(~isnan(data1a));
    data1b = data1b(~isnan(data1b));
    table_data1 = table(data1a', data1b');
    table_data1 = renamevars(table_data1 , ["Var1", "Var2"], ["S", "Sph"]);
   

%     h1 = line([1.7 4.3],[yl(2)*0.99 yl(2)*0.99]);    

    if saveFigs == true
        savefig(strcat(savePath, saveFig4cx{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig4cx{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig4cx{(cond+1)/2}(1:end-4)), 'epsc');
        writetable(table_fig, strcat(savePath, saveFig4cx{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','D:G');
        writetable(table_data1, strcat(savePath, saveFig4cx{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','A:C')
    end
end