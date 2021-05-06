%%% created by RB on 25.03.2012
%%% this function takes as input pairs of connections to be removed [Nx2]
%%% and the type ('exc' or 'inh')
%%% the function returns the modifies mono_res and putativeConnections

function [mono_res, putativeConnections] = removeConnections(pairs, type, mono_res, putativeConnections)

if strcmp(type, 'exc')
    [~,index_pairs,index_mono_res] = intersect(pairs,mono_res.sig_con,'rows')
    mono_res.sig_con(index_mono_res,:) = []; 
    mono_res.sig_con_excitatory = mono_res.sig_con;    
    putativeConnections.excitatory = mono_res.sig_con_excitatory;    
elseif strcmp(type, 'inh')
    [~,index_pairs,index_mono_res] = intersect(pairs,mono_res.sig_con_inhibitory,'rows');
    mono_res.sig_con_inhibitory(index_mono_res,:) = [];     
    putativeConnections.inhibitory = mono_res.sig_con_inhibitory;
end    
    
end