function Lds = StaticLoads(obj,Case,idx)
arguments
    obj
    Case cast.LoadCase
    idx double
end

% get wing handles
Ns = zeros(1,length(obj.Taw.Tags));
wings = baff.Wing.empty;
for i = 1:length(obj.Taw.Tags)
    t = obj.Taw.Tags{i}(1);
    w_idx = find(ismember([obj.Taw.Baff.Wing.Name],t),1);
    wings(i) = obj.Taw.Baff.Wing(w_idx);
    Ns(i) = length(wings(i).Stations);
end
% get beam line positions
Ps = zeros(3,sum(Ns));
Fs = zeros(3,sum(Ns));
ii = 1;
for i = 1:length(wings)
    etas = [wings(i).Stations.Eta];
    a_sts = wings(i).AeroStations.interpolate(etas);
    for j = 1:length(etas)
        Ps(:,ii) = wings(i).GetGlobalWingPos(etas(j),a_sts(j).BeamLoc);
        Fs(:,ii) = wings(i).GetGlobalWingPos(etas(j),0.25);
        ii = ii + 1;
    end
end
ys = abs(Fs(2,:)); 
ys = ys./max(ys);

obj.g = 9.81*Case.LoadFactor;
m = obj.Taw.Baff.GetMass;
L = m*obj.g;

ld = @(eta)gamma_prandtl(eta,0);
% integrate lift distribution in the area around each point
As = zeros(1,length(ys));
for i = 1:length(ys)
    if i == 1
        tmp =  [ys(1),(ys(2)+ys(1))/2];
    elseif i == length(ys)
        tmp =  [(ys(end)+ys(end-1))/2,ys(end)];
    else
        tmp =  [(ys(i)+ys(i-1)),(ys(i)+ys(i+1))]/2;
    end
    As(i) = trapz(tmp,ld(tmp));
end
As = As./sum(As)/2;
Ls = [zeros(2,length(ys));As*L];

[F,M,T] = deal(zeros(1,length(ys)));
F(end) = Ls(end,3);
T(end) = dot(cross(Fs(:,end)-Ps(:,end),Ls(:,end)),-dcrg.geom.norm(Ps(:,end)-Ps(:,end-1)));
for i = (length(ys)-1):-1:1
    F(i) = F(i+1) + Ls(3,i);
    d_eta = Ps(:,i+1)-Ps(:,i);
    if norm(d_eta)==0
        M(i) = M(i+1);
        T(i) = T(i+1) + norm(cross(Fs(:,i)-Ps(:,i),Ls(:,i)));
    else
        M(i) = M(i+1) + dot(-cross(d_eta,[0;0;F(i+1)]),cross([0;0;1],dcrg.geom.norm(d_eta)));
        T(i) = T(i+1) + dot(cross(Fs(:,i)-Ps(:,i),Ls(:,i)),-dcrg.geom.norm(d_eta));
    end
end


% build loads
Lds = cast.size.Loads.empty;
iN = [1,cumsum(Ns)];
iN = sort([iN(1),iN(2:end-1),iN(2:end-1)+1,iN(end)]);
iN = reshape(iN,2,[])';
for i = 1:length(Ns)
    Lds(i) = cast.size.Loads(Ns(i));
    Lds(i).Mx = T(iN(i,1):iN(i,2));
    Lds(i).My = M(iN(i,1):iN(i,2));
    Lds(i).Fz = F(iN(i,1):iN(i,2));
end
Lds = Lds .* Case.SafetyFactor;
Lds = Lds.SetIdx(idx);
end


function G = gamma_jones(y,R)
a = (1-4*R/(3*pi))/(2*(1-4/(3*pi)));
b = R/2-a;
G = 2*(a+b/pi).*sqrt(1-y.^2) + 2*b./pi.*y.^2.*acosh(1./abs(y));
G(y==0) = 2*(a+b/pi);
end
function G = gamma_prandtl(y,R)
G = ((1-R.*y.^2).*sqrt(1-y.^2));
end
