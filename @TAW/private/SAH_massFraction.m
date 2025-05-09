function val = SAH_massFraction(HingeEta)
%SAH_MASS Summary of this function goes here
%   Detailed explanation goes here
etas = [1,0.9,0.64,0.48,0.32];
mf = [0,0.01,0.032,0.087,0.116];
val = interp1(etas,mf,HingeEta,'pchip');
end

