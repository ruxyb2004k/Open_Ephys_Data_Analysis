%%% Created by RB on 07.04.2022
%%% Run this script after running simulationDataLoadAndSave.m
% Load individual unit data and plot traces

saveFigs = true;
clearvars AxesHandle
filePath = '/data/oidata/Ruxandra/Simulation Data Analysis/mat files/';
% exps = {'ActivatingExc', 'ActivatingInh', 'ActivatingBoth'};
keys1 = [0, 10, 20, 30, 40];% 0, 25, 50, 75, 100%
% keys2 = {'inh', 'exc'};
unitType = 1; % 1 = inh, 2 = exc
exps = {'ActivatingInh100-200'}; %-200
keys2 = {'exc'}; % irrelevant, unitType is relevant
bin = 20;
time_stamps = ((bin:bin:4000)/1000)';
event_times = [1000, 2000, 3000, 3500]/1000; %%%%
allYLim = [];
for exp = exps
    exp_type = char(exp);
    mat_file = [filePath, exp_type, '_',num2str(bin),'_all_units.mat'];
    load(mat_file) % dims: sim, no. units, data points

    figure
    title(exp_type)
    i = 1;
    for key1 = keys1
        subplot(1,5,i)
        j = 1;
        for key2 = keys2    
            plot(time_stamps, data_combined_all_units{i,unitType}(:,1:100)); hold on
            
            title([num2str(round(key1/40*100)), '%'])
            if i == 1
                xlabel('Time (s)')
                ylabel('Firing rate (Hz)')
            end
            
            j = j+1;
        end
        plot(time_stamps, mean(data_combined_all_units{1,unitType},2), 'LineWidth', 3)
        AxesHandle(i) = gca;
        YLim = get(AxesHandle, {'YLim'});
        allYLim = [allYLim, cat(2, YLim{:})];
        for event_time = event_times
            line([event_time event_time],cat(2, YLim{end}))
        end   
        i=i+1;
    end
    
    for i = 1:5 % equalize all y axes
        set(AxesHandle(i), 'YLim', [min(allYLim), max(allYLim)]);

    end    
end    

%% Anaylze data

keys1 = [0, 10, 20, 30, 40];% 0, 25, 50, 75, 100%
keys2 = {'inh', 'exc'};
totalConds = numel(keys1);
[totalDatapoints, num_units_inh] = size(data_combined_all_units{1,1});
[totalDatapoints, num_units_exc] = size(data_combined_all_units{1,2});
totalUnits = num_units_inh + num_units_exc; 
classUnitsAll = [ones(num_units_exc,1); ones(num_units_inh,1)*2];
for i =1 : numel(keys1)  
    % first excitatory, then inhibitory units
    data_all_units_mat(i,:,:) = cat(2,data_combined_all_units{i,2}, data_combined_all_units{i,1})';
end

iUnitsFilt = repelem(true(1), totalUnits); % all units
% iUnitsFilt = iUnitsFilt &  classUnitsAll == 1;
%% Figure params

fs = 24; %font size

path = strsplit(pwd,filesep);
savePath = [strjoin({path{1:end}, 'figs','2022-11',  char(exps)}, filesep), filesep];%,  'NexCre', 'long', 'evoked', 'exc'

% generate graphs with colors specific for the respective mouse-cell combination

%exps = {'ActivatingExc', 'ActivatingInh', 'ActivatingBoth'};
if contains(char(exps), 'ActivatingExc')
    cCreCellType(1,:) = [0 176 80]/255;% NexCre exc
    cCreCellType(2,:) = [230 153 153]/255;% NexCre inh
    marker = 's-';
    lineBaseExc = 1.485; % experimental values
    lineBaseInh = 1.708; % experimental values
    lineMagnExc = 0.0663; % experimental values
    lineMagnInh = 0.0402; % experimental values
elseif contains(char(exps), 'ActivatingInh')
    cCreCellType(1,:) = [153 224 185]/255;% PvCre exc
    cCreCellType(2,:) = [192 0 0]/255;% PvCre inh
    marker = 'o-';
    lineBaseExc = 0.6457; % experimental values
    lineBaseInh = 1.227; % experimental values
    lineMagnExc = -0.2259; % experimental values
    lineMagnInh = -0.1031; % experimental values
