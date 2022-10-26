%%% created by RB on 15.02.2022

% Fig 61b (2x): difference of spectrograms of lfp 

if totalStim == 6
    titleFig61b = {'Diff Spectrogram 100% - 100% +photostim'...
    'Diff Spectrogram 0% - 0% +photostim'};

    saveFig61b = {'DiffSpectrgram100.fig','DiffSpectrogram0.fig'};
% elseif totalStim == 1
%     titleFig61b = {'Single-Sided Ampl Spectrum - 100% visual vs 100% visual + photostim.',...
%     'Single-Sided Ampl Spectrum - 50% visual vs 50% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 25% visual vs 25% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 12% visual vs 12% visual + photostim.', ...
%     'Single-Sided Ampl Spectrum - 0% visual vs 0% visual + photostim.'};
% 
%     saveFig61b = {'FFTsp100.fig', 'FFTsp50.fig','FFTsp25.fig','FFTsp12.fig','FFTsp0.fig'};
end


for cond = 1:2:totalConds
    figure
    set(gcf, 'Renderer', 'Painters');
    ax = gca;
    Z = 10*(log10(abs(squeeze(P_all_mean(cond+1,:,:))))-log10(abs(squeeze(P_all_mean(cond,:,:)))));
    surf(T,F,Z,'edgecolor','none');
    low = floor(min(min(Z)));
    high= ceil(max(max(Z)));
    title([num2str(cond+1), ' - ', num2str(cond)])
    line(optStimCoords, [99 99],[10 10], 'Color', 'w', 'LineWidth', 2);
    yl = ylim;
    yf = 0.99;
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
    a.Label.String = 'Power/Frequency (dB/Hz)';;
    view(2)
    grid off
    set(ax, 'TickDir', 'out');
    set(ax,'FontSize',fs)
    title(titleFig61b{(cond+1)/2},'FontSize',18);
   
    if saveFigs == true
        savefig(strcat(savePath, saveFig61b{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig61b{(cond+1)/2}(1:end-3), 'png'));
        saveas(gcf, strcat(savePath, saveFig61b{(cond+1)/2}(1:end-4)), 'epsc');
    end
end