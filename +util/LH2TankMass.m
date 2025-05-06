
function [m_f,m_t,m_tf] = LH2TankMass(L,R,e_w,opts)
arguments
    L
    R
    e_w = 0.8;
    opts.fuelType = cast.config.Fuel.LH2
    opts.Ullage = 0;
    opts.EquipAllowance = 0.006;
    opts.ContractionAllowance = 0.009;
    opts.TrappedFuelAllowance = 0.046;
end
P_vent = 2.5e5;
t_ins = 0.12; %insulation thickness
[~,~,~,P_out] = fh.atmos(convlength(40000,'ft','m'));
L_cylinder = L-R; % assume ellipsoidal end-caps with a 2:1 major-to-minor axis

sigma_aR1 = 172.4e6;
sigma_b = 234e6;
R_1 = 0.43;
R_2 = R_1;
% e_w = 0.8;
% e_w = 0.5;

sigma_a = sigma_aR1/(1-(sigma_aR1*0.5*(1+R_1))/sigma_b);
sigma = sigma_a/(1+(sigma_a*0.5*(1+R_2))/sigma_b);
t_c = (P_vent-P_out)*(R-t_ins)/(sigma*e_w);

V_total = tank_vol(L,R);
V_fuel = tank_vol(L-t_ins*2-t_c*2,R-t_ins-t_c);
V_skin = tank_vol(L-t_ins*2,R-t_ins) - V_fuel;
V_ins = V_total - V_fuel - V_skin;

m_t = V_ins * 32 + V_skin * 2840;

frac = 1-opts.Ullage-opts.EquipAllowance-opts.ContractionAllowance-opts.TrappedFuelAllowance;
m_f = V_fuel*opts.fuelType.Density*frac;
m_tf = V_fuel*opts.fuelType.Density*opts.TrappedFuelAllowance;
end

function V = tank_vol(L,R)
    L_cylinder = L-R; % assume ellipsoidal end-caps with a 2:1 major-to-minor axis
    V_cylinder = pi*R^2*L_cylinder; %Volume of cylinder
    V_cap = 4/3*pi*R*R/2*R;
    V = V_cylinder + V_cap;
end

% function V = tank_skin_vol(L,R,t)
%     L_cylinder = L-R; % assume ellipsoidal end-caps with a 2:1 major-to-minor axis
%     V_cylinder = pi*R^2*L_cylinder; %Volume of cylinder
%     V_cap = 4/3*pi*R*R/2*R;
%     V = V_cylinder + V_cap;
% end

% 
% function V = tank_skin_vol(L,R,t)
%     L_cylinder = L-R; % assume ellipsoidal end-caps with a 2:1 major-to-minor axis
%     V_cylinder = pi*(R^2-(R-t)^2)*L_cylinder; %Volume of cylinder
%     V_cap = 4/3*pi*(R^3-(R-t)^3);
%     V = V_cylinder + V_cap;
% end




