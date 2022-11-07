figure
scatter(amplMinusBase(1, baseSelect, 1), amplMinusBase(1, baseSelect, 4))
lims = max(xlim, ylim);
xlim(lims)
ylim(lims)
lim= max(max(xlim, ylim))
h1 = line([0 lim],[0 lim]); % diagonal line
ff = fit(squeeze(amplMinusBase(1, baseSelect, 1))', squeeze(amplMinusBase(1, baseSelect, 4))', 'poly1')


%%
norm1StimAmplMinusBase = nan(size(amplMinusBase))
for unit = find(baseSelect)
    norm1StimAmplMinusBase(:,unit,:) = amplMinusBase(:,unit,:)/amplMinusBase(1,unit,1);
end
nanmean(norm1StimAmplMinusBase(1,:,1))
nanmean(norm1StimAmplMinusBase(1,:,4))
nanmean(norm1StimAmplMinusBase(2,:,1))
nanmean(norm1StimAmplMinusBase(2,:,4))