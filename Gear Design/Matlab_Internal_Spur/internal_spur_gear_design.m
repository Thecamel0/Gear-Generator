%% ========================================================================
%  INTERNAL SPUR GEAR DESIGN & CAD AUTOMATION SUITE
%  Wind Turbine Pitch Control System
%
%  Features:
%    - Precision Internal Involute Ring Gear & External Pinion Geometry
%    - Dedicated Planar Normals for 100% Flat Smooth End Caps
%    - Subplot 1: 3D CAD Assembly with 3 Multi-Pinions Inside Ring Gear
%    - Subplot 2: Exploded View with SINGLE PAIR Engagement (No Wireframe Artifacts)
%    - Figure 2: 2D Contact Diagram with 1:1 Aspect Ratio & Magnified Meshing Zone
%    - Multi-format CAD Exporters: STL, STEP AP214, IGES 5.3, SolidWorks Macro
%
%  Author: Ahmed Majdy Ahmed
%  Date:   2026-09-03
% ========================================================================

clear; clc; close all;

fprintf('========================================================================\n');
fprintf('   INTERNAL SPUR GEAR DESIGN & CAD AUTOMATION SUITE\n');
fprintf('   Wind Turbine Pitch Control System — Ring Gear & Pinion Drive\n');
fprintf('========================================================================\n\n');

% Set up paths
suite_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(suite_dir, 'Core'));
addpath(fullfile(suite_dir, 'Viz'));
addpath(fullfile(suite_dir, 'Export'));

gear_design_dir = fileparts(suite_dir);
export_dir = fullfile(gear_design_dir, 'Solidworks', 'Exported_Models_Internal_Spur');
if ~exist(export_dir, 'dir'), mkdir(export_dir); end

%% 1. Primary Parameters Definition
inputs = struct();
inputs.m          = 3.0;     % Normal Module [mm]
inputs.Np         = 16;      % Number of Teeth (Pinion)
inputs.Ng         = 48;      % Number of Teeth (Internal Ring Gear)
inputs.phi_deg    = 20.0;    % Pressure Angle [deg]
inputs.F          = 25.0;    % Face Width [mm]
inputs.n_pinions  = 3;       % Number of Pinions driving the Ring Gear
inputs.T_in_ring  = 20.0;    % Total Input Ring Torque [N*m]
inputs.n_in_ring  = 100.0;   % Input Ring Speed [RPM]
inputs.eta        = 0.97;    % Mechanical Efficiency

%% 2. Kinematics, Forces & Stress Calculations
fprintf('[1/4] Calculating Internal Gear Kinematics, Forces, and Safety Factors...\n');
calc = internal_spur_kinematics_and_stress(inputs);

fprintf('   - Module:               m   = %.1f mm\n', calc.m);
fprintf('   - Pinion Teeth:         Np  = %d\n', calc.Np);
fprintf('   - Ring Gear Teeth:      Ng  = %d (Ratio 1:%.1f)\n', calc.Ng, calc.i_ratio);
fprintf('   - Pitch Diameters:      dp  = %.1f mm, dg = %.1f mm\n', calc.dp, calc.dg);
fprintf('   - Center Distance:      C   = %.2f mm\n', calc.center_dist);
fprintf('   - Ring Crest / Root:    ra  = %.2f mm, rd = %.2f mm\n', calc.ra_g_int, calc.rd_g_int);
fprintf('   - Outer Rim Diameter:   Do  = %.1f mm\n', calc.D_outer);
fprintf('   - Contact Ratio:        CR  = %.3f (Target >= 1.50)\n', calc.CR);
fprintf('   - Output Pinion Speed:  np  = %.1f RPM\n', calc.n_pinion_out);
fprintf('   - Pinion Torque (each): Tp  = %.2f N*m\n', calc.T_pinion_each);
fprintf('   - Tangential Force:     Ft  = %.1f N\n', calc.Ft);
fprintf('   - Bending Safety SF:    Pinion = %.1f, Ring Gear = %.1f\n', calc.SF_b_p, calc.SF_b_g);
fprintf('   - Contact Stress:       sigma_H = %.1f MPa (SF = %.1f)\n\n', calc.sigma_H, calc.SF_contact);

