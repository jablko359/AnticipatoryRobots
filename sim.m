function sim(robotData,simTime,corridorLength,obstaclesCount,leaksCount,step)
    [robots, leaks, obstacles, holes] = init(robotData,simTime,corridorLength,obstaclesCount,leaksCount,10);

    %  T = timer('TimerFcn', {@drawCallback, robots}, 'Period', 1);
    %  start(T);

    iterationsCount = simTime / step;
    time = 0;
    %main loop
    for j=1:iterationsCount
        time = time + step;
        activateObstacles();
        simulateRobots();
        pause(0.05);
        clf
        hold on;
        plotObstacles();
        plotRobots();
        plotLeaks();
        hold off;
    end    
    
    
    
      
    function activateObstacles()
        activeCount = 1;
        activeIndexes = [];
        for k=1:size(obstacles,2)
            obstacleInstance = obstacles(k);
            isActive = obstacleInstance.a;
            activate = obstacleInstance.t <= time;
            if (~isActive && activate)
                obstacleInstance.a = 1;
                activeIndexes(activeCount) = j;
                activeCount = activeCount +1;
            end
            obstacles(k) = obstacleInstance;
        end
        
        for x=1:size(leaks,2)
            leak = leaks(x);
            activate = (leak.t + leak.tau) <= time;
            if activate && leak.exists;
                leak.exists = 0;
                obstaclesCount = size(obstacles,2);
                leakObstacle = createObstacle(leak,corridorLength);
                index = getOverlapingObstacle(leakObstacle);
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
                    obstacles(index) = influencedObstacle;
                    %Powinno si� przed�u�y� istniej�c� przeszkod�, a w
                    %przypadku gdy wyd�u�enie jest niemo�liwe z pwoodu
                    %pokrywania si� przeszk�d, trzeba po��czy� 2 przeszkody
                end
            end
            leaks(x) = leak;
        end
    end



    function plotObstacles()
        obstaclePosition = 1;
        X = zeros(size(obstacles,2),2);
        Y = zeros(size(obstacles,2),2);
        for k=1:size(obstacles,2)
            obstacle = obstacles(k);
            X(k,1) = getPositionInCorridor(obstacle.x - obstacle.L);
            X(k,2) = getPositionInCorridor(obstacle.x + obstacle.L);
            Y(k,1) = obstaclePosition;
            Y(k,2) = obstaclePosition;
        end
        plot(X',Y');
        axis([0,corridorLength,0,2]);
        
    end

    function plotRobots()
        X = zeros(size(robots,2),1);
        Y = zeros(size(robots,2),1);
        for k=1:size(robots,2)
            rob = robots(k);
            X(k) = rob.x;
            Y(k) = 1;
        end
        scatter(X,Y);
    end

    function plotLeaks()
        %Y = zeros(size(leaks,2),1);
        for k=1:size(leaks,2)
            lk = leaks(k);
            if lk.repaired
                repairedX(k) = lk.x;
            else
                activeX(k) = lk.x;
                Y(k) = 1;
            end            
        end
        scatter(activeX,Y,'d');
        %dopisa� rysowanie zagro�e� naprawionych
    end

    function x = getPositionInCorridor(in)
        if in < 0
            x = corridorLength + in;
        elseif in < corridorLength
            x = in;
        else
            x = in - corridorLength;
        end
    end

    function simulateRobots()        
        for k=1:size(robots,2)
            simulateRobotTask(robots(k));
        end
    end

    function simulateRobotTask(robot)
        currentTask = robot.task;        
        switch currentTask
            case 'explore'
                %robot jedzie, szukaj�c przeciek�w
                if robot.a < robot.amax
                    robot.a = robot.amax;
                end
                [velocity,isDownturned] = calculateRobotVelocity(robot);
                robot.v = velocity;
                robot.isDownturned = isDownturned;
                robot.x = calculateRobotPosition(robot);
                foundLeaks = searchForLeaks(robot);
                %Znajdz najblizszy wyciek i jedz go naprawic powiadamiaj�c reszt�
                foundLeaksCount = size(foundLeaks,2);
                if foundLeaksCount > 0
                    distance = inf;
                    target = -1;
                    for k=1:foundLeaksCount
                        robotPosition = robot.x;
                        leakPosition = leaks(foundLeaks(k));
                        tmpDist = calculateDistance(leakPosition.x,robotPosition);  % abs(leakPosition - robotPosition);
                        if tmpDist < distance
                            distance = tmpDist;
                            target = leakPosition.x;
                            anyAssigned = checkAssignedAny(target);
                            if ~anyAssigned
                                robot.destination = target;
                                robot.leak = foundLeaks(k);
                                robot.task = 'move';
                            end
                        end
                    end
                end
            case 'move'
                %robot jedzie w konkretne miejsce
                epsilon = 1.5;
                robot.d = getDirection(robot.x,robot.destination);
                distance = calculateDistance(robot.x,robot.destination);
                if(distance < epsilon)
                    robot.a = 0;
                    robot.v = 0;
                    robot.x = robot.destination;
                    robot.task = 'fix';
                else
                    [velocity,isDownturned] = calculateRobotVelocity(robot);
                    oldV = robot.v;
                    robot.v  = velocity;
                    robPos = calculateRobotPosition(robot);
                    traveledDistance = calculateDistance(robPos,robot.x);
                    if distance > traveledDistance
                        robot.isDownturned = isDownturned;
                        robot.x = robPos;
                    else
                        robot.v = robot.d * (distance/step);
                        robot.x = calculateRobotPosition(robot);
                    end
                end
            case 'fix'
                leakIndex = robot.leak;
                fixingLeak = leaks(leakIndex);
                fixingLeak.n = 3;
                fixingLeak.k = fixingLeak.k + 1;
                % a co z tymi kt�re jad� do zagro�enia, bo te� je wykry�y?
                if fixingLeak.n > fixingLeak.k
                    robotsInRange = getRobotsInRange(robot);
                    for k=1:size(robotsInRange,2)
                        robotInstance = robots(robotsInRange(k));
                        robotInstance.task = 'move';
                        robotInstance.destination = fixingLeak.x;
                        robotInstance.leak = leakIndex;                        
                        robots(robotInstance.n) = robotInstance;
                    end
                else                                        
                    fixingLeak.repairStatus = fixingLeak.repairStatus + 0.05 * (1 - fixingLeak.i);        
                    
                end
                if fixingLeak.repairStatus >= 1
                    fixingLeak.repaired = 1;
                    fixingLeak.exists = 0;
                    robot.leak = -1;
                    robot.task = 'explore';
                    for i=size(robots,2)
                        robotInstance = robots(i);
                        if robotInstance.leak == leakIndex
                            robotInstance.leak = -1;
                            robotInstance.task = 'explore';
                            robots(robotInstance.n) = robotInstance;
                        end
                    end
                end
                leaks(leakIndex) = fixingLeak;
                %robot stoi i usuwa wyciek lub przeszkode.
        end
        %1. Wyznacz zadanie dla robota ?
        %2. Je�li ma gdzie� jecha�, oblicz odleg�o��, oraz kierunek
        %3. Na podstawie odleg�o�ci, ustaw przy�pieszenie robota od 0 do amax
        %4. Oblicz pr�dko�� robota
        %5. Oblicz po�o�enie robota
        robotIndex = robot.n;
        robots(robotIndex) = robot;
    end

    function count = countMovingTowards(robots, index)
        count = 0;
        for k = 1:size(robots,2)
            robotInstance = robots(k);
            if strcmp(robotInstance.task,'move')&& robotInstance.task == index
                count = count + 1;
            end
        end
    end

    function robotIndexes = getRobotsInRange(robot)
        robotIndexes =[];
        for k=1:size(robots,2)
            participant = robots(k);
            canCommunicate = checkRobotCommunication(robot.x, participant.x);
            if canCommunicate
                indexSize = size(robotIndexes,2);
                robotIndexes(indexSize + 1) = k;
            end
        end
    end

    function canCommunicate = checkRobotCommunication(x,y)
        distance = calculateDistance(x,y);
        maxDistance = 200;
        canCommunicate = 1;
        if distance > maxDistance
            canCommunicate = 0;
            return;
        end
        for k=1:size(holes,2)
            hole = holes(k);
            start = hole.x - hole.L;
            start = calculatePosition(start);
            stop = hole.x + hole.L;
            stop = calculatePosition(stop);
            if (x > start && x < stop) || (y > start && y < stop)
                canCommunicate = 0;
            end
        end
        if distance > maxDistance
            canCommunicate = 0;
        end
    end


    function pos = calculatePosition(x)
        if x > corridorLength
            pos = x - corridorLength;
        elseif x < 0
            pos = corridorLength - x;
        else
            pos = x;
        end
    end

    function [v,isDownturned] = calculateRobotVelocity(robot)
        
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
        obstacleIndex = getObstacleByX(robot.x);
        if obstacleIndex ~= -1
            isDownturned = 1;
            %powinoo zale�e� od s
            downturn = rand * 0.1;
            v = v * (1 - downturn);
        end
        %Robota moga spowolnic uszkodzenia i przeszkody
    end

    function x = calculateRobotPosition(robot)
        pos = robot.x + step * robot.v;
        x = getPositionInCorridor(pos);
    end

    function index = getOverlapingObstacle(obstacleInstance)
        index = -1;
        length = obstacleInstance.L;
        pos = obstacleInstance.x;
        for k=1:size(obstacles,2)
            obstacleInstance = obstacles(k);
            start = pos - length;
            endd = pos + length;
            obstacleStart = obstacleInstance.x - obstacleInstance.L;
            obstacleEnd = obstacleInstance.x + obstacleInstance.L;
            leftContains = (obstacleStart > start) && (obstacleStart < endd);
            rightContains = (obstacleEnd > start) && (obstacleEnd < endd);
            if leftContains || rightContains
                index = k;
                return;
            end
        end
    end

    function index = getObstacleByX(x)
        index = -1;
        for k=1:size(obstacles,2)
            obstacleInstance = obstacles(k);
            obstacleStart = obstacleInstance.x - obstacleInstance.L;
            obstacleEnd = obstacleInstance.x + obstacleInstance.L;
            if x > obstacleStart && x < obstacleEnd
                index = k;
                return;
            end
        end
    end

    function foundLeaks = searchForLeaks(robot)
        foundLeaks = [];
        for k=1:size(leaks,2)
            leakInstance = leaks(k);
            if ~leakInstance.exists && ~leakInstance.repaired
                continue
            end
            distance = calculateDistance(leakInstance.x,robot.x); % abs(leakInstance.x - robot.x);
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
                foundLeaks(foundSize + 1) = k;
            end
        end
    end

    function distance = calculateDistance(x1,x2)
        d1 = abs(x1-x2);
        smaller = min([x1 x2]);
        bigger = max([x1 x2]);
        d2 = abs(corridorLength + smaller - bigger);
        distance = min([d1 d2]);
    end

    function d = getDirection(robotX,x2)
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

    function isAssigned = checkAssignedAny(target)
        isAssigned = 0;
        for k=1:size(robots,2)
            rob = robots(k);
            if rob.destination == target
                isAssigned = 1;
                return;
            end
        end
    end
%     hold on;
%     plotObstacles(obstacles,corridorLength);
%     plotRobots(robots);
%     plotLeaks(leaks);
end





