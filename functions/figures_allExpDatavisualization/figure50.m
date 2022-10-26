codes = spikeClusterData.goodCodes;
cCreCellType = [192 0 0]/255
figure; % all waveforms

plot(waveformFiltAvg(5,12:52),'LineWidth',5, 'Color', cCreCellType/2); hold on   
plot(waveformFiltAvg(6,12:52),'LineWidth',5,'Color', cCreCellType); 

h1 = line([2 22],[-200 -200]) % 1 ms
h2 = line([2 2],[-100 -200]) % 100 uV
set(h1,'Color',[0 0 0] ,'LineWidth',3);% Set properties of lines
set(h2,'Color',[0 0 0] ,'LineWidth',3);% Set properties of lines
text(10, -220,'1 ms','FontSize',24, 'Color', 'k', 'HorizontalAlignment','center')
h3 = text(0, -150,'100 \muV','FontSize',24, 'Color', 'k', 'HorizontalAlignment','center')
set(h3,'Rotation',90);
axis off
if saveFigs == true
    savefig(strcat(savePath, saveFig50a));
    title('');
    saveas(gcf, strcat(savePath, saveFig50a(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig50a(1:end-4)), 'epsc');
end
end