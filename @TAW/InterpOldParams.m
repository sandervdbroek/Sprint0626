function new_params = InterpOldParams(obj,params)
%INTERPOLDPARAMS Summary of this function goes here
%   Detailed explanation goes here
new_params = obj.WingBoxParams;
% deal with connector
new_params(1) = new_params(1).apply(params(1).interpolate(obj.WingBoxParams(1).Eta));
% combine wing in old params into one parameter object (might have been split at a hinge)
if length(params)==3
    wing_params = params(2).combine(params(3));
else
    wing_params = params(2);
end
% wing_params.Eta = round(wing_params.Eta,10);

if obj.HingeEta <1
    % calculate 
    span = new_params(2).Span + new_params(3).Span;
    wing_etas = new_params(2).Eta*new_params(2).Span/span;
    ffwt_etas = (new_params(3).Eta*new_params(3).Span + new_params(2).Span)/span;

    new_params(2) = new_params(2).apply(wing_params.interpolate(round(wing_etas,10)));
    new_params(3) = new_params(3).apply(wing_params.interpolate(round(ffwt_etas,10)));
else
    new_params(2) = new_params(2).apply(wing_params.interpolate(new_params(2).Eta));
end
obj.WingBoxParams = new_params;
end

