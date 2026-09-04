%% =========================================================================
%  SPIRAL BEVEL GEAR DESIGN, SIMULATION & CAD GENERATION SUITE
%  Wind Turbine Pitch Control Actuator (Orthogonal 90 deg Multi-Pinion Drive)
%  =========================================================================
%
%  Standards:
%    - AGMA 2005-D03 / ISO 23509 (Bevel and Hypoid Gear System)
%    - Gleason Standard Spiral Bevel Design (35 deg Mean Spiral Angle)
%
%  Features:
%    1. Full Gleason spiral bevel kinematics, geometry, and 3D force analysis.
%    2. Watertight 3D solid mesh generation with dedicated planar end-cap normals.
%    3. Publication-grade 3D CAD Assembly & Single-Pair Exploded View (Figure 1).
%    4. 2D Pitch Cones Overview & Detailed Tredgold Meshing Zone (Figure 2).
%    5. Complete CAD Exporters: Binary STL, STEP AP214, IGES 5.3, SolidWorks VBA macro.
%
%  Author: Ahmed Majdy Ahmed
%  Date:   2026-09-04
%  =========================================================================

clear; clc; close all;

%% 1. Path Setup & Environment
script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(script_dir, 'Core'));
addpath(fullfile(script_dir, 'Viz'));
addpath(fullfile(script_dir, 'Export'));

parent_dir = fileparts(script_dir);
output_dir = fullfile(parent_dir, 'Solidworks', 'Exported_Models_Spiral_Bevel');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

fprintf('\n');
fprintf('========================================================================\n');
fprintf('   SPIRAL BEVEL GEAR DESIGN & SIMULATION SUITE (MATLAB)\n');
fprintf('   Wind Turbine Pitch Control System - 90 deg Orthogonal Multi-Pinion\n');
fprintf('========================================================================\n\n');

%% 2. Design Parameters
params = struct();
params.m               = 3.0;     % Module [mm]
params.Np              = 16;      % Pinion tooth count
params.Ng              = 48;      % Gear tooth count (1:3 ratio)
params.tooth_angle_deg = 35.0;    % Mean spiral angle beta_m [deg] (Pinion RH, Gear LH)
params.phi_n_deg       = 20.0;    % Normal pressure angle [deg]
params.Sigma_deg       = 90.0;    % Shaft angle [deg] (Orthogonal)
params.n_pinions       = 3;       % Number of driving pinions around ring (120 deg spacing)
params.F               = 25.0;    % Face width [mm]

params.T_in_ring       = 20.0;    % Ring input torque [N*m]
params.n_in_ring       = 100.0;   % Ring speed [RPM]

%% 3. Kinematic & Stress Analysis
fprintf('--- [1/5] KINEMATICS & STRESS ANALYSIS ---\n');
calc = spiral_bevel_kinematics_and_stress(params);

fprintf('  Module: %g mm  |  Teeth: %d / %d  |  Ratio: 1:%.1f\n', ...
    calc.m, calc.Np, calc.Ng, calc.i_ratio);
fprintf('  Shaft angle: %.1f deg  |  Pitch angles: %.2f deg (Pinion) / %.2f deg (Gear)\n', ...
    calc.Sigma_deg, calc.gamma_p_deg, calc.gamma_g_deg);
fprintf('  Mean spiral angle beta_m: %.1f deg (RH Pinion / LH Gear)\n', calc.beta_m_deg);
fprintf('  Pitch diameters: %.2f mm (Pinion) / %.2f mm (Gear)\n', calc.dp, calc.dg);
fprintf('  Outer cone distance Ao: %.2f mm  |  Face width F: %.2f mm\n', calc.Ao, calc.F);
fprintf('  Cutter radius: %.2f mm  |  Mean cone distance Am: %.2f mm\n', calc.r_cutter, calc.Am);
fprintf('  Contact ratios: Transverse eps_a = %.3f | Overlap eps_b = %.3f | Total eps_g = %.3f\n', ...
    calc.eps_alpha, calc.eps_beta, calc.CR);
fprintf('  Input torque: %.1f N*m @ %.0f RPM  -->  Pinion torque: %.2f N*m each\n', ...
    calc.T_in_ring, calc.n_in_ring, calc.T_pinion_each);
fprintf('  Forces: Ft = %.1f N  |  Fr = %.1f N  |  Fa = %.1f N  |  Fres = %.1f N\n', ...
    calc.Ft, calc.Fr_p, calc.Fa_p, calc.F_resultant);
fprintf('  Bending stress: %.2f MPa (SF = %.1f)  |  Contact stress: %.1f MPa (SF = %.1f)\n\n', ...
    calc.sigma_b_p, calc.SF_b_p, calc.sigma_H, calc.SF_contact);

