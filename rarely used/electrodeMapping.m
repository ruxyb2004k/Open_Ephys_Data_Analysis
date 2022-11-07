%%% Electrode maping

% here for ASSY-77 H6 (64 ch)
% channels numbers on the data sheet of the electrode
% channelsElectrode = [2 4 6 8 10 12 14 31 15 13 11 9 19 7 27 5 20 3 18 1 16 22 29 28 30 32 24 26 23 25 21 17;...
%     34 36 38 40 42 44 46 63 47 45 43 41 51 39 59 37 52 35 50 33 48 54 61 60 62 64 56 58 55 57 53 49];
channelsElectrode = [2 4 6 8 10 12 14 31 15 13 11 9 19 7 27 5 20 3 18 1 16 22 29 28 30 32 24 26 23 25 21 17;...
    43 37 33 39 40 48 46 38 45 47 49 36 51 35 34 41 50 42 52 44 54 63 56 61 58 59 60 57 62 55 64 53];
channelsElectrode = channelsElectrode(:);

% figure
% scatter(ones(64,1),channelsElectrode)

% electrode to adapter mapping
electrodeToAdapter = (1:1:64)'; 

% adapter channels mapped to Intan (from Intan website, starting with 0); indices from 1 to
% 64 are the addapter channels, values in the array are the Intan channels
adapterToIntan0 = [32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 62 63 60 61 58 59 56 54 52 50 48 57 53 51 49 55 ...
    9 15 13 11 7 14 12 10 8 6 5 4 3 2 1 0 17 16 19 18 21 20 23 22 25 24 27 26 29 28 31 30 ]';

% figure
% scatter(ones(64,1),adapterToIntan0 )

% shift channels to start from 1 instead of 0
adapterToIntan1 = adapterToIntan0 + 1;

% channels to be inserted in the Open Ephys channel map in this order
channelsOpenEphys = adapterToIntan1(electrodeToAdapter(channelsElectrode));
% channelsOpenEphys = [46 44 42 40 38 36 34 17 33 35 37 39 29 41 21 43 28 45 30 47 32 26 19 20 18 16 24 22 25 23 27 31;...
%     14 12 10 8 6 4 2 49 1 3 5 7 61 9 53 11 60 13 62 15 0 58 51 52 50 48 56 54 57 55 59 63]+1;
% channelsOpenEphys = channelsOpenEphys(:);
%% channel map 2xP1

channelsOpenEphys = [46 20 45 19 44 22 42 24 40 26 38 28 39 25 35 29 41 23 33 31 43 21 34 32 47 17 36 30 48 18 37 27]; % order from Open Ephys
chOffset = 16;
channelsInd1 = channelsOpenEphys-chOffset; % subtract schannel offest

% sort(channelsInd1 )
xcoords(channelsInd1(1:4:end)) = 0;
xcoords(channelsInd1(2:4:end)) = 200;% 250;
xcoords(channelsInd1(3:4:end)) = 22;
xcoords(channelsInd1(4:4:end)) = 222;% 272;
% xcoords = xcoords';

for i = 0:numel(channelsInd1)/4-1
    ycoordsChannelsInd1(4*i+1) = 75 + i*25;
    ycoordsChannelsInd1(4*i+2) = 75 + i*25;
    ycoordsChannelsInd1(4*i+3) = 87 + i*25;
    ycoordsChannelsInd1(4*i+4) = 87 + i*25;
end    
 
% for i = 0:numel(channelsInd1)/4-1 % just to try more vertical spacing
%     ycoordsChannelsInd1(4*i+1) = 75 + i*50;
%     ycoordsChannelsInd1(4*i+2) = 75 + i*50;
%     ycoordsChannelsInd1(4*i+3) = 100 + i*50;
%     ycoordsChannelsInd1(4*i+4) = 100 + i*50;
% end  


ycoords(channelsInd1) = ycoordsChannelsInd1;
% ycoordsChannelsInd1fin = ycoordsChannelsInd1fin';  

figure; 
scatter(xcoords, ycoords)


%% channel map ASSY-77 H6 (64 ch)

chOffset = 0;
channelsInd1 = channelsOpenEphys-chOffset; % subtract schannel offest

% sort(channelsInd1 )
xcoords(channelsInd1(1:4:end)) = 0;
xcoords(channelsInd1(2:4:end)) = 200;% 250;
xcoords(channelsInd1(3:4:end)) = 22;
xcoords(channelsInd1(4:4:end)) = 222;% 272;
% xcoords = xcoords';

for i = 0:numel(channelsInd1)/4-1
    ycoordsChannelsInd1(4*i+1) = 75 + i*25;
    ycoordsChannelsInd1(4*i+2) = 75 + i*25;
    ycoordsChannelsInd1(4*i+3) = 87 + i*25;
    ycoordsChannelsInd1(4*i+4) = 87 + i*25;
end    
 
% for i = 0:numel(channelsInd1)/4-1 % just to try more vertical spacing
%     ycoordsChannelsInd1(4*i+1) = 75 + i*50;
%     ycoordsChannelsInd1(4*i+2) = 75 + i*50;
%     ycoordsChannelsInd1(4*i+3) = 100 + i*50;
%     ycoordsChannelsInd1(4*i+4) = 100 + i*50;
% end  


ycoords(channelsInd1) = ycoordsChannelsInd1;
% ycoordsChannelsInd1fin = ycoordsChannelsInd1fin';  

figure; 
scatter(xcoords, ycoords)
for i = 1:numel(channelsOpenEphys)
    text(xcoords(channelsOpenEphys(i))+2, ycoords(channelsOpenEphys(i)), ['Id.  ', num2str(channelsElectrode(i))]);
    text(xcoords(channelsOpenEphys(i))+2, ycoords(channelsOpenEphys(i))-8, ['Div. ', num2str(channelsOpenEphys(i))], 'Color','b');
end    
xlim([-10, 250])    
%% other map variables for ASSY-77 H6 (64 ch)
shankInd = [ones(32,1)*2; ones(32,1)];
kcoords = shankInd;
fs = 20000;
chanMap = 1:1:64;
chanMap0ind = chanMap - 1;
connected = true(64,1);