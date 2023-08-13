%%% created by RB on 07.07.2023

% Fig 33a (5x): Violin plots of Opto-index with median and quartiles - 
% comparison norm. magnitudes between before and during photostim. 


titleFig33a = {'Opto-index 100% visual stim. +/- photostim. Magn1',...
    'Opto-index 100% visual stim. +/- photostim. Magn2',...
    'Opto-index 100% visual stim. +/- photostim. Magn3',...
    'Opto-index 100% visual stim. +/- photostim. Magn4',...
    'Opto-index 100% visual stim. +/- photostim. Magn5',...
    'Opto-index 100% visual stim. +/- photostim. Magn6'};

saveFig33a = {'OptoindexViolinplot100NormMagn1Class.fig', 'OptoindexViolinplot100NormMagn2Class.fig',... 
    'OptoindexViolinplot100NormMagn3Class.fig', 'OptoindexViolinplot100NormMagn4Class.fig',...
    'OptoindexViolinplot100NormMagn5Class.fig', 'OptoindexViolinplot100NormMagn6Class.fig'};
fC=0.8; % 0.8 for waveforms
%EI_Color = [1,fC,fC; fC,fC,1];
%EI_Color = [213,94,0; 0,114,178]/255; % 15.02.20023
%EI_Color = [239,191,170; 153,199,225]/255;
if strcmp(expSetFilt(1).animalStrain, 'NexCre')
    EI_Color = cCreCellTypeAll(1:2,:);
elseif strcmp(expSetFilt(1).animalStrain, 'PvCre')
    EI_Color = cCreCellTypeAll(3:4,:);
end    
catCells = {'exc', 'inh'};
cat = catCells(classUnitsAll);
cat = cellstr(cat)';
for cond = 1%(1:2:totalConds)
    for stim =4%1:totalStim
        val = squeeze(OIndexAllStimMagnNormTracesBaseSubtr100((cond+1)/2,:, stim))';
        val1 = val(classUnitsAll == 1);
        val2 = val(classUnitsAll == 2);
        val1 = val1(~isnan(val1));
        val2 = val2(~isnan(val2));
        f = figure('Renderer', 'painters', 'Position', [680 558 280 420]);  
        ax = gca;
        hold on
        line([0.4 2.6], [0 0], 'Color', [0.4 0.4 0.4]) 
         
        vsl = Violin({val1}, 1-0.05, 'HalfViolin','left', 'ViolinColor',{EI_Color(1,:)});%{EI_Color(1,:)});
        vsr = Violin({val2}, 1+0.05, 'HalfViolin','right','ViolinColor',{EI_Color(2,:)});%{EI_Color(2,:)});
        set(ax,'XLim',[0.4 1.6],'YLim', [-1 1],'FontSize',24);
        title(titleFig33a{(cond+1)/2*5+(stim-6)},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'xtick',[], 'ytick',(-1:0.5:1))
        set(gca, 'xcolor', 'w');
%         set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        %set(gca,'FontSize',24, 'XTickLabel',{'Exc. cells','Inh. cells'},'XTick',[1 2]);
        yl = ylim;
        p_temp = pOIndexAllStimMagnNormTracesBaseSubtr100ExcInh;
        if p_temp((cond+1)/2, stim) <= 0.001
        %             pStars = '***';
            text(1, yl(2)*0.98, '***','FontSize',fsStars,  'HorizontalAlignment','center')
        elseif p_temp <= 0.01
        %             pStars = '**';
            text(1, yl(2)*0.98, '**','FontSize',fsStars, 'HorizontalAlignment','center')
        elseif p_temp <= 0.05
        %             pStars = '*';
            text(1, yl(2)*0.98, '*','FontSize',fsStars, 'HorizontalAlignment','center')
        end
        h1 = line([0.8 1.2],[yl(2)*0.96 yl(2)*0.96]);
        set(h1,'Color',[0 0 0] ,'LineWidth',1);% Set properties of lines
        table_data1 = table(val1);
        table_data1 = renamevars(table_data1 , ["val1"], ["Exc."]);
   
        table_data2 = table(val2);
        table_data2 = renamevars(table_data2 , ["val2"], ["Inh."]);
        
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig33a{stim-1}));
            title('');
            saveas(gcf, strcat(savePath, saveFig33a{stim-1}(1:end-3), 'png'));
            saveas(gcf, strcat(savePath, saveFig33a{stim-1}(1:end-4)), 'epsc');
            writetable(table_data1, strcat(savePath, saveFig33a{stim-1}(1:end-3), 'xlsx'),'Sheet',1, 'Range','A:C')
            writetable(table_data2, strcat(savePath, saveFig33a{stim-1}(1:end-3), 'xlsx'),'Sheet',1, 'Range','D:F')

        end
    end
end
