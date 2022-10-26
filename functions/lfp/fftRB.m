function [P1, f] = fftRB(lfpTrace, Fs)            

L = numel(lfpTrace);     % Length of signal
y = fft(lfpTrace);       % fft analysis
P2 = abs(y/L);              % normalization to the length ?
P1 = P2(1:L/2+1);           % just half of the data
P1(2:end-1) = 2*P1(2:end-1);% adjustment of the edges

f = Fs*(0:(L/2))/L;         % frequencies

