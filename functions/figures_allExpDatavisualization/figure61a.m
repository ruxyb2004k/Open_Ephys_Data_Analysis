%%% created by RB on 15.02.2022

% Fig 61a (4x): spectrogram of lfp 
if totalStim == 6
    titleFig61a = {'Spectrogram 100% visual', 'Spectrogram 100% visual + photostim.'...
    'Spectrogram 0% visual', 'Spectrogram 0% visual + photostim.'};

    saveFig61a = {'Spectrogram100.fig','Spectrogram100opt.fig','Spectrogram0.fig','Spectrogram0opt.fig'};
% elseif totalStim == 1
%     titleFig61a = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.',...
%     'Single-Sided Ampl Spectrum - 50% visual vs 50% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 25% visual vs 25% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 12% visual vs 12% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 0% visual vs 0% visual + photostim.'};
% 
%     saveFig61a = {'FFTsp100.fig', 'FFTsp50.fig','FFTsp25.fig','FFTsp12.fig','FFTsp0.fig'};
end
for cond = 1:totalConds
    figure
    set(gcf, 'Renderer', 'Painters');
    ax = gca;
    surf(T,F,10*log10(abs(squeeze(P_all_mean(cond,:,:)))),'edgecolor','none');
    low = floor(min(min(10*log10(abs(squeeze(P_all_mean(cond,:,:)))))));
    high= ceil(max(max(10*log10(abs(squeeze(P_all_mean(cond,:,:)))))));

    yl = ylim;
    yf = 0.99;
    if ~mod(cond,2)
        line(optStimCoords, [yl(2) yl(2)]*yf,[10 10], 'Color', 'w', 'LineWidth', 2);
    end
    x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
    if cond < totalConds-1
        for i = (1:totalStim)
            h2 = line('XData',x(i,:),'YData',[yl(2) yl(2)]*0.97, 'ZData', [10 10]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
            set(h2,'Color',[0.75 0.75 0.75] ,'LineWidth',4);% Set properties of lines
        end
    end
    xlim(round([T(1), T(end)]))
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
%     zlabel('Frequency power')
    colorbar
    caxis([low high])
    a = colorbar('Ticks',[low high]);
    a.Label.String = 'Power/Frequency (dB/Hz)';
    view(2)
    grid off
    set(ax, 'TickDir', 'out');
    set(ax,'FontSize',fs)

    title(titleFig61a{cond},'FontSize',18);
   
    if saveFigs == true
        savefig(strcat(savePath, saveFig61a{cond}));
        title('');
        saveas(gcf, strcat(savePath, saveFig61a{cond}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig61a{cond}(1:end-4)), 'epsc');
    end
end