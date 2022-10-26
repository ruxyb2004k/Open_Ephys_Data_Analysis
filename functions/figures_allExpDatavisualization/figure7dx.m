%%% created by RB on 23.12.2020

% Fig 7dx (10x): Opto-index indivdual data points with average and errorbars - comparison baselines between before and during photostim. 
% as 7b, but markers for each cell type

titleFig7dx = {'Opto-index 100% visual stim. +/- photostim. Base2',...
    'Opto-index 100% visual stim. +/- photostim. Base3',...
    'Opto-index 100% visual stim. +/- photostim. Base4',...
    'Opto-index 100% visual stim. +/- photostim. Base5',...
    'Opto-index 100% visual stim. +/- photostim. Base6',...
    'Opto-index 0% visual stim. +/- photostim. Base2',...
    'Opto-index 0% visual stim. +/- photostim. Base3',...
    'Opto-index 0% visual stim. +/- photostim. Base4',...
    'Opto-index 0% visual stim. +/- photostim. Base5',...
    'Opto-index 0% visual stim. +/- photostim. Base6'};

saveFig7dx = {'OptoindexScatterplot100Base2Class.fig', 'OptoindexScatterplot100Base3Class.fig',...
    'OptoindexScatterplot100Base4Class.fig', 'OptoindexScatterplot100Base5Class.fig',...
    'OptoindexScatterplot100Base6Class.fig',...
    'OptoindexScatterplot0Base2Class.fig', 'OptoindexScatterplot0Base3Class.fig',...
    'OptoindexScatterplot0Base4Class.fig', 'OptoindexScatterplot0Base5Class.fig',...
    'OptoindexScatterplot0Base6Class.fig'};
fC=0.8; % 0.8 for waveforms
EI_Color = [fC,1,fC; 1,fC,fC];
for cond = (1:2:totalConds)
    for stim =2:totalStim
        f = figure('Renderer', 'painters', 'Position', [680 558 420 420]);  
        ax = gca;
        hold on
        % beeswarm graph
%         plotSpread(squeeze(OIndexAllStimBase((cond+1)/2,:, stim))','categoryIdx',classUnitsAll,...
%             'categoryMarkers',{'^','o'},'categoryColors',{'g','r'},'spreadWidth', 0.2)     
%         b7dx = bar([1,2], [meanOIndexAllStimBaseExc((cond+1)/2, stim), meanOIndexAllStimBaseInh((cond+1)/2, stim)], 'EdgeColor', 'none');
        
        bar(1, meanOIndexAllStimBaseExc((cond+1)/2, stim), 'EdgeColor', EIColor(1), 'FaceColor', EI_Color(1,:)); hold on%
        bar(2, meanOIndexAllStimBaseInh((cond+1)/2, stim), 'EdgeColor', EIColor(2), 'FaceColor', EI_Color(2,:));
        
        
        y_all = [meanOIndexAllStimBaseExc((cond+1)/2, stim) + sign(meanOIndexAllStimBaseExc((cond+1)/2, stim)) * (STEMOIndexAllStimBaseExc((cond+1)/2, stim)+0.1),...
            meanOIndexAllStimBaseInh((cond+1)/2, stim) + sign(meanOIndexAllStimBaseInh((cond+1)/2, stim)) * (STEMOIndexAllStimBaseInh((cond+1)/2, stim)+0.1)];
        p_temp_all= [pOIndexAllStimBaseExc((cond+1)/2, stim), pOIndexAllStimBaseInh((cond+1)/2, stim)];
        for i =1:2
            p_temp = p_temp_all(i);
            if p_temp <= 0.001
                text(i+0.35, y_all(i),'***','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
%                 h1 = line([1 2],[y*0.98 y*0.98]);
            elseif p_temp <= 0.01
                text(i+0.35, y_all(i),'**','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
%                 h1 = line([1 2],[y*0.99 y*0.99]);
            elseif p_temp <= 0.05
                text(i+0.35, y_all(i),'*','FontSize',fsStars, 'Color', 'k', 'HorizontalAlignment','center');%*sign(y)
%                 h1 = line([1 2],[y*0.99 y*0.99]);
            end
        end    
            
        %         scatter((1.35), meanOIndexAllStimBaseExc((cond+1)/2, stim), 100, '+', 'g', 'LineWidth', 2); hold on
        %         scatter((2.35), meanOIndexAllStimBaseInh((cond+1)/2, stim), 100, '+', 'r', 'LineWidth', 2); hold on
        
        % beeswarm graph      
        plotSpread(squeeze(OIndexAllStimBase((cond+1)/2,:, stim))','categoryIdx',classUnitsAll,...
            'distributionIdx', classUnitsAll, 'categoryMarkers',{'^','o'},'categoryColors',{'g','r'},'spreadWidth', 0.6)
        set(gca, 'xcolor', 'w');
        errorbar((1.35),meanOIndexAllStimBaseExc((cond+1)/2, stim),STEMOIndexAllStimBaseExc((cond+1)/2, stim),'.g','LineWidth',2);
        errorbar((2.35),meanOIndexAllStimBaseInh((cond+1)/2, stim),STEMOIndexAllStimBaseInh((cond+1)/2, stim),'.r','LineWidth',2);
        ylabel('Opto-index','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'XLim',[0.4 2.6],'YLim', [-1 1],'FontSize',24);
        title(titleFig7dx{(cond+1)/2*5+(stim-6)},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
%         set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        set(gca,'FontSize',24, 'XTickLabel',{'Exc. cells','Inh. cells'},'XTick',[1 2]);
        line([0.4 2.6], [0 0], 'Color', [0.2 0.2 0.2])
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig7dx{(cond+1)/2*5+(stim-6)}));
            title('');
            saveas(gcf, strcat(savePath, saveFig7dx{(cond+1)/2*5+(stim-6)}(1:end-3), 'png'));
            saveas(gcf, strcat(savePath, saveFig7dx{(cond+1)/2*5+(stim-6)}(1:end-4)), 'epsc');
        end
    end
end
