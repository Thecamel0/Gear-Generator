%% =========================================================================
%  STRAIGHT BEVEL GEAR DESIGN & CAD GENERATION SUITE
%  Wind Turbine Pitch Control Actuator (Orthogonal 90 deg Multi-Pinion Drive)
%  =========================================================================
%
%  Features:
%    1. Full Gleason straight bevel kinematics and stress analysis (AGMA/ISO).
%    2. Watertight 3D mesh generation converging directly to cone apex (0, 0, 0).
%    3. Publication-grade 3D CAD Assembly & Single-Pair Exploded View (Figure 1).
%    4. 2D Pitch Cones Overview & Detailed Tredgold Meshing Zone (Figure 2).
%    5. Complete CAD Exporters: Binary STL, STEP AP214, IGES 5.3, SolidWorks VBA macro.
%
%  Author: Ahmed Majdy Ahmed
%  Date:   2026-09-03
%  =========================================================================

clear; clc; close all;

%% 1. Set Up Script Paths
script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(script_dir, 'Core'));
addpath(fullfile(script_dir, 'Viz'));
addpath(fullfile(script_dir, 'Export'));

fprintf('\n');
fprintf('========================================================================\n');
fprintf('   STRAIGHT BEVEL GEAR DESIGN & SIMULATION SUITE (MATLAB)\n');
fprintf('   Wind Turbine Pitch Control System - 90 deg Orthogonal Multi-Pinion\n');
fprintf('========================================================================\n\n');

%% 2. Design Parameters
params = struct();
params.m           = 3.0;     % Module [mm]
params.Np          = 16;      % Pinion tooth count
params.Ng          = 48;      % Gear tooth count (1:3 ratio)
params.phi_deg     = 20.0;    % Pressure angle [deg]
params.Sigma_deg   = 90.0;    % Shaft angle [deg] (Orthogonal)
params.n_pinions   = 3;       % Number of driving pinions around ring (120 deg spacing)
params.F           = 25.0;    % Face width [mm]

params.T_in_ring   = 20.0;    % Ring input torque [N*m]
params.n_in_ring   = 100.0;   % Ring speed [RPM]
params.eta         = 0.97;    % Mechanical efficiency
params.sigma_allow_bend    = 250.0;   % Allowable bending stress [MPa] (Steel)
params.sigma_allow_contact = 1500.0;  % Allowable contact stress [MPa]

%% 3. Kinematic & Stress Analysis
fprintf('--- [1/5] KINEMATICS & STRESS ANALYSIS ---\n');
calc = straight_bevel_kinematics_and_stress(params);

fprintf('  Module: %g mm  |  Teeth: %d / %d  |  Ratio: 1:%.1f\n', ...
    calc.m, calc.Np, calc.Ng, calc.i_ratio);
fprintf('  Shaft angle: %.1f deg  |  Pitch angles: %.2f deg (Pinion) / %.2f deg (Gear)\n', ...
    calc.Sigma_deg, calc.gamma_p_deg, calc.gamma_g_deg);
fprintf('  Pitch diameters: %.2f mm (Pinion) / %.2f mm (Gear)\n', calc.dp, calc.dg);
fprintf('  Outer cone distance Ao: %.2f mm  |  Face width F: %.2f mm\n', calc.Ao, calc.F);
fprintf('  Tredgold contact ratio: %.3f (Safe >= 1.40)\n', calc.CR);
fprintf('  Input torque: %.1f N*m @ %.0f RPM  -->  Pinion torque: %.2f N*m each\n', ...
    calc.T_in_ring, calc.n_in_ring, calc.T_pinion_each);
fprintf('  Tangential mesh force: %.1f N  |  Resultant mesh force: %.1f N\n', ...
    calc.Ft, calc.F_resultant);
fprintf('  Bending stress: %.2f MPa (SF = %.1f)  |  Contact stress: %.1f MPa (SF = %.1f)\n\n', ...
    calc.sigma_b_p, calc.SF_b_p, calc.sigma_H, calc.SF_contact);