elseif contains(char(exps), 'ActivatingBoth')
    cCreCellType(1,:) = [0 255 0]/255;% exc
    cCreCellType(2,:) = [255 0 0]/255;% inh
    lineBase = 1.06; % experimental values
    lineMagn = -0.21; % experimental values
    rangeMagn = [-0.21 -0.6785]; % experimental values
    marker = '*-';
end
% cCreCellType(1,:) = [0 176 80]/255;% NexCre exc
% cCreCellType(2,:) = [192 0 0]/255;% PvCre inh



%% Analysis for Fig. 1 (2x): average of timecourses 

smoothTraceFreqAll = data_all_units_mat;

% Calculate mean of smoothed trace frequency TCs
for unitType = 1:2
    % dims: cond, unit type, data points
    meanTraceFreqAll(:,unitType, :) = squeeze(nanmean(smoothTraceFreqAll(:,classUnitsAll==unitType,:),2));
end
%% Test if the data was processed correctly
% some of the plot commands work only after the next sections 
% figure
% for i = 1:5
%     subplot(1,5,i)
%     plot(time_stamps, squeeze(meanTraceFreqAll(i, 1, :)), '-r'); hold on
%     plot(time_stamps, squeeze(meanTraceFreqAll(i, 2, :)), '-b'); hold on
% %     plot(time_stamps, squeeze(nanmean(traceFreqAllMinusBase(i, classUnitsAll == 1,:),2)), '-r'); hold on
% %     plot(time_stamps, squeeze(nanmean(traceFreqAllMinusBase(i, classUnitsAll == 2,:),2)), '-b'); hold on
% %     plot(time_stamps, squeeze(nanmean(normTraceFreqAll(i, classUnitsAll == 1,:),2)), '-r'); hold on
% %     plot(time_stamps, squeeze(nanmean(normTraceFreqAll(i, classUnitsAll == 2,:),2)), '-b'); hold on
% %     plot(time_stamps, squeeze(meanNormTraceFreqAll(i,1,:)), '-r'); hold on
% %     plot(time_stamps, squeeze(meanNormTraceFreqAll(i,2,:)), '-b'); hold on
% %     plot(time_stamps, squeeze(meanNormTraceFreqAllAdj(i,1,:)), '-r'); hold on
% %     plot(time_stamps, squeeze(meanNormTraceFreqAllAdj(i,2,:)), '-b'); hold on
% end    

%% Analysis for Fig. 2 (2x): average of normalized time courses
% Baseline calculations  % dim: cond, unit, stim 
smooth_method = 'moving';
thresholdFreq = 0.5;
bin = bin /1000;
baseStim = event_times(1)/bin +1; 
baseDuration = (event_times(2)-event_times(1))/bin-1; % additional data points for baseline quantification (1 sec)

% anaylze data as if having a longBase, in order to select for units with baseline above threshold
allStimBase = nan(totalConds, totalUnits);
stim = 1;
for cond = 1:totalConds
    for unit = find(iUnitsFilt)
        allStimBase(cond, unit) = nanmean(smoothTraceFreqAll(cond, unit, baseStim(stim):baseStim(stim)+baseDuration),3);
    end
end
baseSelect = allStimBase(1,:) >= thresholdFreq ; % select units with baseline higher than the selection threshold for 0%;
  
traceFreqAllMinusBase = nan(totalConds, totalUnits, totalDatapoints);
for cond = 1 : totalConds
    for unit = find(iUnitsFilt)
        traceFreqAllMinusBase(cond, unit, :)= smoothTraceFreqAll(cond, unit, :)- allStimBase(cond,unit);
    end
end

% calculare max in each timecourse of each cell, for conds with evoked activity
searchMax = (event_times(3)/bin+1: event_times(4)/bin-1);

smoothMaxTraceFreqAll = nan(totalConds, totalUnits);

for cond = 1: totalConds 
    for unit = find(iUnitsFilt)%find(baseSelect)%
       smoothMaxTraceFreqAll(cond, unit) = mean(traceFreqAllMinusBase(cond, unit, searchMax)); 
    end
end

% amplSelect = smoothMaxTraceFreqAll(1, :) > 0 & smoothMaxTraceFreqAll(1, :) > 0; % select only units with amplitude >0

