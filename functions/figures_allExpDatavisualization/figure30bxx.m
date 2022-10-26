%%% created by RB on 23.12.2020

% Fig. 30bxx (2x) : Thin bar plot, difference of magnitude between the normalized
% traces  (magn =1 and not peak =1)

if totalStim == 6
    titleFig30bxx = {'Magnitude in normalized difference trace 100%',...
        'Magnitude in normalized difference trace 0%'};
    
    saveFig30bxx = {'meanAllStimMagnNormTraceFreqAllAdjSubtr100SubtrThin.fig','meanAllStimMagnNormTraceFreqAllAdjSubtr0SubtrThin.fig'};
elseif totalStim ==1
    titleFig30bxx = {'Magnitude in normalized difference trace 100%',...
    'Magnitude in normalized difference trace 50%', ...
    'Magnitude in normalized difference trace 25%', ...
    'Magnitude in normalized difference trace 12%', ...
    'Magnitude in normalized difference trace 0%'};

    saveFig30bxx = {'meanAllStimMagnNormTraceFreqAllAdjSubtr100SubtrThin.fig', 'meanAllStimMagnNormTraceFreqAllAdjSubtr50SubtrThin.fig','meanAllStimMagnNormTraceFreqAllAdjSubtr25SubtrThin.fig','meanAllStimMagnNormTraceFreqAllAdjSubtr12SubtrThin.fig','meanAllStimMagnNormTraceFreqAllAdjSubtr0SubtrThin.fig'};
end

fw =1;
for cond = (1:2:totalConds-2)
    stims = (1:6);
    if applyBonfCorr %in case we don't use Bonf Corr, comment out the next line
        warning(['Bonferoni Correction applied']);
        BonfCorrF =numel(stims); 
    end   

    figure
    ax = gca;
    hold on
    b4b =bar((1:totalStim)/fw, meanAllStimMagnNormTracesBaseSubtr100Subtr((cond+1)/2,:), 'EdgeColor', 'none', 'BarWidth', 0.15/fw); hold on
    b4b.FaceColor = 'flat';
%     b4b.CData = C(cond+1,:);
    b4b.CData = cCreCellType;
    errorbar((1:totalStim)/fw,meanAllStimMagnNormTracesBaseSubtr100Subtr((cond+1)/2,:),STEMallStimMagnNormTracesBaseSubtr100Subtr((cond+1)/2,:), '.','Color', cCreCellType,'LineWidth', 2); hold on
    xlabel('Stimulus no.');
    ylabel('\Delta Magnitude (norm.) ');
%     set(ax,'XLim',[0.4 2/fw+0.6],'FontSize',fs);
    set(ax,'XLim',[0.5/fw 6/fw+0.5/fw],'FontSize',fs);
    set(ax,'xtick',1:totalStim./fw) % set major ticks
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig30bxx{(cond+1)/2});
    background = get(gcf, 'color');
%     yl=ylim;
    yl = [-0.6 0.5];
    ylim([yl(1), yl(2)*1.1]) 
    y= yl(2)*0.90;
    for stim = 1:totalStim
        p_temp =  pAllStimMagnNormTracesBaseSubtr100Subtr((cond+1)/2,stim);
%         y = (meanAllStimMagnNormTraceFreqAllAdjSubtr((cond+1)/2,stim)+STEMallStimMagnNormTraceFreqAllAdjSubtr((cond+1)/2,stim))*1.1;
       

        %         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001/BonfCorrF
            text(stim/fw, y,'***','FontSize',fsStars, 'Color', cCreCellType, 'HorizontalAlignment','center');%*sign(y)
%             h1 = line([1 2]./fw,[y*0.98 y*0.98]);
%             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp <= 0.01/BonfCorrF
            text(stim/fw, y,'**','FontSize',fsStars, 'Color', cCreCellType, 'HorizontalAlignment','center');%*sign(y)
%             h1 = line([1 2]./fw,[y*0.99 y*0.99]);
%             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        elseif p_temp <= 0.05/BonfCorrF
            text(stim/fw, y,'*','FontSize',fsStars, 'Color', cCreCellType, 'HorizontalAlignment','center');%*sign(y)
%             h1 = line([1 2]./fw,[y*0.99 y*0.99]);
%             set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        end
    end
    max_hist1 = yl(2)*1.1;
    % h1 = line([2.7 4.3], [max_hist1 max_hist1]);
    % set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    
    h1 = line([1.7 4.3], [max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines

%     
    if saveFigs == true
        savefig(strcat(savePath, saveFig30bxx{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig30bxx{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig30bxx{(cond+1)/2}(1:end-4)), 'epsc');
    end
end