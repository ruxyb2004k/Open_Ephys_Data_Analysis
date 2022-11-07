%%% created by RB on 03.03.2021
% tests if first baseline subtr, then norm and then V-S and Vph-Sph is the
% same as first V-S and Vph-Sph, then subtr and then norm are the same and they indeed are 

XtracesBaseSubtr = nan(size(smoothTraceFreqAll));
for cond = 1:totalConds
    for unit = find(iUnitsFilt)
        XtracesBaseSubtr(cond, unit, :) = smoothTraceFreqAll(cond, unit, :) - allStimBase(cond,unit,1);
    end
end    

XnormTracesBaseSubtr100 = nan(2*totalConds-2, totalUnits, totalDatapoints);

for cond = 1:totalConds
    for unit = find(iUnitsFilt & baseSelect)       
        % normalize by the 100% non-photostim condition
        XnormTracesBaseSubtr100(cond, unit, :) = smooth(XtracesBaseSubtr(cond, unit, :)/smoothMaxTraceFreqAll(1, unit),smooth_param, smooth_method);
    end
end
for cond = 1:totalConds-2
    for unit = find(iUnitsFilt & baseSelect)  
        XnormTracesBaseSubtr100(totalConds+cond, unit, :) = XnormTracesBaseSubtr100(cond, unit, :) - XnormTracesBaseSubtr100(totalConds-mod(cond,2), unit,:);
    end
end

XmeanNormTracesBaseSubtr100 = squeeze(nanmean(XnormTracesBaseSubtr100,2));

cond = 6;
figure; 
plot(XmeanNormTracesBaseSubtr100(cond,:)); 
hold on; 
plot(meanNormTracesBaseSubtr100(cond,:));
plot(meanNormTracesBaseSubtr100(cond,:)-XmeanNormTracesBaseSubtr100(cond,:))