%%% created by RB on 09.03.2023

% Fig 7jModxx (1x): Violin plots of Opto-index with median and quartiles - 
% comparison baselines between before and during photostim. 


titleFig7jModxx = {'Opto-index 0% visual stim. +/- photostim.'};

saveFig7jModxx = {'OptoindexViolinplotBaseClass.fig'};
fC=0.8; % 0.8 for waveforms
%EI_Color = [1,fC,fC; fC,fC,1];
%EI_Color = [213,94,0; 0,114,178]/255; % 15.02.20023
%EI_Color = [239,191,170; 153,199,225]/255;
% if strcmp(expSetFilt(1).animalStrain, 'NexCre')
%     EI_Color = cCreCellTypeAll(1:2,:);
% elseif strcmp(expSetFilt(1).animalStrain, 'PvCre')
%     EI_Color = cCreCellTypeAll(3:4,:);
% end    
xdata = (0:totalConds-1)/(totalConds-1)*100;
Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
EI_Color = cCreCellType;
catCells = {'exc', 'inh'};
cat = catCells(classUnitsAll);
cat = cellstr(cat)';
f = figure('Renderer', 'painters', 'Position', [680 558 780 420]);
i = 1;
for cond = (1:totalConds)
    val = squeeze(OIndexAllStimPhotoBase(cond,:))';
    val1 = val(classUnitsAll == 1);
    val2 = val(classUnitsAll == 2);
    val1 = val1(~isnan(val1));
    val2 = val2(~isnan(val2));

    ax = gca;
    hold on
    line([0.4 5.6], [0 0], 'Color', [0.4 0.4 0.4])
    
    vsl = Violin({val1}, cond-0.05, 'HalfViolin','left', 'ViolinColor',{EI_Color(1,:)});%, 'ViolinAlpha', {0.2; 0.2});%, 'ShowData', false);%{EI_Color(1,:)});
    vsr = Violin({val2}, cond+0.05, 'HalfViolin','right','ViolinColor',{EI_Color(2,:)});%, 'ViolinAlpha', {0.2; 0.2});%, 'ShowData', false);%{EI_Color(2,:)});
    set(ax,'XLim',[0.4 totalConds+0.6],'YLim', [-1 1],'FontSize',24);
    title(titleFig7jModxx{1},'FontSize',18);
    background = get(gcf, 'color');
    set(gcf,'color','white'); hold on
    set(gca,'xtick',[], 'ytick',(-1:0.5:1))
    set(gca, 'xcolor', 'w');
    %         set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
    %set(gca,'FontSize',24, 'XTickLabel',{'Exc. cells','Inh. cells'},'XTick',[1 2]);
    %if cond == 1
        table_data1 = table(val1);
        table_data1 = renamevars(table_data1 , ["val1"], strcat("Exc.",num2str(xdata(cond)),'%'));
    
        table_data2 = table(val2);
        table_data2 = renamevars(table_data2 , ["val2"], strcat("Inh.",num2str(xdata(cond)),'%'));
%     else
%         table_data1 = mergevars(table_data1,["val1"],'NewVariableName',"Exc");
%         table_data2 = mergevars(table_data2,["val2"],'NewVariableName',"Inh");
%     end    
    
    
    box off
    if saveFigs == true
        writetable(table_data1, strcat(savePath, saveFig7jModxx{1}(1:end-3), 'xlsx'),'Sheet',1, 'Range', [Alphabet(i),':',Alphabet(i+1)])
        writetable(table_data2, strcat(savePath, saveFig7jModxx{1}(1:end-3), 'xlsx'),'Sheet',1, 'Range', [Alphabet(i+1),':',Alphabet(i+2)])
    end
    i = i+2;
end

if saveFigs == true
    savefig(strcat(savePath, saveFig7jModxx{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig7jModxx{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig7jModxx{1}(1:end-4)), 'epsc');   
end