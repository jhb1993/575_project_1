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
         % gps, cam, comms, panel
    x0 = [10;50;15;20];
    ub = [50;100;150;40];
    lb = [5;5;5;2];

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
        total_vol=gps_vol+camera_vol+comms_vol+panel_vol;
        
        %other analysis variables
        gps_init_cost = 25;     %analogous to manufacture cost ($/m^3)
        camera_init_cost = 40;  %analogous to manufacture cost ($/m^3)
        comms_init_cost = 30;   %analogous to manufacture cost ($/m^3)
        panel_init_cost = 10;   %This value has not been checked for rationality
        
        %payload fairing properties
        r_fairing = 4.572/2;    %From the Atlas V Payload fairing
        h_cylinder = 7.631;     %From the Atlas V Payload fairing
        h_cone = 5.296;         %From the Atlas V Payload fairing
        
        
        %% Placeholders:
         max_volume=pi*r_fairing^2*h_cylinder+pi/3*r_fairing^2*h_cone;
         max_weight=8900; %Max payload cap from wiki (kg)
         max_cost=10^6;
        %%
		
        panel_thick = .05;       %Panel thickness in, guess (m).
        %This value seems reasonable after looking at https://ntrs.nasa.gov/archive/nasa/casi.ntrs.nasa.gov/19710028154.pdf
        
        panel_const = .00338;   %Panel converstion from Hubble (m2/W) 
        
        
        
        %analysis functions
        
        gps_density = 240;
        camera_density = 285; %(kg/m^3) Hubble Space telescope weighs 11000 kilos and is approx. 13.3 m by 4 m.
        comms_density = 200;
        panel_density = 100; 
        superstructure_density = 100; %Presumably, the volume of superstructure
        %necessary will depend on the volume of the cargo we are
        %transporting. This will be expressed as a density of
        %superstructure per volume. TBN
        
        
        %%analysis functions
        
        %%I think that the revenue calculations will be best done in a
        %%single function; some of them may be interdependent. For
        %%instance, I'm very concerned with how we will allocate power to
        %%the different modules. It seems like that could get complicated.
        %%TBN
        
        %Placeholders:
        gps_vol_limit=1.542626329854172e+02/3;
        camera_vol_limit=1.542626329854172e+02/3;
        comms_vol_limit=1.542626329854172e+02/3;

        revenue_total = SatelliteRevenue(gps_vol,camera_vol,comms_vol,gps_vol_limit,camera_vol_limit,comms_vol_limit);
        
        gps_weight = gps_vol*gps_density;
        camera_weight = camera_vol*camera_density;
        comms_weight = comms_vol*comms_density;
        panel_weight = panel_vol*panel_density; 
        structure_weight = total_vol*superstructure_density;
        total_weight=gps_weight+camera_weight+comms_weight+panel_weight...
            +structure_weight;
        
        costs_comms = comms_init_cost*comms_vol;
        costs_gps = gps_init_cost*gps_vol;
        costs_camera=camera_init_cost*camera_vol;
        costs_panel = panel_init_cost*panel_vol;
        costs_fuel = RocketCosts(total_weight); %JHB mentioned he had this.
        costs_total=costs_comms+costs_gps+costs_camera+costs_panel+costs_fuel;
        
        net_profit=revenue_total-costs_total;
        
        
        
        power_camera = 2*camera_vol;                    
        power_comms = .0005*comms_vol^3-.0497*comms_vol^2+1.5122*comms_vol - .981;
        power_gps = -.0018*gps_vol^3+.0703*gps_vol^2-.1371*gps_vol+.8088;
        power_gen = panel_vol/(panel_thick*panel_const); %Power generated from Solar Panels (W)
        
        %objective function
        f =  -net_profit; %Maximize
               
        %inequality constraints: c<=0
        
        %1. Total volume must be below some maximum value;
        %2. Total weight must be below some maximum value;
        %3. Total costs must be below some maximum value;
        
        c = zeros(3,1);
        c(1)=-max_volume+total_vol;
        c(2)=-max_weight+total_weight;
        c(3)=-max_cost+costs_total;
        c(4)= power_camera+power_comms+power_gps-power_gen; % Power consumed <= power gen
        
%         f = revenue_total; 
        
        
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