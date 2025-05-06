function [obj,delta,Lds,Cases] = size_step_family(obj,opts)
arguments
    obj
    opts util.SizingOpts = util.SizingOpts;
end
Lds = cast.size.Loads.empty;
Cases = cast.LoadCase.empty;
delta = 0;
end

