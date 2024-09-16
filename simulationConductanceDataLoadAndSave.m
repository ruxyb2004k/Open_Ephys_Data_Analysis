%%% Created by RB on 21.06.2022
%%% Run this script after running read_pickle_conductance.py
%%% Read and analyze the conductance data from Mohammad's model

clear all
%close all
saveData = false;
filePath = '/data/oidata/Ruxandra/Simulation Data Analysis/conductance 1/';
exps = {'sim_res_Be1.00_Bi-3.00'};
keys1 = [0, 10, 20, 30, 40];% 0, 25, 50, 75, 100%
keys2 = (0:19);
% keys3 = {'inh', 'exc'};
% keys4 = {'g_in', 'g_ex'};

event_times = [1000, 2000, 3000, 3500]/1000;
bin = 20;

no_units = 200;
time_dp = 4000;
time_stamps = ((bin:bin:4000)/1000)';
allYLim = [];

ex_units = (1:160);
in_units = (161:200);

for exp = exps
    exp_type = char(exp);
    
    figure
    title(exp_type)

    i = 1;
    for key1 = keys1   
        data_combined_all_units(i,1).g_ex = [];
        data_combined_all_units(i,2).g_ex = [];
        data_combined_all_units(i,1).g_in = [];
        data_combined_all_units(i,2).g_in = [];
        subplot(1,5,i)
        j = 1;
        for key2 = keys2           
            mat_file = [filePath, exp_type, '-pct-', num2str(round(key1/40*100)), '-sim-', num2str(key2), '.mat'];
            load(mat_file) % dims: sim, no. units, data points
             
            data_exp.g_ex = reshape(data.g_ex, no_units, time_dp-1)'; % 200 recorded units, 3999 time dp
            data_exp.g_in = reshape(data.g_in, no_units, time_dp-1)'; % 200 recorded units, 3999 time dp
            data_exp.senders = reshape(data.senders, no_units, time_dp-1)'; % 200 recorded units, 3999 time dp
            data_exp.times = reshape(data.times, no_units, time_dp-1)'; % 200 recorded units, 3999 time dp
            
            data_exp.g_ex = [zeros(1,no_units); data_exp.g_ex]; % add one more row
            data_exp.g_in = [zeros(1,no_units); data_exp.g_in]; % add one more row
            data_exp.senders = [(1:no_units); data_exp.senders]; % add one more row
            data_exp.times = [zeros(1,no_units); data_exp.times]; % add one more row         
            
            data_exp_binned.g_ex = reshape(data_exp.g_ex, bin, time_dp/bin, []); 
            data_exp_binned.g_in = reshape(data_exp.g_in, bin, time_dp/bin, []);
            data_exp_binned.senders = reshape(data_exp.senders, bin, time_dp/bin, []);
            data_exp_binned.times = reshape(data_exp.times, bin, time_dp/bin, []);
            
            data_exp_binned.g_ex = squeeze(mean(data_exp_binned.g_ex,1));% dims: time, no_units
            data_exp_binned.g_in = squeeze(mean(data_exp_binned.g_in,1));% dims: time, no_units
            data_exp_binned.senders = squeeze(mean(data_exp_binned.senders,1));% dims: time, no_units
            data_exp_binned.times = squeeze(mean(data_exp_binned.times,1));% dims: time, no_units
    
            data_exp_binned_all_units.g_ex = mean(data_exp_binned.g_ex,2);% dims: time,
            data_exp_binned_all_units.g_in = mean(data_exp_binned.g_in,2);% dims: time,
%             data_exp_binned_all_units.senders = mean(data_exp_binned.senders,2);% dims: time, 
%             data_exp_binned_all_units.times = mean(data_exp_binned.times,2);% dims: time, 

%             data_exp_binned_all_units_ex.g_ex = mean(data_exp_binned.g_ex(:,ex_units),2);% dims: time,
%             data_exp_binned_all_units_ex.g_in = mean(data_exp_binned.g_in(:,ex_units),2);% dims: time,
            
