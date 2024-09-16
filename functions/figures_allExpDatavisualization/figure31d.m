%%% created by RB on 23.12.2020

% Fig 31d (2x): Norm average of time courses evoked activity 100% contrast and spontaneous activity

if totalStim == 6
    titleFig31d = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig31d = {'meanNormTC100AllOIsel.fig','meanNormTC0AllOIsel.fig'};
elseif totalStim == 1
    titleFig31d = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '50% visual stim. vs 50% visual + photostim. all cells norm', ...
    '25% visual stim. vs 25% visual + photostim. all cells norm', ...
    '12% visual stim. vs 12% visual + photostim. all cells norm', ...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig31d = {'meanNormTC100AllOIsel.fig', 'meanNormTC50AllOIsel.fig','meanNormTC25AllOIsel.fig','meanNormTC12AllOIsel.fig','meanNormTC0AllOIsel.fig'};
end
for cond = (1:2:totalConds)%(1:2:totalConds-2)
    figure
    ax = gca;
    hold on
%     plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllAdj(cond,:),'LineWidth', 3, 'Color', C(cond,:)); hold on
%     plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllAdjOIpos(cond+1,:),'LineWidth', 3, 'Color', C(cond+1,:)); hold on
%     plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllAdjOIneg(cond+1,:),'LineWidth', 3, 'Color', C(cond+1,:)); hold on
%     plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllAdj(cond+1,:),'LineWidth', 3, 'Color', C(cond+1,:)); hold on
    if cond == totalConds-1
        max_hist1 = 3%5.2;%3%1.5 * max(max(meanNormTraceFreqAllAdj(cond:cond+1,:)));
    else
        max_hist1 =1.5;
    end    
    min_hist = -0.5;
    if cond == totalConds-1
        min_hist = 0.4;
    end    
    xlabel('Time (s)');
    ylabel('Firing rate (normalized)');
    %yticks([ceil(min_hist):1:max_hist1]);
    yticks([ceil(min_hist)/2:0.5:max_hist1]);
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig31d{(cond+1)/2});
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
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllsame(cond,:),STEMnormTraceFreqAllsame(cond,:), {'LineWidth', 3,'Color', C(cond,:)}); hold on
    %shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllsame(cond+1,:),STEMnormTraceFreqAllsame(cond+1,:), {'LineWidth', 3,'Color', C(cond+1,:), 'LineStyle', ':'}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllSameOIpos(cond+1,:),STEMnormTraceFreqAllSameOIpos(cond+1,:), {'LineWidth', 3,'Color', cCreCellType, 'LineStyle', '-'}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllSameOIneg(cond+1,:),STEMnormTraceFreqAllSameOIneg(cond+1,:), {'LineWidth', 3,'Color', cCreCellType, 'LineStyle', '--'}); hold on
 
    %A = normTraceFreqAllsame;
    %notNan = all(~isnan(A),[1,3]);
    val1 = [(plotBeg:bin:plotEnd)',squeeze(normTraceFreqAllSameOIpos(cond,:, :))'];
    val2 = [(plotBeg:bin:plotEnd)',squeeze(normTraceFreqAllSameOIpos(cond+1,:, :))'];

    val3 = [(plotBeg:bin:plotEnd)',squeeze(normTraceFreqAllSameOIneg(cond,:, :))'];
    val4 = [(plotBeg:bin:plotEnd)',squeeze(normTraceFreqAllSameOIneg(cond+1,:, :))'];
    
    table_data1 = array2table(val1);
    table_data2 = array2table(val2);
    table_data3 = array2table(val3);
    table_data4 = array2table(val4);
    
    allVars1 = 1:width(table_data1);
    newNames1 =  ["Time (s)", append("Unit ", string(allVars1(1:(end-1))))];
    
    allVars3 = 1:width(table_data3);
    newNames3 =  ["Time (s)", append("Unit ", string(allVars3(1:(end-1))))];
    
    table_data1 = renamevars(table_data1, allVars1, newNames1);
    table_data2 = renamevars(table_data2, allVars1, newNames1);
    table_data3 = renamevars(table_data3, allVars3, newNames3);
    table_data4 = renamevars(table_data4, allVars3, newNames3);
      
    if saveFigs == true
        savefig(strcat(savePath, saveFig31d{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig31d{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig31d{(cond+1)/2}(1:end-4)), 'epsc');
        writetable(table_data1, strcat(savePath, saveFig31d{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1)
        writetable(table_data2, strcat(savePath, saveFig31d{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',2)
        writetable(table_data3, strcat(savePath, saveFig31d{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',3)
        writetable(table_data4, strcat(savePath, saveFig31d{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',4)
    end
end