% normalize >0% vis. stim. to max (without photostim) (or smoothMax) and then smooth
smooth_param = 1; 
normTraceFreqAll = nan(totalConds,totalUnits, totalDatapoints);
for cond = 1:totalConds %%%%
    condNorm = 1; % normalized by the non-photostim condition
    for unit = find(baseSelect)%find(iUnitsFilt)%find(amplSelect)%f
        normTraceFreqAll(cond, unit, :) = smooth(traceFreqAllMinusBase(cond, unit, :)/smoothMaxTraceFreqAll(condNorm, unit),smooth_param, smooth_method);
    end
end

% Calculate mean of smoothed and norm TCs
meanNormTraceFreqAll = nan(totalConds, 2, totalDatapoints);
for unitType = 1:2 % 1 = exc, 2 = inh
    % dims: cond, unit type, data points
    meanNormTraceFreqAll(:,unitType, :) = squeeze(nanmean(normTraceFreqAll(:,classUnitsAll==unitType,:),2));
end

% Correction for the peak not being at 1 - same variable names as in the
% experiment analysis
normTraceFreqAllAdj = normTraceFreqAll; 
meanNormTraceFreqAllAdj = meanNormTraceFreqAll;
%% figure similar to fig 2 - just for testing
% figure
% for i = 1:5
%     subplot(1,5,i)
% %     plot(time_stamps, squeeze(nanmean(normTraceFreqAll(i, classUnitsAll == 1,:),2)), '-r'); hold on
% %     plot(time_stamps, squeeze(nanmean(normTraceFreqAll(i, classUnitsAll == 2,:),2)), '-b'); hold on
% %     plot(time_stamps, squeeze(meanNormTraceFreqAll(i,1,:)), '-r'); hold on
% %     plot(time_stamps, squeeze(meanNormTraceFreqAll(i,2,:)), '-b'); hold on
%     plot(time_stamps, squeeze(meanNormTraceFreqAllAdj(i,1,:)), '-r'); hold on
%     plot(time_stamps, squeeze(meanNormTraceFreqAllAdj(i,2,:)), '-b'); hold on
% end    

%% Photostim interval analysis

photoStim = event_times(2)/bin +1; % + 1; -1
photoStimDuration = (event_times(3)-event_times(2))/bin-1; % additional data points for baseline quantification (1 sec)

allStimPhoto = nan(totalConds, totalUnits);
stim = 1;
for cond = 1:totalConds
    for unit = find(iUnitsFilt)
        allStimPhoto(cond, unit) = nanmean(smoothTraceFreqAll(cond, unit, photoStim(stim):photoStim(stim)+photoStimDuration),3);
    end
end

for unitType = 1:2% 1 = exc, 2 = inh
    % dims: cond, unit type, data points
    meanAllStimPhoto(:,unitType) = nanmean(allStimPhoto(:,classUnitsAll==unitType),2);
end

%% Analysis Fig. 3 (2x): Baseline quantification

% Calculate mean and STEM of baseline and stat tests

% meanAllStimBase = squeeze(nanmean(allStimBase,2));

for unitType = 1:2% 1 = exc, 2 = inh
    % dims: cond, unit type, data points
    meanAllStimBase(:,unitType) = nanmean(allStimBase(:,classUnitsAll==unitType),2);
end

%% Analysis Fig. 4 (2x) - Normalized baseline to the first stim value

% normalize baseline to first stim (before photostim) in each condition 
normAllStimPhoto = nan(totalConds, totalUnits);
allStimPhotoNormTrace = nan(totalConds, totalUnits);

% thresholdFreq = 0.5 % selection threshold in Hz
% baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; % select units with baseline higher than the selection threshold for 0%;
totalBaseSelectUnits = numel(find(baseSelect));
for cond = 1:totalConds
    for unit = find(baseSelect)
        for stim = 1:numel(photoStim)            
            if allStimBase(cond, unit) ~=0
                normAllStimPhoto(cond, unit) = allStimPhoto(cond, unit)/allStimBase(1, unit);  
            else     
                normAllStimPhoto(cond, unit) = NaN;
            end
        end
    end
end

% Calculate mean and STEM of normalized baseline
for unitType = 1:2% 1 = exc, 2 = inh
    % dims: cond, unit type
    meanNormAllStimPhoto(:,unitType) = nanmean(normAllStimPhoto(:,classUnitsAll==unitType),2);
