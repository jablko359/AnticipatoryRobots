robotData.n = 8;
robotData.r = 5;
robotData.space = 10;
robotData.vmax = 1;
simTime = 3600*8;
corridorLength = 5000;
obstacles = 12;
leak = 10;

sim(robotData,simTime,corridorLength,obstacles,leak,1);