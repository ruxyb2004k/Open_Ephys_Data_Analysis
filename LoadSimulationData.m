%%% Created by RB on 07.04.2022
%%% Read and analyze the model data from Mohammad

clear all
%close all
saveData = false;
filePath = '/data/oidata/Ruxandra/Simulation Data Analysis/';
exps = {'ActivatingExc', 'ActivatingInh', 'ActivatingBoth'};
keys1 = [0, 10, 20, 30, 40];% 0, 25, 50, 75, 100%
keys2 = {'inh', 'exc'};
event_times = [1000, 2000, 3000, 3500]/1000;
bin = 20;
time_stamps = ((bin:bin:4000)/1000)';
allYLim = [];

data_combined_mean = nan(numel(keys1), numel(keys2), round(4000/bin));

for exp = exps
    exp_type = char(exp);
    
    figure
    title(exp_type)
    i = 1;
    for key1 = keys1
        subplot(1,5,i)
        j = 1;
        for key2 = keys2           
            mat_file = [filePath,'Raw data/', exp_type,  num2str(round(key1/40*100)), char(key2), '.mat'];
            load(mat_file) % dims: sim, no. units, data points
            [sims, no_units, datapoints] = size(data);
            
            % make one dimensions for all units, regardless of their simulation            
            data_all_units = reshape(data, sims*no_units, datapoints);
            data_all_units_binned = reshape(data_all_units(:,1:end-1), sims*no_units, bin, []);% bin over time
            data_all_units_binned = mean(data_all_units_binned, 2);
            data_all_units_binned = squeeze(data_all_units_binned)';
            
            % mean over all units
            data_all_units_binned_mean = mean(data_all_units_binned,2);
            
            plot(time_stamps, data_all_units_binned_mean); hold on
            
            title([num2str(round(key1/40*100)), '%'])
            if i == 1
                xlabel('Time (s)')
                ylabel('Firing rate (Hz)')
            end
            
            data_combined_mean(i,j,:) = data_all_units_binned_mean;
            data_combined_all_units(i,j) = {data_all_units_binned};
            j = j+1;
        end
        
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
    
    if saveData 
        save([exp_type, '_',num2str(bin), '.mat'], 'data_combined_mean')
        save([exp_type, '_',num2str(bin), '_all_units.mat'], 'data_combined_all_units')
    end
end    

%% Load individual unit data and plot traces
clearvars AxesHandle
filePath = '/data/oidata/Ruxandra/Simulation Data Analysis/';
% exps = {'ActivatingExc', 'ActivatingInh', 'ActivatingBoth'};
keys1 = [0, 10, 20, 30, 40];% 0, 25, 50, 75, 100%
% keys2 = {'inh', 'exc'};
unitType = 1; % 1 = inh, 2 = exc
exps = {'ActivatingInh'};
keys2 = {'inh'};
bin = 20;
time_stamps = ((bin:bin:4000)/1000)';
event_times = [1000, 2000, 3000, 3500]/1000;
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

% generate graphs with colors specific for the respective mouse-cell combination
%exps = {'ActivatingExc', 'ActivatingInh', 'ActivatingBoth'};
if strcmp(char(exps), 'ActivatingBoth')
    cCreCellType(1,:) = [0 176 80]/255;% NexCre exc
    cCreCellType(2,:) = [230 153 153]/255;% NexCre inh
elseif sum(classUnitsAll(iUnitsFilt) == 2) && strcmp(expSetFilt(1).animalStrain, 'NexCre')
    cCreCellType = [230 153 153]/255;% NexCre inh
elseif sum(classUnitsAll(iUnitsFilt) == 1) && strcmp(expSetFilt(1).animalStrain, 'PvCre')
    cCreCellType = [153 224 185]/255;% PvCre exc
elseif sum(classUnitsAll(iUnitsFilt) == 2) && strcmp(expSetFilt(1).animalStrain, 'PvCre')
    cCreCellType = [192 0 0]/255;% PvCre inh
end

%% Analysis for Fig. 1 (2x): average of timecourses 

smoothTraceFreqAll = data_all_units_mat;

% Calculate mean of smoothed trace frequency TCs
for unitType = 1:2
    % dims: cond, unit type, data points
    meanTraceFreqAll(:,unitType, :) = squeeze(nanmean(smoothTraceFreqAll(:,classUnitsAll==unitType,:),2));
