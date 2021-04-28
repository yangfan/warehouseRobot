function logicalObsMap = createOBS(logicalMap, obstacle, inflation_num)
mapMatrix = logicalMap;
obsMap = false(size(mapMatrix));
% obstacle = [35,30];
obs_grid1 = world2grid(binaryOccupancyMap(mapMatrix), obstacle);
obsMap(obs_grid1(1), obs_grid1(2)) = true;
opmap = binaryOccupancyMap(obsMap);
inflate(opmap,inflation_num);
logicalObsMap = logical(getOccupancy(opmap) + mapMatrix);
