function VisualizeExecuteRobots(f, robotPoses, wayPoints, logicalMap, startLocations, goalLocations, loadingStations, ObstacleLocation, showPaths, xLim, yLim, robotMeshes, range, angle)

%% Initilize working variables
map = binaryOccupancyMap(logicalMap);
numRobots = size(robotPoses, 2);
numLoad = size(loadingStations, 1);
numGoals = size(goalLocations, 1);
numStarts = size(startLocations, 1);

%% Extract data from inputs

% Construct translation from state
xyz = [robotPoses(1:2,:); zeros(1,numRobots)]; % 2-D so z is zero

% Create quaternion from rotation state
theta = robotPoses(3,:);

%% Visualize Results
ax = f.CurrentAxes;
show(map,'Parent', ax);
light
hold(ax, 'on');
plotTransforms([goalLocations, zeros(numGoals, 1)], eul2quat(zeros(numGoals, 3)), 'MeshFilePath', 'exampleWarehouseBlockExecuteTasks.stl', 'MeshColor', 'g', 'Parent', ax);
plotTransforms([loadingStations, zeros(numLoad, 1)], eul2quat(zeros(numLoad, 3)), 'MeshFilePath', 'exampleWarehouseBlockExecuteTasks.stl', 'MeshColor', 'b', 'Parent', ax);
plotTransforms([startLocations, zeros(numStarts, 1)], eul2quat(zeros(numLoad, 3)), 'MeshFilePath', 'exampleWarehouseBlockExecuteTasks.stl', 'MeshColor', 'k', 'Parent', ax);
text(loadingStations(:, 1), loadingStations(:, 2), 2, 'loadingStn', 'FontSize', 12, 'Color', 'b');
text(goalLocations(:, 1), goalLocations(:, 2), ones(numGoals, 1)* 2, 'unloadingStn', 'FontSize', 12, 'Color', 'b');
text(startLocations(:, 1), startLocations(:, 2), ones(numStarts, 1)* 2, 'chargingStn', 'FontSize', 12, 'Color', 'b');

text(ObstacleLocation(1)-10, ObstacleLocation(2)-8, 2, 'Obstacle', 'FontSize', 12, 'Color', 'b');

for robotIdx = 1:numRobots
    
    % Extract the information for the ith robot
    robotQuaternion = eul2quat([0 0 theta(robotIdx)], 'xyz');
    worldToRobotTForm = [axang2rotm([0 0 1 theta(robotIdx)]) xyz(:,robotIdx); 0 0 0 1];
    robotPathWaypoints = wayPoints(:,:,robotIdx);
    
    robotMesh = robotMeshes{1};
    meshTranslation = robotMeshes{2};
    robotTform = worldToRobotTForm*trvec2tform(meshTranslation);
    
    % Plot the robot
    plotTransforms(robotTform(1:3,4)', robotQuaternion, 'MeshFilePath', robotMesh, 'Parent', ax);
    
    % Plot the path
    if showPaths
        plot(robotPathWaypoints(:,1), robotPathWaypoints(:,2), 'x-');
    end
    
    % Plot the end point of the range sensor
    u = robotPoses(:,robotIdx);
    scan = lidarScan(range, angle);
    scan = transformScan(scan, u);
    plot(scan.Cartesian(:, 1), scan.Cartesian(:, 2), 'rX');
end

% Select the view
xlim(xLim');
ylim(yLim');
zlim([0 2]);
title('Warehouse Robot');
drawnow;
hold(ax, 'off');
end
