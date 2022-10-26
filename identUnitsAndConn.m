%%% created by RB on 31.08.2021
%%% find specific cells with connections and a certain OI effect

% protocol with 6 vis stims - look for inh connection

disp('-----------');
indUnitConn = [];
iUnitsFilt2 = (classUnitsAll == 2)% | strcmp([cellMetricsAll.putativeCellType], 'wide_interneuron')'); % inh units

for unit  = find(iUnitsFilt2) % remove units without inhibitory connections
    if isempty(putativeConnections(unit).inhibitory) 
        iUnitsFilt2(unit) = 0;
    end
end

cond1 = 1; % first unit, 1= ev; 3=spont
stim1 = 4; % first unit
cond2 = 1; % 2nd unit, ev
stim2 = 4; % 2nd unit
for unit  = find(iUnitsFilt2)
    if true %OIndexAllStimBase((cond1+1)/2, unit, stim1) > 0 && pSuaBaseAll((cond1+1)/2, unit, stim1) <= 0.2 % OI pos and stat sign
%     if OIndexAllStimAmpl((cond1+1)/2, unit, stim1) > 0 && pSuaBaseAll((cond1+1)/2, unit, stim1) <= 0.05 % OI pos and stat sign
        disp(expSetFiltSua(unit).experimentName);        
        disp(['Ind1: ', num2str(unit), ', code1: ', num2str(spikeClusterDataAll.goodCodes(unit))]);
        % open the original saved figure
        experimentName = expSetFiltSua(unit).experimentName;
        basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
        basePathMatlabFigsGood = strjoin({basePath, 'matlab analysis', 'figs', 'good'}, filesep);
        filenameFig = fullfile(basePathMatlabFigsGood,['AllCondRasterAndTrace_', num2str(spikeClusterDataAll.goodCodes(unit)),'.fig']); % general info about the session
        uiopen(filenameFig,1)
%         putativeConnections(unit).inhibitory
%         spikeClusterDataAll.goodCodes(putativeConnections(unit).inhibitory)
        for unit2 = putativeConnections(unit).inhibitory
        % open the original saved figure           
            filenameFig = fullfile(basePathMatlabFigsGood,['AllCondRasterAndTrace_', num2str(spikeClusterDataAll.goodCodes(unit2)),'.fig']); % general info about the session
            uiopen(filenameFig,1)
%             if OIndexAllStimBase((cond2+1)/2, unit2, stim2) < 0 && pSuaBaseAll((cond2+1)/2, unit2, stim2) <= 0.2 % OI neg and stat sign
            if true %OIndexAllStimAmpl((cond2+1)/2, unit2, stim2) < 0 && pSuaAll((cond2+1)/2, unit2, stim2) <= 0.2 % OI neg and stat sign
                disp(['Ind2: ', num2str(unit2), ', code2: ', num2str(spikeClusterDataAll.goodCodes(unit2)), ' type: ', num2str(classUnitsAll(unit2))]);
                indUnitConn = [indUnitConn; unit, unit2]; 
            end
        end
        disp('---');
    end
end

%%
% protocol with 6 vis stims - look for exc connection

disp('-----------');
indUnitConn = [];
iUnitsFilt2 = (classUnitsAll == 1 | strcmp([cellMetricsAll.putativeCellType], 'pyramidal')'); % exc units

for unit  = find(iUnitsFilt2) % remove units without excitatory connections
    if isempty(putativeConnections(unit).excitatory) 
        iUnitsFilt2(unit) = 0;
    end
end

cond1 = 3; % first unit, 1= ev; 3=spont
stim1 = 4; % first unit
cond2 = 3; % 2nd unit, ev
stim2 = 4; % 2nd unit
for unit  = find(iUnitsFilt2)
    if true%OIndexAllStimBase((cond1+1)/2, unit, stim1) > 0 && pSuaBaseAll((cond1+1)/2, unit, stim1) <= 0.1 % OI pos and stat sign
%     if OIndexAllStimAmpl((cond1+1)/2, unit, stim1) > 0 && pSuaBaseAll((cond1+1)/2, unit, stim1) <= 0.05 % OI pos and stat sign
        disp(expSetFiltSua(unit).experimentName);        
        disp(['Ind1: ', num2str(unit), ', code1: ', num2str(spikeClusterDataAll.goodCodes(unit))]);
        % open the original saved figure
        experimentName = expSetFiltSua(unit).experimentName;
        basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
        basePathMatlabFigsGood = strjoin({basePath, 'matlab analysis', 'figs', 'good'}, filesep);
        filenameFig = fullfile(basePathMatlabFigsGood,['AllCondRasterAndTrace_', num2str(spikeClusterDataAll.goodCodes(unit)),'.fig']); % general info about the session
        uiopen(filenameFig,1)
%         putativeConnections(unit).excitatory
%         spikeClusterDataAll.goodCodes(putativeConnections(unit).excitatory)
        for unit2 = putativeConnections(unit).excitatory
        % open the original saved figure           
            filenameFig = fullfile(basePathMatlabFigsGood,['AllCondRasterAndTrace_', num2str(spikeClusterDataAll.goodCodes(unit2)),'.fig']); % general info about the session
            uiopen(filenameFig,1)
            if true%classUnitsAll(unit2) == 2 | strcmp(cellMetricsAll.putativeCellType{unit2}, 'wide_interneuron')%&& OIndexAllStimBase((cond2+1)/2, unit2, stim2) > 0 && pSuaBaseAll((cond2+1)/2, unit2, stim2) <= 0.1 % OI neg and stat sign
%             if OIndexAllStimAmpl((cond2+1)/2, unit2, stim2) < 0 && pSuaAll((cond2+1)/2, unit2, stim2) <= 0.2 % OI neg and stat sign
                disp(['Ind2: ', num2str(unit2), ', code2: ', num2str(spikeClusterDataAll.goodCodes(unit2)), ' type: ', num2str(classUnitsAll(unit2))]);               
                indUnitConn = [indUnitConn; unit, unit2]; 
            end
        end
        disp('---');
    end
end

%%
% protocol with one vis stim

disp('-----------');
indUnitConn = [];
iUnitsFilt2 = classUnitsAll == 2; % inh units

for unit  = find(iUnitsFilt2) % remove units without inhibitory connections
    if isempty(putativeConnections(unit).inhibitory) 
        iUnitsFilt2(unit) = 0;
    end
end

cond =2; % photostim
stim = 3;

for unit = find(iUnitsFilt2)
    if OIndexAllStimBaseComb(cond, unit, stim) > 0 && pSuaBaseCombAll(unit, stim) <= 0.05 % OI pos and stat sign
        disp(['Ind1: ', num2str(unit), ', code1: ', num2str(spikeClusterDataAll.goodCodes(unit))]);
        for unit2 = putativeConnections(unit).inhibitory
            if OIndexAllStimBaseComb(cond, unit2, stim) > 0 && pSuaBaseCombAll(unit2, stim) <= 0.05 % OI neg and stat sign
                disp(['Ind2: ', num2str(unit2), ', code2: ', num2str(spikeClusterDataAll.goodCodes(unit2))]);
                indUnitConn = [indUnitConn; unit, unit2]; 
            end
        end
        disp('---');
    end
end
