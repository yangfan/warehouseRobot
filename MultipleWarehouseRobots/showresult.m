function showresult(robotPoses, robotPacketStatuses, wayPoints, logicalMap, StartLocations, goalLocations, loadingStations, ObstacleLocation, showPaths, xLim, yLim, robotMeshes, ranges, angles, awayFromGoal, distances)

%% Initilize working variables
map = binaryOccupancyMap(logicalMap);
numRobots = size(robotPoses, 2);
numLoad = size(loadingStations, 1);
numGoals = size(goalLocations, 1);

%% Extract data from inputs

% Construct translation from state
xyz = [robotPoses(1:2,:); zeros(1,numRobots)]; % 2-D so z is zero

% Create quaternion from rotation state
theta = robotPoses(3,:);

%% Visualize Results
delete(findall(gcf,'type','annotation'));
show(map);
light
hold on;
title('Warehouse robots');
ax = gca;
plotTransforms([goalLocations, zeros(numGoals, 1)], eul2quat(zeros(numGoals, 3)), 'MeshFilePath', 'exampleWarehouseBlock.stl', 'MeshColor', 'g', 'Parent', ax);
plotTransforms([loadingStations, zeros(numLoad, 1)], eul2quat(zeros(numLoad, 3)), 'MeshFilePath', 'exampleWarehouseBlock.stl', 'MeshColor', 'b', 'Parent', ax);

text(ObstacleLocation(1)-10, ObstacleLocation(2)-8, 2, 'Obstacle', 'FontSize', 10, 'Color', 'b');
% dim = [0.2 0.5 0.3 0.3];
% str = [];
for robotIdx = 1:numRobots
    % Print travelled distances
%     str =  [str, ['r1: ' num2str(distances(robotIdx))] ];
    % Print robot index
    text(robotPoses(1,robotIdx), robotPoses(2,robotIdx), 2, ['r' num2str(robotIdx)], 'FontSize', 10, 'Color', 'r');
    % Print station index
    text(StartLocations(robotIdx, 1), StartLocations(robotIdx, 2), 2, ['ChargStn' num2str(robotIdx)], 'FontSize', 10, 'Color', 'b');
    text(loadingStations(robotIdx, 1), loadingStations(robotIdx, 2), 2, ['LoadStn' num2str(robotIdx)], 'FontSize', 10, 'Color', 'b');
    text(goalLocations(robotIdx, 1), goalLocations(robotIdx, 2), 2, ['UnloadStn' num2str(robotIdx)], 'FontSize', 10, 'Color', 'b');
    
    % Extract the information for the ith robot
    robotQuaternion = eul2quat([0 0 theta(robotIdx)], 'xyz');
    worldToRobotTForm = [axang2rotm([0 0 1 theta(robotIdx)]) xyz(:,robotIdx); 0 0 0 1];
    robotPathWaypoints = wayPoints(:,:,robotIdx);
    robotHasPacket = robotPacketStatuses(robotIdx);
    
    % Get the robot mesh and offset between the mesh origin and robot origin
    if ~robotHasPacket
        robotMesh = robotMeshes{1};
        meshTranslation = robotMeshes{2};
    else
        robotMesh = robotMeshes{3};
        meshTranslation = robotMeshes{4};
    end
    robotTform = worldToRobotTForm*trvec2tform(meshTranslation);
    
    % Plot the robot
    plotTransforms(robotTform(1:3,4)', robotQuaternion, 'MeshFilePath', robotMesh, 'Parent', ax);
    
    % Plot the path
    if showPaths
        plot(robotPathWaypoints(:,1), robotPathWaypoints(:,2), 'x-');
    end
    
    % Plot range sensor endpoints
    if awayFromGoal(robotIdx)
        u = robotPoses(:,robotIdx);
        range = ranges(:,robotIdx);
        angle = angles(:,robotIdx);
        scan = lidarScan(range, angle);
        scan = transformScan(scan, u);
        plot(scan.Cartesian(:, 1), scan.Cartesian(:, 2), 'rX');
    end
    
end

% annotation('textbox',dim,'String',str,'FitBoxToText','on');


% Select the view
xlim(xLim');
ylim(yLim');
zlim([0 2]);
%%
% Create table
% RobotIndex = {'r1','r2','r3','r4','r5'}; 
% TargetStation = 1:5;
% T = table(RobotIndex',distances,TargetStation','VariableNames',{'RobotIndex','distance','TargetStation'}); 
% % plot some data in the main axes
% % Convert Table to cell to char array
% tableCell = [T.Properties.VariableNames; table2cell(T)]; 
% tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false); 
% tableChar = splitapply(@strjoin,pad(tableCell),[1;2;3;4;5;6]);
% % Add axes (not visible) & text (use a fixed width font)
% text(40,150,tableChar,'VerticalAlignment','Top','HorizontalAlignment','Left','FontName','Consolas');
%%
    
drawnow;
hold off;

end
