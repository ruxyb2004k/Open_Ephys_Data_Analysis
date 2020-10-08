classdef ToolboxParametricDistribution < prob.ParametricDistribution & ...
                                         prob.TruncatableDistribution & ...
                                         prob.ToolboxDistribution
%ParametricDistribution Base class for parametric probability distributions.

%   Copyright 2012 The MathWorks, Inc.

    methods(Access=protected)
        function [varargout] = cdffun(this,x,varargin)
            pcell = num2cell(this.ParameterValues);
            if nargout>=2
                covarg = {this.ParameterCovariance};
            else
                covarg = {};
            end
            [varargout{1:nargout}] = this.cdffunc(x,pcell{1:min(end,this.NumParameters)},covarg{:},varargin{:});
        end
        function [varargout] = icdffun(this,x,varargin)
            pcell = num2cell(this.ParameterValues);
            if nargout>=2
                covarg = {this.ParameterCovariance};
            else
                covarg = {};
            end
            [varargout{1:nargout}] = this.invfunc(x,pcell{1:min(end,this.NumParameters)},covarg{:},varargin{:});
        end
        function y = pdffun(this,x)
            pcell = num2cell(this.ParameterValues);
            y = this.pdffunc(x,pcell{1:min(end,this.NumParameters)});
        end
        function y = randomfun(this,varargin)
            pcell = num2cell(this.ParameterValues);
            y = this.randfunc(pcell{:},varargin{:});
        end
    end

    methods(Access=protected)
        function displayCallback(this)
            fprintf('  %s\n',getString(message('stats:probdists:DisplayDistribution',this.DistributionName)));
            if ~isempty(this)
                nms = this.ParameterNames;
                n = length(nms);
                nameWidth = max(cellfun('length',nms));

                vals = cell(n,1);
                isFitted = isa(this,'prob.FittableDistribution') && ~all(this.ParameterIsFixed);
                if isFitted
                    try
                        ci = paramci(this);
                    catch me
                        ci = [];
                    end
                end
                for j=1:n
                    vals{j} = sprintf('%g',this.ParameterValues(j));
                end
                valWidth = max(cellfun('length',vals));
                
                for j=1:n
                    if ~isFitted || this.ParameterIsFixed(j) || isempty(ci) || any(isnan(ci(:,j)))
                        fprintf('    %*s = %*s\n',nameWidth,nms{j},valWidth,vals{j});
                    else
                        conf = sprintf('[%g, %g]',ci(:,j));
                        fprintf('    %*s = %*s   %s\n',nameWidth,nms{j},valWidth,vals{j},conf);
                    end
                end
            end
        end
    end
    
    methods(Static, Abstract = true)
        y = cdffunc(x,varargin)
        y = invfunc(x,varargin)
        y = pdffunc(x,varargin)
        y = randfunc(varargin)
    end

end % classdef

