%% Fig. 26e (1x) : reproduction of fig 8bi from eLife 2020 (average magnitude of normalized and baseline subtr traces)

if totalStim == 1
    titleFig26e = {'Normalized magnitude of base-subtr traces'};
    saveFig26e = {'meanMagnNormTracesBaseSubtr100.fig'};

end

cond = 1;
figure

ax = gca;
hold on
conds = [1,2,totalConds+2];
intYMagn = [1:2:totalConds-2; 2:2:totalConds-2; totalConds+2:2:totalConds*2-2]';

xMagn = repmat([numel(contrasts):-1:1], 3,1)';
xMagn = xMagn + [-0.2 0 0.2];
xMagn1 = xMagn + [-0.05 0 0.05];
yMagn(:,1) = meanAllStimMagnNormTracesBaseSubtr100(intYMagn(:,1));
yMagn(:,2) = meanAllStimMagnNormTracesBaseSubtr100(intYMagn(:,2));
yMagn(:,3) = meanAllStimMagnNormTracesBaseSubtr100(intYMagn(:,3));
pMagn(:,1) = pAllStimMagnNormTracesBaseSubtr100( 1:totalConds/2-1);
pMagn(:,2) = pAllStimMagnNormTracesBaseSubtr100(totalConds/2+1:totalConds-1);
b26e= bar(xMagn, yMagn, 'EdgeColor', 'none', 'BarWidth', 4);

b26e(1).FaceColor = C(1,:);
b26e(2).FaceColor = C(2,:);
b26e(3).FaceColor = C(totalConds+2,:);

errorbar(xMagn1(:,1),yMagn(:,1),STEMallStimMagnNormTracesBaseSubtr100(1:2:totalConds-2,:), 'LineStyle','none', 'LineWidth', 2,'Color', C(1,:));
errorbar(xMagn1(:,2),yMagn(:,2),STEMallStimMagnNormTracesBaseSubtr100(2:2:totalConds-2,:), 'LineStyle','none', 'LineWidth', 2,'Color', C(2,:));
errorbar(xMagn1(:,3),yMagn(:,3),STEMallStimMagnNormTracesBaseSubtr100(totalConds+2:2:2*totalConds-2,:), 'LineStyle','none', 'LineWidth', 2,'Color', C(totalConds+2,:));

for i = 1:size(pMagn,1) % add stars in case of significance
    for j = 1:size(pMagn,2) % add stars in case of significance
        if pMagn(i, j) <= 0.001
%             pStars = '***';
            text(xMagn1(i, j+1), yMagn(i,j+1)+0.2, '***','FontSize',10, 'Color', C(conds(j+1),:), 'HorizontalAlignment','center')
        elseif pMagn(i, j) <= 0.01
%             pStars = '**';
            text(xMagn1(i, j+1), yMagn(i,j+1)+0.2, '**','FontSize',10, 'Color', C(conds(j+1),:), 'HorizontalAlignment','center')
        elseif pMagn(i, j) <= 0.05
%             pStars = '*';   
            text(xMagn1(i, j+1), yMagn(i,j+1)+0.2, '*','FontSize',10, 'Color', C(conds(j+1),:), 'HorizontalAlignment','center')
        end 
    end
end
box off
xticks(1:numel(contrasts))
xticklabels(contrasts(end:-1:1));
ylabel('Norm. magnitude');
xlabel('Contrasts (%)');
set(ax,'FontSize',fs);  

set(ax, 'TickDir', 'out');

title(titleFig26e,'FontSize',18);
background = get(gcf, 'color');

if saveFigs == true
    savefig(strcat(savePath, saveFig26e{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig26e{1}(1:end-3), 'png'));
    
end


