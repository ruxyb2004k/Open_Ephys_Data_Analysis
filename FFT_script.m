z = bandpass(data,[600 6000], 20000);
 
% data1 = data;
% data = z;

% data = data1;
% data3 = smooth(data,21);
% data = data3;

Fs = 20000;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = numel(data);             % Length of signal
t = (0:L-1)*T;        % Time vector
y = fft(data);
P2 = abs(y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;

figure;
plot(f,P1) 
% plot(f(1:100000),P1(1:100000)) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')