end

% pause(1)
figure4bModx
%% try normalized average instead of average of normalized values - quite similar to the other option
% 
% meanAllStimPhoto(:,1) =  mean(allStimPhoto(:, classUnitsAll==1),2);
% meanAllStimPhoto(:,2) =  mean(allStimPhoto(:, classUnitsAll==2),2);
% normMeanAllStimPhoto = meanAllStimPhoto ./ meanAllStimPhoto(1,:);
% meanNormAllStimPhoto = normMeanAllStimPhoto;

%% selection of positive or negative effects

OIposUnits = false(totalConds, totalUnits);
OInegUnits = false(totalConds, totalUnits);
normAllStimPhotoOIpos = nan(totalConds, totalUnits);
normAllStimPhotoOIneg = nan(totalConds, totalUnits);

for cond = 1:totalConds
    OIposUnits(cond,:) = baseSelect & (normAllStimPhoto(cond,:) > 1); % run the next section before uncommenting this line
    OInegUnits(cond,:) = baseSelect & (normAllStimPhoto(cond,:) < 1); % run the next section before uncommenting this line
%     OIposUnits(cond,:) = baseSelect & (normAllStimPhoto(cond,:) > normAllStimPhoto(1,:)); % run the next section before uncommenting this line
%     OInegUnits(cond,:) = baseSelect & (normAllStimPhoto(cond,:) < normAllStimPhoto(1,:)); % run the next section before uncommenting this line

    for unit = find(OIposUnits(cond,:))
        normAllStimPhotoOIpos(cond,unit) = normAllStimPhoto(cond, unit);
    end
    for unit = find(OInegUnits(cond,:))
        normAllStimPhotoOIneg(cond, unit) = normAllStimPhoto(cond,unit);
    end
end

for unitType = 1:2 % 1 = exc, 2 = inh
    % dims: cond, unit type
    meanNormAllStimPhotoOIpos(:,unitType) = nanmean(normAllStimPhotoOIpos(:,classUnitsAll==unitType),2);
    meanNormAllStimPhotoOIneg(:,unitType) = nanmean(normAllStimPhotoOIneg(:,classUnitsAll==unitType),2);
   
end

%% test figure - histogram: efect of photo stim interval 
% for cond = 1:5
%     figure
%     histogram(normAllStimPhoto(cond, classUnitsAll==1), 'FaceAlpha', 0.5,'Normalization','pdf'); hold on
%     histogram(normAllStimPhoto(cond, classUnitsAll==2), 'FaceAlpha', 0.5,'Normalization','pdf')
% end

%% Analysis for Fig 25b - reproduction of fig 5bi from eLife 2020 (average amplitude of normalized and baseline subtr traces)
% analysis for Fig 26c - reproduction of fig 8di(1) from eLife 2020 (average amplitude of normalized and baseline subtr traces)
% analysis for Fig 26d - reproduction of fig 8di(2) from eLife 2020 (average amplitude of normalized and baseline subtr traces)

% use same variable name as in experimental analysis scripts
normTracesBaseSubtr100 = normTraceFreqAll; %  = normTraceFreqAllAdj
meanNormTracesBaseSubtr100 = meanNormTraceFreqAll; %  = meanNormTraceFreqAllAdj

% calculare ampl in each timecourse of each cell, for conds with evoked activity
searchMax = (event_times(3)/bin+1: event_times(4)/bin-1); % +1; -1
amplInt = searchMax;

allStimAmplNormTracesBaseSubtr100 = nan(totalConds, totalUnits);
for cond = 1:totalConds
    for unit = find(iUnitsFilt) % & baseSelect      
        allStimAmplNormTracesBaseSubtr100(cond, unit) = nanmean(normTracesBaseSubtr100(cond, unit, amplInt),3);
    end
end

% Calculate mean of amplitudes
meanAllStimAmplNormTracesBaseSubtr100 = nan(totalConds, 2);
for unitType = 1:2
    % dims: cond, unit type, data points
    meanAllStimAmplNormTracesBaseSubtr100(:,unitType) = nanmean(allStimAmplNormTracesBaseSubtr100(:,classUnitsAll==unitType),2);
end


%% Analysis for Fig 25c - reproduction of fig 5bii from eLife 2020 ( average baseline of normalized and baseline subtr traces)

