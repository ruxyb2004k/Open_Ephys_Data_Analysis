%%% Created by RB on 07.04.2022
%%% Read and analyze the model data from Mohammad
%%% Run this script after running read_pickle.py
%%% Then run simulationDataAnalysis.m

clear all
%close all
saveData = true;
filePath = '/data/oidata/Ruxandra/Simulation Data Analysis/Raw data 5/';
% exps = {'ActivatingExc25-200', 'ActivatingInh100-200'};%, 'ActivatingBoth-50'};
exps = {'ActivatingInh100Exc50'};%, 'ActivatingBoth-50'};
keys1 = [0, 10, 20, 30, 40];% 0, 25, 50, 75, 100%
keys2 = {'inh', 'exc'};
event_times = [1000, 2000, 3000, 3500]/1000;
bin = 20;
time_stamps = ((bin:bin:4000)/1000)';
allYLim = [];

data_combined_mean = nan(numel(keys1), numel(keys2), round(4000/bin));

% for each exp, it reads numel(keys1)*numel(keys2) .mat files, in this case 10
% and it saves another two .mat files: 
% exp_type, '_',num2str(bin), '.mat' - contains the mean
% exp_type, '_',num2str(bin), '_all_units.mat' - contains data from each unit
for exp = exps
    exp_type = char(exp);
    
    figure
    title(exp_type)
    i = 1;
    for key1 = keys1 % conditions (perturbation strengths)
        subplot(1,5,i)
        j = 1;
        for key2 = keys2           
            mat_file = [filePath, exp_type, '-', num2str(round(key1/40*100)), char(key2), '.mat'];
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
