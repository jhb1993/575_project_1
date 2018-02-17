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

         % gps, cam, comms
    x0 = [2;2;2;2];
    ub = [60;60;60;60];
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
        science_vol = x(4);
               
        
        %other analysis variables
        gps_init_cost = 250000;     %analogous to manufacture cost ($/m^3)
        camera_init_cost = 400000;  %analogous to manufacture cost ($/m^3)
        comms_init_cost = 300000;   %analogous to manufacture cost ($/m^3)
        panel_init_cost = 100000;   %This value has not been checked for rationality
        
        %payload fairing properties
        r_fairing = 4.572/2;    %radius from the Atlas V Payload fairing
        h_cylinder = 7.631;     %height from the Atlas V Payload fairing
        h_cone = 5.296;         %height from the Atlas V Payload fairing
        
        
        %% Placeholders:
         max_volume=pi*r_fairing^2*h_cylinder+pi/3*r_fairing^2*h_cone; %154.26 m^3
         max_weight=8900; %Max payload cap from wiki (kg)
         max_cost=10^8;
        %%
		
        panel_thick = .05;       %Panel thickness in, guess (m).
        %This value seems reasonable after looking at https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19710028154.pdf
        
        panel_const = .00338;   %Panel conversion from Hubble (m2/W) 
        slope_power_cam = 4000; %W/m^3
        slope_power_comm = 1500; %W/m^3
        slope_power_gps = 750; %W/m^3      
        
        %analysis functions
        
        %power requirements
        power_camera = slope_power_cam*camera_vol;                    
        power_comms = slope_power_comm*comms_vol;
        power_gps = slope_power_gps*gps_vol;
        total_power = power_camera+power_comms+power_gps;
        panel_vol = total_power*panel_thick*panel_const;
        
        total_vol=gps_vol+camera_vol+comms_vol+panel_vol+science_vol;

        gps_density = 163;      %(kg/m^3) http://www.boeing.com/space/global-positioning-system/
        camera_density = 170;   %(kg/m^3) Hubble Space telescope weighs 11000 kilos and is approx. 13.3 m by 5 m.
        comms_density = 160;    %(kg/m^3) Inmarsat-4 F3 guesses from https://www.satbeams.com/satellites?norad=33278 and pictures
        panel_density = 8;     %(kg/m^3) http://sunmetrix.com/is-my-roof-suitable-for-solar-panels-and-what-is-the-weight-of-a-solar-panel/
        science_density = 100;    % a bald guess               
                        %This source is for roof-based panels, which will
                        %probably weigh a bit more than space panels.
        superstructure_density = 0; %Presumably, superstructure weight has
        %already been subtracted from payload weight. TBN
        
        
        %%analysis functions
        
        %%I think that the revenue calculations will be best done in a
        %%single function; some of them may be interdependent. For
        %%instance, I'm very concerned with how we will allocate power to
        %%the different modules. It seems like that could get complicated.
        %%TBN
                
        max_Vcam = max_sensor_volume(slope_power_cam, panel_const, panel_thick, max_volume);
        max_Vcomms = max_sensor_volume(slope_power_comm, panel_const, panel_thick, max_volume);
        max_Vgps = max_sensor_volume(slope_power_gps, panel_const, panel_thick, max_volume);

        revenue_total = SatelliteRevenue(gps_vol,camera_vol,comms_vol,science_vol,max_Vgps,max_Vcam,max_Vcomms)
        
        gps_weight = gps_vol*gps_density;
        camera_weight = camera_vol*camera_density;
        comms_weight = comms_vol*comms_density;
        panel_weight = panel_vol*panel_density; 
        science_weight = science_vol*science_density;
        structure_weight = total_vol*superstructure_density;
        total_weight=gps_weight+camera_weight+comms_weight+panel_weight...
            +science_weight+structure_weight;
        
        costs_comms = comms_init_cost*comms_vol;
        costs_gps = gps_init_cost*gps_vol;
        costs_camera=camera_init_cost*camera_vol;
        costs_panel = panel_init_cost*panel_vol;
        costs_fuel = RocketCosts(total_weight); 
        costs_total=costs_comms+costs_gps+costs_camera+costs_panel+costs_fuel;
        %Does science have an initial cost? I think no
        
        
        net_profit=revenue_total-costs_total;

        
        %objective function
        f =  -net_profit; %Maximize
               
        %inequality constraints: c<=0
        
        %1. Total volume must be below some maximum value;
        %2. Total weight must be below some maximum value;
        %3. Total costs must be below some maximum value;
        %4. Total power consumption must be below power generated
        
        c = zeros(3,1);
        c(1)=-max_volume+total_vol;
        c(2)=-max_weight+total_weight;
        c(3)=-max_cost+costs_total;     
        c
        total_weight
        costs_total
        %equality constraints
        ceq = [];

    end

    % ------------Call fmincon------------
    options = optimoptions(@fmincon, 'display', 'iter-detailed');
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);
    
    xopt
    fopt
    

    objcon(xopt)
    % ------------Separate obj/con (do not change)------------
    function [f] = obj(x)
            [f, ~, ~] = objcon(x);
    end
    function [c, ceq] = con(x)
            [~, c, ceq] = objcon(x);
    end
end