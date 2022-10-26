%%% created by RB on 15.02.2022

% Fig 62b (12x): spectrogram of lfp  of a single band
if totalStim == 6
    titleFig62b = {'Spectrogram slow waves 100%', 'Spectrogram slow waves 0%',...
        'Spectrogram delta 100%','Spectrogram delta 0%','Spectrogram theta 100%',...
        'Spectrogram theta 0%','Spectrogram alpha 100%','Spectrogram alpha 0%',...
        'Spectrogram beta 100%', 'Spectrogram beta 0%','Spectrogram gamma 100%', 'Spectrogram gamma 0%'};

    saveFig62b = {'SpectrogramSW100.fig','SpectrogramSW0.fig','SpectrogramDelta100.fig',...
        'SpectrogramDelta0.fig','SpectrogramTheta100.fig','SpectrogramTheta0.fig',...
        'SpectrogramAlpha100.fig','SpectrogramAlpha0.fig','SpectrogramBeta100.fig',...
        'SpectrogramBeta0.fig','SpectrogramGamma100.fig','SpectrogramGamma0.fig'};
% elseif totalStim == 1
%     titleFig62b = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.',...
%     'Single-Sided Ampl Spectrum - 50% visual vs 50% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 25% visual vs 25% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 12% visual vs 12% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 0% visual vs 0% visual + photostim.'};
% 
%     saveFig62b = {'FFTsp100.fig', 'FFTsp50.fig','FFTsp25.fig','FFTsp12.fig','FFTsp0.fig'};
end
for freq = freqs    
    yl = [min(F(waveFreqInd_P{freq})) max(F(waveFreqInd_P{freq}))];

    for cond = 1:2:totalConds
        figure
        set(gcf, 'Renderer', 'Painters');
        low = floor(min(min(min(10*log10(abs(P_all_mean(cond:cond+1,waveFreqInd_P{freq},:)))))));
        high= ceil(max(max(max(10*log10(abs(P_all_mean(cond:cond+1,waveFreqInd_P{freq},:)))))));
        
        subplot(2, 1, 1)
        ax = gca;
        surf(T,F(waveFreqInd_P{freq}),10*log10(abs(squeeze(P_all_mean(cond,waveFreqInd_P{freq},:)))),'edgecolor','none');
        ylim(yl);
        yf = 0.98;
        x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
        if cond < totalConds-1
            for i = (1:totalStim)
                h2 = line('XData',x(i,:),'YData',[yl(2) yl(2)]*0.95, 'ZData', [30 30]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
                set(h2,'Color',[0.75 0.75 0.75] ,'LineWidth',4);% Set properties of lines
            end
        end
        xlim(round([T(1), T(end)]))
        caxis([low high])
        colorbar('Ticks',[low high]);
                view(2)
        grid off
        set(ax,'xtick',[]);
        set(ax, 'TickDir', 'out');
        set(ax,'FontSize',fs)
        if ~saveFigs
            title(titleFig62b{(freq-1)*2+(cond+1)/2},'FontSize',18);
        end
        subplot(2, 1, 2)
        ax = gca;
        surf(T,F(waveFreqInd_P{freq}),10*log10(abs(squeeze(P_all_mean(cond+1,waveFreqInd_P{freq},:)))),'edgecolor','none');
        ylim(yl);
        yf = 0.98;

        x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
        if cond < totalConds-1
            for i = (1:totalStim)
                h2 = line('XData',x(i,:),'YData',[yl(2) yl(2)]*0.95, 'ZData', [30 30]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
                set(h2,'Color',[0.75 0.75 0.75] ,'LineWidth',4);% Set properties of lines
            end
        end
        line(optStimCoords, [yl(2) yl(2)]*yf,[50 50], 'Color', 'w', 'LineWidth', 2);
        xlim(round([T(1), T(end)]))
        caxis([low high])
%         colormap(jet)
        a = colorbar('Ticks',[low high]);
        a.Label.String = 'Power/Frequency (dB/Hz)';
        view(2)
        grid off
        set(ax, 'TickDir', 'out');
        set(ax,'FontSize',fs)
        xlabel('Time (s)')
        ylabel('Frequency (Hz)')
        zlabel('Frequency power')
                
        if saveFigs == true
            savefig(strcat(savePath, saveFig62b{(freq-1)*2+(cond+1)/2}));
            title('');
            saveas(gcf, strcat(savePath, saveFig62b{(freq-1)*2+(cond+1)/2}(1:end-3), 'png'));
            saveas(gcf, strcat(savePath, saveFig62b{(freq-1)*2+(cond+1)/2}(1:end-4)), 'epsc');
        end
    end
end