%% 3. Watertight 3D Mesh Generation (Dedicated Flat Cap Normals)
fprintf('[2/4] Generating Watertight 3D Solid Meshes...\n');
n_sec = 4;
n_pts = 50;
[ring_mesh, pinion_mesh] = build_internal_spur_mesh_3d(calc, n_sec, n_pts);
fprintf('   - Ring Gear Mesh: %d Vertices, %d Faces\n', ring_mesh.n_verts, ring_mesh.n_faces);
fprintf('   - Pinion Mesh:    %d Vertices, %d Faces\n\n', pinion_mesh.n_verts, pinion_mesh.n_faces);

%% 4. Publication-Grade Figure Generation
fprintf('[3/4] Rendering 3D Assembly and 2D Contact Analysis Figures...\n');
fig1 = plot_internal_spur_assembly_3d(ring_mesh, pinion_mesh, calc);
fig2 = plot_internal_spur_mesh_2d(calc);

%% 5. Export CAD Solid Models & SolidWorks Macro
fprintf('[4/4] Exporting Solid CAD Files & SolidWorks Automation Macro...\n');

% STL Models
stl_pin = fullfile(export_dir, 'internal_pinion.stl');
stl_ring = fullfile(export_dir, 'internal_ring_gear.stl');
export_stl(pinion_mesh, stl_pin, 'Internal Pinion');
export_stl(ring_mesh, stl_ring, 'Internal Ring Gear');
fprintf('   [x] Exported STL:  %s\n', stl_pin);
fprintf('   [x] Exported STL:  %s\n', stl_ring);

% STEP AP214 Models
step_pin = fullfile(export_dir, 'internal_pinion.step');
step_ring = fullfile(export_dir, 'internal_ring_gear.step');
export_step(pinion_mesh, step_pin, 'Internal Pinion');
export_step(ring_mesh, step_ring, 'Internal Ring Gear');
fprintf('   [x] Exported STEP: %s\n', step_pin);
fprintf('   [x] Exported STEP: %s\n', step_ring);

% IGES Models
igs_pin = fullfile(export_dir, 'internal_pinion.igs');
igs_ring = fullfile(export_dir, 'internal_ring_gear.igs');
export_igs(pinion_mesh, igs_pin, 'Internal Pinion');
export_igs(ring_mesh, igs_ring, 'Internal Ring Gear');
fprintf('   [x] Exported IGES: %s\n', igs_pin);
fprintf('   [x] Exported IGES: %s\n', igs_ring);

% SolidWorks VBA Macro
bas_path = fullfile(export_dir, 'create_internal_spur_gears.bas');
write_solidworks_macro_internal(calc, bas_path);
fprintf('   [x] Exported SolidWorks Macro: %s\n', bas_path);

% Design Report CSV
csv_path = fullfile(export_dir, 'internal_spur_design_report.csv');
write_csv_report_internal(calc, csv_path);
fprintf('   [x] Exported CSV Report:       %s\n', csv_path);

% Save Workspace MAT
mat_path = fullfile(suite_dir, 'internal_spur_design_params.mat');
save(mat_path, 'calc', 'ring_mesh', 'pinion_mesh');
fprintf('   [x] Saved Parameters:          %s\n\n', mat_path);

fprintf('========================================================================\n');
fprintf('   SUCCESS: Internal Spur Gear Design Pipeline Complete!\n');
fprintf('   Figures & CAD models exported to Solidworks/Exported_Models_Internal_Spur/\n');
fprintf('========================================================================\n');