% photoStim = event_times(2)/bin +1; 
% photoStimDuration = (event_times(3)-event_times(2))/bin-1; % additional data points for baseline quantification (1 sec)

allStimPhotoNormTracesBaseSubtr100 = nan(totalConds, totalUnits);
stim = 1;
for cond = 1:totalConds
    for unit = find(iUnitsFilt)% & baseSelect)  
        allStimPhotoNormTracesBaseSubtr100(cond, unit) = nanmean(normTracesBaseSubtr100(cond, unit, photoStim(stim):photoStim(stim)+photoStimDuration),3);
    end
end

% Calculate mean 
for unitType = 1:2
    meanAllStimBaseNormTracesBaseSubtr100(:,unitType) = nanmean(allStimPhotoNormTracesBaseSubtr100(:,classUnitsAll==unitType),2);
end

%% Anaylsis for Fig. 25d - reproduction of fig 5biii from eLife 2020 (average magnitude of normalized and baseline subtr traces)
% Analysis for Fig. 26e (1x) : reproduction of fig 8bi from eLife 2020 (average magnitude of normalized and baseline subtr traces)

allStimMagnNormTracesBaseSubtr100 = allStimAmplNormTracesBaseSubtr100 - allStimPhotoNormTracesBaseSubtr100;% 2*totalConds-2, totalUnits, numel(baseStim)
    
% Calculate mean a
for unitType = 1:2
    meanAllStimMagnNormTracesBaseSubtr100(:,unitType) = nanmean(allStimMagnNormTracesBaseSubtr100(:,classUnitsAll==unitType),2);
end
%% Fig. 30bx -  compare difference of magnitude in the non-adj norm traces to 0 (magn of 1st stim = 1 and not peak =1)

% calculate the difference in magnitudes in Vph vs V 
normTraceFreqAllAdjSubtr = nan(totalConds, totalUnits, totalDatapoints);
for cond =2:totalConds
    allStimMagnNormTracesBaseSubtr100Subtr(cond,:) = squeeze(allStimMagnNormTracesBaseSubtr100(cond, :) - allStimMagnNormTracesBaseSubtr100(1, :)); 
end

for unitType = 1:2
    meanAllStimMagnNormTracesBaseSubtr100Subtr(:,unitType) = nanmean(allStimMagnNormTracesBaseSubtr100Subtr(:,classUnitsAll==unitType),2);
end

% pause(1)
figure30bxxxModx
%% amplitude quantification

allStimAmpl = nan(totalConds, totalUnits);

for cond = 1:totalConds
    for unit = find(iUnitsFilt)
        allStimAmpl(cond, unit) = nanmean(smoothTraceFreqAll(cond, unit,amplInt),3);
    end
end


%% photo stim interval quantification


cond = 5;
norm = 1;
unitType = 1;
unitsLR = classUnitsAll==unitType;%find(baseSelect);%find(OInegUnits);%
x1 = allStimPhoto(1, unitsLR)'; % no photostim cond, pre photostim
x2 = allStimPhoto(1, unitsLR)'; % photostim cond, pre photostim
y1 = allStimPhoto(1, unitsLR)'; % no photostim cond, post photostim
y2 = allStimPhoto(cond, unitsLR)'; % photostim cond, post photostim

%% magnitude quantification

allStimMagn = allStimAmpl-allStimPhoto;

cond = 4;
norm = 1;
unitType = 2;
unitsLR = classUnitsAll==unitType;%find(baseSelect);%find(OInegUnits);%
x1 = allStimMagn(1, unitsLR)'; % no photostim cond, pre photostim
x2 = allStimMagn(1, unitsLR)'; % photostim cond, pre photostim
y1 = allStimMagn(1, unitsLR)'; % no photostim cond, post photostim
y2 = allStimMagn(cond, unitsLR)'; % photostim cond, post photostim

%%
% for cond = 1:5
%     figure
%     histogram(allStimMagn(cond, classUnitsAll==1), 'FaceAlpha', 0.5,'Normalization','pdf'); hold on
%     histogram(allStimMagn(cond, classUnitsAll==2), 'FaceAlpha', 0.5,'Normalization','pdf')
% end
%% Test the magnitude as an normalized average, and not average of the normalized traces

