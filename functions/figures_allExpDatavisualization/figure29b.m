%%% created by RB on 23.12.2020

% Fig. 29b (2x) : Bar plot, average normalized magnitude to same stim in the control
% condition

if totalStim == 6
    titleFig29b = {'Normalized magnitude 100% visual stim. vs 100% visual + photostim. all cells'};
    
    saveFig29b = {'meanAllStimMagnNormToStim100.fig','meanAllStimMagnNormToStim0.fig'};
elseif totalStim ==1
    titleFig29b = {'Normalized magnitude 100% visual stim. vs 100% visual + photostim. all cells',...
    'Normalized magnitude 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Normalized magnitude 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Normalized magnitude 12% visual stim. vs 12% visual + photostim. all cells norm'};

    saveFig29b = {'meanAllStimMagnNormToStim100.fig', 'meanAllStimMagnNormToStim50.fig','meanAllStimMagnNormToStim25.fig','meanAllStimMagnNormToStim12.fig','meanAllStimMagnNormToStim0.fig'};
end

fx =1;
for cond = (1:2:totalConds-2)
    figure
    ax = gca;
    hold on
    b4b =bar((1:totalStim)/fw, meanAllStimMagnNormToStim(cond+1,:), 'EdgeColor', 'none', 'BarWidth', 0.6/fw); hold on
    b4b.FaceColor = 'flat';
    b4b.CData = C(cond+1,:);
%     b4b.CData(2,:) = C(cond+1,:);
    errorbar((1:totalStim)/fw,meanAllStimMagnNormToStim(cond+1,:),STEMallStimMagnNormToStim(cond+1,:), '.','Color', C(cond+1,:),'LineWidth', 4); hold on
    xlabel('Stim#');
    ylabel('Firing rate (norm.) ');
%     set(ax,'XLim',[0.4 2/fw+0.6],'FontSize',fs);
    set(ax,'XLim',[0.5/fw 6/fw+0.5/fw],'FontSize',fs);
    set(ax,'xtick',1:totalStim/fw) % set major ticks
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Magn. 1','Magn. 2', 'Magn. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig29b{(cond+1)/2});
    background = get(gcf, 'color');
    yl=ylim;
    ylim([yl(1), yl(2)*1.1]) 
    y= yl(2)*1.05;
    for stim = 1:totalStim
        p_temp =  pAllStimMagnNormToStim((cond+1)/2,stim);
        y = (meanAllStimMagnNormToStim(cond+1,stim)+STEMallStimMagnNormToStim(cond+1,stim))*1.1;
       

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
        savefig(strcat(savePath, saveFig29b{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig29b{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig29b{(cond+1)/2}(1:end-4)), 'epsc');
    end
end