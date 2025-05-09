classdef EnforcedLiftDist < cast.ADP & cast.size.AbstractLoads
    %TAW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Taw TAW
    end
    %jig twist
    properties
        

    end
    properties
        GravVector = [0;0;-1];
        g = 9.81;
    end

    properties
        Tags
    end
    methods
        function val = get.Tags(obj)
            val = obj.getTag();
        end
    end
    methods (Access=protected)
        function val = getTag(obj)
            if ~isnan(obj.Taw.HingeEta) && obj.Taw.HingeEta<1
                val = {["Wing_Connector_RHS","Wing_Connector_LHS"],["Wing_RHS","Wing_LHS"],["FFWT_RHS","FFWT_LHS"]};
            else
                val = {["Wing_Connector_RHS","Wing_Connector_LHS"],["Wing_RHS","Wing_LHS"]};
            end
        end
    end
    
    methods
        function obj = EnforcedLiftDist(Taw)
            arguments
                Taw TAW
            end
            obj.Taw = Taw;
        end
    end
end
