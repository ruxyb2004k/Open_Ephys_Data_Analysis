%%% Script wrote by RB on 11.01.2021
function fft_metrics = fftMetrics(acg_wide, goodCodes) % calculates the FFT of auto-correlograms
  
interval = (1:200);

Fs = 1000;            % Sampling frequency of ACG
T = 1/Fs;              % Sampling period of ACG
L = numel(interval);    % Length of signal
t = (0:L-1)*T;        % Time vector
f = Fs*(0:(L/2))/L;

totalUnits = size(acg_wide,2);
P1 = nan(numel(f), totalUnits); % frequency power
M = nan(totalUnits ,1);  % max frequency power
maxI = nan(totalUnits ,1);  % index of max frequency power
maxF = nan(totalUnits ,1);    % frequency with maximum power
snrM = nan(totalUnits ,1);    % SNR of max power

for i = 1:totalUnits

    x = acg_wide(:,i); % ACG for one unit
    offset = ceil(numel(x)/2); 
    x_offset = x(offset+interval); % select only the 2nd half of the ACG 
    
    y = fft(x_offset); % fft calculations
    P2(:,i) = abs(y/L);
    P1(:,i) = P2(1:L/2+1,i);
    P1(2:end-1,i) = 2*P1(2:end-1,i);
        
    [M(i), maxI(i)] = max(P1(5:end-20,i)); % determine max amplitude
    maxI(i) = maxI(i)+4; % adjust index of max
    maxF(i) = f(maxI(i)); %Hz freq   
    snrM(i) = M(i)/nanmean(P1(maxI(i)+2:maxI(i)+11,i)); % calculate some sort of SNR
    
    figure    
    subplot(2,1,1) % plot ACG
    bar(interval(1:200), x_offset(1:200)) % ACG
    title(num2str(goodCodes(i)))
    xlabel('Time (ms)')
    ylabel('Count') 
    
    subplot(2,1,2)
    plot(f,P1(:,i)) % plot the FFT spectrum of ACG
    title(['Frequency amplitude spectrum - freq with max power: ', num2str(maxF(i)), ' and snrM: ', num2str(snrM(i))])
    xlabel('f (Hz)')
    ylabel('|P1(f)|')

end
fft_metrics.f = f;
fft_metrics.P1 = P1;
fft_metrics.M = M;
fft_metrics.maxI = maxI;
fft_metrics.maxF = maxF;
fft_metrics.snrM = snrM;
end
