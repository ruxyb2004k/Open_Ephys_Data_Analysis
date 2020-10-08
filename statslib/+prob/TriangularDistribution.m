classdef TriangularDistribution < prob.ParametricDistribution & ...
                                  prob.TruncatableDistribution
%TriangularDistribution Triangular probability distribution
%    An object of the TriangularDistribution class represents a
%    distribution with a density in the shape of a triangle. This
%    distribution object can be created using the MAKEDIST function.
%
%    TriangularDistribution methods:
%       cdf                   - Cumulative distribution function
%       icdf                  - Inverse cumulative distribution function
%       iqr                   - Interquartile range
%       mean                  - Mean
%       median                - Median
%       pdf                   - Probability density function
%       random                - Random number generation
%       std                   - Standard deviation
%       truncate              - Truncation distribution to an interval
%       var                   - Variance
%
%    TriangularDistribution properties:    
%       a                     - Value of the lower limit
%       b                     - Value of the location of the peak
%       c                     - Value of the upper limit
%       DistributionName      - Name of the distribution
%       NumParameters         - Number of parameters
%       ParameterNames        - Names of parameters
%       ParameterDescription  - Descriptions of parameters
%       ParameterValues       - Vector of values of parameters
%       Truncation            - Two-element vector indicating truncation limits
%       IsTruncated           - Boolean flag indicating if distribution is truncated
%
%    See also makedist.

%   Copyright 2012-2018 The MathWorks, Inc.

    properties(Dependent)
%A Lower limit of triangular distribution.
%    The A property represents the parameter that is the lower limit
%    of the triangular distribution. This distribution has a density that
%    increases linearly from A to B, then decreases linearly from B to C.
%
%    See also B, C.
        A

%B Location of peak of triangular distribution.
%    The B property represents the parameter that is the location of the
%    peak of the triangular distribution. This distribution has a density
%    that increases linearly from A to B, then decreases linearly from B to
%    C.
%
%    See also B, C.
        B
        
%C Upper limit of triangular distribution.
%    The C property represents the parameter that is the upper limit
%    of the triangular distribution. This distribution has a density that
%    increases linearly from A to B, then decreases linearly from B to C.
%
%    See also A, B.
        C
    end
    properties(GetAccess='public',Constant=true)
%DistributionName Distribution name.
%    The DistributionName property indicates the name of the probability
%    distribution.
%
%    See also ParameterNames, ParameterValues.
        DistributionName = getString(message('stats:probdists:DistributionTriangular'));

%NumParameter Number of parameters.
%    NumParameters is the number of parameters in the distribution.
%
%    See also ParameterValues. 
        NumParameters = 3;

%ParameterNames Parameter names.
%    ParameterNames is a cell array of strings containing the names of the
%    parameters of the probability distribution.
%
%    See also ParameterValues, ParameterDescription.
        ParameterNames = {'A' 'B' 'C'};