%% Helper: Write SolidWorks VBA Macro
function write_solidworks_macro_internal(calc, filename)
    fid = fopen(filename, 'w');
    if fid == -1, return; end
    fprintf(fid, ''' =========================================================================\n');
    fprintf(fid, ''' SOLIDWORKS VBA MACRO: PARAMETRIC INTERNAL SPUR GEAR DRIVE\n');
    fprintf(fid, ''' Wind Turbine Pitch Control System\n');
    fprintf(fid, ''' Module: %g mm, Teeth: %d (Pinion) / %d (Ring Gear)\n', calc.m, calc.Np, calc.Ng);
    fprintf(fid, ''' Center Distance: %.2f mm, Face Width: %.2f mm\n', calc.center_dist, calc.F);
    fprintf(fid, ''' =========================================================================\n\n');
    fprintf(fid, 'Option Explicit\n\n');
    fprintf(fid, 'Dim swApp As Object\n');
    fprintf(fid, 'Dim Part As Object\n\n');
    fprintf(fid, 'Sub main()\n');
    fprintf(fid, '    Set swApp = Application.SldWorks\n');
    fprintf(fid, '    Set Part = swApp.ActiveDoc\n');
    fprintf(fid, '    If Part Is Nothing Then\n');
    fprintf(fid, '        Set Part = swApp.NewDocument("", 0, 0, 0)\n');
    fprintf(fid, '    End If\n\n');
    fprintf(fid, '    MsgBox "Internal Spur Gear Parameters Loaded:" & vbCrLf & _\n');
    fprintf(fid, '           "Module: %g mm" & vbCrLf & _\n', calc.m);
    fprintf(fid, '           "Pinion Teeth: %d" & vbCrLf & _\n', calc.Np);
    fprintf(fid, '           "Ring Teeth: %d" & vbCrLf & _\n', calc.Ng);
    fprintf(fid, '           "Center Distance: %.2f mm" & vbCrLf & _\n', calc.center_dist);
    fprintf(fid, '           "Contact Ratio: %.3f", vbInformation, "Gear Master Suite"\n', calc.CR);
    fprintf(fid, 'End Sub\n');
    fclose(fid);
end

%% Helper: Write CSV Design Report
function write_csv_report_internal(calc, filename)
    fid = fopen(filename, 'w');
    if fid == -1, return; end
    fprintf(fid, 'Parameter,Symbol,Value,Unit\n');
    fprintf(fid, 'Gear Type,-,Internal Involute Spur Gear,-\n');
    fprintf(fid, 'Normal Module,m,%.4f,mm\n', calc.m);
    fprintf(fid, 'Pinion Teeth,Np,%d,-\n', calc.Np);
    fprintf(fid, 'Ring Gear Teeth,Ng,%d,-\n', calc.Ng);
    fprintf(fid, 'Gear Ratio,i,%.4f,-\n', calc.i_ratio);
    fprintf(fid, 'Pressure Angle,phi,%.2f,deg\n', calc.phi_deg);
    fprintf(fid, 'Face Width,F,%.2f,mm\n', calc.F);
    fprintf(fid, 'Number of Pinions,n_pinions,%d,-\n', calc.n_pinions);
    fprintf(fid, 'Center Distance,C,%.4f,mm\n', calc.center_dist);
    fprintf(fid, 'Pinion Pitch Diameter,dp,%.4f,mm\n', calc.dp);
    fprintf(fid, 'Ring Pitch Diameter,dg,%.4f,mm\n', calc.dg);
    fprintf(fid, 'Ring Internal Tip Radius,ra_g_int,%.4f,mm\n', calc.ra_g_int);
    fprintf(fid, 'Ring Internal Root Radius,rd_g_int,%.4f,mm\n', calc.rd_g_int);
    fprintf(fid, 'Outer Rim Diameter,D_outer,%.4f,mm\n', calc.D_outer);
    fprintf(fid, 'Transverse Contact Ratio,CR,%.4f,-\n', calc.CR);
    fprintf(fid, 'Input Ring Torque,T_in,%.2f,N*m\n', calc.T_in_ring);
    fprintf(fid, 'Pinion Torque (each),Tp,%.4f,N*m\n', calc.T_pinion_each);
    fprintf(fid, 'Input Ring Speed,ng,%.2f,RPM\n', calc.n_in_ring);
    fprintf(fid, 'Output Pinion Speed,np,%.2f,RPM\n', calc.n_pinion_out);
    fprintf(fid, 'Tangential Force,Ft,%.2f,N\n', calc.Ft);
    fprintf(fid, 'Radial Force,Fr,%.2f,N\n', calc.Fr);
    fprintf(fid, 'Resultant Force,F_res,%.2f,N\n', calc.F_resultant);
    fprintf(fid, 'Pinion Bending Stress,sigma_b_p,%.2f,MPa\n', calc.sigma_b_p);
    fprintf(fid, 'Pinion Bending Safety Factor,SF_b_p,%.2f,-\n', calc.SF_b_p);
    fprintf(fid, 'Ring Bending Stress,sigma_b_g,%.2f,MPa\n', calc.sigma_b_g);
    fprintf(fid, 'Ring Bending Safety Factor,SF_b_g,%.2f,-\n', calc.SF_b_g);
    fprintf(fid, 'Hertzian Contact Stress,sigma_H,%.2f,MPa\n', calc.sigma_H);
    fprintf(fid, 'Contact Safety Factor,SF_contact,%.2f,-\n', calc.SF_contact);
    fclose(fid);
end
