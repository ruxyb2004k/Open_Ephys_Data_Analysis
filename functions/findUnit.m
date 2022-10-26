%%% Writen by RB on 06.01.2022
%%% prints info about a specific unit

unitIndex= 382;

exp = expSetFiltSua(unitIndex).experimentName;
unitID = num2str(spikeClusterDataAll.goodCodes(unitIndex));

disp(['Experiment name: ', exp]);
disp([' Unit ID: ' , unitID]);