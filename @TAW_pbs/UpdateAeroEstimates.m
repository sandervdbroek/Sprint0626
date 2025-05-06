function obj = UpdateAeroEstimates(obj)
%UPDATEAEROESTIMATES Summary of this function goes here
%   Detailed explanation goes here
pLamFuselage = 0.3*34/obj.Baff.BluffBody(1).EtaLength; % length of laminar flow 30% of a319 and same length on other aircraft
[CD0,meta] = cast.drag.baff2CD0(obj.Baff,obj.WingArea,obj.ADR.Alt_cruise,obj.ADR.M_c,"pLamFuselage",pLamFuselage,"pLamWing",0.25);
obj.CD0_meta = [meta,cast.drag.DragMeta("Extra",CD0*obj.ProturbanceDrag)];
CD0 = sum([obj.CD0_meta.CD0]);
% CD0 = CD0 + CD0 * 0.015 + 0.035/obj.WingArea; % 10.2514/1.C036529 (near Eq. 5)

% cruise info
K_e = 1.075;
% K_e = 1;
[rho,a] = ads.util.atmos(obj.ADR.Alt_cruise);
e_c = obj.EstimateOswald(obj.ADR.M_c,"NitaNastran")*K_e;
CL_c = obj.Mf_TOC*obj.MTOM*9.81/(1/2*rho*(a*obj.ADR.M_c)^2*obj.WingArea);
CD_c = CD0 + CL_c^2/(pi*obj.AR*e_c);
obj.CD0 = CD0;
obj.LD_c = CL_c/CD_c;
obj.e = e_c;
obj.CL_cruise = CL_c;


sweep = real(acosd(0.75.*obj.Mstar./obj.ADR.M_c));
%% Take off info
M_app = obj.ADR.V_app/340;
CD0_to = cast.drag.baff2CD0(obj.Baff,obj.WingArea,0,M_app,"pLamFuselage",pLamFuselage,"pLamWing",0.25);
CD0_to = CD0_to + CD0_to*0.03 + 0.04; % 10.2514/1.C036529 (near Eq. 5) + 0.015 fudge factor
e_to = obj.EstimateOswald(M_app,"NitaNastran")*K_e-0.05;

obj.CL_TOmax = 0.9*(obj.Cl_max+obj.Delta_Cl_to)*cosd(sweep); % Raymer 12.15
obj.CL_TO = obj.CL_TOmax/1.21;      % 10.2514/1.C036529 (near Eq. 2)
obj.CD_TO = CD0_to + obj.CL_TO^2/(pi*obj.AR*e_to);

%% landing 
CD0_ld = cast.drag.baff2CD0(obj.Baff,obj.WingArea,0,obj.ADR.V_app/340,"pLamFuselage",pLamFuselage,"pLamWing",0.25);
CD0_ld = CD0_ld + CD0_ld * 0.03 + 0.085; % 10.2514/1.C036529 (near Eq. 5) + 0.015 fudge factor
e_ld = obj.EstimateOswald(M_app,"NitaNastran")*K_e-0.1;

obj.CL_max = 0.9*(obj.Cl_max+obj.Delta_Cl_ld)*cosd(sweep); % Raymer 12.15
CD_app = CD0_ld + obj.CL_max^2/(pi*obj.AR*e_ld);
obj.LD_app = obj.CL_max/CD_app;


obj.CL_LDG = obj.CL_max/1.21;
obj.CD_LDG = CD0_ld + obj.CL_LDG^2/(pi*obj.AR*e_ld);
end

