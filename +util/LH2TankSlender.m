function [m_f,m_t,m_tf] = LH2TankSlender(L,slenderness,e_w,Ullage_TO,opts)
arguments
    L 
    slenderness 
    e_w 
    Ullage_TO 
    opts.fuelType = cast.config.Fuel.LH2
end
%LH2TANKSLENDER Summary of this function goes here
%   Detailed explanation goes here
[m_f,m_t,m_tf] = util.LH2TankMass(L,L/slenderness/2,e_w,Ullage=Ullage_TO,fuelType=opts.fuelType);
end

