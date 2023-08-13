% Fig 36
if strcmp(expSetFilt(1).animalStrain, 'NexCre')
    EI_Color = cCreCellTypeAll(1:2,:);
elseif strcmp(expSetFilt(1).animalStrain, 'PvCre')
    EI_Color = cCreCellTypeAll(3:4,:);
end    




figure; scatterhist(OIndexAllStimBase(2, :, 4),OIndexAllStimMagn(1, :, 4),'Group',classUnitsAll,...
    'Kernel','on','Color',EI_Color,'Marker','.','MarkerSize', 20,'Location','NorthEast','Direction','out'); hold on
line([-1 1], [0 0], 'Color', [0.4 0.4 0.4])
line([0 0],[-1 1], 'Color', [0.4 0.4 0.4])
errorbar(meanOIndexAllStimBaseExc(2,4), meanOIndexAllStimMagnExc(4),STEMOIndexAllStimBaseExc(2, stim), 'horizontal', "^k", 'MarkerFaceColor', EI_Color(1,:), 'LineWidth', 2)
errorbar(meanOIndexAllStimBaseExc(2,4), meanOIndexAllStimMagnExc(4),STEMOIndexAllStimMagnExc(1, stim), 'vertical', "^k",'MarkerFaceColor', EI_Color(1,:), 'LineWidth', 2)
errorbar(meanOIndexAllStimBaseInh(2,4), meanOIndexAllStimMagnInh(4),STEMOIndexAllStimBaseInh(2, stim), 'horizontal', "ok",'MarkerFaceColor', EI_Color(2,:), 'LineWidth', 2)
errorbar(meanOIndexAllStimBaseInh(2,4), meanOIndexAllStimMagnInh(4),STEMOIndexAllStimMagnInh(1, stim), 'vertical',  "ok",'MarkerFaceColor', EI_Color(2,:), 'LineWidth', 2)
xlabel('OI baseline')
ylabel('OI magnitude')
xlim([-1 1])
ylim([-1 1])