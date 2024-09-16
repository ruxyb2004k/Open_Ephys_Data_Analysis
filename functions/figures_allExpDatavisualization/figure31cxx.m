%%% created by RB on 27.02.2023

% Fig. 31cxx (2x) : Average normalized baseline 

if totalStim == 6
    titleFig31cxx = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
        'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig31cxx = {'meanNormBaseline100BarOIselCtrl.fig','meanNormBaseline0BarOIselCtrl.fig'};
elseif totalStim ==1
    titleFig31cxx = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
    'Normalized baseline 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Normalized baseline 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Normalized baseline 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig31cxx = {'meanNormBaseline100BarOIselCtrl.fig', 'meanNormBaseline50BarOIselCtrl.fig','meanNormBaseline25BarOIselCtrl.fig','meanNormBaseline12BarOIselCtrl.fig','meanNormBaseline0BarOIselCtrl.fig'};
end
stim =4;
fw = 1;
xval = [1,1.8, 3,3.8]./fw;
xval_ticks = [1.4, 3.4]/fw;
C_dark = C- repmat([0.3],size(C));
C_dark(C_dark<0 ) = 0;
C_darkOI = [190,219,239]/255 - repmat([0.3],1,3);
C_darkOI(C_darkOI<0 ) = 0;
for cond = totalConds-1
    %idx = [repmat(xval(1), numel(normAllStimBase(cond+1,:,stim)), 1);...
    %    repmat(xval(2), numel(normAllStimBaseOIpos(cond+1,:,stim)), 1);...
    %    repmat(xval(3), numel(normAllStimBaseOIneg(cond+1,:,stim)), 1)];

    
    %yval = [squeeze(normAllStimBase(cond+1,:,stim)), squeeze(normAllStimBaseOIpos(cond+1,:,stim)), squeeze(normAllStimBaseOIneg(cond+1,:,stim))]';
    
    f = figure('Renderer', 'painters', 'Position', [680 558 320 420]); % left bottom width height
    ax = gca;
    hold on
    yval = [meanNormAllStimBaseOIpos(cond,stim), meanNormAllStimBaseOIpos(cond+1,stim),...
        meanNormAllStimBaseOIneg(cond,stim), meanNormAllStimBaseOIneg(cond+1,stim)];
    b4b =bar(xval, yval, 'EdgeColor', 'none', 'BarWidth', 1/fw); hold on
    b4b.FaceColor = 'flat';
    b4b.CData(1,:) = C(cond,:);
    b4b.CData(2,:) = cCreCellType;%[190,219,239]/255;
    b4b.CData(3,:) = C(cond,:);
    b4b.CData(4,:) = cCreCellType;%[190,219,239]/255;
    
    STEMval = [STEMnormAllStimBaseOIpos(cond,stim), STEMnormAllStimBaseOIpos(cond+1,stim),...
        STEMnormAllStimBaseOIneg(cond,stim),STEMnormAllStimBaseOIneg(cond+1,stim)];
    errorbar(xval(1),yval(1),STEMval(1),'.','Color', C(cond,:),'LineWidth', 3); hold on
    errorbar(xval(2),yval(2),STEMval(2),'.','Color', cCreCellType ,'LineWidth', 3); hold on
    errorbar(xval(3),yval(3),STEMval(3),'.','Color', C(cond,:),'LineWidth', 3); hold on
    errorbar(xval(4),yval(4),STEMval(4),'.','Color', cCreCellType,'LineWidth', 3); hold on

    % beeswarm graph   
    if size(normAllStimBaseOIpos,2) <= 10 
        idx = repmat(xval(1:2), numel(normAllStimBaseOIpos(cond,:, stim)), 1);
        idx = idx(:);
        plotSpread(squeeze(normAllStimBaseOIpos(cond:cond+1,:, stim))','distributionIdx', idx,...
            'categoryIdx',idx, 'categoryMarkers',{'o', 'o'},'categoryColors',[0,0,0; 0,0,0],'spreadWidth', 0.5)%
    end
    if size(normAllStimBaseOIneg,2) <= 10 
        idx = repmat(xval(3:4), numel(normAllStimBaseOIneg(cond,:, stim)), 1);
        idx = idx(:);
        plotSpread(squeeze(normAllStimBaseOIneg(cond:cond+1,:, stim))','distributionIdx', idx,...
            'categoryIdx',idx, 'categoryMarkers',{'o', 'o'},'categoryColors',[0,0,0; 0,0,0],'spreadWidth', 0.5)%
    end
    
    %     xlabel('Stim#');
    ylabel('Firing rate (norm.) ');
