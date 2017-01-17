classdef leak
    properties
        x   %position
        t   %time of activation
        i   %intensity
        tau %time of activity
        theta %time when leak becomes an obstacle
        rho %damages thah leak causes to passing robots       
        exists = 1 %set to 0 when changed to obstacle
        repaired = 0
        n %robots needed to repair
    end
    
    methods
        function obst = createObstacle(obj,corridorLength)
            obst = obstacle;
            obst.a = 1;
            obst.x = obj.x;
            obst.r = 1;
            obst.t = 0;
            obst.L = obj.i * corridorLength/100;
            obst.s = 0.9 * obj.i + 0.1;            
        end
    end
end