%% ========================================================================
%  HELICAL GEAR DESIGN, SIMULATION & CAD GENERATION SUITE
%  Wind Turbine Pitch Control System - Parallel-Axis Multi-Pinion Drive
%
%  Standards: AGMA 2001-D04 / ISO 6336
%  Author: Ahmed Majdy Ahmed
%  Date:   2026-09-03
%  ========================================================================

clear; clc; close all;

%% 1. Path Setup & Environment
script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(script_dir, 'Core'));
addpath(fullfile(script_dir, 'Viz'));
addpath(fullfile(script_dir, 'Export'));

parent_dir = fileparts(script_dir);
output_dir = fullfile(parent_dir, 'Solidworks', 'Exported_Models_Helical');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

fprintf('\n');
fprintf('========================================================================\n');
fprintf('   HELICAL GEAR DESIGN & SIMULATION SUITE (MATLAB)\n');
fprintf('   Wind Turbine Pitch Control System - Parallel-Axis Multi-Pinion Drive\n');
fprintf('========================================================================\n\n');

%% 2. Design Parameters
params = struct();
params.mn              = 3.0;     % Normal module [mm]
params.Np              = 16;      % Pinion tooth count
params.Ng              = 48;      % Gear tooth count (1:3 ratio)
params.tooth_angle_deg = 15.0;    % Tooth angle / Helix angle (beta) [deg] (Pinion RH, Gear LH)
params.phi_n_deg       = 20.0;    % Normal pressure angle [deg]
params.n_pinions       = 3;       % Number of driving pinions around ring (120 deg spacing)
params.F               = 40.0;    % Face width [mm] (guarantees continuous overlap eps_beta > 1.0)

params.T_in_ring       = 20.0;    % Ring input torque [N*m]
params.n_in_ring       = 100.0;   % Ring speed [RPM]

%% 3. Kinematic & Stress Analysis
fprintf('--- [1/5] KINEMATICS & STRESS ANALYSIS ---\n');
calc = helical_kinematics_and_stress(params);

fprintf('  Normal module: %g mm  |  Transverse module: %.4f mm\n', calc.mn, calc.mt);
fprintf('  Teeth: %d / %d  |  Ratio: 1:%.1f  |  Tooth angle (Helix angle beta): %g deg\n', ...
    calc.Np, calc.Ng, calc.i_ratio, calc.tooth_angle_deg);
fprintf('  Pitch diameters: %.2f mm (Pinion) / %.2f mm (Gear)\n', calc.dp, calc.dg);
fprintf('  Center distance C: %.2f mm  |  Face width F: %.2f mm\n', calc.center_dist, calc.F);
fprintf('  Contact ratios: Transverse eps_a = %.3f | Overlap eps_b = %.3f | Total eps_g = %.3f\n', ...
    calc.eps_alpha, calc.eps_beta, calc.eps_gamma);
fprintf('  Input torque: %.1f N*m @ %g RPM  -->  Pinion torque: %.2f N*m each\n', ...
    calc.T_in_ring, calc.n_in_ring, calc.T_pinion_each);
fprintf('  Forces: Ft = %.1f N  |  Fr = %.1f N  |  Fa = %.1f N  |  Fres = %.1f N\n', ...
    calc.Ft, calc.Fr, calc.Fa, calc.F_resultant);
fprintf('  Bending stress: %.2f MPa  |  Contact stress: %.1f MPa\n\n', ...
    calc.sigma_b_p, calc.sigma_H);

%% 4. Constructing Watertight 3D Meshes
fprintf('--- [2/5] GENERATING WATERTIGHT 3D MESHES ---\n');
fprintf('  Constructing Helical Pinion (%dT, RH, lead-sweep)...\n', calc.Np);
pinion_mesh = build_helical_mesh_3d(calc.Np, calc.mn, calc.beta_deg, calc.phi_n_deg, ...
    calc.a_p, calc.b_p, calc.st_p, calc.F, +1, 18, 24);

fprintf('  Constructing Helical Central Gear (%dT, LH, lead-sweep)...\n', calc.Ng);
gear_mesh = build_helical_mesh_3d(calc.Ng, calc.mn, calc.beta_deg, calc.phi_n_deg, ...
    calc.a_g, calc.b_g, calc.st_g, calc.F, -1, 18, 24);

fprintf('  [x] Pinion mesh: %d vertices, %d faces (Watertight: %d, Euler: %d)\n', ...
    pinion_mesh.num_vertices, pinion_mesh.num_faces, pinion_mesh.is_watertight, pinion_mesh.euler_char);
fprintf('  [x] Gear mesh:   %d vertices, %d faces (Watertight: %d, Euler: %d)\n\n', ...
    gear_mesh.num_vertices, gear_mesh.num_faces, gear_mesh.is_watertight, gear_mesh.euler_char);

