function sim(robotData,simTime,corridorLength,obstaclesCount,leaksCount,step)
    [robots, leaks, obstacles] = init(robotData,simTime,corridorLength,obstaclesCount,leaksCount);    
    
    iterationsCount = simTime / step;     
    time = 0;
    activeObstacles = zeros([size(obstacles,2),1]);
    %main loop
    for i=1:step:iterationsCount
        time = time + step;        
        obstacles = activateObstacles(obstacles,time);                 
    end
    
 
    plotObstacles(obstacles,corridorLength)
end



function obstacles = activateObstacles(inputObstacles,time)
    activeCount = 1;   
    activeIndexes = [];
    for i=1:size(inputObstacles,2)      
        obstacle = inputObstacles(i);
        isActive = obstacle.a;        
        activate = obstacle.t <= time;
        if (~isActive && activate)
            obstacle.a = 1;
            activeIndexes(activeCount) = i;
            activeCount = activeCount +1;
        end
        obstacles(i) = obstacle;
    end    
    %How to change leak into obstacle?
end

function plotObstacles(activeObstacles,corridorLength)
    obstaclePosition = 1;    
    X = zeros(size(activeObstacles,2),2);
    Y = zeros(size(activeObstacles,2),2);
    for i=1:size(activeObstacles,2)
        obstacle = activeObstacles(i);   
        X(i,1) = getPositionInCorridor(obstacle.x - obstacle.L,corridorLength);
        X(i,2) = getPositionInCorridor(obstacle.x + obstacle.L,corridorLength);
        Y(i,1) = obstaclePosition;
        Y(i,2) = obstaclePosition;        
    end    
    plot(X',Y');
    axis([0,corridorLength,0,2]);
    
end

function x = getPositionInCorridor(in,corridorLength)
    if in < 0
        x = corridorLength + in;       
    elseif in < corridorLength
        x = in;
    else
        x = in - corridorLength;
    end
end