%ParameterDescription Parameter description.
%    ParameterNames is a cell array of strings containing short
%    descriptions of the parameters of the probability distribution.
%
%    See also ParameterNames, ParameterValues.
        ParameterDescription = {getString(message('stats:probdists:ParameterDescriptionLower')) ...
                                getString(message('stats:probdists:ParameterDescriptionPeak')) ...
                                getString(message('stats:probdists:ParameterDescriptionUpper'))};
    end
    properties(GetAccess='public',SetAccess='protected')
        ParameterValues = [0 .5 1];       % need to store these as a group to do error checking
    end
    
    methods(Hidden)
        function pd = TriangularDistribution(a,b,c)
 %TRIANGULARDISTRIBUTION Create a TRIANGULARDISTRIBUTION object.
 %   PD = TRIANGULARDISTRIBUTION(A,B,C) creates a TRIANGULARDISTRIBUTION 
 %   object with support on [A,B] and maximum probability density at
 %   B, where A<B<C.

            if nargin==0
                a = 0;
                b = 0.5;
                c = 1;
            end
            checkParams(a,b,c);
            pd.ParameterValues = [a b c];
        end
    end
    methods
        function m = mean(this)
            requireScalar(this)
            if this.IsTruncated
                m = truncatedMoment(this,1);
                return
            end
            a = this.A;
            b = this.B;
            c = this.C;
            
            % Compute the mean as a linear combination of the means of each
            % part
            p1 = (b-a)/(c-a);
            m1 = (1/3)*a + (2/3)*b;
            m2 = (1/3)*c + (2/3)*b;
            m = p1*m1 + (1-p1)*m2;
        end
        function v = var(this)
            requireScalar(this)
            if this.IsTruncated
                v = truncatedMoment(this,2);
                return
            end
            a = this.A;
            b = this.B;
            c = this.C;
            
            % Compute the variance by combining variance and bias for the
            % two parts
            p1 = (b-a)/(c-a);
            m1 = (1/3)*a + (2/3)*b;
            m2 = (1/3)*c + (2/3)*b;
            m = p1*m1 + (1-p1)*m2;
            v1 = (b-a)^2/18;
            v2 = (c-b)^2/18;
            v = p1*v1 + (1-p1)*v2 + p1*(m1-m)^2 + (1-p1)*(m2-m)^2;
        end
        function this = set.A(this,a)
            checkParams(a,this.B,this.C);
            this.ParameterValues(1) = a;
        end
        function this = set.B(this,b)
            checkParams(this.A,b,this.C);
            this.ParameterValues(2) = b;
        end
        function this = set.C(this,c)
            checkParams(this.A,this.B,c);
            this.ParameterValues(3) = c;
        end
        function a = get.A(this)
            a = this.ParameterValues(1);
        end
        function b = get.B(this)
            b = this.ParameterValues(2);
        end
        function c = get.C(this)
            c = this.ParameterValues(3);
        end
    end
    methods(Access=protected)
        function y = pdffun(this,x)
            requireScalar(this);
            a = this.A;
            b = this.B;
            c = this.C;
            y = max(0, (2/(c-a))*min((x-a)/(b-a), (c-x)/(c-b)));
            % Pass input NaNs to output 
            % (necessary because max(0,NaN) = 0 not NaN).
            y(isnan(x)) = NaN;
        end
        function y = cdffun(this,x,uflag)
            requireScalar(this);
            if nargin==3 && ~strcmpi(uflag,'upper')
                error(message('stats:cdf:UpperTailProblem'));
            end
            
            a = this.A;
            b = this.B;
            c = this.C;
            top = (x>b);
            if nargin<3
                xx = max(x,a);
                y    = (xx-a).^2    / ((b-a)*(c-a));
                xx = min(x,c);
                y(top) = 1-(c-xx(top)).^2 / ((c-b)*(c-a));
                y(x<=a) = 0;
                y(x>=c) = 1;
            else
                xx = max(x,a);
                y = 1 - (xx-a).^2    / ((b-a)*(c-a));
                xx = min(x,c);
                y(top) = (c-xx(top)).^2 / ((c-b)*(c-a));
                y(x<=a) = 1;
                y(x>=c) = 0;
            end
        end
        function y = icdffun(this,p)
            requireScalar(this);
            a = this.A;
            b = this.B;
            c = this.C;
            y = p;
            y(p<0 | p>1 | isnan(p)) = NaN;
            t = (p>=0 & p<=(b-a)/(c-a));
            y(t) = a + sqrt(p(t) * (b-a) * (c-a));
            t = (p<=1 & p>(b-a)/(c-a));
            y(t) = c - sqrt((1-p(t)) * (c-b) * (c-a));
        end
        function y = randomfun(this,varargin)
            requireScalar(this);
            y = icdf(this,rand(varargin{:}));
        end
    end
    methods(Access=protected)
        function displayCallback(this)
            fprintf('A = %g, B = %g, C = %g\n',this.A, this.B, this.C)
        end
    end

end % classdef

function checkParams(a,b,c)
if ~(isscalar(a) && isnumeric(a) && isreal(a) && isfinite(a))
    error(message('stats:probdists:ScalarParameter','A'))
end
if ~(isscalar(b) && isnumeric(b) && isreal(b) && isfinite(b))
    error(message('stats:probdists:ScalarParameter','B'))
end
if ~(isscalar(c) && isnumeric(c) && isreal(c) && isfinite(c))
    error(message('stats:probdists:ScalarParameter','C'))
end
if ~(a<c && a<=b && b<=c)
    error(message('stats:probdists:AltBltC'));
end
end


