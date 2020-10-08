classdef ProbabilityDistribution < matlab.mixin.Heterogeneous
%ProbabilityDistribution Base class for probability distributions.
    
%   Copyright 2012 The MathWorks, Inc.

    properties(Constant,Abstract)
        DistributionName;
    end
    
    methods(Abstract)
        [varargout] = cdf(this,x,varargin)
        y = pdf(this,x)
        y = random(this,x,varargin)
    end
    
    methods
        function m = mean(this)
%MEAN Mean of the distribution.
%   M = MEAN(PD) returns the mean M of the probability distribution PD.
%
%   Example: Create a Weibull distribution and demonstrate that its mean
%            is larger than its median.
%        p = makedist('weibull', 'A',200, 'B',1.1)
%        wmean = mean(p)
%        wmedian = median(p)
%
%   See also VAR, STD, ParameterValues.
            error(message('stats:probdists:NoMethod','mean'));
        end
        function v = var(this)
 %VAR Variance of the distribution.
%   V = VAR(PD) returns the variance V of the probability distribution PD.
%
%   Example: Create a Weibull distribution and compute its variance.
%        p = makedist('weibull', 'A',20, 'B',1.1)
%        var(p)
%
%   See also MEAN, STD, ParameterValues.
            error(message('stats:probdists:NoMethod','var'));
        end
        function s = std(this)
%STD Standard deviation of the distribution.
%   S = STD(PD) returns the standard deviation S of the probability
%   distribution PD.
%
%   Example: Create a Weibull distribution and compute its standard
%            deviation.
%        p = makedist('weibull', 'A',20, 'B',1.1)
%        std(p)
%
%   See also VAR, MEAN, ParameterValues.
            s = sqrt(var(this));
        end
    end
    
    methods(Access=protected,Abstract)
        displayCallback(this)
    end
    
    methods(Sealed,Hidden)
        function disp(this)
            mc = metaclass(this);
            bHotLinks = feature('hotlinks');
            shortname = mc.Name;
            j = find(shortname=='.',1,'last');
            if ~isempty(j)
                shortname(1:j) = [];
            end
            
            % Minimal display for array
            if ~isscalar(this)
                sz = size(this);
                szText = [sprintf('%d',sz(1)), sprintf('x%d',sz(2:end))];
                if bHotLinks
                    fprintf('  %s <a href="matlab: helpPopup %s">%s</a> array\n', szText, mc.Name, shortname);
                else
                    fprintf('  %s %s %s\n',szText,shortname,getString(message('stats:probdists:TextArray')));
                end
                return
            end
            
            % Class name
            if bHotLinks
                fprintf('  <a href="matlab: helpPopup %s">%s</a>\n', mc.Name, shortname);
            else
                fprintf('  %s\n', shortname);
            end
            
%             % Print the package name
%             if ~isempty(mc.ContainingPackage)
%                 fprintf('  %s: %s\n\n','Package', mc.ContainingPackage.Name);
%             else
                  fprintf('\n');
%             end
            
            % Body of display, subclass may override
            displayBody(this);
            
            % Links for methods and properties
%             if bHotLinks
%                 fprintf('\n  <a href="matlab: properties(''%s'')">%s</a>, ', mc.Name,'Properties');
%                 fprintf('<a href="matlab: methods(''%s'')">%s</a>\n\n', mc.Name,'Methods');
%             else
                fprintf('\n');
%             end
        end
    end
    methods(Access=protected)
        function displayBody(this)
            displayCallback(this)
        end
	end
	methods(Access=protected,Sealed,Static)
		function value = getDefaultScalarElement()
			% Required by matlab.mixin.Heterogeneous parent
			value = makedist('Uniform', 'Lower',0, 'Upper',1);
		end
	end
    methods(Hidden)
        % Hidden but public so interface classes can use this utility
        function requireScalar(this)
            if ~isscalar(this)
                throwAsCaller(MException(message('stats:probdists:RequiresScalar')));
            end
        end
    end
end % classdef
