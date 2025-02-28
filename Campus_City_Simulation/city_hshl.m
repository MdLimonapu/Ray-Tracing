%% Noimg only sbr city to hshl
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

% Rx
rx = rxsite("Name", "Campus Rx", ...
    "Latitude", 51.6737, "Longitude", 8.3448, ...
    "AntennaHeight", 1.5); 

show(rx);

% Image 
pm_image = propagationModel("raytracing", ...
    "Method", "image", ... 
    "MaxNumReflections", 1, ... 
    "BuildingsMaterial", "concrete", ...
    "TerrainMaterial", "loam"); 

% display Img 
disp("Performing Ray Tracing (Image Method)...");
raytrace(tx, rx, pm_image, "Type", "pathloss"); 

% SBR 
pm_sbr = propagationModel("raytracing", ...
    "Method", "sbr", ... 
    "MaxNumReflections", 2, ... 
    "MaxNumDiffractions", 1, ... 
    "BuildingsMaterial", "brick", ... 
    "TerrainMaterial", "concrete", ... 
    "AngularSeparation", "low"); 

% Display sbr
disp("Performing Ray Tracing (SBR Method)...");
raytrace(tx, rx, pm_sbr, "Type", "pathloss"); 

% LOS 
disp("Checking Line of Sight (LOS)...");
los_status = los(tx, rx); 
if los_status
    disp("LOS Available: Direct path exists between Tx and Rx.");
else
    disp("LOS Blocked: No direct path, relying on reflections/diffractions.");
end

% Path Loss 
disp("Calculating Path Loss for Ray Paths...");
rays = raytrace(tx, rx, pm_sbr, "Type", "pathloss");
if isempty(rays{1})
    disp("No rays detected between Tx and Rx.");
else
    for p = 1:length(rays{1})
        fprintf("Path %d: Path Loss = %.2f dB\n", p, rays{1}(p).PathLoss);
    end
end

% Coverage 
disp("Computing Coverage Map with Optimized Parameters...");

%  coverage estimation
pm_coverage = propagationModel("closein"); 

coverage(tx, pm_coverage, ...
    'SignalStrengths', -100:5:-60, ... 
    'MaxRange', 1500, ... 
    'Resolution', 10); 

disp("Optimized Coverage Simulation Complete.");