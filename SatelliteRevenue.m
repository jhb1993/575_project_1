function [revenue] = SatelliteRevenue(gps_vol,camera_vol,comms_vol,panel_vol,total_vol_limit)


gps_rev = 500-500^(-gps_vol/total_vol_limit);           %Sale value of data
gps_energy = gps_vol/total_vol_limit*1.3;               %Power cost of module

camera_rev = 600-600^(-camera_vol/total_vol_limit);
camera_energy = gps_vol/total_vol_limit*1.5;

comms_rev = 900-900^(-comms_vol/total_vol_limit);
comms_energy = gps_vol/total_vol_limit*3;               

energy_use = gps_energy+camera_energy+comms_energy;

panel_energy=panel_vol/total_vol_limit*10;

if (energy_use>panel_energy)
    %If the satellite uses too much energy, its data becomes rapidly less
    %reliable, and cannot be sold as well. This penalty cost models this 
    %interaction.
    overuse_penalty = (energy_use-panel_energy)*1000;  
else
    overuse_penalty=0;
end

revenue=gps_rev+camera_rev+comms_rev-overuse_penalty;

end

