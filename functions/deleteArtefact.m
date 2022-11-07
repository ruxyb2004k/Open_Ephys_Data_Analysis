%%% Script by RB / 13.10.2020 %%%
%%% rewrites the data matrix with the same value during the opto-electrical
%%% artefact 

numDp = round(sessionInfo.rates.wideband*0.001); % number of data points to average out (1 ms)
artefactTimes = timestampsEv(dataEv == artefactCh);

m = 1; % choose between 1 (white gaussian noise) and 2 (flat line)
if m == 1 % introduce white gaussian noise - best method so far
    for timeInd = 1: numel(artefactTimes) % for each artefact
        exclInd = find(timestamps == artefactTimes(timeInd)); % find its index in timestamps and data
        for i = 1:size(data,1)
            noise = wgn(1,numDp+1,1)*round((data(i, exclInd+numDp) - data(i, exclInd-1))/10);
            diffDiv = linspace(data(i, exclInd-1), data(i, exclInd+numDp), numDp+1);
            data(i,exclInd: exclInd+numDp) = noise+diffDiv;
        end
    end
elseif m == 2 % introduce flat line - usually it also works, but sometimes it fails to properly remove the artefact
    for timeInd = 1: numel(artefactTimes) % for each artefact
        exclInd = find(timestamps == artefactTimes(timeInd)); % find its index in timestamps and data
        data(:,exclInd: exclInd+numDp) = repmat(data(:, exclInd-1), [1,numDp+1]); % remove artefact
    end
end

% try to remove onset/offset artefact - not succesful
% artefactCh = 1;
% numDp = round(sessionInfo.rates.wideband*0.1); % number of data points to average out (100 ms)
% artefactDpOn = recStartDataPoint(1:end-1);
% artefactDpOff = recStartDataPoint(2:end) - 1;

% for dpInd = 1: numel(artefactDpOn) % for each onset artefact index 
%     exclInd = artefactDpOn(dpInd);% 
%     data(:,exclInd: exclInd+numDp) = repmat(data(:, exclInd+numDp+1), [1,numDp+1]); % method 1: flat line
%     data(:,exclInd: exclInd+numDp) = flip(data(:,exclInd+numDp+1: exclInd+2*numDp+1),2);% method 2: mirror data
%     for i = 1:size(data,1) % method 3: white noise
%         noise = wgn(1,numDp+1,1)*sqrt(std_ch(i));
%         data(i,exclInd: exclInd+numDp) = noise;% + data(i, exclInd+numDp+1);
%     end    
% end

% for dpInd = 1: numel(artefactDpOff) % for each onset artefact index 
%     exclInd = artefactDpOff(dpInd);
%     data(:,exclInd-numDp: exclInd) = repmat(data(:, exclInd-numDp-1), [1,numDp+1]); %  method 1: flat line
%     data(:,exclInd-numDp: exclInd) =flip(data(:,exclInd-2*numDp-1: exclInd-numDp-1),2);% method 2: mirror data
%     for i = 1:size(data,1)% method 3: white noise
%         noise = wgn(1,numDp+1,1)*sqrt(std_ch(i));
%         data(i,exclInd-numDp: exclInd) = noise;% + data(i, exclInd-numDp-1);
%     end
% end   