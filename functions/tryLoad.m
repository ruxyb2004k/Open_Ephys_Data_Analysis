function [varOut, varExist] = tryLoad(varName, fileName)
% load structures
% function created by RB, 17.07.2020

ise = ismember(varName,evalin('base','who')); % check if varName exists in the base workspace

if ise == 1 % if the variable already exists in the base workspace
    disp([varName, ' already exists in the workspace']);
    varOut = evalin('base', varName);
    varExist = true;    
end    

if ise ~= 1 || numel(fieldnames(varOut)) == 0 %isempty(varOut) % if the variable doesn't exist in the workspace or it is empty  
    fileNameSep = regexp(fileName,filesep,'split');
    if exist(fileName,'file') % if the file exists
        disp(['Loading ', char(fileNameSep(end))])
        varOutStruct = load(fileName); % load file containing the variable/structure
        varsInVarOutStruct = fieldnames(varOutStruct); 
        if numel(varsInVarOutStruct)==1 % check that it only contains one structure
            varOut = varOutStruct.(varsInVarOutStruct{1}); % select the first/only stucture
        else
            warning(['Your .' varName, '.mat has multiple variables/structures in it... wtf.'])
            varOut = varOutStruct;
        end
        varExist = true;  %Marks that session info exists as expected
    else        
        disp(['could not find file ',char(fileNameSep(end))]) 
        varOut = struct();
        varExist = false; %Marks that session info doesn't exists
    end    
end
end
