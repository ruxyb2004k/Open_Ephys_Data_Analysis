%%% test the NakaRushton function

% only contrasts > 0%
r = meanAllStimAmplNormTracesBaseSubtr100(1:2:totalConds-2);
fit = fitNakaRushton1(contrasts/100,r);

%% with 0% contrast
r = meanAllStimAmplNormTracesBaseSubtr100(1:2:totalConds);
fit0 = fitNakaRushton1([contrasts/100 0.01],r);

%% with an extra data point 
r = meanAllStimAmplNormTracesBaseSubtr100(1:2:totalConds);
r= [r(1:4); 0.2; r(5)]; 
c=[contrasts(1:4), 6]; 
fit0 = fitNakaRushton1([c/100 0],r);