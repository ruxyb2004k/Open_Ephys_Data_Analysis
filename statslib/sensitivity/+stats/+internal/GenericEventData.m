classdef GenericEventData < event.EventData
    % GENERICEVENTDATA -- Used for providing event data, for notification
    %                     of events
    
    % Copyright 2014 The MathWorks, Inc.
    
    properties(GetAccess = 'public', SetAccess = 'private')
        Data %Event data
    end
    
    methods(Access = public)
        function obj = GenericEventData(data)
            %GENERICEVENTDATA Construct GenericEventData object
            %
            
            %Call superclass constructor
            obj = obj@event.EventData;
            
            %Set data property
            obj.Data = data;
        end
    end
end