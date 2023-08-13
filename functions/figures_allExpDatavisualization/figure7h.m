%%% created by RB on 14.02.2023

% Fig 7h (10x): Violin plots of Opto-index with median and quartiles - 
% comparison baselines between before and during photostim. 


titleFig7h = {'Opto-index 100% visual stim. +/- photostim. Base2',...
    'Opto-index 100% visual stim. +/- photostim. Base3',...
    'Opto-index 100% visual stim. +/- photostim. Base4',...
    'Opto-index 100% visual stim. +/- photostim. Base5',...
    'Opto-index 100% visual stim. +/- photostim. Base6',...
    'Opto-index 0% visual stim. +/- photostim. Base2',...
    'Opto-index 0% visual stim. +/- photostim. Base3',...
    'Opto-index 0% visual stim. +/- photostim. Base4',...
    'Opto-index 0% visual stim. +/- photostim. Base5',...
    'Opto-index 0% visual stim. +/- photostim. Base6'};

saveFig7h = {'OptoindexViolinplot100Base2Class.fig', 'OptoindexViolinplot100Base3Class.fig',...
    'OptoindexViolinplot100Base4Class.fig', 'OptoindexViolinplot100Base5Class.fig',...
    'OptoindexViolinplot100Base6Class.fig',...
    'OptoindexViolinplot0Base2Class.fig', 'OptoindexViolinplot0Base3Class.fig',...
    'OptoindexViolinplot0Base4Class.fig', 'OptoindexViolinplot0Base5Class.fig',...
    'OptoindexViolinplot0Base6Class.fig'};
fC=0.8; % 0.8 for waveforms
EI_Color = [fC,1,fC; 1,fC,fC];

catCells = {'exc', 'inh'};
cat = catCells(classUnitsAll);
cat = cellstr(cat)';
for cond = 3%(1:2:totalConds)
    for stim =4%2:totalStim
        val = squeeze(OIndexAllStimBase((cond+1)/2,:, stim))';
        val1 = val(classUnitsAll == 1);
        val2 = val(classUnitsAll == 2);
        f = figure('Renderer', 'painters', 'Position', [680 558 420 420]);  
        ax = gca;
        hold on
        line([0.4 2.6], [0 0], 'Color', [0.4 0.4 0.4]) 
        
        vs = violinplot(val,cat,'GroupOrder',catCells, 'HalfViolin','right');
        
        set(ax,'XLim',[0.4 2.6],'YLim', [-1 1],'FontSize',24);
        title(titleFig7h{(cond+1)/2*5+(stim-6)},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
%         set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        set(gca,'FontSize',24, 'XTickLabel',{'Exc. cells','Inh. cells'},'XTick',[1 2]);

        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig7h{(cond+1)/2*5+(stim-6)}));
            title('');
            saveas(gcf, strcat(savePath, saveFig7h{(cond+1)/2*5+(stim-6)}(1:end-3), 'png'));
            saveas(gcf, strcat(savePath, saveFig7h{(cond+1)/2*5+(stim-6)}(1:end-4)), 'epsc');
        end
    end
end
 