%% 5. Visualization Figures (3D Assembly & 2D Contact Diagram)
fprintf('--- [3/5] RENDERING VISUALIZATION FIGURES ---\n');

% Figure 1: 3D CAD Assembly & Single-Pair Exploded View
fig1 = plot_helical_assembly_3d(gear_mesh, pinion_mesh, calc);
fig1_path = fullfile(output_dir, 'helical_cad_assembly.png');
exportgraphics(fig1, fig1_path, 'Resolution', 300);
fprintf('   [x] Exported 3D Assembly Figure: %s\n', fig1_path);

% Figure 2: 2D Transverse Engagement & Contact Mechanics Diagram
fig2 = plot_helical_mesh_2d(calc);
fig2_path = fullfile(output_dir, 'helical_mesh_2d_diagram.png');
exportgraphics(fig2, fig2_path, 'Resolution', 300);
fprintf('   [x] Exported 2D Mesh Diagram:   %s\n\n', fig2_path);

%% 6. Solid CAD Exporters (STL, STEP AP214, IGES 5.3, SolidWorks Macro)
fprintf('--- [4/5] EXPORTING CAD MODELS & ENGINEERING FILES ---\n');

% Binary STL
stl_pin_path  = fullfile(output_dir, 'helical_pinion.stl');
stl_gear_path = fullfile(output_dir, 'helical_gear.stl');
export_stl(pinion_mesh, stl_pin_path, 'Helical Pinion RH - Binary STL');
export_stl(gear_mesh, stl_gear_path, 'Helical Gear LH - Binary STL');
pin_info  = dir(stl_pin_path);
gear_info = dir(stl_gear_path);
fprintf('   [x] Exported Binary STL: %s (%.2f MB, %d triangles)\n', stl_pin_path, pin_info.bytes/1e6, pinion_mesh.num_faces);
fprintf('   [x] Exported Binary STL: %s (%.2f MB, %d triangles)\n', stl_gear_path, gear_info.bytes/1e6, gear_mesh.num_faces);

% STEP AP214 Manifold Solid Bodies
step_pin_path  = fullfile(output_dir, 'helical_pinion.step');
step_gear_path = fullfile(output_dir, 'helical_gear.step');
export_step(pinion_mesh, step_pin_path, sprintf('HELICAL_PINION_%dT_RH', calc.Np));
export_step(gear_mesh, step_gear_path, sprintf('HELICAL_GEAR_%dT_LH', calc.Ng));
step_pin_info  = dir(step_pin_path);
step_gear_info = dir(step_gear_path);
fprintf('   [x] Exported STEP AP214: %s (%.2f MB, %d faces)\n', step_pin_path, step_pin_info.bytes/1e6, pinion_mesh.num_faces);
fprintf('   [x] Exported STEP AP214: %s (%.2f MB, %d faces)\n', step_gear_path, step_gear_info.bytes/1e6, gear_mesh.num_faces);

% IGES 5.3 Surface Entities
igs_pin_path  = fullfile(output_dir, 'helical_pinion.igs');
igs_gear_path = fullfile(output_dir, 'helical_gear.igs');
export_igs(pinion_mesh, igs_pin_path, sprintf('HELICAL_PINION_%dT_RH', calc.Np));
export_igs(gear_mesh, igs_gear_path, sprintf('HELICAL_GEAR_%dT_LH', calc.Ng));
igs_pin_info  = dir(igs_pin_path);
igs_gear_info = dir(igs_gear_path);
fprintf('   [x] Exported IGES 5.3:   %s (%.2f MB, %d patches)\n', igs_pin_path, igs_pin_info.bytes/1e6, pinion_mesh.num_faces);
fprintf('   [x] Exported IGES 5.3:   %s (%.2f MB, %d patches)\n', igs_gear_path, igs_gear_info.bytes/1e6, gear_mesh.num_faces);

% SolidWorks VBA Macro, Equations, and CSV Report
export_solidworks_macro(calc, output_dir);
fprintf('   [x] Exported SolidWorks Macro:  %s\n', fullfile(output_dir, 'create_helical_gears.bas'));
fprintf('   [x] Exported Equations File:    %s\n', fullfile(output_dir, 'helical_equations.txt'));
fprintf('   [x] Exported Design CSV Report: %s\n\n', fullfile(output_dir, 'helical_design_report.csv'));

%% 7. Save Complete Parameters Workspace
fprintf('--- [5/5] SAVING PARAMETERS ---\n');
mat_path = fullfile(script_dir, 'helical_design_params.mat');
save(mat_path, 'calc', 'params');
fprintf('  [x] Saved workspace to %s\n\n', mat_path);

fprintf('========================================================================\n');
fprintf('  HELICAL GEAR PIPELINE COMPLETE!\n');
fprintf('  Outputs saved to: %s\n', output_dir);
fprintf('========================================================================\n\n');
