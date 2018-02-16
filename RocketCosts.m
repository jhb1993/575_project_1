function [cost] = RocketCosts(total_weight)
%This function performs the rocket equation analysis to determine how much
%fuel is needed to get to orbit. It returns the total cost of the fuel.

%Documentation to follow.

    liq_h_cost = 4;          %cost for liquid hydrogen fuel ($/kg)
    liq_oxy_cost = 0.20;     %cost for liquid oxygen fuel ($/kg)
    h_oxy_ratio = 5.5;       %Hydrogen/oxygen ratio.
    i_sp = 450;              %specific impulse of fuel (s)
    delta_v_leo = 9800;      %delta v from Earth to LEO orbit (m/s)
    delta_v_geo = 4240;      %delta v from LEO to GEO orbit (m/s)
    mf = 46697+total_weight; %dry mass of Atlas V rocket and satellite(kg)
    g = 9.80665;             %acc. due to gravity at Earth's surface
    ve = i_sp*g;             %exhaust velocity of propellant
        
    mo = mf*exp(delta_v_leo/ve)*exp(delta_v_geo/ve);    %total mass of rocket with propellant   
    mass_propellant = mo-mf;
    
    mass_liq_oxy = mass_propellant/(h_oxy_ratio+1);
    mass_liq_h = h_oxy_ratio*mass_liq_oxy;
    
    cost=liq_h_cost*mass_liq_h + liq_oxy_cost*mass_liq_oxy;  

end

