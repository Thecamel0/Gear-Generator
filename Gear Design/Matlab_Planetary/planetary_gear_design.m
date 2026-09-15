%% ========================================================================
%  PLANETARY GEAR (EPICYCLIC TRAIN) DESIGN & CAD AUTOMATION SUITE
%  Wind Turbine Pitch Control System
%
%  Features:
%    - Parametric Epicyclic Reduction Drive: Sun, K Planets, Ring Gear, and Carrier
%    - Willis Kinematics (Stationary Ring: Ratio i = 1 + Nr/Ns)
%    - Strict Assembly Condition Checking: (Ns + Nr) / K = Integer
%    - Adjacent Planet Tip Clearance Verification
%    - Dedicated Planar Cap Normals for 100% Flat Smooth End Caps
%    - Subplot 1: 3D CAD Assembly with All Components Meshing in True Engagement
%    - Subplot 2: Exploded Assembly View along Z Axis (Carrier, Ring, Planets, Sun)
%    - Figure 2: 2D Contact Analysis with 1:1 Aspect Ratio & Dual-Mesh Zoom
%    - Multi-format CAD Exporters: STL, STEP AP214, IGES 5.3, SolidWorks Macro
%
%  Author: Ahmed Majdy Ahmed
%  Date:   2026-09-11
% ========================================================================

clear; clc; close all;

fprintf('========================================================================\n');
fprintf('   PLANETARY GEAR (EPICYCLIC) DESIGN & CAD AUTOMATION SUITE\n');
fprintf('   Wind Turbine Pitch Control System — High-Torque Epicyclic Reducer\n');
fprintf('========================================================================\n\n');

% Set up paths
suite_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(suite_dir, 'Core'));
addpath(fullfile(suite_dir, 'Viz'));
addpath(fullfile(suite_dir, 'Export'));

gear_design_dir = fileparts(suite_dir);
export_dir = fullfile(gear_design_dir, 'Solidworks', 'Exported_Models_Planetary');
if ~exist(export_dir, 'dir'), mkdir(export_dir); end

%% 1. Primary Parameters Definition
inputs = struct();
inputs.m          = 3.0;     % Normal Module [mm]
inputs.Ns         = 12;      % Number of Teeth (Sun Gear)
inputs.Np         = 18;      % Number of Teeth (Planet Gears)
inputs.K          = 4;       % Number of Planets (Equally Spaced)
inputs.phi_deg    = 20.0;    % Pressure Angle [deg]
inputs.F          = 25.0;    % Face Width [mm]
inputs.T_in_sun   = 15.0;    % Input Sun Torque [N*m]
inputs.n_in_sun   = 500.0;   % Input Sun Speed [RPM]
inputs.eta        = 0.97;    % Mechanical Efficiency

%% 2. Kinematics, Forces & Stress Calculations
fprintf('[1/4] Calculating Planetary Kinematics, Forces, and Safety Factors...\n');
calc = planetary_kinematics_and_stress(inputs);

fprintf('   - Module:                 m       = %.1f mm\n', calc.m);
fprintf('   - Teeth Configuration:    Sun = %d, Planet = %d, Ring = %d\n', calc.Ns, calc.Np, calc.Nr);
fprintf('   - Number of Planets:      K       = %d (Symmetric Spacing: %s)\n', ...
    calc.K, string(calc.is_symmetric));
fprintf('   - Pitch Diameters:        ds = %.1f mm, dp = %.1f mm, dr = %.1f mm\n', ...
    calc.ds, calc.dp, calc.dr);
fprintf('   - Carrier Orbit Radius:   C       = %.2f mm\n', calc.center_dist);
fprintf('   - Outer Rim Diameter:     Do      = %.1f mm\n', calc.D_outer);
fprintf('   - Planet Tip Clearance:   Delta   = %.2f mm (Clearance OK: %s)\n', ...
    calc.clearance_adjacent_planets, string(calc.has_clearance));
fprintf('   - Willis Reduction Ratio: i       = 1 + Nr/Ns = %.2f:1\n', calc.i_ratio);
fprintf('   - Carrier Output Speed:   nc      = %.1f RPM\n', calc.n_carrier_out);
fprintf('   - Planet Spin on Pin:     np/c    = %.1f RPM (Absolute: %.1f RPM)\n', ...
    calc.n_planet_relative, calc.n_planet_absolute);
fprintf('   - Carrier Output Torque:  Tc      = %.2f N*m\n', calc.T_carrier_out);
fprintf('   - Tangential Force/Mesh:  Ft      = %.1f N (K_gamma = %.2f)\n', calc.Ft, calc.K_gamma);
fprintf('   - Contact Ratios:         Sun-Planet = %.3f, Planet-Ring = %.3f\n', ...
    calc.CR_sp, calc.CR_pr);
