%%% created by RB on 09.03.2023

% Fig 7jModxxx (1x): Violin plots of Opto-index with median and quartiles - 
% comparison baselines between before and during photostim. 
% units colorcoded to weather they are activated or not


titleFig7jModxxx = {'Opto-index 0% visual stim. +/- photostim.'};

saveFig7jModxxx = {'OptoindexViolinplotBaseClassAct.fig'};
fC=0.8; % 0.8 for waveforms
xdata = (0:totalConds-1)/(totalConds-1)*100;
Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
EI_Color = cCreCellType;
catCells = {'exc', 'inh'};
cat = catCells(classUnitsAll);
cat = cellstr(cat)';
f = figure('Renderer', 'painters', 'Position', [680 558 780 420]);
i=1;
for cond = (1:totalConds)
    activated = zeros(numel(classUnitsAll),1);
    val = squeeze(OIndexAllStimPhotoBase(cond,:))';
    if cond >1
        if contains(char(exps), 'ActivatingExc')
            act = ones(totalUnits*0.8*(keys1(cond)/40),1);
            activated(1:numel(act))=1;
        elseif contains(char(exps), 'ActivatingInh')
            act = ones(totalUnits*0.2*(keys1(cond)/40),1);
            activated(totalUnits*0.8+1:totalUnits*0.8+numel(act))=1;
        end
    end

    val1 = val(classUnitsAll == 1 & activated);
    val2 = val(classUnitsAll == 2 & activated);
    val3 = val(classUnitsAll == 1 & ~activated);
    val4 = val(classUnitsAll == 2 & ~activated);
    val1 = val1(~isnan(val1));
    val2 = val2(~isnan(val2));
    val3 = val3(~isnan(val3));
    val4 = val4(~isnan(val4));

    ax = gca;
    hold on
    line([0.4 5.6], [0 0], 'Color', [0.4 0.4 0.4])
    
    if ~isempty(val1) % exc, activated
        vsl1 = Violin({val1}, cond-0.05, 'HalfViolin','left', 'ViolinColor',{cCreAllColors(1,:)}, 'ViolinAlpha', {0.7}, 'ShowData', false);%{EI_Color(1,:)});
    end
    if ~isempty(val2) % inh, activated
    vsr1 = Violin({val2}, cond+0.05, 'HalfViolin','right','ViolinColor',{cCreAllColors(4,:)}, 'ViolinAlpha', {0.7}, 'ShowData', false);%{EI_Color(2,:)});
    end
    if ~isempty(val3) % exc, not activated
    vsl2 = Violin({val3}, cond-0.05, 'HalfViolin','left', 'ViolinColor',{cCreAllColors(3,:)}, 'ViolinAlpha', {0.7}, 'ShowData', false);%{EI_Color(1,:)});
    end
    if ~isempty(val4) % inh, not activated
        vsr2 = Violin({val4}, cond+0.05, 'HalfViolin','right','ViolinColor',{cCreAllColors(2,:)}, 'ViolinAlpha', {0.7}, 'ShowData', false);%{EI_Color(2,:)});
    end
    set(ax,'XLim',[0.4 5.6],'YLim', [-1 1],'FontSize',24);
    title(titleFig7jModxxx{1},'FontSize',18);
    background = get(gcf, 'color');
    set(gcf,'color','white'); hold on
    set(gca,'xtick',[], 'ytick',(-1:0.5:1))
    set(gca, 'xcolor', 'w');
    %         set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
    %set(gca,'FontSize',24, 'XTickLabel',{'Exc. cells','Inh. cells'},'XTick',[1 2]);
    
    table_data1 = table(val1);
    table_data1 = renamevars(table_data1 , ["val1"], strcat("Exc. units activated",num2str(xdata(cond)),'%'));
    
    table_data2 = table(val2);
    table_data2 = renamevars(table_data2 , ["val2"], strcat("Inh. units activated",num2str(xdata(cond)),'%'));
    
    table_data3 = table(val3);
    table_data3 = renamevars(table_data3 , ["val3"], strcat("Exc. units non-activated",num2str(xdata(cond)),'%'));
    
    table_data4 = table(val4);
    table_data4 = renamevars(table_data4 , ["val4"], strcat("Inh. units non-activated",num2str(xdata(cond)),'%'));
    
    
    box off
    if saveFigs == true
        writetable(table_data1, strcat(savePath, saveFig7jModxxx{1}(1:end-3), 'xlsx'),'Sheet',1, 'Range', [Alphabet(i),':',Alphabet(i+1)])
        writetable(table_data2, strcat(savePath, saveFig7jModxxx{1}(1:end-3), 'xlsx'),'Sheet',1, 'Range', [Alphabet(i+1),':',Alphabet(i+2)])
        writetable(table_data3, strcat(savePath, saveFig7jModxxx{1}(1:end-3), 'xlsx'),'Sheet',1, 'Range', [Alphabet(i+2),':',Alphabet(i+3)])
        writetable(table_data4, strcat(savePath, saveFig7jModxxx{1}(1:end-3), 'xlsx'),'Sheet',1, 'Range', [Alphabet(i+3),':',Alphabet(i+4)])       
    end
    i = i+4;
end

if saveFigs == true
    savefig(strcat(savePath, saveFig7jModxxx{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig7jModxxx{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig7jModxxx{1}(1:end-4)), 'epsc');
end
