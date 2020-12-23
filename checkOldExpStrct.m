if sessionInfo.nChannels == 32
    sessionInfo.chOffset = 16;
    if ~strcmp(sessionInfo.probe, '2x16_E1') % check sessionInfo.probe
        warning('probe might be wrong')
    end
    if numel(sessionInfo.recordingDepth) == 1
        warning('recordingDepth might be wrong') % check sessionInfo.recordingDepth
    end
elseif sessionInfo.nChannels == 16
    if ~strcmp(sessionInfo.probe, '1x16_P1') % check sessionInfo.probe
        warning('probe might be wrong')
    end
    if numel(sessionInfo.recordingDepth) == 2
        warning('recordingDepth might be wrong')% check sessionInfo.recordingDepth
    end
end
%%
checkFields(sessionInfo); % check fields
checkFields(timeSeries); % check fields

load('allExp.mat')
experimentNameValues = extractfield(allExp,'experimentName');
a = ismember(sessionInfo.session.experimentName, experimentNameValues );

if ~a % if the experiment doesn't already exist, add it and save allExp.mat
    warning('allExp.mat does not include this experiment')
end
