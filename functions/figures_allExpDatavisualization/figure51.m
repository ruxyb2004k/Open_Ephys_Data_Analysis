%%% created by RB on 26.09.2022

% Fig 51 : histogram of trough to peak times and tp times vs recording depth 

titleFig51 = {'TP time vs. Depth'};

saveFig51 = {'TPhistDepth.fig'};

%cc = [0 1 0; 1 0 0];%'gr';
cc = [cCreCellTypeAll(1,:); cCreCellTypeAll(4,:)];
f = figure('Renderer', 'painters');% , 'Position', [680 558 420 420] 
%figure
subplot(3, 1, 1) % histogram of TP time
% histogram(cellMetricsAll.troughPeakTime(classUnitsAll == 2 & iUnitsFilt), (0.0:0.05:0.5), 'FaceColor', 'r', 'EdgeColor', 'w'); hold on
% histogram(cellMetricsAll.troughPeakTime(classUnitsAll == 1 & iUnitsFilt), (0.5:0.05:1.2), 'FaceColor', 'g', 'EdgeColor', 'w')
histogram(cellMetricsAll.troughPeakTime(classUnitsAll == 2 & baseSelect), (0.0:0.05:0.5), 'FaceColor', cc(2,:), 'EdgeColor', 'w'); hold on
histogram(cellMetricsAll.troughPeakTime(classUnitsAll == 1 & baseSelect), (0.5:0.05:1.2), 'FaceColor', cc(1,:), 'EdgeColor', 'w')
ylabel('No. units');
box off
xlim([0, 1.2])
set(gca,'xtick',[0:0.2:1.2])
set(gca,'Xticklabel',[]) 
set(gca,'FontSize',fs-12)
set(gca, 'TickDir', 'out')
%title(titleFig51)


subplot(3, 1, 2:3) % TP time vs depth
% scatter(cellMetricsAll.troughPeakTime(iUnitsFilt), realDepthAll(iUnitsFilt), 60,cc(classUnitsAll(iUnitsFilt),:), 'filled', 'MarkerFaceAlpha', 0.4);
scatter(cellMetricsAll.troughPeakTime(baseSelect), realDepthAll(baseSelect), 60,cc(classUnitsAll(baseSelect),:), 'filled', 'MarkerFaceAlpha', 0.6);
xlabel('Trough-to-peak time (ms)'); 
ylabel('Depth (\mum)');
box off
xlim([0, 1.2])
set(gca,'FontSize',fs-12)
set(gca, 'TickDir', 'out')
set(gca,'ytick',(-600:200:0))

varNames = ["TroughToPeak", "Depth"];
table_data = table(cellMetricsAll.troughPeakTime(baseSelect)', realDepthAll(baseSelect));
table_data = renamevars(table_data , ["Var1", "Var2"], varNames);
   

if saveFigs == true
    savefig(strcat(savePath, saveFig51{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig51{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig51{1}(1:end-4)), 'epsc');
    writetable(table_data, strcat(savePath, saveFig51{1}(1:end-3), 'xlsx'),'Sheet',1, 'Range','A:C')
end