f = figure('units','normalized','outerposition',[0 0 0.75 0.75]);
ax = axes('Parent', f);
title('Mobile Robot Motion');
set(f, 'Visible', 'on');
% filename = 'demo/fullview.gif';
% gif(filename,'overwrite',true)

% Robot mesh options are cells of the unloaded and loaded robot mesh and
% the translation between the visualized origin and the desired origin
meshOptions = {...
    {'groundvehicle.stl', [.314 0 .155], 'groundvehiclewithload.stl', [.312 0 .156]}, ...
    {'forklift.stl', [.3569 0 .297], 'forkliftwithload.stl', [.3813 0 .2893]}, ...
    };
showPaths = true;
xLim = [0,100];
yLim = [0,100];
MeshSelectionIdx = 1;
% robotViewIdx = 4;
for i = 1:30:length(out.tout)
% for i = 750:2:1000
    robotPoses = out.robotPoses(:,:,i);
    %% uncomment it when using local view
%     robotx = robotPoses(1,robotViewIdx);
%     roboty = robotPoses(2,robotViewIdx);
%     xLim = [robotx-15,robotx+15];
%     yLim = [roboty-15,roboty+15];
%%
    robotPacketStatus = out.hasPackage(i,:);
    wayPoints = out.pathes(:,:,:,i);
    ranges = out.range(:,:,i);
    angles = out.angles(:,:,i);
    awayFromGoal = out.awayFromGoal(i,:);
    distances = out.metric(:,1,i);
    showresult(robotPoses, robotPacketStatus, wayPoints, logicalObsMap, chargingStations, unloadingStations, loadingStations, obstacle, showPaths, xLim, yLim, meshOptions{MeshSelectionIdx},ranges, angles, awayFromGoal, distances);
%     gif;
end
% web(filename)