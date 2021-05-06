%%%%%%%%%%%%%%%%%%%%%
%    parseParams    %
%%%%%%%%%%%%%%%%%%%%%
function p = parseParams(params,m)

if m.fixedN
  p.Rmax = params(1);
  p.c50 = params(2);
  p.n = m.n;
  p.offset = params(3);
else
  p.Rmax = params(1);
  p.c50 = params(2);
  p.n = params(3);
  p.offset = params(4);
end  