fprintf('   - Bending Safety SF:      Sun = %.1f, Planet = %.1f, Ring = %.1f\n', ...
    calc.SF_b_s, calc.SF_b_p, calc.SF_b_r);
fprintf('   - Contact Stress SF:      Sun-Planet = %.1f, Planet-Ring = %.1f\n\n', ...
    calc.SF_contact_sp, calc.SF_contact_pr);

%% 3. Watertight 3D Mesh Generation (Dedicated Flat Cap Normals)
fprintf('[2/4] Generating Watertight 3D Solid Meshes...\n');
n_sec = 4;
n_pts = 36;
[sun_mesh, planet_mesh, ring_mesh, carrier_mesh] = build_planetary_mesh_3d(calc, n_sec, n_pts);

fprintf('   - Sun Gear Mesh:     %d Vertices, %d Faces\n', sun_mesh.n_verts, sun_mesh.n_faces);
fprintf('   - Planet Gear Mesh:  %d Vertices, %d Faces\n', planet_mesh.n_verts, planet_mesh.n_faces);
fprintf('   - Ring Gear Mesh:    %d Vertices, %d Faces\n', ring_mesh.n_verts, ring_mesh.n_faces);
fprintf('   - Carrier Disc+Pins: %d Vertices, %d Faces\n\n', carrier_mesh.n_verts, carrier_mesh.n_faces);

%% 4. Publication-Grade Figure Generation
fprintf('[3/4] Rendering 3D Assembly and 2D Contact Analysis Figures...\n');
fig1 = plot_planetary_assembly_3d(sun_mesh, planet_mesh, ring_mesh, carrier_mesh, calc);
fig2 = plot_planetary_mesh_2d(calc);

% Save high-resolution PNGs
fig1_path = fullfile(suite_dir, 'Viz', 'planetary_cad_assembly.png');
fig2_path = fullfile(suite_dir, 'Viz', 'planetary_mesh_2d_diagram.png');
exportgraphics(fig1, fig1_path, 'Resolution', 300);
exportgraphics(fig2, fig2_path, 'Resolution', 300);
fprintf('   [x] Saved 3D Figure: %s\n', fig1_path);
fprintf('   [x] Saved 2D Figure: %s\n\n', fig2_path);

%% 5. Export CAD Solid Models & SolidWorks Macro
fprintf('[4/4] Exporting Solid CAD Files & SolidWorks Automation Macro...\n');

% STL Models
export_stl(sun_mesh,     fullfile(export_dir, 'planetary_sun_gear.stl'),    'Planetary Sun Gear');
export_stl(planet_mesh,  fullfile(export_dir, 'planetary_planet_gear.stl'), 'Planetary Planet Gear');
export_stl(ring_mesh,    fullfile(export_dir, 'planetary_ring_gear.stl'),   'Planetary Ring Gear');
export_stl(carrier_mesh, fullfile(export_dir, 'planetary_carrier.stl'),     'Planetary Carrier with Pins');

% Combined Assembly STL
assembly_mesh = assemble_planetary_mesh(sun_mesh, planet_mesh, ring_mesh, carrier_mesh, calc);
export_stl(assembly_mesh, fullfile(export_dir, 'planetary_assembly.stl'),   'Planetary Gear Complete Assembly');
fprintf('   [x] Exported STL Models (Sun, Planet, Ring, Carrier, Assembly)\n');

% STEP AP214 Models
export_step(sun_mesh,     fullfile(export_dir, 'planetary_sun_gear.step'),    'Planetary Sun Gear');
export_step(planet_mesh,  fullfile(export_dir, 'planetary_planet_gear.step'), 'Planetary Planet Gear');
export_step(ring_mesh,    fullfile(export_dir, 'planetary_ring_gear.step'),   'Planetary Ring Gear');
export_step(carrier_mesh, fullfile(export_dir, 'planetary_carrier.step'),     'Planetary Carrier');
fprintf('   [x] Exported STEP Models (Sun, Planet, Ring, Carrier)\n');

% IGES Models
export_igs(sun_mesh,     fullfile(export_dir, 'planetary_sun_gear.igs'),    'Planetary Sun Gear');
export_igs(planet_mesh,  fullfile(export_dir, 'planetary_planet_gear.igs'), 'Planetary Planet Gear');
export_igs(ring_mesh,    fullfile(export_dir, 'planetary_ring_gear.igs'),   'Planetary Ring Gear');
export_igs(carrier_mesh, fullfile(export_dir, 'planetary_carrier.igs'),     'Planetary Carrier');
fprintf('   [x] Exported IGES Models (Sun, Planet, Ring, Carrier)\n');

