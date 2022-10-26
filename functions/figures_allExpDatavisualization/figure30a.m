%%% created by RB on 23.12.2020

% Fig. 30a (2x) : Bar plot, baseline of the trace that represents the difference of the normalized traces

if totalStim == 6
    titleFig30a = {'Baseline in normalized difference trace 100%',...
        'Baseline in normalized difference trace 0%'};
    
    saveFig30a = {'meanAllStimBaseNormTraceFreqAllAdjSubtr100.fig','meanAllStimBaseNormTraceFreqAllAdjSubtr0.fig'};
elseif totalStim ==1
    titleFig30a = {'Baseline in normalized difference trace 100%',...
    'Baseline in normalized difference trace 50%', ...
    'Baseline in normalized difference trace 25%', ...
    'Baseline in normalized difference trace 12%', ...
    'Baseline in normalized difference trace 0%'};

    saveFig30a = {'meanAllStimBaseNormTraceFreqAllAdjSubtr100.fig', 'meanAllStimBaseNormTraceFreqAllAdjSubtr50.fig','meanAllStimBaseNormTraceFreqAllAdjSubtr25.fig','meanAllStimBaseNormTraceFreqAllAdjSubtr12.fig','meanAllStimBaseNormTraceFreqAllAdjSubtr0.fig'};
end

fw =1;
for cond = (1:2:totalConds)
    figure
    ax = gca;
    hold on
    b4b =bar((1:numel(baseStim))/fw, meanAllStimBaseNormTraceFreqAllAdjSubtr((cond+1)/2,:), 'EdgeColor', 'none', 'BarWidth', 0.6/fw); hold on
    b4b.FaceColor = 'flat';
    b4b.CData = C(cond+1,:);
%     b4b.CData(2,:) = C(cond+1,:);
    errorbar((1:numel(baseStim))/fw,meanAllStimBaseNormTraceFreqAllAdjSubtr((cond+1)/2,:),STEMallStimBaseNormTraceFreqAllAdjSubtr((cond+1)/2,:), '.','Color', C(cond+1,:),'LineWidth', 4); hold on
    xlabel('Stim#');
    ylabel('Firing rate (norm.) ');
%     set(ax,'XLim',[0.4 2/fw+0.6],'FontSize',fs);
    set(ax,'XLim',[0.5/fw 6/fw+0.5/fw],'FontSize',fs);
    set(ax,'xtick',1:numel(baseStim)./fw) % set major ticks
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig30a{(cond+1)/2});
    background = get(gcf, 'color');
%     yl=ylim;
    yl = [-0.5 0.5];
    ylim([yl(1), yl(2)*1.1]) 
    y= yl(2)*1.05;
    for stim = 1:numel(baseStim)
        p_temp =  pAllStimBaseNormTraceFreqAllAdjSubtr((cond+1)/2,stim);
%         y = (meanAllStimBaseNormTraceFreqAllAdjSubtr((cond+1)/2,stim)+STEMallStimBaseNormTraceFreqAllAdjSubtr((cond+1)/2,stim))*1.1;
       

        %         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text(stim/fw, y,'***','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
%             h1 = line([1 2]./fw,[y*0.98 y*0.98]);
%             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp <= 0.01
            text(stim/fw, y,'**','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
%             h1 = line([1 2]./fw,[y*0.99 y*0.99]);
%             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp <= 0.05
            text(stim/fw, y,'*','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
%             h1 = line([1 2]./fw,[y*0.99 y*0.99]);
%             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        end
    end

%     
    if saveFigs == true
        savefig(strcat(savePath, saveFig30a{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig30a{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig30a{(cond+1)/2}(1:end-4)), 'epsc');
    end
end