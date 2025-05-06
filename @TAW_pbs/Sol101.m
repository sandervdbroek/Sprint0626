function binFolder = Sol101(obj,opts,solOpts)
arguments
    obj
    opts.BinFolder = '';
    opts.NumAttempts = 1
    opts.Silent = true;
    opts.TruelySilent = false;
    solOpts.g = 9.81;
    solOpts.GravVector = [0 0 1]';

end
%% get info for flight condtion
% update FE Model
obj.fe.AeroSettings = ads.fe.AeroSettings(obj.Span./obj.AR,1,obj.Span,obj.Span.^2./obj.AR,...
    "ACSID",obj.fe.CoordSys(end),"Velocity",1);
IDs = obj.fe.UpdateIDs();
%make solver object
idx_CoM = find([obj.fe.Constraints.Tag] == "CoM",1);
sol = ads.nast.Sol101();
sol.isFree = true;
sol.CoM = obj.fe.Constraints(idx_CoM);
sol.DoFs = [];
sol.g = solOpts.g;
sol.Grav_Vector = solOpts.GravVector;
sol.LoadFactor = 1;
sol.UpdateID(IDs);

%% run Nastran
binFolder = sol.run(obj.fe,Silent=opts.Silent,NumAttempts=opts.NumAttempts,...
    BinFolder=opts.BinFolder,TruelySilent=opts.TruelySilent);
end

