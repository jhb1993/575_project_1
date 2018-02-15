function [max_vol_sens] = max_sensor_volume(slope, const, thick, max)

y = slope*const*thick +1;

max_vol_sens = max/y;