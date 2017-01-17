classdef robot
    properties
        n   %id
        x   %position in Corridor
        d   %direction
        v=0   %speed
        a=0   %acceleration        
        vmax %current vmax reduced by obstacles
        amax %current amax reduced by damage level
        dm=0  %damage(0-100)?             
        task='explore' %current robot task (explore,move,fix)        
        isDownturned = 0 %whether robot is downturned by obstacle       
        destination = -1        
    end     
end