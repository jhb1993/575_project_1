function [revenue] = SatelliteRevenue(gps_vol,camera_vol,comms_vol,science_vol,gps_vol_limit,camera_vol_limit,comms_vol_limit)

% %         Cameron's proposed valuations that I found after making these:
% %         revenue_gps = sqrt(gps_vol);        %revenue from gps ($)
% %         revenue_camera = -.0007*camera_vol^5+.186*camera_vol^4-20.494*camera_vol^3+1099.7*camera_vol^2-283658*camera_vol+280822;  %revenue from camera ($)
% %         revenue_comms = sqrt(comms_vol);

%% GPS revenues are presumed to have a logistic growth pattern, where
%%returns rapidly diminish beyond a certain level of volume (a fairly small
%%one compared to the total volume of the craft).
gps_rev=zeros(15,1);



Kgps=3.125*10^6;
%Kgps=3.125*10^7;
%K is the maximum revenue per year achievable by a GPS satellite.
%It is estimated to be slightly above the current cost to the taxpayer.
%http://nation.time.com/2012/05/21/how-much-does-gps-cost/

Agps=(Kgps-9)/9;
%Agps=(Kgps-10^2)/10^2;                
%A is a term based on K and the initial profits of any functional comms
%satellite, which we estimate to be 10,000 per year.

kgps = -1;
%kgps = -1;
%K is a scaling factor.

norm_gps_vol=gps_vol;      %Current GPS satellites are approx 10m^3
                %http://www.boeing.com/space/global-positioning-system/

gps_rev(1) = Kgps/(1+Agps*exp(kgps*norm_gps_vol));

for i=2:length(gps_rev)
    gps_rev(i)=gps_rev(1);
    %Value of the GPS array remains constant.
end
total_gps_rev=NPV(gps_rev);

%% Camera revenues are presumed to have a cubic growth pattern
%%(a larger camera is much better than a few smaller ones). 

%placeholder
camera_rev=zeros(15,1);
camera_rev(1) = 30*10^2*(12*camera_vol/(camera_vol_limit))^(4);


for i=2:length(camera_rev)
    camera_rev(i)=camera_rev(1)*exp(-i*.35);
    %Value of the camera decays according to some function. This is just a
    %placeholder for Cameron's version of that function.
end
total_camera_rev=NPV(camera_rev);

%% Comms revenues are presumed to have a logistic growth pattern, where returns
%%rapidly increase for some amount of volume (basic communications are
%%established) and then fall off as less additional benefit accrues as
%%the sensor grows past the necessary volume.
comms_rev=zeros(15,1);
Kcomms=100*10^5;
%K is the maximum revenue per year achievable by a communications satellite.
%It is estimated as approx 100 million using this website.
%https://www.sia.org/wp-content/uploads/2017/07/SIA-SSIR-2017.pdf

Acomms=(Kcomms-10^2)/10^2;                
%A is a term based on K and the initial profits of any functional comms
%satellite, which we estimate to be 1,000 per year.
kcomms = -1;
%K is a scaling factor.
norm_coms_vol=comms_vol;
%Unused

comms_rev(1) = Kcomms/(1+Acomms*exp(kcomms*norm_coms_vol));    
%Find initial value for comms revenue.
for i=2:length(comms_rev)
    comms_rev(i)=comms_rev(1)*exp(-i*.05);
    %Value of the communications decays exponentially, reaching
    %approxiamtely half its original values in 15 years.
end
total_comms_rev=NPV(comms_rev);
%% End of Comms section.

total_science_rev = science_vol^1.5*comms_vol^(1)*gps_vol^(.5)*camera_vol^.5*1000;


revenue=(total_gps_rev+total_camera_rev+total_comms_rev+total_science_rev);

% % if (revenue>10^6)
% %     disp 'check'
% % end

end