end
%%
figure
for i = 1:5
    subplot(1,5,i)
%     plot(time_stamps, squeeze(meanTraceFreqAll(i, 1, :)), '-r'); hold on
%     plot(time_stamps, squeeze(meanTraceFreqAll(i, 2, :)), '-b'); hold on
%     plot(time_stamps, squeeze(nanmean(traceFreqAllMinusBase(i, classUnitsAll == 1,:),2)), '-r'); hold on
%     plot(time_stamps, squeeze(nanmean(traceFreqAllMinusBase(i, classUnitsAll == 2,:),2)), '-b'); hold on
%     plot(time_stamps, squeeze(nanmean(normTraceFreqAll(i, classUnitsAll == 1,:),2)), '-r'); hold on
%     plot(time_stamps, squeeze(nanmean(normTraceFreqAll(i, classUnitsAll == 2,:),2)), '-b'); hold on
%     plot(time_stamps, squeeze(meanNormTraceFreqAll(i,1,:)), '-r'); hold on
%     plot(time_stamps, squeeze(meanNormTraceFreqAll(i,2,:)), '-b'); hold on
    plot(time_stamps, squeeze(meanNormTraceFreqAllAdj(i,1,:)), '-r'); hold on
    plot(time_stamps, squeeze(meanNormTraceFreqAllAdj(i,2,:)), '-b'); hold on
end    
%% not needed yet
% subtract Vph - V
% smoothTraceFreqAllSubtr = squeeze((smoothTraceFreqAll(2,:,:)-smoothTraceFreqAll(1,:,:)));
% meanTraceFreqAllSubtr = nanmean(smoothTraceFreqAllSubtr,1);
% 
% % Calculate STEM of frequency TCs over cells
% STEMtraceFreqAll = nan(totalConds, totalDatapoints);
% for cond = 1 : totalConds
%     for datapoint = 1:totalDatapoints
%         STEMtraceFreqAll(cond, datapoint) = nanstd(smoothTraceFreqAll(cond, :, datapoint))/sqrt(sum(~isnan(smoothTraceFreqAll(cond, :, datapoint))));
%     end 
% end
% 
% STEMtraceFreqAllSubtr = nan(1, totalDatapoints);
% for datapoint = 1:totalDatapoints
%     STEMtraceFreqAllSubtr(1, datapoint) = nanstd(smoothTraceFreqAllSubtr(:, datapoint))/sqrt(sum(~isnan(smoothTraceFreqAllSubtr(:, datapoint))));
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
searchMax = [event_times(3)/bin+1: event_times(4)/bin-1];

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
for unitType = 1:2
    % dims: cond, unit type, data points
    meanNormTraceFreqAll(:,unitType, :) = squeeze(nanmean(normTraceFreqAll(:,classUnitsAll==unitType,:),2));
end

% Correction for the peak not being at 1
normTraceFreqAllAdj = normTraceFreqAll; 
meanNormTraceFreqAllAdj = meanNormTraceFreqAll;
%% figure similar to fig 2 - just for testing
figure
for i = 1:5
    subplot(1,5,i)
%     plot(time_stamps, squeeze(nanmean(normTraceFreqAll(i, classUnitsAll == 1,:),2)), '-r'); hold on
%     plot(time_stamps, squeeze(nanmean(normTraceFreqAll(i, classUnitsAll == 2,:),2)), '-b'); hold on
%     plot(time_stamps, squeeze(meanNormTraceFreqAll(i,1,:)), '-r'); hold on
%     plot(time_stamps, squeeze(meanNormTraceFreqAll(i,2,:)), '-b'); hold on
    plot(time_stamps, squeeze(meanNormTraceFreqAllAdj(i,1,:)), '-r'); hold on
    plot(time_stamps, squeeze(meanNormTraceFreqAllAdj(i,2,:)), '-b'); hold on
