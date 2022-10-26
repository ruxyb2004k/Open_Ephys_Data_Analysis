
%%% created by RB on 23.12.2020

% Fig 1Mod: average of time courses 

titleFig1Mod = {'Mean time course'};
saveFig1Mod = {'meanTC.fig'};

axesType = 1;% 1 = normal, 2 = L-type (short axes)

figure;
i = 1;
condsPlot = [1,3];
C = 'gr';

if strcmp(char(exps), 'ActivatingBoth')
    cCreCellType(1,:) = [0 0 255]/255;% exc
    cCreCellType(2,:) = [0 0 255]/255;% inh
end

for cond = condsPlot %(1:totalConds)
    subplot(1,numel(condsPlot), i)
    ax = gca;
    hold on
    for unitType =(1:2)
        cCond = cCreCellType(1,:);
        if cond == 1
            cCond = [0 0 0];
        end    
        plot(time_stamps, squeeze(meanTraceFreqAll(cond,unitType, :)),'LineWidth', 3, 'Color', cCond); hold on
    end
    yl = [3 13];
    xlim([1,4]);
    ylim(yl)
    if cond == 1
        xlabel('Time (s)');
        ylabel('Firing rate (Hz)');
        
        if axesType == 2
            plot([1.5; 1.5], [7; 9], '-k',  [1.5; 2.5], [7; 7], '-k', 'LineWidth', 2)
            text(1.2, 9, '2 Hz', 'HorizontalAlignment','right', 'FontSize', fs, 'Rotation', 90)
            text(2,6, '1 s', 'HorizontalAlignment','center', 'FontSize', fs)   
        end
    end
    set(ax,'FontSize',fs);
    title([num2str(round(keys1(cond)/40*100)), '%'])
    
    set(ax, 'TickDir', 'out');
    xticks([1,2,3,4]);
    xticklabels([0,1,2,3]);
    if cond ~= 1
        h1 = line([event_times(2), 4] ,[yl(2) yl(2)]);
        set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    end    
    fact = 0.95;
    x = event_times(3:4);
    
    h2 = line('XData',x,'YData',fact*[yl(2) yl(2)]); 
    set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
    box off
    if axesType == 2
        set(gca, 'Visible', 'off')
    end
    
    i = i+1;
end
    
if saveFigs == true
    savefig(strcat(savePath, saveFig1Mod{1}));
%     title('');
    saveas(gcf, strcat(savePath, saveFig1Mod{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig1Mod{1}(1:end-4)), 'epsc');
end
