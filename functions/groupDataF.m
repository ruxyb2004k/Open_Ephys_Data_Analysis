%%% Created by RB on 07.05.2021
%%% called by groupData.m
%%% groups the single units by experiment, hemisphere or animal

iUnitsFilt_temp = false(1, max(groups)); % groups is iEN, iHN or iAN
classUnitsAll_temp = ones(1, max(groups));

for i = 1:max(groups)
    iUnitsFiltGrouped = (groups == i)' & (iUnitsFilt == 1);
    clusterTimeSeriesAll.traceFreqGoodGrouped(:,i,:) = nanmean(clusterTimeSeriesAll.traceFreqGood(:,iUnitsFiltGrouped,:), 2);
    iUnitsFilt_temp(i) = sum(iUnitsFiltGrouped) > 0;
end

classUnitsAll = classUnitsAll_temp * mean(classUnitsAll(iUnitsFilt));% a strange workaround 
iUnitsFilt = iUnitsFilt_temp;
clusterTimeSeriesAll.traceFreqGood = clusterTimeSeriesAll.traceFreqGoodGrouped;
totalUnits = size(iUnitsFilt,2);
totalUnitsFilt = sum(iUnitsFilt);