%             data_exp_binned_all_units_in.g_ex = mean(data_exp_binned.g_ex(:,in_units),2);% dims: time,
%             data_exp_binned_all_units_in.g_in = mean(data_exp_binned.g_in(:,in_units),2);% dims: time,
                 
            plot(time_stamps, data_exp_binned_all_units.g_ex, 'r'); hold on
            plot(time_stamps, data_exp_binned_all_units.g_in, 'b'); hold on
            
%             plot(time_stamps, data_exp_binned_all_units_ex.g_ex, 'b'); hold on
%             plot(time_stamps, data_exp_binned_all_units_ex.g_in, 'k'); hold on
            
%             plot(time_stamps, data_exp_binned_all_units_in.g_ex, 'r'); hold on
%             plot(time_stamps, data_exp_binned_all_units_in.g_in, 'm'); hold on
            
%             plot(time_stamps, data_exp_binned.g_ex, 'b'); hold on
%             plot(time_stamps, data_exp_binned.g_in, 'r'); hold on
             
            title([num2str(round(key1/40*100)), '%'])
            
%             disp(['ex:', num2str(sum(mean(data_exp_binned.g_ex,1) > 30))])
%             disp(['in:', num2str(sum(mean(data_exp_binned.g_in,1) > 30))])
            
            if i == 1
                xlabel('Time (s)')
                ylabel('Conductance (nS)')
            end
            
            data_combined_all_units(i,1).g_ex = [data_combined_all_units(i,1).g_ex, data_exp_binned.g_ex(:,in_units)]; % exc conductance in inh units
            data_combined_all_units(i,2).g_ex = [data_combined_all_units(i,2).g_ex, data_exp_binned.g_ex(:,ex_units)]; % exc conductance in exc units
            data_combined_all_units(i,1).g_in = [data_combined_all_units(i,1).g_in, data_exp_binned.g_in(:,in_units)]; % inh conductance in inh units
            data_combined_all_units(i,2).g_in = [data_combined_all_units(i,2).g_in, data_exp_binned.g_in(:,ex_units)]; % inh conductance in exc units
            
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
        save([exp_type, '_',num2str(bin), '_all_units.mat'], 'data_combined_all_units')
    end
end    
%%
totalConds = numel(keys1);
for cond= 1:totalConds
    for unitType =1:2
        meanConductance(cond, unitType).g_ex = nanmean(data_combined_all_units(cond, unitType).g_ex,2);
        meanConductance(cond, unitType).g_in = nanmean(data_combined_all_units(cond, unitType).g_in,2);
    end
end    

%%
exps = 'ActivatingBoth';
path = strsplit(pwd,filesep);
savePath = [strjoin({path{1:end}, 'figs','2023-06',  char(exps)}, filesep), filesep];%,  'NexCre', 'long', 'evoked', 'exc'

event_times = [1000, 2000, 3000, 3500]/1000; %%%%
saveFigs = false;
fs = 24;
%% created by RB on 24.06.2022

% Fig. Modelxx (2x) : Average normalized baseline 

titleFig70Mod = {'Conductance'};
    
saveFig70Mod = {'meanConductance.fig'};

axesType = 1;% 1 = normal, 2 = L-type (short axes)

figure;
title(exp_type)
i = 1;
condsPlot = [1,3];
for cond = condsPlot %(1:totalConds)
    subplot(1,numel(condsPlot), i)
    ax = gca;
    for unitType =1%:2 % 1 is ex, 2 is in
        plot(time_stamps, meanConductance(cond, unitType).g_in, 'r', 'LineWidth',5); hold on
        plot(time_stamps, meanConductance(cond, unitType).g_ex, 'g', 'LineWidth',5); hold on
    end
    xlim([1,4])
    if cond == 1
        xlabel('Time (s)')
        ylabel('Conductance (nS)')       
        if axesType == 2
            plot([1.5; 1.5], [50; 100], '-k',  [1.5; 2.5], [50; 50], '-k', 'LineWidth', 2)
            text(1, 90, '50 nS', 'HorizontalAlignment','right', 'FontSize', fs, 'Rotation', 90)
            text(2,40, '1 s', 'HorizontalAlignment','center', 'FontSize', fs)   
        end
    end
    ylim([-10 130]);
    yl = ylim;
    title([num2str(round(keys1(cond)/40*100)), '%'])
   
    set(ax,'FontSize',fs)
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

