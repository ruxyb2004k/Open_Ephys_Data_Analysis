%%% scrap code

% if exist(filenameSessionInfo,'file')
%     sessionInfoStruct = load(filenameSessionInfo);
%     %Checks that there is a single structure in the sessionInfo file
%     varsInFileSessionInfo = fieldnames(sessionInfoStruct); 
%     if numel(varsInFileSessionInfo)==1
%         sessionInfo = sessionInfoStruct.(varsInFileSessionInfo{1});
%         disp('Loading .sessionInfo.mat')
%     else
%         warning('Your .sessionInfo.mat has multiple variables/structures in it... wtf.')
%         sessionInfo = sessionInfoStruct;
%     end
%     SIexist = true;  %Marks that session info exists as expected
% else
%     warning(['could not find file ',sessionName,'.sessionInfo.mat ',...
%        'running the script instead..']) 
%     SIexist = false; %Marks that session info doesn't exists
% end
% 
% % check if a structure with Time Series info already exists
% if exist(filenameTimeSeries,'file')
%     timeSeriesStruct = load(filenameTimeSeries);
%     %Checks that there is a single structure in the sessionInfo file
%     varsInFileTimeSeries = fieldnames(timeSeriesStruct); 
%     if numel(varsInFileTimeSeries)==1
%         timeSeries = timeSeriesStruct.(varsInFileTimeSeries{1});
%         disp('Loading .timeSeries.mat')
%     else
%         warning('Your .timeSeries.mat has multiple variables/structures in it... wtf.')
%         timeSeries = timeSeriesStruct;
%     end
%     TSexist = true;  %Marks that session info exists as expected
% else
%     warning(['could not find file ',sessionName,'.timeSeries.mat ',...
%        'running the script instead..']) 
%     TSexist = false; %Marks that session info doesn't exists
% end    
% 
% 
% % check if a structure spikeClusterData already exists
% if exist(filenameSpikeClusterData,'file')
%     spikeClusterDataStruct = load(filenameSpikeClusterData);
%     %Checks that there is a single structure in the sessionInfo file
%     varsInFileSpikeClusterData = fieldnames(spikeClusterDataStruct); 
%     if numel(varsInFileSpikeClusterData)==1
%         spikeClusterData = spikeClusterDataStruct.(varsInFileSpikeClusterData{1});
%         disp('Loading .spikeClusterData.mat')
%     else
%         warning('Your .spikeClusterData.mat has multiple variables/structures in it... wtf.')
%         spikeClusterData = spikeClusterDataStruct;
%     end
%     SCDexist = true;  %Marks that session info exists as expected
% else
%     warning(['could not find file ',sessionName,'.spikeClusterData.mat ',...
%        'running the script instead..']) 
%     SCDexist = false; %Marks that session info doesn't exists
% end    
% 
% 
% % check if a structure with Cluster Time Series info already exists
% if exist(filenameClusterTimeSeries,'file')
%     clusterTimeSeriesStruct = load(filenameClusterTimeSeries);
%     %Checks that there is a single structure in the sessionInfo file
%     varsInFileClusterTimeSeries = fieldnames(clusterTimeSeriesStruct); 
%     if numel(varsInFileClusterTimeSeries)==1
%         clusterTimeSeries = clusterTimeSeriesStruct.(varsInFileClusterTimeSeries{1});
%         disp('Loading .clusterTimeSeries.mat')
%     else
%         warning('Your .clusterTimeSeries.mat has multiple variables/structures in it... wtf.')
%         clusterTimeSeries = clusterTimeSeriesStruct;
%     end
%     CTSexist = true;  %Marks that session info exists as expected
% else
%     warning(['could not find file ',sessionName,'.clusterTimeSeries.mat ',...
%        'running the script instead..']) 
%     CTSexist = false; %Marks that session info doesn't exists
% end    



%     checkFieldsSessionInfo;
%      if ~cfSI
%          sessionInfo         
%          disp(['Saving ', experimentName, ' / ' , sessionName, ' .sessionInfo.mat file'])
%          save(filenameSessionInfo, 'sessionInfo')
%      end    