%     set(ax,'XLim',[0.4 2/fw+0.6],'FontSize',fs);
    set(ax,'XLim',[0.5/fw (4+0.5)/fw],'FontSize',fs);
    set(ax,'xtick',xval_ticks) % set major ticks
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig31cxx{(cond+1)/2});
    background = get(gcf, 'color');


    % p values for comparing to the same stim in control cond
    p_temp =  [pNormAllStimBaseOIpos((cond+1)/2,stim,2), pNormAllStimBaseOIneg((cond+1)/2,stim,2)];
%     y = max(meanNormAllStimBase(cond:cond+1,stim)+STEMnormAllStimBase(cond:cond+1,stim))*1.05;
    y= 2.3;%3.6;
    yl=ylim;
    ylim([yl(1), y+0.1])%2.2
    %         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
    for i = 1:2:numel(p_temp)*2
        if p_temp((i+1)/2) <= 0.001
            text(mean(xval(i:i+1)), y,'***','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
            h1 = line([xval(i), xval(i+1)]./fw,[y*0.98 y*0.98]);
            set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp((i+1)/2) <= 0.01
            text(mean(xval(i:i+1)), y,'**','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
            h1 = line([xval(i), xval(i+1)]./fw,[y*0.99 y*0.99]);
            set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp((i+1)/2) <= 0.05
            text(mean(xval(i:i+1)), y,'*','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
            h1 = line([xval(i), xval(i+1)]./fw,[y*0.99 y*0.99]);
            set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        else
            text(mean(xval(i:i+1)), y,'n. s.','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
            h1 = line([xval(i), xval(i+1)]./fw,[y*0.99 y*0.99]);
            set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines    
        end
    end
    if cond == 1
        xticklabels({'V', 'V_p_h'})
    elseif cond == totalConds-1
        %xticklabels({'S','S_p_h', 'S','S_p_h'})
        xticklabels({'OI+','OI-'})
    end  
    p_temp2 = [p_temp; nan(size(p_temp))];
    varNames = ["FiringRateNorm", "SEM", "Pvalue"];
    table_fig = table(yval', STEMval', p_temp2(:) );
    table_fig = renamevars(table_fig, ["Var1", "Var2", "Var3"], varNames); 
    
    table_data1 = table(normAllStimBaseOIpos(cond,:,stim)', normAllStimBaseOIpos(cond+1,:,stim)');
    table_data2 = table(normAllStimBaseOIneg(cond,:,stim)', normAllStimBaseOIneg(cond+1,:,stim)');
    table_data1 = renamevars(table_data1 , ["Var1", "Var2"], ["S", "Sph"]);
    table_data2 = renamevars(table_data2 , ["Var1", "Var2"], ["S", "Sph"]);
    
%     h1 = line([1.7 4.3],[yl(2)*0.99 yl(2)*0.99]);    

    if saveFigs == true
        savefig(strcat(savePath, saveFig31cxx{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig31cxx{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig31cxx{(cond+1)/2}(1:end-4)), 'epsc');
        writetable(table_fig, strcat(savePath, saveFig31cxx{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','I:L');
        writetable(table_data1, strcat(savePath, saveFig31cxx{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','A:C')
        writetable(table_data2, strcat(savePath, saveFig31cxx{(cond+1)/2}(1:end-3), 'xlsx'),'Sheet',1, 'Range','E:G')
    end
end