val1 = data_combined_all_units(1, 1).g_ex(50:200,:)';
val2 = data_combined_all_units(1, 1).g_in(50:200,:)';
val3 = data_combined_all_units(3, 1).g_ex(50:200,:)';
val4 = data_combined_all_units(3, 1).g_in(50:200,:)';

table_data1 = array2table(val1);
table_data2 = array2table(val2);
table_data3 = array2table(val3);
table_data4 = array2table(val4);

allVars1 = 1:width(table_data1);
newNames1 =  string(0:0.02:3);

table_data1 = renamevars(table_data1, allVars1, newNames1); % exc 0%
table_data2 = renamevars(table_data2, allVars1, newNames1); % inh 0%
table_data3 = renamevars(table_data3, allVars1, newNames1); % exc 50%
table_data4 = renamevars(table_data4, allVars1, newNames1); % inh 50%

if saveFigs == true
    savefig(strcat(savePath, saveFig70Mod{1}));
    saveas(gcf, strcat(savePath, saveFig70Mod{1}(1:end-3), 'png'));
    saveas(gcf, strcat(savePath, saveFig70Mod{1}(1:end-4)), 'epsc');
    writetable(table_data1, strcat(savePath, saveFig70Mod{1}(1:end-3), 'xlsx'),'Sheet',1)
    writetable(table_data2, strcat(savePath, saveFig70Mod{1}(1:end-3), 'xlsx'),'Sheet',2)
    writetable(table_data3, strcat(savePath, saveFig70Mod{1}(1:end-3), 'xlsx'),'Sheet',3)
    writetable(table_data4, strcat(savePath, saveFig70Mod{1}(1:end-3), 'xlsx'),'Sheet',4)
end

%% E/I conductance
for unitType = 1:2% 1 is ex, 2 is in
    figure 
    for cond = 1:totalConds
        e_i = smooth(meanConductance(cond, unitType).g_ex./meanConductance(cond, unitType).g_in, 'moving',9);
        subplot(1,5,cond)
        plot(time_stamps, e_i, 'k', 'LineWidth',3); hold on
        ylim([0.2, 1.6])
    end
end   

%% E/I conductance relative change during vis stim, normalized to the previous 1 s

for unitType = 1:2% 1 is ex, 2 is in
    figure 
    for cond = 1:totalConds
        e_norm = meanConductance(cond, unitType).g_ex / mean(meanConductance(cond, unitType).g_ex(event_times(2)*1000/bin+3:event_times(3)*1000/bin-3));
        i_norm = meanConductance(cond, unitType).g_in / mean(meanConductance(cond, unitType).g_in(event_times(2)*1000/bin+3:event_times(3)*1000/bin-3));

        e_i = smooth(e_norm./i_norm, 'moving',9);
        
        subplot(1,5,cond)
        plot(time_stamps, e_norm, 'g', 'LineWidth',3); hold on
        plot(time_stamps, i_norm, 'r', 'LineWidth',3); hold on
        plot(time_stamps, e_i, 'k', 'LineWidth',3); hold on
        ylim([0.2, 1.6])
    end
end   

%% E/I conductance abs change during vis stim, normalized to the previous 1 s
% a bit stranger graph

for unitType = 1:2% 1 is ex, 2 is in
    figure 
    for cond = 1:totalConds
        e_norm = meanConductance(cond, unitType).g_ex - mean(meanConductance(cond, unitType).g_ex(event_times(2)*1000/bin+3:event_times(3)*1000/bin-3));
        i_norm = meanConductance(cond, unitType).g_in - mean(meanConductance(cond, unitType).g_in(event_times(2)*1000/bin+3:event_times(3)*1000/bin-3));

        e_i = smooth(e_norm./i_norm, 'moving',9);
        
        subplot(1,5,cond)
        plot(time_stamps, e_norm, 'g', 'LineWidth',3); hold on
        plot(time_stamps, i_norm, 'r', 'LineWidth',3); hold on
        plot(time_stamps, e_i, 'k', 'LineWidth',3); hold on
        ylim([-6, 6])
    end
