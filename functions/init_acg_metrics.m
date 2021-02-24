%%%%%%%%% Code created by RB on 08.01.2021 %%%

fields = {'acg_wide', 'acg_narrow', 'thetaModulationIndex', 'burstIndex_Royer2012', 'burstIndex_Doublets',...
    'acg_tau_decay', 'acg_tau_rise', 'acg_c', 'acg_d', 'acg_asymptote', 'acg_refrac', 'acg_tau_burst', 'acg_h', 'acg_fit_rsquare'};
        

for fieldInd = 1:numel(fields)
    field = char(fields(fieldInd));    
    acg_metrics.(field) = [];
end    

putativeCellType = cell(0,1);

mono_res = struct();

putativeConnections.excitatory = [];
putativeConnections.inhibitory = [];