% SolidWorks VBA Macro
bas_path = fullfile(export_dir, 'create_planetary_gears.bas');
write_solidworks_macro_planetary(calc, bas_path);
fprintf('   [x] Exported SolidWorks Macro: %s\n', bas_path);

% Design Report CSV
csv_path = fullfile(export_dir, 'planetary_gear_design_report.csv');
write_csv_report_planetary(calc, csv_path);
fprintf('   [x] Exported CSV Report:       %s\n', csv_path);

% Save Workspace MAT
mat_path = fullfile(suite_dir, 'planetary_design_params.mat');
save(mat_path, 'calc', 'sun_mesh', 'planet_mesh', 'ring_mesh', 'carrier_mesh');
fprintf('   [x] Saved Parameters:          %s\n\n', mat_path);

fprintf('========================================================================\n');
fprintf('   SUCCESS: Planetary Gear Design Pipeline Complete!\n');
fprintf('   Figures & CAD models exported to Solidworks/Exported_Models_Planetary/\n');
fprintf('========================================================================\n');

%% ========================================================================
%  Helper: Combine Components into Single Watertight Assembly Mesh
%  ========================================================================
function asm = assemble_planetary_mesh(sun_mesh, planet_mesh, ring_mesh, carrier_mesh, calc)
    asm = struct();
    all_v = ring_mesh.vertices;
    all_n = ring_mesh.normals;
    all_f = ring_mesh.faces;

    % Add Sun Gear
    off = size(all_v, 1);
    all_v = [all_v; sun_mesh.vertices];
    all_n = [all_n; sun_mesh.normals];
    all_f = [all_f; sun_mesh.faces + off];

    % Add K Planets
    C = calc.center_dist;
    K = calc.K;
    Ns = calc.Ns;
    Np = calc.Np;

    for k = 1:K
        th_k = (k - 1) * 2 * pi / K;
        cx = C * cos(th_k);
        cy = C * sin(th_k);

        phi_rot = th_k + th_k * (Ns / Np);
        c_p = cos(phi_rot); s_p = sin(phi_rot);
        Rz_p = [c_p -s_p 0; s_p c_p 0; 0 0 1];

        pv = (Rz_p * planet_mesh.vertices')';
        pv(:, 1) = pv(:, 1) + cx;
        pv(:, 2) = pv(:, 2) + cy;
        pn = (Rz_p * planet_mesh.normals')';

        off = size(all_v, 1);
        all_v = [all_v; pv];
        all_n = [all_n; pn];
        all_f = [all_f; planet_mesh.faces + off];
    end

    % Add Carrier
    off = size(all_v, 1);
    all_v = [all_v; carrier_mesh.vertices];
    all_n = [all_n; carrier_mesh.normals];
    all_f = [all_f; carrier_mesh.faces + off];

    asm.vertices = all_v;
    asm.normals  = all_n;
    asm.faces    = all_f;
    asm.n_verts  = size(all_v, 1);
    asm.n_faces  = size(all_f, 1);
end

%% ========================================================================
%  Helper: Write SolidWorks VBA Macro
%  ========================================================================
function write_solidworks_macro_planetary(calc, filename)
    fid = fopen(filename, 'w');
    if fid == -1, return; end
    fprintf(fid, ''' =========================================================================\n');
    fprintf(fid, ''' SOLIDWORKS VBA MACRO: PARAMETRIC PLANETARY GEAR DRIVE\n');
    fprintf(fid, ''' Wind Turbine Pitch Control System\n');
    fprintf(fid, ''' Module: %g mm, Sun: %dT, Planet: %dT (x%d), Ring: %dT\n', ...
        calc.m, calc.Ns, calc.Np, calc.K, calc.Nr);
    fprintf(fid, ''' Ratio: 1:%.2f, Center Distance: %.2f mm, Face Width: %.2f mm\n', ...
        calc.i_ratio, calc.center_dist, calc.F);
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
    fprintf(fid, '    MsgBox "Planetary Gear Parameters Loaded:" & vbCrLf & _\n');
    fprintf(fid, '           "Module: %g mm" & vbCrLf & _\n', calc.m);
    fprintf(fid, '           "Sun Teeth: %d" & vbCrLf & _\n', calc.Ns);
    fprintf(fid, '           "Planet Teeth: %d (x%d)" & vbCrLf & _\n', calc.Np, calc.K);
    fprintf(fid, '           "Ring Teeth: %d" & vbCrLf & _\n', calc.Nr);
    fprintf(fid, '           "Willis Ratio: 1:%.2f" & vbCrLf & _\n', calc.i_ratio);
    fprintf(fid, '           "Center Distance: %.2f mm", vbInformation, "Gear Master Suite"\n', calc.center_dist);
    fprintf(fid, 'End Sub\n');
    fclose(fid);
end

%% ========================================================================
%  Helper: Write CSV Design Report
%  ========================================================================
function write_csv_report_planetary(calc, filename)
    fid = fopen(filename, 'w');
    if fid == -1, return; end
    fprintf(fid, 'Parameter,Value,Unit,Notes\n');
    fprintf(fid, 'Gear Type,Planetary (Epicyclic) Gear Train,-,Sun + K Planets + Ring + Carrier\n');
    fprintf(fid, 'Module (m),%g,mm,Standard metric module\n', calc.m);
    fprintf(fid, 'Sun Gear Teeth (Ns),%d,-,Central input gear\n', calc.Ns);
    fprintf(fid, 'Planet Gear Teeth (Np),%d,-,Planetary idler gears\n', calc.Np);
    fprintf(fid, 'Ring Gear Teeth (Nr),%d,-,Nr = Ns + 2*Np (Coaxiality condition)\n', calc.Nr);
    fprintf(fid, 'Number of Planets (K),%d,-,Equally spaced around carrier\n', calc.K);
    fprintf(fid, 'Symmetric Assembly OK,%s,-,(Ns + Nr)/K = %g\n', string(calc.is_symmetric), calc.assembly_index);
    fprintf(fid, 'Willis Reduction Ratio (i),%.2f,-,i = 1 + Nr/Ns\n', calc.i_ratio);
    fprintf(fid, 'Center Distance (C),%.3f,mm,Carrier pin orbit radius\n', calc.center_dist);
    fprintf(fid, 'Face Width (F),%.2f,mm,Axial tooth width\n', calc.F);
    fprintf(fid, 'Pressure Angle (phi),%.1f,deg,Standard involute angle\n', calc.phi_deg);
    fprintf(fid, 'Sun Pitch Diameter,%.3f,mm,ds = m * Ns\n', calc.ds);
    fprintf(fid, 'Planet Pitch Diameter,%.3f,mm,dp = m * Np\n', calc.dp);
    fprintf(fid, 'Ring Pitch Diameter,%.3f,mm,dr = m * Nr\n', calc.dr);
    fprintf(fid, 'Outer Rim Diameter,%.3f,mm,Outer casing mounting cylinder\n', calc.D_outer);
    fprintf(fid, 'Adjacent Planet Clearance,%.3f,mm,Clearance between planet tips\n', calc.clearance_adjacent_planets);
    fprintf(fid, 'Sun-Planet Contact Ratio,%.3f,-,External involute mesh\n', calc.CR_sp);
    fprintf(fid, 'Planet-Ring Contact Ratio,%.3f,-,Internal involute mesh\n', calc.CR_pr);
    fprintf(fid, 'Input Sun Speed,%.1f,RPM,Motor drive speed\n', calc.n_in_sun);
    fprintf(fid, 'Carrier Output Speed,%.1f,RPM,Pitch drive output speed\n', calc.n_carrier_out);
    fprintf(fid, 'Planet Relative Speed on Pin,%.1f,RPM,Spin on needle/pin bearing\n', calc.n_planet_relative);
    fprintf(fid, 'Input Sun Torque,%.2f,N*m,Nominal motor torque\n', calc.T_in_sun);
    fprintf(fid, 'Carrier Output Torque,%.2f,N*m,Tc = Ts * i * eta\n', calc.T_carrier_out);
    fprintf(fid, 'Tangential Force / Mesh,%.1f,N,Ft with AGMA K_gamma\n', calc.Ft);
    fprintf(fid, 'Sun Bending SF,%.1f,-,Lewis bending safety factor\n', calc.SF_b_s);
    fprintf(fid, 'Planet Bending SF,%.1f,-,Reversed fatigue bending SF\n', calc.SF_b_p);
    fprintf(fid, 'Ring Bending SF,%.1f,-,Internal tooth bending SF\n', calc.SF_b_r);
    fprintf(fid, 'Sun-Planet Contact SF,%.1f,-,Hertzian contact safety factor\n', calc.SF_contact_sp);
    fprintf(fid, 'Planet-Ring Contact SF,%.1f,-,Conforming contact safety factor\n', calc.SF_contact_pr);
    fclose(fid);
end