end   

%% .   E/I conductance abs change during vis stim, normalized to the previous 1 s
% calculations
for cond = 1:totalConds
    for unitType = 1:2
        for time = (2:3)
            ge(cond, unitType, time-1) = mean(meanConductance(cond, unitType).g_ex(event_times(time)*1000/bin+3:event_times(time+1)*1000/bin-3));
            gi(cond, unitType, time-1) = mean(meanConductance(cond, unitType).g_in(event_times(time)*1000/bin+3:event_times(time+1)*1000/bin-3));
            
        end
        ge_diff(cond, unitType) = ge(cond, unitType, 2) - ge(cond, unitType, 1);
        gi_diff(cond, unitType) = gi(cond, unitType, 2) - gi(cond, unitType, 1);
    end
end

% figure
for unitType = 1:2 % 1 is ex, 2 is in
    figure 
    scatter(1:totalConds, ge_diff(:, unitType), 'g', 'LineWidth',3); hold on
    scatter(1:totalConds, gi_diff(:, unitType), 'r', 'LineWidth',3); hold on
    scatter(1:totalConds, ge_diff(:, unitType)./gi_diff(:, unitType), 'k', 'LineWidth',3); hold on
    title(['unit type: ', num2str(unitType)])   
%     ylim([-6, 6])

end   
     
%% 09.03.2023
% data_combined_all_units dim: (pct act neurons, cell type ) . g type (time points, cell no)
% data_combined_all_units(i,1).g_ex = [data_combined_all_units(i,1).g_ex, data_exp_binned.g_ex(:,in_units)]; % exc conductance in inh units
% data_combined_all_units(i,2).g_ex = [data_combined_all_units(i,2).g_ex, data_exp_binned.g_ex(:,ex_units)]; % exc conductance in exc units
% data_combined_all_units(i,1).g_in = [data_combined_all_units(i,1).g_in, data_exp_binned.g_in(:,in_units)]; % inh conductance in inh units
% data_combined_all_units(i,2).g_in = [data_combined_all_units(i,2).g_in, data_exp_binned.g_in(:,ex_units)]; % inh conductance in exc units

%event_times 
flag = 0; %normalization by n-1
for cond = 1:totalConds
    for unitType = 1:2% 1 is ex, 2 is in
        for time = 1:numel(event_times)-1
            std_data_combined_all_units(cond, unitType).g_ex(time,:) = nanstd(data_combined_all_units(cond, unitType).g_ex(event_times(time)*1000/bin+3:event_times(time+1)*1000/bin-3,:),flag,1);
            std_data_combined_all_units(cond, unitType).g_in(time,:) = nanstd(data_combined_all_units(cond, unitType).g_in(event_times(time)*1000/bin+3:event_times(time+1)*1000/bin-3,:),flag,1);
        end
    end
end

for cond = 1:totalConds
    for unitType = 1:2% 1 is ex, 2 is in
        mean_std_data_combined_all_units(cond, unitType).g_ex = nanmean(std_data_combined_all_units(cond, unitType).g_ex,2);
        mean_std_data_combined_all_units(cond, unitType).g_in = nanmean(std_data_combined_all_units(cond, unitType).g_in,2);        
    end
end

% incremental increase for conductance STD depending on the % of activated neurons
unitType_char = {'excitatory units', 'inhibitory units'};
xdata = (0:totalConds-1)/(totalConds-1)*100;


figure
for unitType = 1:2% 1 is ex, 2 is in
    subplot(2,1,unitType)
    ax = gca;
    for cond = 1:totalConds
        scatter(xdata(cond), [mean_std_data_combined_all_units(cond, unitType).g_ex(2)], 100, '.g'); hold on, 
        scatter(xdata(cond), [mean_std_data_combined_all_units(cond, unitType).g_in(2)], 100, '.r')
    end    
    set(ax,'XLim', [-5 100],'FontSize',fs-10);
    set(ax,'xtick',(0:totalConds-1)/(totalConds-1)*100) % set major ticks
    
    title(unitType_char(unitType))
end
xlabel('% units with activated 5-HT_2_A ');
ylabel('STD during photostim');