end    
%% not needed at the moment
%subtract Vph-V and Sph-S
% normTraceFreqAllAdjSubtr = nan(totalConds/2, totalUnits, totalDatapoints);
% for cond =1:2:totalConds
%     normTraceFreqAllAdjSubtr((cond+1)/2,:,:) = squeeze(normTraceFreqAllAdj(cond+1, :, :) - normTraceFreqAllAdj(cond, :, :)); 
% end
% meanNormTraceFreqAllAdjSubtr = squeeze(nanmean(normTraceFreqAllAdjSubtr,2));

% Calculate STEM of TCs over cells
% STEMnormTraceFreqAll = nan(totalConds, totalDatapoints);
% STEMnormTraceFreqAllAdj = nan(totalConds, totalDatapoints);
% for cond = 1:totalConds
%     for datapoint = 1:totalDatapoints
%         STEMnormTraceFreqAll(cond, datapoint) = nanstd(normTraceFreqAll(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAll(cond, :,datapoint))));
%         STEMnormTraceFreqAllAdj(cond, datapoint) = nanstd(normTraceFreqAllAdj(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAllAdj(cond, :,datapoint))));        
%     end    
% end
% 
% STEMnormTraceFreqAllAdjSubtr = nan(1, totalDatapoints);
% for cond =1:totalConds/2
%     for datapoint = 1:totalDatapoints
%         STEMnormTraceFreqAllAdjSubtr(cond, datapoint) = nanstd(normTraceFreqAllAdjSubtr(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAllAdjSubtr(cond,:,datapoint))));
%     end
% end
%% Photostim analysis

photoStim = event_times(2)/bin +1; 
photoStimDuration = (event_times(3)-event_times(2))/bin-1; % additional data points for baseline quantification (1 sec)

allStimPhoto = nan(totalConds, totalUnits);
stim = 1;
for cond = 1:totalConds
    for unit = find(iUnitsFilt)
        allStimPhoto(cond, unit) = nanmean(smoothTraceFreqAll(cond, unit, photoStim(stim):photoStim(stim)+photoStimDuration),3);
    end
end

for unitType = 1:2
    % dims: cond, unit type, data points
    meanAllStimPhoto(:,unitType) = nanmean(allStimPhoto(:,classUnitsAll==unitType),2);
end

%% Analysis Fig. 3 (2x): Baseline quantification

% Calculate mean and STEM of baseline and stat tests

% meanAllStimBase = squeeze(nanmean(allStimBase,2));

for unitType = 1:2
    % dims: cond, unit type, data points
    meanAllStimBase(:,unitType) = nanmean(allStimBase(:,classUnitsAll==unitType),2);
end

% for cond = 1:totalConds
%     for stim = 1:numel(baseStim)
%         STEMallStimBase(cond, stim) = nanstd(allStimBase(cond,:,stim))/sqrt(sum(~isnan(allStimBase(cond, :,stim))));
%     end
% end

% for cond = 1:2:totalConds
%     for stim = 1:numel(baseStim)
%         [hAllStimBase((cond+1)/2,stim,1), pAllStimBase((cond+1)/2,stim,1)] = ttest(squeeze(allStimBase(cond+1,:,1)),squeeze(allStimBase(cond+1,:,stim))); % param: all stims vs first stim in photostim conditions
%         [hAllStimBase((cond+1)/2,stim,2), pAllStimBase((cond+1)/2,stim,2)] = ttest(squeeze(allStimBase(cond,:,stim)),squeeze(allStimBase(cond+1,:,stim))); % param: stim in photostim cond vs stim in non-photostim cond
%         [pAllStimBaseW((cond+1)/2,stim,1), hAllStimBaseW((cond+1)/2,stim,1)] = signrank(squeeze(allStimBase(cond+1,:,1)),squeeze(allStimBase(cond+1,:,stim))); % nonparam: all stims vs first stim in photostim conditions
%         [pAllStimBaseW((cond+1)/2,stim,2), hAllStimBaseW((cond+1)/2,stim,2)] = signrank(squeeze(allStimBase(cond,:,stim)),squeeze(allStimBase(cond+1,:,stim))); % nonparam: stim in photostim cond vs stim in non-photostim cond
%     end    
% end



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
for unitType = 1:2
    % dims: cond, unit type, data points
    meanNormAllStimPhoto(:,unitType) = nanmean(normAllStimPhoto(:,classUnitsAll==unitType),2);
end

