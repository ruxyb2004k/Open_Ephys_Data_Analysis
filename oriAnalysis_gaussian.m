% orientation experiment analysis
clearvars -except experimentName sessionName


path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
basePathData = strjoin({basePath, 'data'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % spike cluster data
filenameClusterTimeSeries = fullfile(basePathMatlab,[sessionName,'.clusterTimeSeries.mat']); % cluster time series 
filenameCellMetrics = fullfile(basePathMatlab,[sessionName,'.cellMetrics.mat']); % spike cluster data

% try to load structures if they don't already exist in the workspace
[spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);
[clusterTimeSeries, CTSexist] = tryLoad('clusterTimeSeries', filenameClusterTimeSeries);
[cellMetrics, CMexist] = tryLoad('cellMetrics', filenameCellMetrics);


savePath = basePathMatlab;
savePathFigs = fullfile(basePathMatlab, 'figs');
savePathGood = fullfile(savePathFigs, 'good');

saveFigs = false;

%%
% use amplByTrial % conds, codes, trials
meanAmplByTrial = squeeze(nanmean(clusterTimeSeries.amplByTrial, 3));
% meanAmplByTrial = squeeze(nanmean(amplByTrial, 3));
totalConds = size(meanAmplByTrial, 1); % all good codes
% totalCodes = size(clusterTimeSeries.selectedCodes, 1);
totalCodes = size(meanAmplByTrial, 2);
m = ceil(sqrt(totalCodes));

titleColor = 'gr';
if exist('cellMetrics') 
    EItype = (cellMetrics.troughPeakTime<0.5) + 1;
else    
    EItype = ones(totalCodes, 1);
end


%% Calculate Fit and put all corresponding data into structure

radians = deg2rad(0:30:330); %vector with all angles the visual response has been recorded for, converted into radians (bc matlab)
MaxYall = repmat(max(meanAmplByTrial), [24 1]); % find the maximum for each unit and repeat it for the entire column for calculation purposes in the next line

normMeanAmplByTrial = meanAmplByTrial./MaxYall; % normalize each column for Gauss
NormForGauss = nan(size(normMeanAmplByTrial,1)+2, size(normMeanAmplByTrial,2)); % preallocate space for working matrix

for code = 1: totalCodes

%     shifted = false;
    
    [circVarf1,Maxf1] = calccircVar(meanAmplByTrial(1:2:end,code),radians);

    [circVarf2,Maxf2] = calccircVar(meanAmplByTrial(2:2:end,code),radians);
    
    MaxY = 1;
        
    % figure out whether it's okay to take the average of the two Max
    % values (one from each condition), or whether it's better to check
    % which one is closer to the maximum data value
    
    if (abs(Maxf1-Maxf2) <= 30)
        Max = mean([Maxf1,Maxf2]);
    elseif (abs(Maxf1-Maxf2) >= 180-30) %%%% added exception for cases like Maxf1 = 10 deg and Maxf2 = 170 deg
        Max = mod((Maxf1 + Maxf2 + 180)/2, 180);
    else
        [MaxY,MaxYPos] = max(normMeanAmplByTrial(:,code));
        MaxYPos = (ceil(MaxYPos/2)-1)*30; 
        if (abs(MaxYPos - Maxf1) < abs(MaxYPos - Maxf2))
            Max = Maxf1;
        else
            Max = Maxf2;
        end
    end
    
    
    
    % we want both of the peaks to be as far away from the borders of the
    % plot as possible
    % to this end, we want to shift the calculated Max to position 3 of the
    % graph (Max180 will be at pos 9, consequently)
    
    % calculate the distance of Max to position 3 (= 90 degrees), and derive
    % the number of positions the vector for x-axis data needs to be
    % circshifted
    ShiftDist = Max - 90;
    CircshiftK = floor(-ShiftDist/30);
    xDataDegrees = circshift(0:30:330,CircshiftK);   

    xDataDegrees(13) = xDataDegrees(1); % this needs to be in place before the next step!

    % matlab sadly can't use a vector who is not constanly rising as a
    % x-axis for a plot
    % therefore, we need to substract every value before 0 by 360 degrees
    if (CircshiftK > 0)
        xDataDegrees = [(xDataDegrees(1:CircshiftK))-360,xDataDegrees(CircshiftK+1:end)];
    elseif (CircshiftK < 0)
        xDataDegrees = [(xDataDegrees(1:12+CircshiftK))-360,xDataDegrees(12+CircshiftK+1:end)];
        Max = Max - 360;
    end
    
    xDataDegrees(13) = xDataDegrees(1)+360; % need this in case CircshiftK = 0
    

    % Custom algorithm from this paper: https://pubmed.ncbi.nlm.nih.gov/22878719/
    % a0 = baseline, a1 & a2  = height of curves; b1 = position of curve on X-axis,
    % c1 = width of curves  
    customGauss = fittype( @(a0,a1,a2,b1,c1,x) a0 + a1*exp(-((x-b1).^2/(2*c1.^2))) + a2*exp(-((x-b1-180).^2/(2*c1.^2))),'dependent','y','independent','x');
    
    % since theta from calccircVar is always in the range 0:180:
    Max180 = Max + 180;

    % now, fill the preallocated working matrix
    % CirkshiftK needs to be doubled because the matrix contains values for
    % both light conditions (w/ and w/o blue light)
    NormForGauss(1:24,code) = circshift(normMeanAmplByTrial(:,code),CircshiftK*2,1);
    NormForGauss(25:26,code) = NormForGauss(1:2,code);

    MinY = min(NormForGauss(:,code));
    
  
    
    % Syntax for options: [a0 a1 a2 b1 c1]
    options = fitoptions(customGauss);   
    options.StartPoint = [MinY MaxY MaxY Max 30];
    options.Lower = [0 0 0 xDataDegrees(1) 0];
    options.Upper = [1 1 1 xDataDegrees(7) Inf];
    
    % StartPoint: The Algorithm will start looking at these points for the
    % appropiate values. It is capable of looking for a start point itself,
    % but alas, this doesn't yield usable results
    % Lower and Upper are lower and upper limits. Helps the algorithm find
    % reasonable results, and prevents errors
    
 
    % here we construct the Gauss curve
    f1 = fit((xDataDegrees)',NormForGauss(1:2:end,code),customGauss,options); 
    f2 = fit((xDataDegrees)',NormForGauss(2:2:end,code),customGauss,options); 
    % f1 and f2 can be inspected in the console window, not in the
    % variables tab!
    % for experimenting with fitting, it's best to use 'cftool'
    
    
    
    allFitData(code).NormForGauss = NormForGauss(:,code);
%     allFitData(code).shifted = shifted;
    allFitData(code).Max = Max;
    allFitData(code).Max180 = Max180;
    allFitData(code).MaxY = MaxY;
    allFitData(code).f1 = [f1.a0, f1.a1, f1.a2, f1.b1, f1.c1];
    allFitData(code).f2 = [f2.a0, f2.a1, f2.a2, f2.b1, f2.c1];
    allFitData(code).f1cfit = f1;
    allFitData(code).f2cfit = f2;
    allFitData(code).xDataDegrees = xDataDegrees;
    allFitData(code).circVarf1 = circVarf1;
    allFitData(code).circVarf2 = circVarf2;
    allFitData(code).Maxf1 = Maxf1;
    allFitData(code).Maxf2 = Maxf2;
    allFitData(code).yf1 = f1(xDataDegrees); 
    allFitData(code).yf2 = f2(xDataDegrees);
    
end

%% Compute fitting error for each unit

for code = 1:totalCodes

    allFitData(code).fitErrorf1 = fittingError_circ(allFitData(code).NormForGauss(1:2:end),allFitData(code).yf1); 
    allFitData(code).fitErrorf2 = fittingError_circ(allFitData(code).NormForGauss(2:2:end),allFitData(code).yf2); 

end

%% Create logical array for editing data later based on Fitting Error

% if Fitting Error > 0.5, exclude tuning width and direction selectivity
% from further analysis
fitErrorFilt(1:totalCodes,1:2) = true;
fitErrorFilt(:,1) = [allFitData.fitErrorf1] <= 0.5;
fitErrorFilt(:,2) = [allFitData.fitErrorf2] <= 0.5;

for code = 1:totalCodes
    allFitData(code).fitErrorOkay = (fitErrorFilt(code,1) & fitErrorFilt(code,2));
end   
selectedCodesByFitError = [allFitData(:).fitErrorOkay];

%% Compute signal-to-noise ratio for each unit

for code = 1:totalCodes
   
    allFitData(code).snrf1 = snr(clusterTimeSeries.amplByTrial(1:2:end,code,:)); 
    allFitData(code).snrf2 = snr(clusterTimeSeries.amplByTrial(2:2:end,code,:));
    
end

%% Plot Fitting error against signal-to-noise, colorcode fitting error > 0.5
figure

ColorMap = makeColorMap([allFitData.fitErrorf1],totalCodes,0.5,[0 0 0]);
scatter([allFitData.fitErrorf1],[allFitData.snrf1],[],ColorMap); hold on
ColorMap = makeColorMap([allFitData.fitErrorf2],totalCodes,0.5,[0 0 1]);
scatter([allFitData.fitErrorf2],[allFitData.snrf2],[],ColorMap);

xticks([0,0.5,1]);
xlim([0 1])
ylim([0 1])
xlabel('Fitting Error')
ylabel('Signal-to-noise ratio')

%% plot the fits

figure
for code = 1: totalCodes
    subplot(m,m,code, 'align'); 

    %draw a blue line at the position of the maximum, and a grey one at
    %max180
    line([allFitData(code).Max,allFitData(code).Max],[0,allFitData(code).MaxY],'Linewidth', 10, 'Color', [0.8,0.8,1]); hold on
    line([allFitData(code).Max180,allFitData(code).Max180],[0,allFitData(code).MaxY], 'Linewidth', 10, 'Color', [0.8,0.8,0.8]); 
    plot((allFitData(code).xDataDegrees)',allFitData(code).NormForGauss(1:2:end), '.k');%%%%, 'MarkerSize', 20
    plot((allFitData(code).xDataDegrees)',allFitData(code).NormForGauss(2:2:end), '.b');%%%% , 'MarkerSize', 20 
    plot(allFitData(code).f1cfit, 'k');
    plot(allFitData(code).f2cfit, 'b');  

    legend('off')
    grid on
    title(spikeClusterData.goodCodes(code), 'Color', titleColor(EItype(code)), 'Fontsize', 8); 

    xlim([allFitData(code).xDataDegrees(1) allFitData(code).xDataDegrees(13)])
    xticks([-270 -180 -90 0 90 180 270])
    xticklabels({'90','180','270','0','90','180','270'})

    xlabel('')  
    ylabel('') 
    if code == totalCodes %%%% plot labels only for the last code
        ylabel('FR (norm)')
        xlabel('Orientation (�)')
    end
end    
if saveFigs == true
    savefig(strcat(savePathGood,  filesep, 'tuningCurve_all.fig'));
end

disp(spikeClusterData.goodCodes(selectedCodesByFitError)')

%% process data for plotting Tuning Width, Direction selectivity & Preferred Orientation
for code = 1:totalCodes
    % X is f1, Y is f2
    
       
        % plot c1 of f1 and f2
        TuningWidthLightOff = allFitData(code).f1(5);
        TuningWidthLightOn = allFitData(code).f2(5);

        %plot |a1-a2|/(a1+a2) of f1 and f2
        DirectionSelectivityLightOff = abs((allFitData(code).f1(2)-allFitData(code).f1(3)))/(allFitData(code).f1(2)+allFitData(code).f1(3));
        DirectionSelectivityLightOn = abs((allFitData(code).f2(2)-allFitData(code).f2(3)))/(allFitData(code).f2(2)+allFitData(code).f2(3)); 
        
        %plot b1 of f1 and f2
        PreferredOrientationLightOff = allFitData(code).f1(4);
        PreferredOrientationLightOn = allFitData(code).f2(4);

        PopulationSummary(code,:) = [TuningWidthLightOff,TuningWidthLightOn,DirectionSelectivityLightOff,DirectionSelectivityLightOn,PreferredOrientationLightOff,PreferredOrientationLightOn];
        
        allFitData(code).PopulationSummary = PopulationSummary(code,:);
        
        allFitData(code).TuningWidth = index_1(TuningWidthLightOff,TuningWidthLightOn);
        allFitData(code).DirectionSelectivity = index_1(DirectionSelectivityLightOff,DirectionSelectivityLightOn);
        allFitData(code).PreferredOrientation = index_1(PreferredOrientationLightOff,PreferredOrientationLightOn);
end

% if Fitting Error > 0.5, exclude tuning width and direction selectivity
% will be excluded from further analysis
TWandDSI_Selected = PopulationSummary(selectedCodesByFitError',1:4);

% replace negative degree values (-90° = 270°, -20° = 340°, etc.)
% and turn 0-330 into 0-150
PrefOri_All = mod(PopulationSummary(:,5:6),180);

% PopulationSummary(:,5:6) => 180 = mod(PopulationSummary(:,5:6));


%% plot Tuning Width, Direction selectivity & Preferred Orientation

figure
% subplot(1,3,1);
scatter(TWandDSI_Selected(:,1),TWandDSI_Selected(:,2)); hold on
pbaspect([1 1 1]);
axis = gca;
maxAxis = max([axis.XLim, axis.YLim]);
line([0 maxAxis],[0 maxAxis],'Color',[0.8 0.8 0.8]);
title('Tuning width');
xlabel('light off')
ylabel('light on')
offset = 0.005*axis.XLim(2);
for code = 1:totalCodes
    if (selectedCodesByFitError(code) == true)      
        text(PopulationSummary(code,1),PopulationSummary(code,2),num2str(code),'FontSize', 8);
    end
end

figure
% subplot(1,3,2);
scatter(TWandDSI_Selected(:,3),TWandDSI_Selected(:,4)); hold on
pbaspect([1 1 1]);
axis = gca;
maxAxis = max([axis.XLim, axis.YLim]);
line([0 maxAxis],[0 maxAxis],'Color',[0.8 0.8 0.8]);
title('Direction selectivity');
xlabel('light off')
ylabel('light on')
offset = 0.005*axis.XLim(2);
for code = 1:totalCodes
    if (selectedCodesByFitError(code) == true)
        text(PopulationSummary(code,3)-offset,PopulationSummary(code,4),num2str(code),'FontSize', 8);
    end
end
figure
% subplot(1,3,3);
scatter(PrefOri_All(:,1),PrefOri_All(:,2)); hold on
pbaspect([1 1 1]);
axis = gca;
maxAxis = max([axis.XLim, axis.YLim]);
line([0 maxAxis],[0 maxAxis],'Color',[0.8 0.8 0.8]);
title('Preferred orientation');
xlabel('light off')
ylabel('light on')
offset = 0.005*axis.XLim(2);
for code = 1:totalCodes
    text(PrefOri_All(code,1)-offset,PrefOri_All(code,2),num2str(code),'FontSize', 8);
end


% %% Doesn't work anymore
% figure
% for code = 1: totalCodes
%     subplot(m,m,code, 'align');
%     
% % polarplot wants the values of the x-axis in radians, not in degrees
% % that's why we have to calculate the number of steps by dividing 2*pi
%     
% %     polarsteps = (2*pi)/ (totalConds/2);
% %     allaroundmeanAmplByTrial = cat(1,meanAmplByTrial,meanAmplByTrial(1:2,:));
%     fitdata1 = plot(allFitData(code).f1cfit, 'k'); hold on
%     fitdata2 = plot(allFitData(code).f2cfit, 'b');   
%     hold off;
%     
%     rho1 = fitdata1.YData';
%     rho2 = fitdata2.YData';
%     
%     polarsteps = (2*pi)/1001;
%     polarplot(polarsteps:polarsteps:2*pi,rho1, 'k'); hold on
%     polarplot(polarsteps:polarsteps:2*pi,rho2, 'b');
% 
%     
%     title(spikeClusterData.goodCodes(code), 'Color', titleColor(EItype(code))); 
% 
% %     thetaticks([90 180 360]);
% %     thetaticklabels({ '90', '180', '360°'});
% end    
% if saveFigs == true
%     savefig(strcat(savePathGood,  filesep, 'tuningCurve_polar.fig'));
% end


% %% Doesn't work anymore Merge parallel movements, plot half polarplot
% 
% figure
% for code = 1: totalCodes
%     subplot(m,m,code, 'align');
%     
%     % we basically cut meanAmplByTrial horizontally in half, and then make
%     % the sum of these two halfes
%     tempmatrix1 = meanAmplByTrial(1:totalConds/2, :);
%     tempmatrix2 = meanAmplByTrial(totalConds/2+1:totalConds, :);
%     mergedmeanAmplByTrial = tempmatrix1 + tempmatrix2;   
%     clear tempmatrix1 tempmatrix2
%   
% 
%     % it is not actually possible to let matlab plot only half a circle.
%     % Instead, we double the number of steps on the x-axis and double all the datapoints 
%     % let matlab plot it all...
%     polarsteps = (2*pi)/ (totalConds/2);
%     ypolarplot = mergedmeanAmplByTrial(1:2:totalConds/2, code);          ypolarplot(7:12) = NaN;
%     polarplot(0:polarsteps:2*pi-polarsteps,ypolarplot, '.-k'); hold on
%     
%     ypolarplot = mergedmeanAmplByTrial(2:2:totalConds/2, code);          ypolarplot(7:12) = NaN;
%     polarplot(0:polarsteps:2*pi-polarsteps,ypolarplot, '.-b');
%     title(spikeClusterData.goodCodes(code), 'Color', titleColor(EItype(code))); 
%     
%     %.. and then tell matlab to show us only half of the result
%     thetalim([0 180]);
%     
%     if code == 1
%         thetaticks([0 30 60 90 120 150]);
%         thetaticklabels({'0/180', '30/120', '60/240','90/270', '120/300', '150/330',});
%     else
%         thetaticklabels({});
%     end
% end    
% if saveFigs == true
%     savefig(strcat(savePathGood,  filesep, 'tuningCurve_polarhalf.fig'));
% end
% 
% 
% %%
% figure
% for code = 1: totalCodes
%     subplot(m,m,code, 'align');
%     %     scatter(meanAmplByTrial(1:2:totalConds, clusterTimeSeries.selectedCodesInd(code)), meanAmplByTrial(2:2:totalConds, clusterTimeSeries.selectedCodesInd(code))); hold on
%     scatter(meanAmplByTrial(1:2:totalConds, code), meanAmplByTrial(2:2:totalConds, code)); hold on
% 
% %     fitline = fit(meanAmplByTrial(1:2:totalConds, clusterTimeSeries.selectedCodesInd(code)), meanAmplByTrial(2:2:totalConds, clusterTimeSeries.selectedCodesInd(code)), 'poly1');
%     fitline = fit(meanAmplByTrial(1:2:totalConds, code), meanAmplByTrial(2:2:totalConds, code), 'poly1');
% 
%     plot(fitline);
%     coeffs(code,:) = coeffvalues(fitline);
% %     title(spikeClusterData.uniqueCodes(code,1));
% %     title(clusterTimeSeries.selectedCodes(code), 'Color', titleColor(EItype(clusterTimeSeries.selectedCodesInd(code))));  
%     title(spikeClusterData.goodCodes(code), 'Color', titleColor(EItype(code)));  
%     legend off
%     lim = max(max(meanAmplByTrial));
%     text(lim*0.3, lim*0.95, [num2str(round(coeffs(code,1),2)),'*x + ',num2str(round(coeffs(code,2),2)) ] ,'FontSize',8, 'HorizontalAlignment','center');
%     h1 = line([0 lim],[0 lim]); % diagonal line
%     set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
%     xlabel('');
%     ylabel('');
% end    
% xlabel('FR no photostim. (Hz)');
% ylabel('FR with photostim. (Hz)');
% if saveFigs == true
%     savefig(strcat(savePathGood,  filesep, 'fitTuningCurve_all.fig'));
% end
% %%
% normMeanAmplByTrial = nan(totalConds, totalCodes);
% for code = 1: totalCodes % normalize by the most selective orientation in non-ph conds
% %     normMeanAmplByTrial(:,code) = meanAmplByTrial(:, clusterTimeSeries.selectedCodesInd(code)) / max(meanAmplByTrial(1:2:totalConds, clusterTimeSeries.selectedCodesInd(code)));
%     normMeanAmplByTrial(:,code) = meanAmplByTrial(:, code) / max(meanAmplByTrial(1:2:totalConds, code));
% end  
% 
% figure
% for code = 1: totalCodes
%     subplot(m,m,code, 'align');
%     scatter(normMeanAmplByTrial(1:2:totalConds, code), normMeanAmplByTrial(2:2:totalConds, code)); hold on
%     fitline = fit(normMeanAmplByTrial(1:2:totalConds, code), normMeanAmplByTrial(2:2:totalConds, code), 'poly1');
%     plot(fitline);
%     coeffs(code,:) = coeffvalues(fitline);
% %     title(spikeClusterData.uniqueCodes(code,1));
%     title(spikeClusterData.goodCodes(code), 'Color', titleColor(EItype(code)));  
%     legend off
%     lim = max(normMeanAmplByTrial(:, code));
%     text(lim*0.3, lim*0.95, [num2str(round(coeffs(code,1),2)),'*x + ',num2str(round(coeffs(code,2),2)) ] ,'FontSize',8, 'HorizontalAlignment','center');
%     h1 = line([0 lim],[0 lim]); % diagonal line
%     set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
%     xlabel('');
%     ylabel('');
% end   
% xlabel('Norm. FR no photostim.');
% ylabel('Norm. FR with photostim.');
% 
% if saveFigs == true
%     savefig(strcat(savePathGood,  filesep, 'fitNormTuningCurve_all.fig'));
% end