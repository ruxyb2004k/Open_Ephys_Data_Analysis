excel.numGoodCodes = numel(spikeClusterData.goodCodes);
excel.numEvGoodCodes = numel(clusterTimeSeries.selectedCodes(~logical(clusterTimeSeries.selectedCodesIndSpont)));
excel.evGoodCodes = clusterTimeSeries.selectedCodes(~logical(clusterTimeSeries.selectedCodesIndSpont));
excel.numSpontGoodCodes = sum(clusterTimeSeries.selectedCodesIndSpont);
excel.spontGoodCodes = clusterTimeSeries.selectedCodes(logical(clusterTimeSeries.selectedCodesIndSpont));
excel.numMuaCodes = numel(clusterTimeSeries.selectedCodesMua);
excel.MuaCodes = clusterTimeSeries.selectedCodesMua;
