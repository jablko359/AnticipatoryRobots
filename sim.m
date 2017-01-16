function sim(robotData,simTime,corridorLength,obstaclesCount,leaksCount,step)
    [robots, leaks, obstacles] = init(robotData,simTime,corridorLength,obstaclesCount,leaksCount);    
    
    iterationsCount = simTime / step;     
    time = 0;    
    %main loop
    for i=1:iterationsCount
        time = time + step;        
        [obstacles,leaks] = activateObstacles(obstacles,time,leaks,corridorLength);      
        robots = simulateRobots(robots,obstacles,leaks,step,corridorLength);
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

function robots = simulateRobots(inputRobots,obstacles,leaks,step,corridorLength)
    robots = robot.empty;
    for i=1:size(inputRobots,2)
        robots(i) = simulateRobotTask(inputRobots(i),obstacles,step,leaks,corridorLength);
        
    end
end

function robotTask = simulateRobotTask(robot,obstacles,step,leaks,corridorLength)
    currentTask = robot.task;
    switch currentTask
        case 'explore'
            %robot jedzie, szukaj�c przeciek�w
            if robot.a < robot.amax
                robot.a = robot.amax;
            end
            [velocity,isDownturned] = calculateRobotVelocity(robot,step,obstacles);
            robot.v = velocity;
            robot.isDownturned = isDownturned;
            robot.x = calculateRobotPosition(robot,corridorLength,step);
            foundLeaks = searchForLeaks(robot,leaks,corridorLength);
            %Znajdz najblizszy wyciek i jedz go naprawic powiadamiaj�c reszt�
            foundLeaksCount = size(foundLeaks,2);
            if foundLeaksCount > 0
                distance = inf;
                target = -1;
                for i=1:foundLeaksCount
                    robotPosition = robot.x;
                    leakPosition = leaks(foundLeaks(i));
                    tmpDist = calculateDistance(leakPosition.x,robotPosition,corridorLength);  % abs(leakPosition - robotPosition);
                    if tmpDist < distance
                        distance = tmpDist;
                        target = leakPosition;
                        robot.destination = target;
                        robot.task = 'move';
                    end
                end
            end
        case 'move'
            %robot jedzie w konkretne miejsce
            
        case 'fix'
            %robot stoi i usuwa wyciek lub przeszkode.
    end
    robotTask = robot;
    %1. Wyznacz zadanie dla robota ?
    %2. Je�li ma gdzie� jecha�, oblicz odleg�o��, oraz kierunek
    %3. Na podstawie odleg�o�ci, ustaw przy�pieszenie robota od 0 do amax
    %4. Oblicz pr�dko�� robota
    %5. Oblicz po�o�enie robota
end

function [v,isDownturned] = calculateRobotVelocity(robot,step,obstacles)

    velocity = robot.d * (robot.v + robot.a * step);
    if velocity < -robot.vmax
        v = -robot.vmax;
    elseif velocity > robot.vmax
        v = robot.vmax;
    else
        v = velocity;
    end
    
    %spowolnienie robota przez przeszkody
    isDownturned = 0;
    obstacleIndex = getObstacleByX(robot.x,obstacles);
    if obstacleIndex ~= -1
        isDownturned = 1;
        downturn = rand * 0.1;
        v = v * (1 - downturn);    
    end
    %Robota moga spowolnic uszkodzenia i przeszkody
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

function index = getObstacleByX(x,obstacles)
    index = -1;
    for i=1:size(obstacles,2)
       obstacleInstance = obstacles(i);
       obstacleStart = obstacleInstance.x - obstacleInstance.L;
       obstacleEnd = obstacleInstance.x + obstacleInstance.L;
       if x > obstacleStart && x < obstacleEnd
           index = i;
           return;
       end
    end
end

function foundLeaks = searchForLeaks(robot,leaks,corridorLength)
    foundLeaks = []; 
    for i=1:size(leaks,2)        
        leakInstance = leaks(i);
        if ~leakInstance.exists
            continue
        end
        distance = calculateDistance(leakInstance.x,robot.x,corridorLength); % abs(leakInstance.x - robot.x);
        relativeDistance = distance/corridorLength;
        %Powinno najbardziej zale�e� od odleg�o�ci a nie po r�wno
        distanceProb = -0.7*relativeDistance + 0.7;
        intesityProb = leakInstance.i * 0.1;
        velocityProb = -0.1*(robot.v/robot.vmax) + 0.1;
        damageProb = -0.1*robot.dm + 0.1;
        prob = distanceProb + intesityProb + velocityProb + damageProb;
        isDetected = rand <= prob;
        if isDetected
            foundSize = size(foundLeaks,2);
            foundLeaks(foundSize + 1) = i;
        end
    end
end

function distance = calculateDistance(x1,x2,corridorLength)
    d1 = abs(x1-x2);
    smaller = min([x1 x2]);
    bigger = max([x1 x2]);
    d2 = abs(corridorLength + smaller - bigger);
    distance = min([d1 d2]);
end

function d = getDirection(robotX,x2,corridorLength)
    d1 = abs(robotX-x2);
    smaller = min([robotX x2]);
    bigger = max([robotX x2]);
    d2 = abs(corridorLength + smaller - bigger);
    if robotX > x2 
        if d1 < d2
            d = -1;
        else
            d = 1;
        end
    else
        if d1 < d2
            d = 1;
        else
            d = -1;
        end
    end
    
end