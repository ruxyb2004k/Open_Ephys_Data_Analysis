%%% Generation of random sine signal 

%range of possibles frequencies
FrequenciesRandon = [20:1:50];
AmplitudesRandon = [0.1:0.1:1];
%number of randon frequencies ??
nf = 12;

EndSignal=[];

for j = 1 : nf
    f=randsample(FrequenciesRandon,1); % get the randon frequencie
    a = randsample(AmplitudesRandon,1);
    Fs = 1000;                     % Sampling Frequency
    t  = [ 0 : 1 : ceil(Fs/f)];           % Time Samples
    data = sin(2*pi*f/Fs*t)'*a;        % Generate Sine Wave
    EndSignal= [data(1:end-1);EndSignal];    
end
figure;
plot(EndSignal, '-k')

%%

EvSignal = zeros(5,1);
Fs = 1000;
f = 15;
a = 5;
t  = [ 0 : 1 : ceil(Fs/f)]*0.25;           % Time Samples
data = sin(2*pi*f/Fs*t)'*a;        % Generate Sine Wave
EvSignal= [EvSignal;data(1:end-1)];    

f = 2;
a = 2.5;
t  = [ 0 : 1 : ceil(Fs/f)];           % Time Samples
t = t(ceil(end/4):1:ceil(end*3/4)+5);
data = sin(2*pi*f/Fs*t)'*a+a;        % Generate Sine Wave
EvSignal= [EvSignal;data(1:end-1)];    

figure;
plot(EvSignal, '-k')
l = numel(EvSignal);
%%
savePath = '/data/oidata/Ruxandra/Open Ephys/Open_Ephys_Data_Analysis/figs/IGSN SFB paper/';
saveFigs = 1;
yl = [-3,6];
EndSignal = EndSignal(1:l);
FinalSignal1 = EndSignal + EvSignal;
FinalSignal2 = EndSignal*3 + EvSignal/2;



figure;
plot(EndSignal, '-k')
ylim(yl)
box off
set(gca,'visible','off')
if saveFigs == true    
    savefig(strcat(savePath, '1.fig'));
    saveas(gcf, strcat(savePath, '1.png'));
    saveas(gcf, strcat(savePath, '1'), 'epsc');
end

figure;
plot(EvSignal, '-k')
ylim(yl)
box off
set(gca,'visible','off')
if saveFigs == true    
    savefig(strcat(savePath, '2.fig'));
    saveas(gcf, strcat(savePath, '2.png'));
    saveas(gcf, strcat(savePath, '2'), 'epsc');
end

figure;
plot(EndSignal*3, '-b')
ylim(yl)
box off
set(gca,'visible','off')
if saveFigs == true    
    savefig(strcat(savePath, '3.fig'));
    saveas(gcf, strcat(savePath, '3.png'));
    saveas(gcf, strcat(savePath, '3'), 'epsc');
end

figure;
plot(EvSignal/2, '-b')
ylim(yl)
box off
set(gca,'visible','off')
if saveFigs == true    
    savefig(strcat(savePath, '4.fig'));
    saveas(gcf, strcat(savePath, '4.png'));
    saveas(gcf, strcat(savePath, '4'), 'epsc');
end
figure;
plot(FinalSignal1, '-k')
ylim(yl)
box off
set(gca,'visible','off')
if saveFigs == true    
    savefig(strcat(savePath, '5.fig'));
    saveas(gcf, strcat(savePath, '5.png'));
    saveas(gcf, strcat(savePath, '5'), 'epsc');
end

figure;
plot(FinalSignal2, '-b')
ylim(yl)
box off
set(gca,'visible','off')
if saveFigs == true    
    savefig(strcat(savePath, '6.fig'));
    saveas(gcf, strcat(savePath, '6.png'));
    saveas(gcf, strcat(savePath, '6'), 'epsc');
end