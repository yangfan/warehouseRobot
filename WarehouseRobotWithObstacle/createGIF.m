f = figure('units','normalized','outerposition',[0 0 0.75 0.75]);
ax = axes('Parent', f);

set(f, 'Visible', 'on');
filename = 'demo/demo.gif';
gif(filename,'overwrite',true)

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
for i = 1:30:length(simulation.tout)
    robotPoses = simulation.Pose(i,:)';
    wayPoints = simulation.waypoints(:,:,i);
    range = simulation.ranges(i,:)';
    angle = simulation.angles(i,:)';
    VisualizeExecuteRobots(f, robotPoses, wayPoints, logicalMapObs, chargingStn, unloadingStn, loadingStn, obstacle, showPaths, xLim, yLim, meshOptions{MeshSelectionIdx}, range, angle)
    gif;
end
web(filename)