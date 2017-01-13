function sim(robotData,simTime,corridorLength,obstaclesCount,leaksCount,step)
    [robots, leaks, obstacles] = init(robotData,simTime,corridorLength,obstaclesCount,leaksCount);    
    
    iterationsCount = simTime / step;     
    time = 0;
    activeObstacles = zeros([size(obstacles,2),1]);
    %main loop
    for i=1:iterationsCount
        time = time + step;        
        [obstacles,leaks] = activateObstacles(obstacles,time,leaks,corridorLength);      
        i
    end
    obstacles
    leaks
 
    plotObstacles(obstacles,corridorLength);
end



function [obstacles,leaks] = activateObstacles(inputObstacles,time,inputLeaks,corridorLength)
    activeCount = 1;   
    activeIndexes = [];
    for i=1:size(inputObstacles,2)      
        obstacleInstance = inputObstacles(i);
        isActive = obstacleInstance.a;        
        activate = obstacleInstance.t <= time;
        if (~isActive && activate)
            obstacleInstance.a = 1;
            activeIndexes(activeCount) = i;
            activeCount = activeCount +1;
        end
        obstacles(i) = obstacleInstance;
    end
    
    for i=1:size(inputLeaks,2) 
        leak = inputLeaks(i);        
        activate = (leak.t + leak.tau) <= time;
        if activate && leak.exists;
            leak.exists = 0;
            obstaclesCount = size(obstacles,2);
            leakObstacle = createObstacle(leak,corridorLength);
            index = getOverlapingObstacle(leakObstacle,obstacles);
            if index == -1
                obstacles(obstaclesCount + 1) = leakObstacle;
            else
                influencedObstacle = obstacles(index);                
                severity = influencedObstacle.s + leak.i;
                if severity < 1
                    influencedObstacle.s = severity;
                else
                    influencedObstacle.s = 1;
                end
                %Powinno si� przed�u�y� istniej�c� przeszkod�, a w
                %przypadku gdy wyd�u�enie jest niemo�liwe z pwoodu
                %pokrywania si� przeszk�d, trzeba po��czy� 2 przeszkody
            end
        end
        leaks(i) = leak;
    end   
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

function robotTask = simulateRobotTask(robot,obstacles)
    %1. Wyznacz zadanie dla robota ?
    %2. Je�li ma gdzie� jecha�, oblicz odleg�o��, oraz kierunek
    %3. Na podstawie odleg�o�ci, ustaw przy�pieszenie robota od 0 do amax
    %4. Oblicz pr�dko�� robota
    %5. Oblicz po�o�enie robota
end

function v = calculateRobotVelocity(robot,step)
    velocity = robot.d * (robot.v + robot.a * step);
    if velocity < -robot.vmax
        v = -vmax;
    elseif velocity > robot.vmax
        v = vmax;
    else
        v = velocity;
    end
end

function x = calculateRobotPosition(robot,corridorLength,step)
    pos = robot.x + step * robot.v;
    x = getPositionInCorridor(pos,corridorLength);
end

function index = getOverlapingObstacle(obstacleInstance,obstacleList)
    index = -1;
    length = obstacleInstance.L;
    pos = obstacleInstance.x;
    for i=1:size(obstacleList,2)
        obstacleInstance = obstacleList(i);
        start = pos - length;
        endd = pos + length;
        obstacleStart = obstacleInstance.x - obstacleInstance.L;
        obstacleEnd = obstacleInstance.x + obstacleInstance.L;
        leftContains = (obstacleStart > start) && (obstacleStart < endd);
        rightContains = (obstacleEnd > start) && (obstacleEnd < endd);
        if leftContains || rightContains
            index = i;
            return;
        end
    end
end