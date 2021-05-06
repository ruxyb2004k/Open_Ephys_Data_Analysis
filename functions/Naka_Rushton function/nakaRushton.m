
%%%%%%%%%%%%%%%%%%%%%
%    nakaRushton    %
%%%%%%%%%%%%%%%%%%%%%
function response = nakaRushton(c,p)

response = p.Rmax * ((c.^p.n) ./ ((c.^p.n) + p.c50.^p.n)) + p.offset;



