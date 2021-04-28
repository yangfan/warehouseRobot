% load the logical matrix defining the warehouse environment, which is used
% to generated path from PRM
load warehouseInitial.mat logicalMap
% assign the xy coordinates of charging stations, loading stations and
% unloading stations
chargingStations = [90,15;90,25;90,37;90,50;90,60];
loadingStations = [70,55;58,21;65,5;47,5;40,30];
unloadingStations = [20,58;20,72;10,78;30,78;20,92];
numRobots = size(chargingStations,1);
% specify the assignment of robots to targets
% In this example, robot 1 to 5 will go to loading and unloading stations 
% 1, 3, 4, 5, 2 respectively
packages = [1,3,4,5,2];
% assign the xy coordinates of charging stations
obstacle = [35,30];
% create logical matrix for the warehouse environment with obstacle
inflation_num = 4;
logicalObsMap = createOBS(logicalMap, obstacle, inflation_num);
% specify the distance determining wheter robot arrives at the goal
awayFromGoalThresh = 0.7;
% load the bus object used in the simulink
load warehouseInitial.mat RangeSensor RobotDeliverCommand RobotPackageStatus
% open the simulink model
open_system('multiRobotWarehouseVFH.slx');
% run the simulation
out = sim('multiRobotWarehouseVFH');