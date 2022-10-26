%%% created by RB on 23.12.2020
% Fig. 33 - plots the effect of photostim vs the visually evoked response


titleFig33 = {'Photostim. effect vs visual response'};
    
saveFig33 = {'allStimBaseEffvsAllStimMagn.fig'};

%%% Modify if necesary %%%
excludeOutliers =0;
thOut = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%

cond = 4;
xdata = squeeze(allStimBase(cond, baseSelect, 4)-allStimBase(cond, baseSelect, 1));

cond = 2;
stim = 4;
ydata = squeeze(allStimMagn(cond, baseSelect, stim));

if excludeOutliers  % exclude trials with 0 in pre or post stim
    warning('excludeOutliers activated')
    indOut = xdata <= thOut;
    xdata = xdata(indOut);
    ydata = ydata(indOut);    
end
% sum(classUnitsAll(iUnitsFilt) == 1) & sum(classUnitsAll(iUnitsFilt) == 2)
figure
ax=gca;

[f1, S]= fit(xdata',ydata', 'poly1');
scatter(xdata, ydata, 50, cCreCellType, 'filled'); hold on
plot(f1)

xlabel('FR_P_h - FR_n_o_P_h (Hz)')% xlabel('base4 - base1')
ylabel('FR_v_i_s - FR_P_h (Hz)')% ylabel('ampl4 - base4')
set(ax,'FontSize',fs)

plot(NaN,NaN,'display',['R^2: ', num2str(S.rsquare)], 'linestyle', 'none')
lgd = legend;
lgd.FontSize = 14;
box off
title(titleFig33);

if saveFigs == true
    savefig(strcat(savePath, saveFig33{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig33{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig33{1}(1:end-4)), 'epsc');
end