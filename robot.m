classdef robot
    properties
        n   %id
        x   %position in Corridor
        d   %direction
        v=0   %speed
        a=0   %acceleration
        vmax %current vmax reduced by obstacles
        dm=0  %damage(0-100)?              
    end
end