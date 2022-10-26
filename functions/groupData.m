%%% Created by RB on 07.05.2021
%%% groups the single units by experiment, hemisphere or animal

if strcmp(analyzeBy, 'unit')
    disp('Analyzing the data by unit');
       
elseif strcmp(analyzeBy, 'exp') 
    disp('Grouping the data by experiment');
    groups = iEN;
    groupDataF;
    
elseif strcmp(analyzeBy, 'hem')
    disp('Grouping the data by hemisphere');
    groups = iHN;
    groupDataF;
    
elseif strcmp(analyzeBy, 'animal')
    disp('Grouping the data by animal');
    groups = iAN;
    groupDataF;
    
end
