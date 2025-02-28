%% 2rx 1tx img sbr 
clear; clc; close all;

% campus
viewer = siteviewer("Buildings", "hshl.osm", "Basemap", "satellite");

% Tx
tx = txsite("Name", "Campus Tx", ...
    "Latitude", 51.673, "Longitude", 8.3621, ...
    "AntennaHeight", 10, ...  
    "TransmitterFrequency", 2.5e9, ... 
    "TransmitterPower", 5); 

show(tx); 

% Rx1 (City Center)
rx1 = rxsite("Name", "City Center Rx", ...
    "Latitude", 51.6737, "Longitude", 8.3448, ...
    "AntennaHeight", 1.5); 

show(rx1);

% Rx2 (Campus)
rx2 = rxsite("Name", "Campus Rx", ...
    "Latitude", 51.6745, "Longitude", 8.3632, ...
    "AntennaHeight", 10); 

show(rx2);

% SBR 
pm_sbr = propagationModel("raytracing", ...
    "Method", "sbr", ... 
    "MaxNumReflections", 2, ... 
    "MaxNumDiffractions", 1, ... 
    "BuildingsMaterial", "brick", ... 
    "TerrainMaterial", "concrete", ... 
    "AngularSeparation", "low"); 

% Display sbr for Rx1
disp("Performing Ray Tracing (SBR Method) for Rx1...");
raytrace(tx, rx1, pm_sbr, "Type", "pathloss"); 

% Display sbr for Rx2
disp("Performing Ray Tracing (SBR Method) for Rx2...");
raytrace(tx, rx2, pm_sbr, "Type", "pathloss"); 

% LOS for Rx1
disp("Checking Line of Sight (LOS) for Rx1...");
los_status_rx1 = los(tx, rx1); 
if los_status_rx1
    disp("LOS Available for Rx1: Direct path exists.");
else
    disp("LOS Blocked for Rx1: Relying on reflections/diffractions.");
end

% LOS for Rx2
disp("Checking Line of Sight (LOS) for Rx2...");
los_status_rx2 = los(tx, rx2); 
if los_status_rx2
    disp("LOS Available for Rx2: Direct path exists.");
else
    disp("LOS Blocked for Rx2: Relying on reflections/diffractions.");
end

% Path Loss for Rx1
disp("Calculating Path Loss for Rx1...");
rays_rx1 = raytrace(tx, rx1, pm_sbr, "Type", "pathloss");
if isempty(rays_rx1{1})
    disp("No rays detected for Rx1.");
else
    for p = 1:length(rays_rx1{1})
        fprintf("Rx1 - Path %d: Path Loss = %.2f dB\n", p, rays_rx1{1}(p).PathLoss);
    end
end

% Path Loss for Rx2
disp("Calculating Path Loss for Rx2...");
rays_rx2 = raytrace(tx, rx2, pm_sbr, "Type", "pathloss");
if isempty(rays_rx2{1})
    disp("No rays detected for Rx2.");
else
    for p = 1:length(rays_rx2{1})
        fprintf("Rx2 - Path %d: Path Loss = %.2f dB\n", p, rays_rx2{1}(p).PathLoss);
    end
end

% Coverage 
disp("Computing Coverage Map with Optimized Parameters...");

% Coverage estimation
pm_coverage = propagationModel("closein"); 

coverage(tx, pm_coverage, ...
    'SignalStrengths', -100:10:-60, ... 
    'MaxRange', 1000, ... 
    'Resolution', 20); 

disp("Optimized Coverage Simulation Complete.");