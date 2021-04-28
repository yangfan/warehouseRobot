classdef RobotState < Simulink.IntEnumType
% Enumeration for the Robot's state in the warehouse.
    enumeration
        AtDock(1)
        AtLoadingStn(2)
        AtUnloadingStn(3)
    end
end
