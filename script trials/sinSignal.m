len = 0.001;                                       % Length (sec)
f   = 1E+4;                                     % Frequency (Hz)
Fs  = 20000;                                     % Sampling Frequency (Hz)
t   = linspace(0, len, Fs*len);                 % Time Vector
signal = sin(2*pi*f*t);    
signal_flt = highpass(signal, 150, Fs);
figure;
plot(signal)
figure;
plot(signal_flt)