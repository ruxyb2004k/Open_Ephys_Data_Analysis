function [fitError] = fittingError(measuredData, fitData)
%FITTINGERROR Compute the fitting error
%   Treshold for fitting error: <0.5

%error = sum over all orientations ((measured response - fitted response value)^2) /
%sum over all orientations ((measured response - measured response averaged across all orientations)^2)


meanMeasuredData  = mean(measuredData);
fitError = sum((measuredData - fitData).^2)/sum((measuredData-meanMeasuredData).^2);

end

