function logicalMapObs = createObs(logicalMap, obstacle, influate_size)
mmp = false(100,100);
poses_grid1 = world2grid(binaryOccupancyMap(logicalMap), obstacle);
mmp(poses_grid1(1), poses_grid1(2)) = true;
opmap = binaryOccupancyMap(mmp);
inflate(opmap,influate_size);
mmp = getOccupancy(opmap) + logicalMap;
logicalMapObs = logical(mmp);
end