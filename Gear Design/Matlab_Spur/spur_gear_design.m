%% ========================================================================
%  SPUR GEAR DESIGN & CONTACT ANALYSIS SUITE — Wind Turbine Pitch System
%  ========================================================================
%  Full parallel-axis involute spur gear engineering suite:
%    - True involute flanks with trochoidal root fillet & tip land
%    - Watertight 3D solid meshes for Pinion & Central Ring/Bull Gear
%    - AGMA / Lewis bending stress, Hertzian contact stress & safety factors
%    - Figure 1: 3D CAD Assembly (Multi-Pinion Pitch Drive) + 3D Exploded View
%    - Figure 2: 2D Pitch Engagement Overview + High-Zoom Active Meshing Zone
%    - Direct CAD export: Binary STL, STEP AP214, and IGES 5.3
%
%  Architecture:
%    Central Spur Bull Gear (48T, Driver, PD = 144 mm)
%      -> 3 Spur Pinions (16T, Driven, PD = 48 mm) -> 3 Blade Pitch Shafts
%    Center Distance C = 96.0 mm (120° symmetric radial distribution)
%
%  Author:  Ahmed Majdy Ahmed
%  Date:    2026-09-03
% =========================================================================

clear; clc; close all;

%% --- Add Paths ---
script_folder = fileparts(mfilename('fullpath'));
if ~isempty(script_folder)
    addpath(fullfile(script_folder, 'Core'));
    addpath(fullfile(script_folder, 'Viz'));
    addpath(fullfile(script_folder, 'Export'));
end

fprintf('========================================================================\n');
fprintf('   SPUR GEAR DESIGN SUITE — WIND TURBINE PITCH CONTROL SYSTEM\n');
fprintf('========================================================================\n\n');

%% ========================================================================
%  INPUT PARAMETERS
%  ========================================================================

% Gear Tooth Parameters
m       = 3.0;      % Module [mm]
Np      = 16;       % Pinion teeth (Pitch Dia = 48 mm)
Ng      = 48;       % Central gear teeth (Pitch Dia = 144 mm)
phi_deg = 20.0;     % Pressure angle [deg]
F       = 25.0;     % Face width [mm]

% Multi-Pinion Pitch Control Configuration
n_pinions = 3;      % 1 per blade (120° symmetry around central gear)

% Operating Conditions
T_in_gear   = 20.0; % Total input torque to central gear [N·m]
n_in_gear   = 100;  % Central gear input speed [RPM]

% Allowable Stresses (Case-hardened steel / engineering polymers)
sigma_allow_bend    = 250;  % [MPa]
sigma_allow_contact = 1500; % [MPa]

% 3D Mesh Generation Resolution
n_sec = 4;          % Axial cross-sections along face width
n_pts = 60;         % Involute curve resolution per flank
r_bore_pinion = 0.0;   % Shaft bore radius for pinion [mm] (0 = Solid)
r_bore_gear   = 0.0;   % Central hub bore radius for gear [mm] (0 = Solid)

%% ========================================================================
%  KINEMATIC & STRESS ANALYSIS
%  ========================================================================

fprintf('--> Computing kinematics, gear mesh forces, and AGMA stresses...\n');
calc = spur_kinematics_and_stress(m, Np, Ng, phi_deg, F, ...
    T_in_gear, n_in_gear, n_pinions, sigma_allow_bend, sigma_allow_contact);

% Print Engineering Summary Report
fprintf('\n------------------------------------------------------------------------\n');
fprintf('GEOMETRIC & KINEMATIC SUMMARY:\n');
fprintf('  Module (m):                   %.2f mm\n', calc.m);
fprintf('  Gear Ratio (Ng/Np):           %d / %d (1:%.1f)\n', calc.Ng, calc.Np, calc.i_ratio);
fprintf('  Center Distance (C):          %.2f mm\n', calc.center_dist);
fprintf('  Face Width (F):               %.2f mm\n', calc.F);
fprintf('  Pitch Diameters (dp / dg):    %.1f mm / %.1f mm\n', calc.dp, calc.dg);
fprintf('  Base Diameters (rbp / rbg):   %.2f mm / %.2f mm\n', 2*calc.rb_p, 2*calc.rb_g);
fprintf('  Addendum Diameters (dap/dag): %.2f mm / %.2f mm\n', 2*calc.ra_p, 2*calc.ra_g);
fprintf('  Root Diameters (ddp / ddg):   %.2f mm / %.2f mm\n', 2*calc.rd_p, 2*calc.rd_g);
fprintf('  Working Depth / Whole Depth:  %.2f mm / %.3f mm\n', calc.hw, calc.ht);
fprintf('  Transverse Contact Ratio (CR):%.3f (Standard: >= 1.20)\n', calc.CR);
fprintf('\nFORCES & POWER TRANSMISSION (%d PINIONS):\n', calc.n_pinions);
fprintf('  Total Input Power:            %.2f W (%.1f RPM)\n', calc.P_in_total, calc.n_in_gear);
fprintf('  Output Speed per Pinion:      %.1f RPM\n', calc.n_pinion_out);
fprintf('  Torque per Blade Pinion:      %.2f N·m\n', calc.T_pinion_each);
fprintf('  Tangential Force (Ft):        %.1f N\n', calc.Ft);
fprintf('  Radial Force (Fr):            %.1f N\n', calc.Fr);
fprintf('  Resultant Mesh Force (Fres):  %.1f N\n', calc.F_resultant);
fprintf('\nSTRESS CHECKS & SAFETY FACTORS:\n');
fprintf('  Lewis Bending Stress (Pinion):%.2f MPa -> SF = %.1f (%s)\n', ...
    calc.sigma_b_p, calc.SF_b_p, get_status(calc.SF_b_p, 1.5));
