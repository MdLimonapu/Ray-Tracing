%% Img and sbr
clear; clc; close all;

% campus map
viewer = siteviewer("Buildings", "hshl.osm", "Basemap", "satellite");

% Tx
tx = txsite("Name", "Campus Tx", ...
    "Latitude", 51.6732, "Longitude", 8.3634, ...
    "AntennaHeight", 10, ...  
    "TransmitterFrequency", 2.5e9, ...
    "TransmitterPower", 5); 

show(tx); % Show tx

% Rx
rx = rxsite("Name", "Campus Rx", ...
    "Latitude", 51.6743, "Longitude", 8.3632, ...
    "AntennaHeight", 1.5); 

show(rx); % Show rx

% Image Method
pm_image = propagationModel("raytracing", ...
    "Method", "image", ... 
    "MaxNumReflections", 1, ... 
    "BuildingsMaterial", "concrete", ...
    "TerrainMaterial", "loam"); 

% disply Image
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

% Disp SBR
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

% model for coverage estimation
pm_coverage = propagationModel("closein");

coverage(tx, pm_coverage, ...
    'SignalStrengths', -100:5:-60, ... 
    'MaxRange', 300, ... 
    'Resolution', 10); 

disp("Optimized Coverage Simulation Complete.");