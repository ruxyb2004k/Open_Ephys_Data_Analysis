clc
clear
close all

%%
load data_1

fltrFreq = 300;

fltrFreqInt = [1 300];

samplingRate = 20000;

tic
data_low = lowpass(data_1, fltrFreq, samplingRate);
toc

% tic
% data_band = bandpass(data_1, fltrFreqInt, samplingRate);
% toc

% Die beiden gehen gleich so schnell für 200.000 datapoints, aber bandpass ist 1000 mal langsamer als lowpass für 2.000.000 datapoints.
% 
% Anbei ist data_1.matB, bitte als .mat bennenen (RUB email will nicht es als .mat schicken) 

%%
% 
% Fst1     First stopband frequency set to 0.35.
% Fp1      First passband frequency set to 0.45.
% Fp2      Second passband frequency set to 0.55.
% Fst2     Second stopband frequency set to 0.65.
% Ast1     First stopband attenuation set to 60 dB.
% AP       Passband ripple set to 1dB.
% Ast2    Second stopband attenuation set to 60 dB.

% Fs must be specified as a scalar trailing the other numerical values provided. In this case, all frequencies in the specifications are in Hz as well.


designSpecs = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',1,10,300,1000,60,1,20,samplingRate);
designmethods(designSpecs,'SystemObject',true)
designoptions(designSpecs,'cheby1','SystemObject',true)
BP = design(designSpecs,'cheby1','FilterStructure','df1sos','SystemObject',true)
fvtool(BP)


tic
data_BP = BP(data_1);
toc

figure
plot(data_1)
hold on
plot(data_BP)
legend('data','filtered data')