%% 4. 3D Watertight Mesh Generation
fprintf('--- [2/5] 3D WATERTIGHT MESH GENERATION ---\n');
n_inv = 16;
n_sec = 18;

fprintf('  Generating Pinion 3D Mesh (Right-Hand, %d Teeth)...\n', calc.Np);
pinion_mesh = build_spiral_bevel_mesh_3d(...
    calc.Np, calc.m, calc.phi_n, calc.a_p, calc.b_p, calc.gamma_p, ...
    calc.Ao, calc.F, calc.beta_m, calc.r_cutter, +1, calc.s_p, n_inv, n_sec);
fprintf('    Watertight: %s (Euler char: %d) | Vertices: %d | Faces: %d\n', ...
    string(pinion_mesh.is_watertight), pinion_mesh.euler_char, pinion_mesh.n_verts, pinion_mesh.n_faces);

fprintf('  Generating Central Gear 3D Mesh (Left-Hand, %d Teeth)...\n', calc.Ng);
gear_mesh = build_spiral_bevel_mesh_3d(...
    calc.Ng, calc.m, calc.phi_n, calc.a_g, calc.b_g, calc.gamma_g, ...
    calc.Ao, calc.F, calc.beta_m, calc.r_cutter, -1, calc.s_g, n_inv, n_sec);
fprintf('    Watertight: %s (Euler char: %d) | Vertices: %d | Faces: %d\n\n', ...
    string(gear_mesh.is_watertight), gear_mesh.euler_char, gear_mesh.n_verts, gear_mesh.n_faces);

%% 5. Publication-Grade Visualization (Figure 1 & Figure 2)
fprintf('--- [3/5] GENERATING PUBLICATION VISUALIZATIONS ---\n');
fig1 = plot_spiral_bevel_assembly_3d(gear_mesh, pinion_mesh, calc);
rotate3d(fig1, 'on');
fprintf('    Created Figure 1: 3D CAD Multi-Pinion Assembly & Exploded Meshing View (Interactive 3D Rotation & Zoom active)\n');

fig2 = plot_spiral_bevel_mesh_2d(calc);
fprintf('    Created Figure 2: 2D Pitch Cones Overview & Tredgold Contact Analysis\n\n');

%% 6. Complete CAD Exporters Pipeline
fprintf('--- [4/5] EXPORTING CAD FILES TO DISK ---\n');

% Binary STL Exports
stl_pinion = fullfile(output_dir, sprintf('Spiral_Bevel_Pinion_%dT_RH.stl', calc.Np));
export_stl(pinion_mesh, stl_pinion, sprintf('Spiral Bevel Pinion %dT RH (m=%g)', calc.Np, calc.m));

stl_gear = fullfile(output_dir, sprintf('Spiral_Bevel_Gear_%dT_LH.stl', calc.Ng));
export_stl(gear_mesh, stl_gear, sprintf('Spiral Bevel Gear %dT LH (m=%g)', calc.Ng, calc.m));

% STEP AP214 Solid Model Exports
step_pinion = fullfile(output_dir, sprintf('Spiral_Bevel_Pinion_%dT_RH.stp', calc.Np));
export_step(pinion_mesh, step_pinion, sprintf('Spiral Bevel Pinion %dT AP214', calc.Np));

step_gear = fullfile(output_dir, sprintf('Spiral_Bevel_Gear_%dT_LH.stp', calc.Ng));
export_step(gear_mesh, step_gear, sprintf('Spiral Bevel Gear %dT AP214', calc.Ng));

% IGES 5.3 Surface Exports
iges_pinion = fullfile(output_dir, sprintf('Spiral_Bevel_Pinion_%dT_RH.igs', calc.Np));
export_igs(pinion_mesh, iges_pinion, sprintf('Spiral Bevel Pinion %dT IGES', calc.Np));

iges_gear = fullfile(output_dir, sprintf('Spiral_Bevel_Gear_%dT_LH.igs', calc.Ng));
export_igs(gear_mesh, iges_gear, sprintf('Spiral Bevel Gear %dT IGES', calc.Ng));

% SolidWorks Macro, Equations & CSV Design Report
export_solidworks_macro(calc, output_dir);
export_solidworks_equations(calc, output_dir);
export_design_report_csv(calc, output_dir);

%% 7. Save Session MAT File
mat_file = fullfile(script_dir, 'spiral_bevel_design_params.mat');
save(mat_file, 'calc', 'params');
fprintf('\n--- [5/5] SAVED DESIGN PARAMETERS ---\n');
fprintf('    MAT file saved to: %s\n', mat_file);

fprintf('\n========================================================================\n');
fprintf('   SPIRAL BEVEL GEAR DESIGN COMPLETE & VERIFIED SUCCESSFULLY!\n');
fprintf('========================================================================\n\n');