meanAllStimMagn(:,1) =  mean(allStimMagn(:, classUnitsAll==1),2);
meanAllStimMagn(:,2) =  mean(allStimMagn(:, classUnitsAll==2),2);
normMeanAllStimMagn = meanAllStimMagn ./ meanAllStimMagn(1,:);
meanAllStimMagnNormTracesBaseSubtr100Subtr = normMeanAllStimMagn - 1;

%% OR magnitude as average of normalized magnitudes - noisier responses and non-liniarities
% for unit = 1:totalUnits
%     if allStimMagn(1,unit)
%         normAllStimMagn(:, unit) = allStimMagn(:, unit) ./ allStimMagn(1,unit);
%     else   
%         normAllStimMagn(:, unit) = NaN;
%     end
% end    
% meanNormAllStimMagn(:,1) =  nanmean(normAllStimMagn(:, classUnitsAll==1),2);
% meanNormAllStimMagn(:,2) =  nanmean(normAllStimMagn(:, classUnitsAll==2),2);
% meanAllStimMagnNormTracesBaseSubtr100Subtr = meanNormAllStimMagn - 1;

%%  OR calculate the mean magnitude from the avg of all traces - exactly the same as the first option above

% ampl = nanmean(meanTraceFreqAll(:,:,amplInt),3);
% photo = nanmean(meanTraceFreqAll(:, :, photoStim(stim):photoStim(stim)+photoStimDuration),3);
% magn = ampl - photo;
% meanAllStimMagnNormTracesBaseSubtr100Subtr = magn ./ magn(1,:) -1;
% a = meanAllStimMagnNormTracesBaseSubtr100Subtr;
%% linear model with 4 parameters - all units
norm = 1;
exclude0 = 1;
excludeOutliers = 0;
thOut = 0.23;
totalCoeffs = 4;
dataLM = 'magn';% 'base', 'ampl', 'magn' 

if exclude0  % exclude trials with 0 in pre or post stim
    warning('exclude0 activated')
    % Method 1
%     ind1 = (x1~= 0 & y1 ~= 0);
%     ind2 = (x2~= 0 & y2 ~= 0);
%     x1 = x1(ind1);
%     y1 = y1(ind1);
%     x2 = x2(ind2);
%     y2 = y2(ind2);
    % Method 2
    ind12 = (x1~= 0 & y1 ~= 0 & x2~= 0 & y2 ~= 0);
    x1 = x1(ind12);
    y1 = y1(ind12);
    x2 = x2(ind12);
    y2 = y2(ind12);    
end
if norm % normalize data to the max value in the data set
    maxData = max([x1;x2]) 
    x1 = x1/maxData; 
    y1 = y1/maxData;
    x2 = x2/maxData;
    y2 = y2/maxData;
end

if excludeOutliers  % exclude trials with 0 in pre or post stim
    warning('excludeOutliers activated')
    ind1Out = (x1<= thOut);
    ind2Out = (x2<= thOut);
    x1 = x1(ind1Out);
    y1 = y1(ind1Out);
    x2 = x2(ind2Out);
    y2 = y2(ind2Out);
    if norm % normalize data to the max value in the data set
        maxData = max([x1;x2])
        x1 = x1/maxData;
        y1 = y1/maxData;
        x2 = x2/maxData;
        y2 = y2/maxData;
    end
end


x_all = [x1;x2];
y_all = [y1;y2];

% size (X) = [2*numUnits 4]
% Columns: 1st: 1; 2nd: 0 for no ph stim, 1 for ph stim conds (s); 3rd: x_all (rpre);
% 4th: 0 for the non stim cond, x2 for the ph stim cond (rpre*s)
ph = [zeros(size(x1)); ones(size(x2))];
X = [x_all, ph, x_all.*ph]; 
mdl = fitlm(X,y_all) % returns parameters and p-values
% also useful: regress function from matlab
coeffsLM = table2array(mdl.Coefficients); % 4 params, 4 properties of coeffs
coeffsLM1 = [coeffsLM(2,1), coeffsLM(1,1)]; % coefficients for x1,y1
coeffsLM2 = [coeffsLM(2,1)+coeffsLM(4,1), coeffsLM(1,1)+coeffsLM(3,1)]; % coefficients for x2,y2

% figure16fMod
% figure16fxMod
