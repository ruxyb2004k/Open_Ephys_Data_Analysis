%%% Created by RB on 22.04.2021 %%%
% initialized variables based on the sessionInfo structure

basePath = sessionInfo.session.path;
sessionName = sessionInfo.session.name;
experimentName = sessionInfo.session.experimentName;
channelNo = sessionInfo.nChannels;
recordingDepth = sessionInfo.recordingDepth;
conditionNames = sessionInfo.conditionNames;
trialDuration = sessionInfo.trialDuration;
preTrialTime = sessionInfo.preTrialTime;
afterTrialTime = sessionInfo.afterTrialTime; 
visStim = sessionInfo.visStim;
optStimInterval = sessionInfo.optStimInterval;
probe = sessionInfo.probe;
animal = sessionInfo.animal;
recRegion = sessionInfo.recRegion;
chOffset = sessionInfo.chOffset;
samplingRate = sessionInfo.rates.wideband;
% visStimDuration = sessionInfo.visStimDuration;
condData = sessionInfo.condData;