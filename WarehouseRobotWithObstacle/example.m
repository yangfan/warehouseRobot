% load logical map of the environment, xy coordinates of stations
load modelInitial
% create logical map of the environment with obstacle
influate_size = 4;
logicalMapObs = createObs(logicalMap, obstacle, influate_size);
% open the simulink model
open_system('warehouseTasksRobot')
simulation = sim('warehouseTasksRobot.slx');