% STEMnormAllStimBase = nan(totalConds, numel(baseStim));
% for cond = 1:totalConds
%     for stim = 1:numel(baseStim)
%         STEMnormAllStimBase(cond,stim) = nanstd(normAllStimBase(cond,:,stim))/sqrt(sum(~isnan(normAllStimBase(cond,:,stim))));
%     end
% end

% for cond = 1:2:totalConds
%     for stim = 1:numel(baseStim)
%         [hNormAllStimBase((cond+1)/2,stim,1), pNormAllStimBase((cond+1)/2,stim,1)] = ttest(squeeze(normAllStimBase(cond+1,:,1)),squeeze(normAllStimBase(cond+1,:,stim))); % param: all stims vs first stim in photostim conditions
%         [hNormAllStimBase((cond+1)/2,stim,2), pNormAllStimBase((cond+1)/2,stim,2)] = ttest(squeeze(normAllStimBase(cond,:,stim)),squeeze(normAllStimBase(cond+1,:,stim))); % param: stim in photostim cond vs stim in non-photostim cond
%         [pNormAllStimBaseW((cond+1)/2,stim,1), hNormAllStimBaseW((cond+1)/2,stim,1)] = signrank(squeeze(normAllStimBase(cond+1,:,1)),squeeze(normAllStimBase(cond+1,:,stim))); % nonparam: all stims vs first stim in photostim conditions
%         [pNormAllStimBaseW((cond+1)/2,stim,2), hNormAllStimBaseW((cond+1)/2,stim,2)] = signrank(squeeze(normAllStimBase(cond,:,stim)),squeeze(normAllStimBase(cond+1,:,stim))); % nonparam: stim in photostim cond vs stim in non-photostim cond
%     end    
% end


%% created by RB on 08.04.2022

% Fig. 4bModel (2x) : Average normalized baseline 

% if totalStim == 6
%     titleFig4b = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
%         'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
%     
%     saveFig4b = {'meanNormBaseline100Bar.fig','meanNormBaseline0Bar.fig'};
% elseif totalStim ==1
%     titleFig4b = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
%     'Normalized baseline 50% visual stim. vs 50% visual + photostim. all cells norm', ...
%     'Normalized baseline 25% visual stim. vs 25% visual + photostim. all cells norm', ...
%     'Normalized baseline 12% visual stim. vs 12% visual + photostim. all cells norm', ...
%     'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
% 
%     saveFig4b = {'meanNormBaseline100Bar.fig', 'meanNormBaseline50Bar.fig','meanNormBaseline25Bar.fig','meanNormBaseline12Bar.fig','meanNormBaseline0Bar.fig'};
% end

% stim =4;
fw = 1;
% f = figure('Renderer', 'painters', 'Position', [680 558 360 420]); % left bottom width height
figure
ax = gca;
plot((0:totalConds-1)/(totalConds-1)*100, meanNormAllStimPhoto(:,1), 'o-r','LineWidth',2,...
    'MarkerSize',10,'MarkerEdgeColor','r','MarkerFaceColor',[1,0.7,0.7]);    hold on
plot((0:totalConds-1)/(totalConds-1)*100, meanNormAllStimPhoto(:,2), 'o-b','LineWidth',2,...
    'MarkerSize',10,'MarkerEdgeColor','b','MarkerFaceColor',[0.7,0.7,1]);    hold on
xlabel('% units with activated 5-HT2A ');
ylabel('Firing rate (norm.) ');
set(ax,'YLim',[0 1.5],'FontSize',fs-4);
set(ax,'xtick',(0:totalConds-1)/(totalConds-1)*100) % set major ticks
set(ax, 'TickDir', 'out');
%title(titleFig4b{(cond+1)/2});
background = get(gcf, 'color');
box off
% if cond == 1
%     xticklabels({'V', 'V_p_h'})
% elseif cond == totalConds-1
%     xticklabels({'S', 'S_p_h'})
% end

% if saveFigs == true
%     savefig(strcat(savePath, saveFig4b{(cond+1)/2}));
%     title('');
%     saveas(gcf, strcat(savePath, saveFig4b{(cond+1)/2}(1:end-3), 'png'));
%     saveas(gcf, strcat(savePath, saveFig4b{(cond+1)/2}(1:end-4)), 'epsc');
% end
