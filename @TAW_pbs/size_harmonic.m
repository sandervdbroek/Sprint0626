function obj = size_harmonic(obj,opts)
arguments
    obj
    opts util.SizingOpts = util.SizingOpts;
end
res = struct();
for i = 1:100
    old = obj.MTOM;
    obj.ConstraintAnalysis();
    obj.BuildBaff(Retracted=false);
    obj.UpdateAeroEstimates();
    obj.MissionAnalysis();
    obj.OEM = obj.Baff.GetOEM();
    mtom = obj.OEM + obj.ADR.Payload + obj.MTOM * obj.Mf_Fuel;
    delta = mtom - old;
    res(i).X = old;
    res(i).Y = delta;
    % if i<3
        obj.MTOM = mtom;
    % else
    %     m = (res(end).X-res(end-1).X)/(res(end).Y-res(end-1).Y);
    %     c = res(end).Y - m*res(end).X;
    %     obj.MTOM = res(end).X + c;
    % end
    % disp([obj.MTOM/1e3,delta])
    if abs(delta)<1
        if opts.Verbose
            ads.util.printing.title(sprintf('Harmonic Loop completed on iter %.0f: MTOM %.0f kg',i,obj.MTOM),Length=60,Symbol=' ');
        end
        return
    end
end
    if opts.Verbose
        ads.util.printing.title(sprintf('No Harmonic Convergence Continuing Anyway: MTOM %.0f kg',i,obj.MTOM),Length=60,Symbol='E');
    end
    warning('No harmonic Convergence - continuing anyway')
end

