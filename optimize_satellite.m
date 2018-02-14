%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file was created by first copying/pasting the 'fmincon'
% optimizing template that Dr. Parkinson provided us. --JB
%
% Our design variables are expressed in terms of volumes. We have made the
% simplifying assumption that a higher volume means better quality and more
% capacity for revenue. --JB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xopt, fopt, exitflag, output] = optimize_satellite()

    % ------------Starting point and bounds------------
    
    % Design Variables:
    %   gps_vol- size of GPS equipment (m^3)
    %   camera_vol- size of camera equipment (m^3)
    %   comms_vol- size of communications equipment (m^3)
    %   panel_vol- size of solar panels (m^3)
    
    x0 = [2;2;2;2];
    ub = [3;3;3;3];
    lb = [1;1;1;1];

    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % ------------Objective and Non-linear Constraints------------
    function [f, c, ceq] = objcon(x)
        
        %set design variable values
        gps_vol = x(1);
        camera_vol = x(2);
        comms_vol = x(3);
        panel_vol = x(4);
        
        %other analysis variables
        gps_init_cost = 25;     %analogous to manufacture cost ($/m^3)
        camera_init_cost = 40;  %analogous to manufacture cost ($/m^3)
        comms_init_cost = 30;   %analogous to manufacture cost ($/m^3)
        liq_h_cost = 4;         %cost for liquid hydrogen fuel ($/kg)
        liq_oxy_cost = 0.20;    %cost for liquid oxygen fuel ($/kg)
        h_oxy_ratio = 5.5;      %ratio for 
        panel_thick = .5;       %Panel thickness in, guess (m)
        panel_const = .00338;   %Panel converstion from huble (m2/W) 
        
        
        
        %analysis functions
        revenue_gps = sqrt(gps_vol);        %revenue from gps ($)
        revenue_camera = -.0007*camera_vol^5+.186*camera_vol^4-20.494*camera_vol^3+1099.7*camera_vol^2-283658*camera_vol+280822;  %revenue from camera ($)
        revenue_comms = sqrt(comms_vol);    %revenue from comms ($)
        
        revenue_total = revenue_gps + revenue_camera + revenue_comms;
        
        power_gen = panel_vol/(panel_thick*panel_const); %Power generated from Solar Panels (W)
        
        %objective function
        f = revenue_total; %Maximize
        
        %inequality constraints
        c = [];
        c(1) = power_cam + power_gps + power_comms - power_gen;     %Total Power <= Power_gen;
        
        %equality constraints
        ceq = [];

    end

    % ------------Call fmincon------------
    options = optimoptions(@fmincon, 'display', 'iter-detailed');
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);
    
    
    % ------------Separate obj/con (do not change)------------
    function [f] = obj(x)
            [f, ~, ~] = objcon(x);
    end
    function [c, ceq] = con(x)
            [~, c, ceq] = objcon(x);
    end
end