function [fitError] = fittingError_circ(measuredData, fitData)
%FITTINGERROR_CIRC Compute the fitting error, weight of outer values: 0.5
%   Treshold for fitting error: <0.5

%error = sum over all orientations ((measured response - fitted response value)^2) /
%sum over all orientations ((measured response - measured response averaged across all orientations)^2)

measuredData1 = measuredData(1:12);
measuredData2 = measuredData(2:13);

fitData1 = fitData(1:12);
fitData2 = fitData(2:13);

meanMeasuredData1  = mean(measuredData1);
fitError(1) = sum((measuredData1 - fitData1).^2)/sum((measuredData1-meanMeasuredData1).^2);

meanMeasuredData2  = mean(measuredData2);
fitError(2) = sum((measuredData2 - fitData2).^2)/sum((measuredData2-meanMeasuredData2).^2);

fitError = mean(fitError);

end

