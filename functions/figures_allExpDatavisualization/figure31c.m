%%% created by RB on 23.12.2020

% Fig. 31c (2x) : Average normalized baseline 

if totalStim == 6
    titleFig31c = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
        'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig31c = {'meanNormBaseline100BarOIselDots.fig','meanNormBaseline0BarOIselDots.fig'};
elseif totalStim ==1
    titleFig31c = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
    'Normalized baseline 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Normalized baseline 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Normalized baseline 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig31c = {'meanNormBaseline100BarOIselDots.fig', 'meanNormBaseline50BarOIselDots.fig','meanNormBaseline25BarOIselDots.fig','meanNormBaseline12BarOIselDots.fig','meanNormBaseline0BarOIselDots.fig'};
end
stim =4;
fw = 1;
xval = (1:0.9:3)./fw;
C_dark = C- repmat([0.3],size(C));
C_dark(C_dark<0 ) = 0;
C_darkOI = [190,219,239]/255 - repmat([0.3],1,3);
C_darkOI(C_darkOI<0 ) = 0;
for cond = totalConds-1
    idx = [repmat(xval(1), numel(normAllStimBase(cond+1,:,stim)), 1);...
        repmat(xval(2), numel(normAllStimBaseOIpos(cond+1,:,stim)), 1);...
        repmat(xval(3), numel(normAllStimBaseOIneg(cond+1,:,stim)), 1)];

    
    yval = [squeeze(normAllStimBase(cond+1,:,stim)), squeeze(normAllStimBaseOIpos(cond+1,:,stim)), squeeze(normAllStimBaseOIneg(cond+1,:,stim))]';
    
    f = figure('Renderer', 'painters', 'Position', [680 558 600 420]); % left bottom width height
    ax = gca;
    h1 = line([0 5]./fw,[1 1]);
    set(h1,'Color',[0.3 0.3 0.3] ,'LineWidth',1);% Set properties of lin
    hold on
    b4b =bar(xval, [meanNormAllStimBase(cond+1,stim), meanNormAllStimBaseOIpos(cond+1,stim), meanNormAllStimBaseOIneg(cond+1,stim)], 'EdgeColor', 'none', 'BarWidth', 0.7/fw); hold on
    b4b.FaceColor = 'flat';
    b4b.CData(1,:) = [190,219,239]/255;
    b4b.CData(2,:) = C(cond+1,:);
    b4b.CData(3,:) = [190,219,239]/255;
    
   % beeswarm graph      
    plotSpread(yval,'distributionIdx', idx,...
        'categoryIdx',idx, 'categoryMarkers',{'o', 'o', 'o'},'categoryColors',[C_darkOI; C_dark(cond+1,:); C_darkOI],'spreadWidth', 0.5)

    
    errorbar(xval(1),meanNormAllStimBase(cond+1,stim),STEMnormAllStimBase(cond+1,stim),'.','Color', [190,219,239]/255,'LineWidth', 4); hold on
    errorbar(xval(2),meanNormAllStimBaseOIpos(cond+1,stim),STEMnormAllStimBaseOIpos(cond+1,stim),'.','Color', C(cond+1,:),'LineWidth', 4); hold on
    errorbar(xval(3),meanNormAllStimBaseOIneg(cond+1,stim),STEMnormAllStimBaseOIneg(cond+1,stim),'.','Color', [190,219,239]/255,'LineWidth', 4); hold on

    
    %     xlabel('Stim#');
    ylabel('Firing rate (norm.) ');
%     set(ax,'XLim',[0.4 2/fw+0.6],'FontSize',fs);
    set(ax,'XLim',[0.5/fw (4+0.5)/fw],'FontSize',fs);
    set(ax,'xtick',xval) % set major ticks
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig31c{(cond+1)/2});
    background = get(gcf, 'color');


    % p values for comparing to the baseline of stim 1 
    p_temp =  [pNormAllStimBase((cond+1)/2,stim,1), pNormAllStimBaseOIpos((cond+1)/2,stim,1), pNormAllStimBaseOIneg((cond+1)/2,stim,1)];
%     y = max(meanNormAllStimBase(cond:cond+1,stim)+STEMnormAllStimBase(cond:cond+1,stim))*1.05;
    y= 6.2;%2.1;
    yl=ylim;
    ylim([yl(1), 6.3])%2.2
    %         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
    for i = 1:3
        if p_temp(i) <= 0.001
            text(xval(i), y,'***','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
%             h1 = line([1 2]./fw,[y*0.98 y*0.98]);
%             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp(i) <= 0.01
            text(xval(i), y,'**','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
%             h1 = line([1 2]./fw,[y*0.99 y*0.99]);
%             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp(i) <= 0.05
            text(xval(i), y,'*','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
%             h1 = line([1 2]./fw,[y*0.99 y*0.99]);
%             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        end
    end
    if cond == 1
        xticklabels({'V', 'V_p_h'})
    elseif cond == totalConds-1
        xticklabels({'S_p_h', 'S_p_hOI+', 'S_p_hOI-'})
    end  


%     h1 = line([1.7 4.3],[yl(2)*0.99 yl(2)*0.99]);    

    if saveFigs == true
        savefig(strcat(savePath, saveFig31c{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig31c{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig31c{(cond+1)/2}(1:end-4)), 'epsc');
    end
end