fprintf('  Lewis Bending Stress (Gear):  %.2f MPa -> SF = %.1f (%s)\n', ...
    calc.sigma_b_g, calc.SF_b_g, get_status(calc.SF_b_g, 1.5));
fprintf('  Hertzian Contact Stress:      %.2f MPa -> SF = %.1f (%s)\n', ...
    calc.sigma_H, calc.SF_contact, get_status(calc.SF_contact, 1.2));
fprintf('------------------------------------------------------------------------\n\n');

%% ========================================================================
%  3D SOLID MESH GENERATION
%  ========================================================================

fprintf('--> Generating watertight 3D solid meshes...\n');
fprintf('  [1/2] Building Pinion 3D mesh (%dT, bore=%.1f mm)...\n', Np, r_bore_pinion);
pinion_mesh = build_spur_mesh_3d(Np, m, calc.phi, calc.a_p, calc.b_p, ...
    calc.s_p, F, n_sec, r_bore_pinion, n_pts);
fprintf('        Pinion: %d vertices, %d triangular faces.\n', ...
    pinion_mesh.n_verts, pinion_mesh.n_faces);

fprintf('  [2/2] Building Central Gear 3D mesh (%dT, bore=%.1f mm)...\n', Ng, r_bore_gear);
gear_mesh = build_spur_mesh_3d(Ng, m, calc.phi, calc.a_g, calc.b_g, ...
    calc.s_g, F, n_sec, r_bore_gear, n_pts);
fprintf('        Central Gear: %d vertices, %d triangular faces.\n', ...
    gear_mesh.n_verts, gear_mesh.n_faces);

%% ========================================================================
%  VISUALIZATION: FIGURES 1 & 2 (MATCHING ZEROL BEVEL STANDARDS)
%  ========================================================================

fprintf('\n--> Rendering figures...\n');

% --- Figure 1: 3D CAD Assembly & Exploded View ---
fprintf('  [Fig 1] Rendering 3D CAD Assembly & Exploded View...\n');
fig1 = plot_spur_assembly_3d(pinion_mesh, gear_mesh, calc);

% --- Figure 2: 2D Tooth Mesh & Contact Analysis ---
fprintf('  [Fig 2] Rendering 2D Tooth Mesh & Contact Analysis...\n');
fig2 = plot_spur_mesh_2d(m, Np, Ng, phi_deg, 2.00, 0.188, ...
    calc.s_p, calc.s_g, calc.hw, calc.ht, calc.a_p, calc.a_g, calc.b_p, calc.b_g, calc.CR);

drawnow;

%% ========================================================================
%  EXPORT 3D CAD MODELS (STL, STEP, IGES)
%  ========================================================================

fprintf('\n--> Exporting 3D solid models to Solidworks/Exported_Models_Spur/...\n');
gear_design_dir = fileparts(script_folder);
export_dir = fullfile(gear_design_dir, 'Solidworks', 'Exported_Models_Spur');
if ~exist(export_dir, 'dir'), mkdir(export_dir); end

% STL Export (Binary watertight)
export_stl(pinion_mesh, fullfile(export_dir, 'spur_pinion.stl'), ...
    sprintf('Spur Pinion m%g Np%d F%g', m, Np, F));
export_stl(gear_mesh, fullfile(export_dir, 'spur_gear.stl'), ...
    sprintf('Spur Gear m%g Ng%d F%g', m, Ng, F));

% STEP AP214 Export (Solid BREP body)
fprintf('  Exporting STEP AP214 solid models...\n');
export_step(pinion_mesh, fullfile(export_dir, 'spur_pinion.stp'), ...
    sprintf('Spur Pinion m%g Np%d', m, Np));
export_step(gear_mesh, fullfile(export_dir, 'spur_gear.stp'), ...
    sprintf('Spur Gear m%g Ng%d', m, Ng));

% IGES 5.3 Export (Surface/Solid entities for CATIA & SolidWorks)
fprintf('  Exporting IGES 5.3 surface models...\n');
export_igs(pinion_mesh, fullfile(export_dir, 'spur_pinion.igs'), ...
    sprintf('Spur Pinion m%g Np%d', m, Np));
export_igs(gear_mesh, fullfile(export_dir, 'spur_gear.igs'), ...
    sprintf('Spur Gear m%g Ng%d', m, Ng));

% Save calculation parameters to MAT file
mat_path = fullfile(script_folder, 'spur_design_params.mat');
save(mat_path, 'calc', 'pinion_mesh', 'gear_mesh');
fprintf('  Saved design parameters to: %s\n', mat_path);

fprintf('\n========================================================================\n');
fprintf('   SUCCESS: Spur Gear Design Suite execution completed successfully!\n');
fprintf('   All 3D models and high-res figures saved to:\n');
fprintf('   %s\n', export_dir);
fprintf('========================================================================\n');

function str = get_status(sf, min_sf)
    if sf >= min_sf
        str = 'PASS';
    else
        str = 'FAIL';
    end
end
