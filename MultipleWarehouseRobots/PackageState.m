classdef PackageState < Simulink.IntEnumType
% Enumeration for the Robot's state in the warehouse.
    enumeration
        Unassigned(1)
        InProgress(2)
        Delivered(3)
    end
end
