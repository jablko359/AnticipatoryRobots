function [robots, leaks, obstacles] = init(robotData,simTime,corridorLength,obstaclesCount,leaksCount)
    robots = initRobots(robotData.n,robotData.r,robotData.space,robotData.vmax,corridorLength);
    leaks = generateLeaks(simTime,leaksCount,corridorLength);
    obstacles = generateObstacles(simTime,obstaclesCount,corridorLength);
end

function robots = initRobots(n,r,space,vmax,corridorLength)
    for i = 1:n
        rob = robot;
        rob.n = i;
        if i <= r
            rob.d = 1; 
            rob.x = (i - 1) * space;
        else
            pos = corridorLength - ((i - r -1) * space);
            rob.x = pos;
        end       
        rob.vmax = vmax;
        robots(i) = rob;
    end
end

function leaks = generateLeaks(simTime,leaksCount,corridorLength)
    
    for i = 1:leaksCount
        instanceLeak = leak;        
        x = rand * corridorLength;
        
        if i ~= 1
            while hasLeak(x,leaks,10)
                x = rand * corridorLength;
            end   
        end         
      
        instanceLeak.x = x;         
        instanceLeak.t = rand * simTime;
        instanceLeak.i = rand;
        instanceLeak.tau = rand * simTime;
        instanceLeak.theta = rand * simTime;
        instanceLeak.rho = rand;
        leaks(i) = instanceLeak;
    end    
end

function res = hasLeak(x,leaks,offset)    
    res = 0;
    for i = 1: size(leaks)
        instace = leaks(i);
        if (x - instace.x) < offset
            res = 1;
            return;
        end
    end
end

function obstacles = generateObstacles(simTime,obstaclesCount,corridorLength) 
    for i = 1:obstaclesCount
        instaceObstacle = obstacle;
        x = rand * corridorLength;
        length = (rand * corridorLength)/100; %Obstacles should be too long 
        if i ~= 1 
            while obstacleOverlaps(x,length,obstacles);
                x = rand * corridorLength;
                length = (rand * corridorLength)/obstaclesCount; %Obstacles should be too long 
            end
        end
        
        instaceObstacle.x = rand * corridorLength;
        instaceObstacle.t = rand * simTime;
        instaceObstacle.s = 0.9 * rand + 0.1;
        instaceObstacle.L = length;
        instaceObstacle.x = x;
        obstacles(i) = instaceObstacle;        
    end
end

function overlaps = obstacleOverlaps(pos,length,obstacleList)
    overlaps = 0;
    for i = 1: size(obstacleList)
        obstacle = obstacleList(i);
        start = pos - length;
        endd = pos + length;
        obstacleStart = obstacle.x - obstacle.L;
        obstacleEnd = obstacle.x + obstacle.L;
        leftContains = (obstacleStart > start) && (obstacleStart < endd);
        rightContains = (obstacleEnd > start) && (obstacleEnd < endd);
        if leftContains || rightContains
            overlaps = 1;
            return;
        end
    end
    
end