%% 4. 3D Watertight Mesh Generation
fprintf('--- [2/5] GENERATING WATERTIGHT 3D MESHES ---\n');
fprintf('  Constructing Straight Bevel Pinion (%dT, apex-convergent)...\n', calc.Np);
pinion_mesh = build_straight_bevel_mesh_3d(calc.Np, calc.m, calc.phi, calc.a_p, calc.b_p, ...
    calc.gamma_p, calc.Ao, calc.F, calc.s_p, 16, 14);

fprintf('  Constructing Straight Bevel Central Gear (%dT, apex-convergent)...\n', calc.Ng);
gear_mesh = build_straight_bevel_mesh_3d(calc.Ng, calc.m, calc.phi, calc.a_g, calc.b_g, ...
    calc.gamma_g, calc.Ao, calc.F, calc.s_g, 16, 14);

fprintf('  [x] Pinion mesh: %d vertices, %d faces (Watertight: %d, Euler: %d)\n', ...
    pinion_mesh.n_verts, pinion_mesh.n_faces, pinion_mesh.is_watertight, pinion_mesh.euler_char);
fprintf('  [x] Gear mesh:   %d vertices, %d faces (Watertight: %d, Euler: %d)\n\n', ...
    gear_mesh.n_verts, gear_mesh.n_faces, gear_mesh.is_watertight, gear_mesh.euler_char);

%% 5. Visualization Figures (3D Assembly & 2D Meshing Diagram)
fprintf('--- [3/5] RENDERING VISUALIZATION FIGURES ---\n');
fig1 = plot_straight_bevel_assembly_3d(gear_mesh, pinion_mesh, calc);
fig2 = plot_straight_bevel_mesh_2d(calc);

%% 6. Export CAD Models & Engineering Files
fprintf('\n--- [4/5] EXPORTING CAD MODELS & ENGINEERING FILES ---\n');
parent_dir = fileparts(script_dir);
export_dir = fullfile(parent_dir, 'Solidworks', 'Exported_Models_Straight_Bevel');
if ~exist(export_dir, 'dir')
    mkdir(export_dir);
end

% A. Binary STL Files
stl_pinion = fullfile(export_dir, 'straight_bevel_pinion.stl');
stl_gear   = fullfile(export_dir, 'straight_bevel_gear.stl');
export_stl(pinion_mesh, stl_pinion, sprintf('Straight Bevel Pinion m%g N%d', calc.m, calc.Np));
export_stl(gear_mesh, stl_gear, sprintf('Straight Bevel Gear m%g N%d', calc.m, calc.Ng));

% B. STEP AP214 Solid Models (.step)
step_pinion = fullfile(export_dir, 'straight_bevel_pinion.step');
step_gear   = fullfile(export_dir, 'straight_bevel_gear.step');
export_step(pinion_mesh, step_pinion, 'Straight Bevel Pinion Solid');
export_step(gear_mesh, step_gear, 'Straight Bevel Gear Solid');

% C. IGES 5.3 Solid Models (.igs)
igs_pinion = fullfile(export_dir, 'straight_bevel_pinion.igs');
igs_gear   = fullfile(export_dir, 'straight_bevel_gear.igs');
export_igs(pinion_mesh, igs_pinion, 'Straight Bevel Pinion IGES');
export_igs(gear_mesh, igs_gear, 'Straight Bevel Gear IGES');

% D. SolidWorks Macro, Equations, and CSV Report
export_solidworks_macro(calc, export_dir);

%% 7. Save Parameters
fprintf('\n--- [5/5] SAVING PARAMETERS ---\n');
mat_file = fullfile(script_dir, 'straight_bevel_design_params.mat');
save(mat_file, 'calc', 'pinion_mesh', 'gear_mesh');
fprintf('  [x] Saved workspace to %s\n\n', mat_file);

fprintf('========================================================================\n');
fprintf('  STRAIGHT BEVEL GEAR PIPELINE COMPLETE!\n');
fprintf('  Outputs saved to: %s\n', export_dir);
fprintf('========================================================================\n\n');
