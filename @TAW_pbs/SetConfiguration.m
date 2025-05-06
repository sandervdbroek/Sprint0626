function SetConfiguration(obj,opts)
%SETCONFIGURATION Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj
    opts.FuelMass = obj.MTOM*obj.Mf_Fuel;
    opts.PayloadFraction = 1;
    opts.ArtForceFactor = 0;
    opts.IsLocked = true;
    opts.NChord = 5;
end

obj.BuildBaff(ArtificialForce=opts.ArtForceFactor>0,Retracted=false);

for i = 1:length(obj.Baff.Payload)
obj.Baff.Payload(i).FillingLevel = opts.PayloadFraction;
end

FuelFraction = opts.FuelMass/sum([obj.Baff.Fuel.Capacity]);
for i = 1:length(obj.Baff.Fuel)
obj.Baff.Fuel(i).FillingLevel = FuelFraction;
end
obj.WingEta = obj.Baff.Wing(1).Eta;
% distribute Artifical forces
if opts.ArtForceFactor>0
    %if TAH tune postion of the Tank
    if obj.IsTAH && obj.HingeEta<1 && ~opts.DisableTanks
        obj.TuneTAHEta;
    end
    obj.g = 9.81*opts.ArtForceFactor;
    m = obj.Baff.GetMass;
    L = m*obj.g;
    idx = contains([obj.Baff.Point.Name],'ArtLift');
    ArtPoints = obj.Baff.Point(idx);
    p = cell2mat(arrayfun(@(x)x.GetGlobalPos(0),ArtPoints,'UniformOutput',false)');
    py = p(2,:);
    [py,idx] = unique(py);
    ys = [-obj.Span/2,(py(2:end)+py(1:end-1))/2,obj.Span/2];
    %define lift dist (elipse with std dist. going to zero for fuselage)
    FusDiam = max([obj.Baff.BluffBody(1).Stations.Radius])*2;
    if obj.HingeEta == 1 || opts.IsLocked
        [ysi,z_i] = get_lift_dist(obj.Span,FusDiam,1,m,0,0,obj.g);
    else
        %get FFWT mass and COM
        ffwt_idx = find(contains([obj.Baff.Wing.Name],"FFWT_RHS"),1);
        [CoM,mass_ffwt]=obj.Baff.Wing(ffwt_idx).GetCoM;
        [ysi,z_i] = get_lift_dist(obj.Span,FusDiam,obj.HingeEta,m,mass_ffwt,CoM(1),obj.g);
    end
    % integrate lift distribution in the area around each point
    As = zeros(1,length(ys)-1);
    for i = 1:length(As)
        l_idx = ysi<=ys(i+1) & ysi>=ys(i);
        As(i) = trapz(ysi(l_idx),z_i(l_idx));
    end
    Fs = As./sum(As)*L;
    %apply the force to each point
    for i = 1:length(idx)
        A = ArtPoints(idx(i)).GetGlobalA;
        ArtPoints(idx(i)).Force = A'*[0 0 Fs(i)]';
    end
    [ArtPoints.VectorPltScaling] = deal(obj.Span/4*1/max(Fs));
else
    obj.g = 9.81;
end
% obj.g = 0;
obj.GravVector = [0;0;-1];
obj.UpdateAeroEstimates();
obj.ToFE('GenAero',opts.ArtForceFactor==0,'NChord',opts.NChord);
if obj.HingeEta<1
    for i = 1:2
        obj.fe.Hinges(i).isLocked = opts.IsLocked;
        if opts.ArtForceFactor>0
            obj.fe.Hinges(i).K = 1e3;
        end
    end
end
end

