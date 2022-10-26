%%% created by RB on 15.02.2022

% Fig 62a (6x): spectrogram of lfp  of a single band
if totalStim == 6
    titleFig62a = {'Spectrogram slow waves', 'Spectrogram delta'...
    'Spectrogram theta', 'Spectrogram alpha', 'Spectrogram beta', 'Spectrogram gamma'};

    saveFig62a = {'SpectrogramSW.fig','SpectrogramDelta.fig','SpectrogramTheta.fig',...
        'SpectrogramAlpha.fig','SpectrogramBeta.fig','SpectrogramGamma.fig'};
% elseif totalStim == 1
%     titleFig62a = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.',...
%     'Single-Sided Ampl Spectrum - 50% visual vs 50% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 25% visual vs 25% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 12% visual vs 12% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 0% visual vs 0% visual + photostim.'};
% 
%     saveFig62a = {'FFTsp100.fig', 'FFTsp50.fig','FFTsp25.fig','FFTsp12.fig','FFTsp0.fig'};
end
for freq = freqs
    figure
    set(gcf, 'Renderer', 'Painters');
    low = min(min(min(10*log10(abs(P_all_mean(:,waveFreqInd_P{freq},:))))));
    high= max(max(max(10*log10(abs(P_all_mean(:,waveFreqInd_P{freq},:))))));
    for cond = 1:totalConds       
        subplot(totalConds, 1, cond)
        ax = gca;
        surf(T,F(waveFreqInd_P{freq}),10*log10(abs(squeeze(P_all_mean(cond,waveFreqInd_P{freq},:)))),'edgecolor','none');
        yl = ylim;
        yf = 0.98;
        if ~mod(cond,2)
            line(optStimCoords, [yl(2) yl(2)]*yf,[10 10], 'Color', 'w', 'LineWidth', 2);
        end
        x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
        if cond < totalConds-1
            for i = (1:totalStim)
                h2 = line('XData',x(i,:),'YData',[yl(2) yl(2)]*0.95, 'ZData', [10 10]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
                set(h2,'Color',[0.75 0.75 0.75] ,'LineWidth',4);% Set properties of lines
            end
        end
        xlim(round([T(1), T(end)]))
        caxis([low high])
        colorbar
        view(2)
        grid off
        set(ax, 'TickDir', 'out');
        set(ax,'FontSize',fs)
        if cond == 1
            title(titleFig62a{freq},'FontSize',18);
        end
    end

    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
%     zlabel('Frequency power')
 
   
    if saveFigs == true
        savefig(strcat(savePath, saveFig62a{freq}));
        title('');
        saveas(gcf, strcat(savePath, saveFig62a{freq}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig62a{freq}(1:end-4)), 'epsc');
    end
end