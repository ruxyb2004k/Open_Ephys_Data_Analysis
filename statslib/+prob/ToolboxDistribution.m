classdef ToolboxDistribution
    %ToolboxDistribution Interface for probability distributions
    
%   Copyright 2012-2014 The MathWorks, Inc.

    methods(Static,Hidden)
        function info = getInfo(classname)
            % INFO is a struct with fields that are used by fitdist, dfittool, and
            % other utility functions of the Statistics and Machine Learning Toolbox.
            % 
                        
            info.name = [];
            info.code = [];
            info.pnames = [];
            info.pdescription = [];
            info.prequired = [];
            info.fitfunc = [];
            info.likefunc = [];
            info.cdffunc = [];
            info.pdffunc = [];
            info.invfunc = [];
            info.statfunc = [];
            info.randfunc = [];
            info.checkparam = [];
            info.cifunc = [];
            info.loginvfunc = [];
            info.logcdffunc = [];
            info.hasconfbounds = false;
            info.censoring = false;
            info.paramvec = true;
            info.support = [-Inf Inf];
            info.closedbound = [false false];
            info.iscontinuous = true;
            info.islocscale = false;
            info.uselogpp = false;
            info.optimopts = false;
            info.supportfunc = [];
            info.logci = false;
            info.fittable = false;
            info.plim = [];
            
            if nargin>0
                if ismember('prob.ToolboxParametricDistribution',superclasses(classname))
                    info.cdffunc = str2func([classname '.cdffunc']);
                    info.pdffunc = str2func([classname '.pdffunc']);
                    info.randfunc = str2func([classname '.randfunc']);
                    info.invfunc = str2func([classname '.invfunc']);
                end
                if ismember('prob.FittableDistribution',superclasses(classname))
                    info.likefunc = str2func([classname '.likefunc']);
                    info.fittable = true;
                else
                    info.likefunc = [];
                    info.fittable = false;
                end
                if ismember('prob.ParametricDistribution',superclasses(classname))
                    info.pnames = eval([classname '.ParameterNames']);
                    info.pdescription = eval([classname '.ParameterDescription']);
                    n = eval([classname '.NumParameters']);
                    info.prequired = false(1,n);
                    info.logci = false(1,n);
                    info.plim = repmat([-Inf;Inf],1,n);
                end
            end
        end
    end
    
end
