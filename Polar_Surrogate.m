classdef Polar_Surrogate
    %POLAR_SURROGATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        e
    end
    
    methods
        function obj = Polar_Surrogate(baffGeometry)
            %POLAR_SURROGATE Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end

        function Cd0  = Get_Wing_Cd0(obj,Cl)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
        
        function Cd = Get_Cd(obj,Cl,)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

