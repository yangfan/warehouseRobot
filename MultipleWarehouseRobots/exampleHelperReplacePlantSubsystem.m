function exampleHelperReplacePlantSubsystem(plantSubsystem, numRobots)
% This function is for internal use only and may be removed in a future
% release.
%replacePlantSubsystem Replace subsystem with one that has the specified number of robots

%   Copyright 2019 The MathWorks, Inc.

% Initialize constants
plantBlockSrc = 'robotmobilelib/Differential Drive Kinematic Model';
selectorBlockSrc = 'simulink/Signal Routing/Selector';

% Use a helper function to get full block names including the modelName
fullBlkName = @(blockNameVar)([plantSubsystem '/' blockNameVar]);

validateattributes(plantSubsystem, {'char'}, {'nonempty', 'row'}, 'createPlantSubsystem', 'plantSubsystem');
validateattributes(numRobots, {'numeric'}, {'nonempty'}, 'createPlantSubsystem', 'numRobots');


% Remove all blocks except inport and outport
inBlock = 'velocityCommands';
outBlock = 'currentPoses';
clearSubsystemContent(plantSubsystem, {fullBlkName(inBlock), fullBlkName(outBlock)});

% Move inport and outport blocks to positions that will look nice
set_param(fullBlkName(inBlock), 'position', [0 12 30 28]);
set_param(fullBlkName(outBlock), 'position', [600 212 630 228]);

% Add the vector concatenate block. This doesn't scale by size, but this
% sizing looks nice with the default 5-robot configuration.
concatenateBlock = 'Concatenate Signals';
add_block('simulink/Signal Routing/Vector Concatenate', fullBlkName(concatenateBlock), 'position', [500 -30 520 470]);
set_param(fullBlkName(concatenateBlock), 'NumInputs', num2str(numRobots))
set_param(fullBlkName(concatenateBlock), 'Mode', 'Multidimensional array');
set_param(fullBlkName(concatenateBlock), 'ConcatenateDimension', '2');

% Connect the vector concatenate to the outport block
add_line(plantSubsystem, [concatenateBlock '/1'], [outBlock '/1']);


% Add the specified number of kinematic models and connect them
for i = 1:numRobots
    
    % Add two selector blocks to get position velocity and heading angular
    % velocity
    selector1Block = ['VelocitySelector ' num2str(i)];
    add_block(selectorBlockSrc, fullBlkName(selector1Block), 'position', [100 8+(i-1)*100 150 32+(i-1)*100]);
    configureSelectBlock(fullBlkName(selector1Block), 1, i);
    add_line(plantSubsystem, [inBlock '/1'], [selector1Block '/1']);
    
    selector2Block = ['OmegaSelector ' num2str(i)];
    add_block(selectorBlockSrc, fullBlkName(selector2Block), 'position', [100 48+(i-1)*100 150 72+(i-1)*100]);
    configureSelectBlock(fullBlkName(selector2Block), 2, i);
    add_line(plantSubsystem, [inBlock '/1'], [selector2Block '/1']);
    
    % Add the plant block and configure the parameters
    plantBlock = ['Differential-Drive Robot ' num2str(i)];
    add_block(plantBlockSrc, fullBlkName(plantBlock), 'position', [200 (i-1)*100 350 80+(i-1)*100]);
    set_param(fullBlkName(plantBlock), 'VehicleInputs', 'Vehicle Speed & Heading Angular Velocity', ...
        'WheelRadius', '0.1', ...
        'TrackWidth', '0.2', ...
        'InitialState', sprintf('[chargingStations(%i, :), 0]''', i));
    
    % Connect the plant to the two selector blocks
    add_line(plantSubsystem, [selector1Block '/1'], [plantBlock '/1']);
    add_line(plantSubsystem, [selector2Block '/1'], [plantBlock '/2']);
    
    % Connect the plant to the vector concatenate block
    add_line(plantSubsystem, [plantBlock '/1'], [concatenateBlock '/' num2str(i)]);
end

% Add terminators for the unconnnected outputs
addterms(plantSubsystem);
    
% Can try to auto-clean up, but this spreads things out a bit
% Simulink.BlockDiagram.arrangeSystem(plantSubsystem);

end

function configureSelectBlock(blk, idx1, idx2)

    % Set all the parameters at once to avoid conflicts
    set_param(blk, 'NumberOfDimensions', '2', ...
        'IndexOptions', 'Index vector (dialog),Index vector (dialog)', ...
        'Indices', sprintf('%i,%i', idx1, idx2));
end

function clearSubsystemContent(subsys, blksToKeep)
%clearSubsystemContent Clear all the contents except the specified blocks

% Get the handles to everything in the system
allSubsystemBlocks = find_system(subsys, 'SearchDepth', 1);

% Remove the handles of all the blocks to keep from the list
blksToKeep = [{subsys} blksToKeep];
blksToDelete = setdiff(allSubsystemBlocks, blksToKeep);
cellfun(@(x) delete_block(x), blksToDelete);

% Clear all the unconnected lines
delete_line(find_system(subsys, 'FindAll', 'on', 'Type', 'line', 'Connected', 'off'));
end