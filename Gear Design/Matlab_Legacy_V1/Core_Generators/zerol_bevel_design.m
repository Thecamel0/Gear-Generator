%% ========================================================================
%  ZEROL BEVEL GEAR DESIGN — Wind Turbine Pitch Control System
%  ========================================================================
%  Comprehensive design tool for Zerol bevel gear pairs.
%  Based on AGMA / Gleason standards — 20 deg full-depth tooth system.
%
%  Features:
%    - Full geometry, force, stress, and contact ratio calculations
%    - Multi-pinion configuration (1-6 pinions per ring gear)
%    - Interactive 3D model with assembly + exploded views
%    - STL export for SolidWorks (File > Open > .stl)
%
%  Usage:
%    1. Set the input parameters in the section below
%    2. Run this script in MATLAB
%    3. Review the console output and 3D figures
%    4. Find STL files in the ../Solidworks/ folder
%
%  Author:  Ahmed Majdy Ahmed
%  Date:    2026-08-05
% =========================================================================

clear; clc; close all;

% Automatically add script folder, Exporters, and parent Matlab folder to MATLAB search path
script_folder = fileparts(mfilename('fullpath'));
if ~isempty(script_folder)
    matlab_root = fileparts(script_folder);
    addpath(script_folder);
    addpath(fullfile(matlab_root, 'Exporters'));
    addpath(fullfile(matlab_root, 'Core_Generators'));
    addpath(matlab_root);
end


%% ========================================================================
%  INPUT PARAMETERS — Modify these to match your application
%  ========================================================================

% --- Multi-Pinion Configuration ---
n_pinions = 3;      % Number of blade pinions driven by the central ring gear [1-6]
                     % (3 = one per blade, typical for wind turbine pitch)

% --- Gear Tooth Parameters ---
m       = 3;        % Module [mm] — tooth size (mm of pitch diameter per tooth)
Np      = 16;       % Number of pinion teeth (driven blade pitch pinion)
Ng      = 48;       % Number of gear (ring) teeth (driver connected to worm wheel)
phi_deg = 20;       % Pressure angle [degrees] — AGMA standard
Sigma   = 90;       % Shaft angle [degrees] — central-to-blade layout
psi_deg = 0;        % Spiral angle [degrees] — 0 for Zerol 35 degrees for Spiral

% --- Tooth Depth & Clearance Factors ---
khw_factor = 2.20;  % Working depth factor (hw = khw_factor * m) [Standard: 2.00, Deep-Tooth: 2.15-2.25]
c_factor   = 0.35; % Bottom clearance factor (c = c_factor * m) [Gleason std: 0.188]

% --- Operating Conditions (Drivetrain: Motor -> Worm Stage -> Ring Gear -> 3 Pinions) ---
n_in_ring   = 100;   % Central ring gear speed from worm gear stage [RPM]
T_in_ring   = 50;  % Total input torque delivered to central ring gear by worm wheel [N*m]
eta         = 0.97; % Estimated mesh efficiency per bevel pair

% --- Geometry Factors ---
f_factor = 0.28;    % Face width as fraction of outer cone distance (AGMA recommended ~0.28-0.30)

% --- Material Properties (for stress estimates) ---
sigma_allow_bend = 250;  % Allowable bending stress [MPa] (hardened steel)
sigma_allow_cont = 1400; % Allowable contact stress [MPa] (case-hardened)

%% ========================================================================
%  DERIVED / CALCULATED PARAMETERS
%  ========================================================================

% --- Validate inputs ---
assert(n_pinions >= 1 && n_pinions <= 6, ...
    'Number of pinions must be between 1 and 6.');
assert(Np >= 13, ...
    'Pinion teeth < 13 risks undercutting at 20 deg pressure angle.');

% --- Angular conversions ---
phi     = deg2rad(phi_deg);         % Pressure angle [rad]
Sigma_r = deg2rad(Sigma);           % Shaft angle [rad]
psi_r   = deg2rad(psi_deg);         % Spiral angle [rad]

% --- Gear ratio ---
i_ratio = Ng / Np;                  % Gear ratio (48/16 = 3.0)

% --- Pitch diameters ---
dp = m * Np;        % Pinion pitch diameter [mm]
dg = m * Ng;        % Gear (ring) pitch diameter [mm]

% --- Pitch cone angles ---
gamma_p = atan2(sin(Sigma_r), (Ng/Np + cos(Sigma_r)));  % Pinion [rad]
gamma_g = Sigma_r - gamma_p;                              % Gear [rad]

% --- Cone distances ---
Ao = dp / (2 * sin(gamma_p));   % Outer cone distance [mm]
F  = f_factor * Ao;              % Face width [mm]
Am = Ao - F/2;                   % Mean cone distance [mm]
Ai = Ao - F;                     % Inner cone distance [mm]

% --- Tooth dimensions (Gleason Unequal Addendum & Balanced Thickness System) ---
% Long addendum + thickened pinion root maximizes bending strength and eliminates undercutting
% Short addendum + thinned gear prevents tooth tip pointing
hw      = khw_factor * m;                % Working depth [mm] (6.600 mm for khw=2.20)
c_std   = c_factor * m;                  % Gleason standard clearance [mm] (0.564 mm)
ht      = hw + c_std;                    % Whole depth [mm] (7.164 mm for khw=2.20)

% Gleason unequal addendum split (60% Pinion / 40% Gear of working depth):
a_p     = 0.600 * hw;                    % Long addendum pinion [mm] (3.960 mm)
a_g     = 0.400 * hw;                    % Short addendum gear [mm] (2.640 mm)

% Dedendums
b_p     = ht - a_p;                      % Pinion dedendum [mm] (3.204 mm)
b_g     = ht - a_g;                      % Gear dedendum [mm] (4.524 mm)

% Circular tooth thickness at pitch circle (Gleason tooth thickness balance)
s_nom   = pi * m / 2;                    % Standard reference tooth thickness [mm]
s_shift = 0.180 * m;                     % Tooth thickness shift [mm] (0.540 mm)
s_p     = s_nom + s_shift;               % Thickened pinion tooth [mm] (5.252 mm)
s_g     = s_nom - s_shift;               % Thinned gear tooth [mm] (4.172 mm)
tooth_thick = s_nom;                     % Reference circular pitch thickness [mm]

% --- Outside diameters ---
Do_p = dp + 2 * a_p * cos(gamma_p);
Do_g = dg + 2 * a_g * cos(gamma_g);

% --- Back cone radius (Tregold's approximation) ---
rb_p = dp / (2 * cos(gamma_p));
rb_g = dg / (2 * cos(gamma_g));

% --- Virtual (equivalent) number of teeth ---
Nv_p = Np / cos(gamma_p);
Nv_g = Ng / cos(gamma_g);

% --- Circular & diametral pitch ---
pc   = pi * m;                      % Circular pitch [mm]
P_d  = 25.4 / m;                    % Diametral pitch [teeth/inch]

% --- Contact ratio (Tregold's virtual spur gear) ---
rv_p  = m * Nv_p / 2;               % Virtual pinion pitch radius
rv_g  = m * Nv_g / 2;               % Virtual gear pitch radius
rav_p = rv_p + a_p;
rav_g = rv_g + a_g;
rbv_p = rv_p * cos(phi);
rbv_g = rv_g * cos(phi);
pb    = pi * m * cos(phi);          % Base pitch

CR = (sqrt(rav_p^2 - rbv_p^2) + sqrt(rav_g^2 - rbv_g^2) - ...
     (rv_p + rv_g) * sin(phi)) / pb;

% --- Mounting distances ---
MD_p = Ao * cos(gamma_p) - a_p * sin(gamma_p);
MD_g = Ao * cos(gamma_g) - a_g * sin(gamma_g);

% --- AGMA / ISO Manufacturing & Assembly Tolerances (AGMA Class 10 / ISO Grade 6) ---
j_n_min         = 0.025 * m + 0.05;              % Minimum normal backlash [mm] (AGMA 2005-D03)
j_n_max         = 0.040 * m + 0.08;              % Maximum normal backlash [mm]
j_n_nominal     = (j_n_min + j_n_max) / 2;       % Nominal normal backlash [mm]
tol_MD_p        = 0.030;                         % Pinion mounting distance tolerance [±mm]
tol_MD_g        = 0.030;                         % Gear mounting distance tolerance [±mm]
tol_Sigma       = 2.0;                           % Shaft angle alignment tolerance [±arcmin]
tol_Sigma_deg   = tol_Sigma / 60;              % Shaft angle alignment tolerance [±deg]
tol_Axis_offset = 0.025;                         % Axis offset / out-of-plane runout tolerance [±mm]
delta_sn        = -(j_n_nominal / (2 * cos(phi)));% Tooth thickness allowance for backlash [mm]
tol_sn          = 0.025;                         % Tooth thickness tolerance [±mm]
f_pt            = 0.012;                         % Single pitch deviation tolerance [mm] (AGMA 10)
F_p             = 0.035;                         % Total cumulative pitch deviation tolerance [mm]
F_r             = 0.028;                         % Radial runout tolerance [mm]

% --- Drivetrain Kinematics & Power (Ring Gear = Driver, 3 Pinions = Driven) ---
n_ring_in       = n_in_ring;                     % Ring gear input speed [RPM]
n_pinion_out    = n_ring_in * i_ratio;           % Pinion output speed (step-up to blades) [RPM]
T_ring_total    = T_in_ring;                     % Total input torque from worm wheel [N*m]
T_ring_per_mesh = T_ring_total / n_pinions;      % Torque distributed per pinion mesh [N*m]
T_pinion_each   = (T_ring_per_mesh / i_ratio) * eta; % Output torque delivered per blade [N*m]
T_pinion_total  = T_pinion_each * n_pinions;     % Total output torque delivered to all blades [N*m]

P_in_total      = T_ring_total * 2 * pi * n_ring_in / 60;        % Total input power from worm wheel [W]
P_out_each      = T_pinion_each * 2 * pi * n_pinion_out / 60;    % Output power delivered per blade [W]
P_out_total     = P_out_each * n_pinions;                        % Total output power delivered to blades [W]

% --- Gear forces (per pinion mesh, at mean cone distance) ---
dg_mean = dg * Am / Ao;                         % Mean pitch diameter ring gear [mm]
dp_mean = dp * Am / Ao;                         % Mean pitch diameter pinion [mm]
Ft = 2 * T_ring_per_mesh * 1000 / dg_mean;      % Tangential mesh force [N]

% Zerol: spiral angle = 0, so axial/radial forces from pressure angle only
Fr_g = Ft * tan(phi) * cos(gamma_g);            % Ring gear radial force [N]
Fa_g = Ft * tan(phi) * sin(gamma_g);            % Ring gear axial thrust [N]
Fr_p = Ft * tan(phi) * cos(gamma_p);            % Pinion radial force [N]
Fa_p = Ft * tan(phi) * sin(gamma_p);            % Pinion axial thrust [N]
F_resultant = sqrt(Ft^2 + Fr_p^2 + Fa_p^2);    % Mesh resultant force [N]
Ft_total_ring = Ft * n_pinions;                 % Combined tangential tooth force on ring gear [N]

% --- Lewis bending stress estimate (per pinion mesh with Gleason thickness factor) ---
m_mean = m * Am / Ao;
Y_p = (0.484 - 2.87 / Nv_p) * (s_p / s_nom)^2;   % Lewis form factor (pinion - thickened)
Y_g = (0.484 - 2.87 / Nv_g) * (s_g / s_nom)^2;   % Lewis form factor (gear - thinned)
sigma_b_p = Ft / (F * m_mean * Y_p);             % Pinion bending stress [MPa]
sigma_b_g = Ft / (F * m_mean * Y_g);             % Gear bending stress [MPa]
SF_p = sigma_allow_bend / sigma_b_p;             % Safety factor pinion
SF_g = sigma_allow_bend / sigma_b_g;             % Safety factor gear

% --- Pitch line velocity ---
v_pitch = pi * dg_mean * n_ring_in / (60 * 1000); % [m/s]

%% ========================================================================
%  DISPLAY RESULTS
%  ========================================================================

fprintf('\n');
fprintf([repmat('=', 1, 70) '\n']);
fprintf('      ZEROL BEVEL GEAR DESIGN - WIND TURBINE PITCH CONTROL\n');
fprintf('       Architecture: Motor -> Worm Stage -> Ring Gear -> 3 Pinions\n');
fprintf([repmat('=', 1, 70) '\n']);

fprintf('\n--- DRIVETRAIN OPERATING CONDITIONS ');
fprintf([repmat('-', 1, 33) '\n']);
fprintf('  Drivetrain Configuration: Central Ring Gear (Driver) -> %d Pinions (Driven)\n', n_pinions);
fprintf('  Worm Wheel Input Torque : %8.2f N*m (Total applied to Ring Gear)\n', T_ring_total);
fprintf('  Ring Gear Input Speed   : %8.2f RPM\n', n_ring_in);
fprintf('  Torque per Pinion Mesh  : %8.2f N*m (Split equally among %d pinions)\n', T_ring_per_mesh, n_pinions);
fprintf('  Mesh efficiency         : %8.1f %%\n', eta*100);
fprintf('  Tooth System            : Gleason Unequal Addendum (Industrial Bevel Standard)\n');

fprintf('\n--- GEAR RATIO & PERFORMANCE ');
fprintf([repmat('-', 1, 42) '\n']);
fprintf('  Speed Ratio (Ring:Pinion): 1 : %-4.2f (Step-Up to blades)\n', i_ratio);
fprintf('  Blade Pinion Output Speed: %8.2f RPM\n', n_pinion_out);
fprintf('  Pitch line velocity      : %8.4f m/s\n', v_pitch);
fprintf('  ---- Per Blade Output ----\n');
fprintf('  Torque to each blade     : %8.2f N*m\n', T_pinion_each);
fprintf('  Power to each blade      : %8.2f W  (%.3f kW)\n', P_out_each, P_out_each/1000);
fprintf('  ---- Total Drivetrain ----\n');
fprintf('  Total Input Power        : %8.2f W  (%.3f kW)\n', P_in_total, P_in_total/1000);
fprintf('  Total Output Power       : %8.2f W  (%.3f kW)\n', P_out_total, P_out_total/1000);

fprintf('\n--- PITCH GEOMETRY ');
fprintf([repmat('-', 1, 51) '\n']);
fprintf('  %-26s %10s %10s\n', 'Parameter', 'Pinion (Blade)', 'Ring Gear (Worm)');
fprintf('  %-26s %9.2f %10.2f  mm\n', 'Pitch diameter', dp, dg);
fprintf('  %-26s %9.2f %10.2f  deg\n', 'Pitch cone angle', rad2deg(gamma_p), rad2deg(gamma_g));
fprintf('  %-26s %9.2f %10.2f  mm\n', 'Outside diameter', Do_p, Do_g);
fprintf('  %-26s %9.2f %10.2f  mm\n', 'Back cone radius', rb_p, rb_g);
fprintf('  %-26s %9.2f %10.2f\n', 'Virtual teeth (Tregold)', Nv_p, Nv_g);
fprintf('  %-26s %9.2f %10.2f  mm\n', 'Mounting distance', MD_p, MD_g);

fprintf('\n--- CONE DISTANCES ');
fprintf([repmat('-', 1, 51) '\n']);
fprintf('  Outer cone distance (Ao): %8.2f mm\n', Ao);
fprintf('  Mean cone distance (Am) : %8.2f mm\n', Am);
fprintf('  Inner cone distance (Ai): %8.2f mm\n', Ai);
fprintf('  Face width (F)          : %8.2f mm (%.2f * Ao, %.2f * m)\n', F, f_factor, F/m);

fprintf('\n--- TOOTH PROPORTIONS ');
fprintf([repmat('-', 1, 48) '\n']);
fprintf('  %-26s %10s %10s\n', 'Dimension', 'Pinion (Blade)', 'Ring Gear (Worm)');
fprintf('  %-26s %9.3f %10.3f  mm\n', 'Addendum', a_p, a_g);
fprintf('  %-26s %9.3f %10.3f  mm\n', 'Dedendum', b_p, b_g);
fprintf('  Working depth (hw)      : %8.3f mm\n', hw);
fprintf('  Whole depth (ht)        : %8.3f mm\n', ht);
fprintf('  Clearance (c)           : %8.3f mm\n', c_std);
fprintf('  Circular tooth thickness: %8.3f mm\n', tooth_thick);
fprintf('  Circular pitch (pc)     : %8.3f mm\n', pc);
fprintf('  Diametral pitch (Pd)    : %8.3f teeth/in\n', P_d);

fprintf('\n--- AGMA / ISO MANUFACTURING & ASSEMBLY TOLERANCES ');
fprintf([repmat('-', 1, 18) '\n']);
fprintf('  AGMA Quality Class      : AGMA 10 (ISO Grade 6)\n');
fprintf('  Normal Backlash (j_n)   : %6.3f - %6.3f mm  (Nominal: %.3f ± %.3f mm)\n', ...
    j_n_min, j_n_max, j_n_nominal, (j_n_max - j_n_min)/2);
fprintf('  Pinion Mounting Tol (ΔMD_p): ±%5.3f mm\n', tol_MD_p);
fprintf('  Gear Mounting Tol   (ΔMD_g): ±%5.3f mm\n', tol_MD_g);
fprintf('  Shaft Angle Tol     (ΔΣ)  : ±%5.1f arcmin (±%.4f deg)\n', tol_Sigma, tol_Sigma_deg);
fprintf('  Axis Offset Tol     (ΔE)  : ±%5.3f mm\n', tol_Axis_offset);
fprintf('  Tooth Thickness Red. (Δs_n): %6.3f ± %.3f mm\n', delta_sn, tol_sn);
fprintf('  Single Pitch Error  (f_pt): %6.3f mm\n', f_pt);
fprintf('  Total Pitch Error   (F_p) : %6.3f mm\n', F_p);
fprintf('  Radial Runout       (F_r) : %6.3f mm\n', F_r);

fprintf('\n--- CONTACT RATIO ');
fprintf([repmat('-', 1, 52) '\n']);
fprintf('  Contact ratio (CR)      : %8.3f\n', CR);
if CR >= 1.7
    fprintf('  Status                  : EXCELLENT (Robust contact overlap)\n');
elseif CR >= 1.4
    fprintf('  Status                  : GOOD (adequate overlap)\n');
elseif CR >= 1.2
    fprintf('  Status                  : ACCEPTABLE\n');
else
    fprintf('  Status                  : *** WARNING - Low CR! ***\n');
end

fprintf('\n--- GEAR MESH FORCES (Per Pinion Mesh) ');
fprintf([repmat('-', 1, 31) '\n']);
fprintf('  %-26s %10s %10s\n', 'Force Component', 'Pinion (Blade)', 'Ring Gear (Worm)');
fprintf('  %-26s %9.1f %10.1f  N\n', 'Tangential (Ft)', Ft, Ft);
fprintf('  %-26s %9.1f %10.1f  N\n', 'Radial (Fr)', Fr_p, Fr_g);
fprintf('  %-26s %9.1f %10.1f  N\n', 'Axial thrust (Fa)', Fa_p, Fa_g);
fprintf('  Resultant force         : %8.1f N\n', F_resultant);
fprintf('  Total tangential on Ring: %8.1f N (All %d pinions combined)\n', Ft_total_ring, n_pinions);

fprintf('\n--- BENDING STRESS & SAFETY FACTOR (Lewis) ');
fprintf([repmat('-', 1, 27) '\n']);
fprintf('  %-26s %10s %10s\n', 'Parameter', 'Pinion (Blade)', 'Ring Gear (Worm)');
fprintf('  %-26s %9.3f %10.3f\n', 'Lewis form factor (Y)', Y_p, Y_g);
fprintf('  %-26s %9.1f %10.1f  MPa\n', 'Bending stress', sigma_b_p, sigma_b_g);
fprintf('  %-26s %9.2f %10.2f\n', 'Safety factor (SF)', SF_p, SF_g);
if SF_p >= 1.5 && SF_g >= 1.5
    fprintf('  Structural Status       : >>> SAFE & DURABLE (SF >= 1.5) <<<\n');
elseif SF_p >= 1.0 && SF_g >= 1.0
    fprintf('  Structural Status       : >>> ACCEPTABLE (SF >= 1.0) <<<\n');
else
    fprintf('  Structural Status       : *** WARNING - High Stress! ***\n');
end

fprintf('\n');
fprintf([repmat('=', 1, 70) '\n']);

%% ========================================================================
%  3D VISUALIZATION & 2D INTERSECTION / TOLERANCE DIAGRAMS
%  ========================================================================
fprintf('\nGenerating 3D model and 2D intersection/tolerance diagrams...\n');

% Pack parameters into structure
params.m            = m;
params.Np           = Np;
params.Ng           = Ng;
params.phi          = phi;
params.gamma_p      = gamma_p;
params.gamma_g      = gamma_g;
params.Ao           = Ao;
params.Am           = Am;
params.Ai           = Ai;
params.F            = F;
params.a_p          = a_p;
params.b_p          = b_p;
params.a_g          = a_g;
params.b_g          = b_g;
params.hw           = hw;
params.ht           = ht;
params.c_std        = c_std;
params.khw_factor   = khw_factor;
params.a            = a_p;   % default fallback
params.b            = b_p;   % default fallback
params.dp           = dp;
params.dg           = dg;
params.Do_p         = Do_p;
params.Do_g         = Do_g;
params.MD_p         = MD_p;
params.MD_g         = MD_g;
params.s_p          = s_p;
params.s_g          = s_g;
params.Sigma        = Sigma_r;
params.n_pinions    = n_pinions;
params.n_ring_in    = n_ring_in;
params.n_pinion_out = n_pinion_out;
params.T_ring_total = T_ring_total;
params.T_ring_per_mesh = T_ring_per_mesh;
params.T_pinion_each   = T_pinion_each;
params.P_in_total      = P_in_total;
params.P_out_each      = P_out_each;
params.P_out_total     = P_out_total;
params.Ft              = Ft;
params.Fr_p            = Fr_p;
params.Fa_p            = Fa_p;
params.F_resultant     = F_resultant;
params.sigma_b_p       = sigma_b_p;
params.sigma_b_g       = sigma_b_g;
params.SF_p            = SF_p;
params.SF_g            = SF_g;
params.eta             = eta;

% Tolerance parameters
params.j_n_min         = j_n_min;
params.j_n_max         = j_n_max;
params.j_n_nominal     = j_n_nominal;
params.tol_MD_p        = tol_MD_p;
params.tol_MD_g        = tol_MD_g;
params.tol_Sigma       = tol_Sigma;
params.tol_Sigma_deg   = tol_Sigma_deg;
params.tol_Axis_offset = tol_Axis_offset;
params.delta_sn        = delta_sn;
params.tol_sn          = tol_sn;
params.f_pt            = f_pt;
params.F_p             = F_p;
params.F_r             = F_r;
params.CR              = CR;

% Save design parameters for simulation synchronization
param_file = fullfile(script_folder, 'zerol_design_params.mat');
save(param_file, 'params');

[pinion_mesh, gear_mesh] = generate_zerol_bevel_3d(params);

%% ========================================================================
%  STL EXPORT FOR SOLIDWORKS
%  ========================================================================
fprintf('\nExporting STL files for SolidWorks...\n');

% Determine path to the Solidworks/Exported_Models folder
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end
gear_design_dir = fileparts(fileparts(script_dir));
stl_dir = fullfile(gear_design_dir, 'Solidworks', 'Exported_Models');
if ~exist(stl_dir, 'dir')
    stl_dir = fullfile(gear_design_dir, 'Solidworks');
    if ~exist(stl_dir, 'dir')
        mkdir(stl_dir);
    end
end

export_gear_stl(pinion_mesh, fullfile(stl_dir, 'zerol_pinion.stl'), ...
    sprintf('Zerol Pinion m%g Np%d', m, Np));
export_gear_stl(gear_mesh, fullfile(stl_dir, 'zerol_gear.stl'), ...
    sprintf('Zerol Gear m%g Ng%d', m, Ng));

fprintf('\nExporting STEP, OBJ, IGS & STL files for SolidWorks / CATIA import...\n');
export_gear_step(pinion_mesh, fullfile(stl_dir, 'zerol_pinion.stp'), ...
    sprintf('Zerol Pinion m%g Np%d', m, Np));
export_gear_step(gear_mesh, fullfile(stl_dir, 'zerol_gear.stp'), ...
    sprintf('Zerol Gear m%g Ng%d', m, Ng));

export_gear_obj(pinion_mesh, fullfile(stl_dir, 'zerol_pinion.obj'), ...
    sprintf('Zerol Pinion m%g Np%d', m, Np));
export_gear_obj(gear_mesh, fullfile(stl_dir, 'zerol_gear.obj'), ...
    sprintf('Zerol Gear m%g Ng%d', m, Ng));

% IGES 5.3 export — compatible with SolidWorks and CATIA V5/V6
export_gear_igs(pinion_mesh, fullfile(stl_dir, 'zerol_pinion.igs'), ...
    sprintf('Zerol Pinion m%g Np%d', m, Np));
export_gear_igs(gear_mesh, fullfile(stl_dir, 'zerol_gear.igs'), ...
    sprintf('Zerol Gear m%g Ng%d', m, Ng));

% Export SolidWorks Macro & Equations
export_solidworks_macro(params, fullfile(gear_design_dir, 'Solidworks'));

fprintf('\n');
fprintf([repmat('=', 1, 70) '\n']);
fprintf('  DESIGN COMPLETE\n');
fprintf([repmat('=', 1, 70) '\n']);
fprintf('  Files saved to: %s\n', stl_dir);
fprintf('    1. zerol_pinion.stp / zerol_gear.stp  (STEP AP214 Solid Body — SolidWorks & CATIA)\n');
fprintf('    2. zerol_pinion.igs / zerol_gear.igs  (IGES 5.3 Surface Body — SolidWorks & CATIA)\n');
fprintf('    3. zerol_pinion.obj / zerol_gear.obj  (Wavefront 3D Mesh)\n');
fprintf('    4. zerol_pinion.stl / zerol_gear.stl  (STL 3D Mesh)\n');
fprintf('    5. Solidworks/Macros/create_zerol_bevel_gears.bas (SolidWorks VBA Macro)\n');
fprintf('    6. Solidworks/zerol_bevel_equations.txt (SolidWorks Equations Import)\n');
fprintf('\n  SolidWorks: File > Open > select file  (choose .igs or .stp)\n');
fprintf('  CATIA V5/V6: File > Open > select file  (choose .igs or .stp)\n');
fprintf('\n');
fprintf([repmat('=', 1, 70) '\n\n']);

%% ========================================================================
%  SOLIDWORKS TOOLBOX — BEVEL GEAR PARAMETER TABLE
%  ========================================================================
%  Use these values in SolidWorks:
%    Toolbox > Power Transmission > Gears > Bevel Gear
%  Enter the parameters below for the Pinion and Gear separately.

fprintf([repmat('=', 1, 70) '\n']);
fprintf('  SOLIDWORKS TOOLBOX — BEVEL GEAR PARAMETERS\n');
fprintf('  Standard : ANSI Metric  (module-based, all dims in mm)\n');
fprintf('  Path     : Toolbox > ANSI Metric > Power Transmission > Gears\n');
fprintf('\n');
fprintf('  Item to create         Toolbox component to use\n');
fprintf('  %-22s %s\n', sprintf('Pinion (%d teeth)', Np),  '>> Straight Bevel (Pinion)');
fprintf('  %-22s %s\n', sprintf('Ring Gear (%d teeth)', Ng),'>> Straight Bevel (Gear)');
fprintf('\n');
fprintf('  NOTE: Toolbox has no Zerol option. Use Straight Bevel\n');
fprintf('  (spiral angle = 0 deg is identical to Zerol geometry).\n');
fprintf([repmat('=', 1, 70) '\n\n']);

% Derived parameters for Toolbox & CAD Modeling
bore_pin  = 0.0;                  % Solid gear — no shaft hole
bore_gear = 0.0;                  % Solid gear — no center opening
hub_pin   = 36.0;                  % Pinion hub collar diameter [mm]
hub_gear  = 72.0;                  % Ring gear inner boss diameter [mm]
p_circ    = pi * m;                % Circular pitch [mm]
Pd        = 25.4 / m;              % Diametral pitch [teeth/in]

fprintf([repmat('=', 1, 70) '\n']);
fprintf('  SOLIDWORKS PROPERTYMANAGER — QUICK DATA ENTRY TABLE\n');
fprintf('  (Matches the exact fields & top-to-bottom order in SolidWorks UI)\n');
fprintf([repmat('=', 1, 70) '\n\n']);

fprintf('  %-28s %18s %18s\n', 'SolidWorks UI Field Name', 'Pinion Entry', 'Gear Entry');
fprintf('  %s\n', repmat('-', 1, 68));
fprintf('  %-28s %18g %18g\n',     'Module:',                    m, m);
fprintf('  %-28s %18d %18d\n',     'Number of Teeth:',          Np, Ng);
fprintf('  %-28s %18d %18d  <-- Swapped!\n', 'Gear''s No. of Teeth:', Ng, Np);
fprintf('  %-28s %18g %18g\n',     'Pressure Angle:',           rad2deg(phi), rad2deg(phi));
fprintf('  %-28s %18.2f %18.2f\n', 'Face Width:',               F, F);
fprintf('  %-28s %18.2f %18.2f  (Suggested)\n', 'Hub Diameter:', hub_pin, hub_gear);
fprintf('  %-28s %18.2f %18.2f\n', 'Mounting Distance:',        MD_p, MD_g);
fprintf('  %-28s %18.1f %18.1f  (Solid)\n',     'Nominal Shaft Diameter:', bore_pin, bore_gear);
fprintf('  %-28s %18s %18s\n',     'Keyway:',                   'None', 'None');
fprintf('  %-28s %18d %18d\n',     'Show Teeth:',               Np, Ng);
fprintf('\n');

fprintf([repmat('=', 1, 70) '\n']);
fprintf('  FULL AGMA / ISO GEOMETRY REFERENCE TABLE\n');
fprintf([repmat('=', 1, 70) '\n\n']);

fprintf('  %-34s %12s %12s\n', 'Parameter', 'Pinion (Blade)', 'Ring Gear (Worm)');
fprintf('  %s\n', repmat('-', 1, 58));
fprintf('  %-34s %12g %12g\n',     'Module [mm]',               m, m);
fprintf('  %-34s %12d %12d\n',     'Number of teeth',           Np, Ng);
fprintf('  %-34s %12.1f %12.1f\n', 'Pressure angle [deg]',      rad2deg(phi), rad2deg(phi));
fprintf('  %-34s %12.1f %12.1f\n', 'Shaft angle [deg]',         rad2deg(Sigma_r), rad2deg(Sigma_r));
fprintf('  %-34s %12s %12s\n',     'Spiral angle [deg]',        '0 (Zerol)', '0 (Zerol)');
fprintf('  %-34s %12.2f %12.2f\n', 'Pitch diameter [mm]',       dp, dg);
fprintf('  %-34s %12.2f %12.2f\n', 'Outside diameter [mm]',     Do_p, Do_g);
fprintf('  %-34s %12.2f %12.2f\n', 'Pitch cone angle [deg]',    rad2deg(gamma_p), rad2deg(gamma_g));
fprintf('  %-34s %12.3f %12.3f\n', 'Addendum [mm]',             a_p, a_g);
fprintf('  %-34s %12.3f %12.3f\n', 'Dedendum [mm]',             b_p, b_g);
fprintf('  %-34s %12.3f %12.3f\n', 'Working depth [mm]',        hw, hw);
fprintf('  %-34s %12.3f %12.3f\n', 'Whole depth [mm]',          ht, ht);
fprintf('  %-34s %12.3f %12.3f\n', 'Clearance [mm]',            c_std, c_std);
fprintf('  %-34s %12.3f %12.3f\n', 'Circular tooth thick [mm]', s_p, s_g);
fprintf('  %-34s %12.2f %12.2f\n', 'Face width [mm]',           F, F);
fprintf('  %-34s %12.2f %12.2f\n', 'Outer cone distance [mm]',  Ao, Ao);
fprintf('  %-34s %12.2f %12.2f\n', 'Mounting distance [mm]',    MD_p, MD_g);
fprintf('  %-34s %12.3f %12.3f\n', 'Circular pitch [mm]',       p_circ, p_circ);
fprintf('  %-34s %12.3f %12.3f\n', 'Diametral pitch [teeth/in]', Pd, Pd);
fprintf('  %-34s %12.2f %12.2f\n', 'Back cone radius [mm]',     rb_p, rb_g);
fprintf('  %-34s %12.1f %12.1f\n', 'Bore diameter [mm] (*)',    bore_pin, bore_gear);
fprintf('\n');
fprintf('  (*) Bore diameters: 0.0 mm (Solid gear blank without central hole).\n');
fprintf('\n');

fprintf('  --- Tolerance Specs (for drawing GD&T) ---\n');
fprintf('  %-34s %s\n', 'AGMA Quality Class',        'AGMA 10 (ISO Grade 6)');
fprintf('  %-34s %.3f - %.3f mm\n', 'Normal backlash (j_n)',    j_n_min, j_n_max);
fprintf('  %-34s ±%.3f mm\n',       'Mounting distance tol',    tol_MD_p);
fprintf('  %-34s ±%.1f arcmin\n',   'Shaft angle tol',          tol_Sigma);
fprintf('  %-34s ±%.3f mm\n',       'Axis offset tol',          tol_Axis_offset);
fprintf('  %-34s %.3f mm\n',        'Single pitch error (f_pt)', f_pt);
fprintf('  %-34s %.3f mm\n',        'Total pitch error (F_p)',  F_p);
fprintf('  %-34s %.3f mm\n',        'Radial runout (F_r)',      F_r);
fprintf('\n');
fprintf([repmat('=', 1, 70) '\n\n']);


% =========================================================================
%  LOCAL FUNCTIONS — Embedded so the script is 100% self-contained
% =========================================================================

function [pinion_mesh, gear_mesh] = generate_zerol_bevel_3d(params)
    % Resolution Parameters
    n_inv = 20;       % Points per involute curve segment
    n_sec = 16;       % Cross-sections along face width
    n_top = 4;        % Interior points on top land arc
    n_root = 4;       % Interior points on root arc
    n_rad = 3;        % Points on radial line

    % Build Meshes (Supports Gleason Unequal Addendum)
    if isfield(params, 'a_p') && isfield(params, 'b_p')
        a_p = params.a_p;  b_p = params.b_p;
    else
        a_p = params.a;    b_p = params.b;
    end

    if isfield(params, 'a_g') && isfield(params, 'b_g')
        a_g = params.a_g;  b_g = params.b_g;
    else
        a_g = params.a;    b_g = params.b;
    end

    if isfield(params, 's_p')
        s_p = params.s_p;
    else
        s_p = pi * params.m / 2;
    end

    if isfield(params, 's_g')
        s_g = params.s_g;
    else
        s_g = pi * params.m / 2;
    end

    pinion_mesh = build_bevel_mesh(params.Np, params.m, params.phi, ...
        a_p, b_p, params.gamma_p, params.Ao, params.F, ...
        n_inv, n_sec, n_top, n_root, n_rad, 0, s_p);

    gear_mesh = build_bevel_mesh(params.Ng, params.m, params.phi, ...
        a_g, b_g, params.gamma_g, params.Ao, params.F, ...
        n_inv, n_sec, n_top, n_root, n_rad, 0, s_g);

    fprintf('  Pinion mesh: %d vertices, %d triangles\n', ...
        size(pinion_mesh.vertices,1), size(pinion_mesh.faces,1));
    fprintf('  Gear mesh:   %d vertices, %d triangles\n', ...
        size(gear_mesh.vertices,1), size(gear_mesh.faces,1));

    % Figure 1 — 3D Assembly View
    fig1 = figure('Name', 'Zerol Bevel Gear - 3D Assembly', ...
                  'NumberTitle', 'off', ...
                  'Position', [50 50 1400 850], ...
                  'Color', [0.10 0.10 0.13]);

    % --- Left subplot: Full assembly with all pinions ---
    ax1 = subplot(1, 2, 1, 'Parent', fig1);
    hold(ax1, 'on');

    % Ring gear placed naturally on horizontal plane (Z is central gear axis)
    patch(ax1, 'Vertices', gear_mesh.vertices, ...
          'Faces', gear_mesh.faces, ...
          'FaceColor', [0.78 0.52 0.28], ...
          'EdgeColor', 'none', ...
          'FaceAlpha', 0.92, ...
          'FaceLighting', 'gouraud', ...
          'AmbientStrength', 0.35, ...
          'DiffuseStrength', 0.65, ...
          'SpecularStrength', 0.4);

    n_pinions = params.n_pinions;
    pinion_colors = [0.45 0.58 0.78;
                     0.55 0.75 0.55;
                     0.72 0.48 0.65;
                     0.78 0.68 0.45;
                     0.50 0.70 0.75;
                     0.70 0.55 0.55];

    Ry90 = [0 0 1; 0 1 0; -1 0 0];

    % Tooth clocking: rotate pinion by half-pitch (pi/Np = 11.25 deg)
    % so pinion teeth drop directly into gear valleys (zero tip-on-tip collision)
    phi_clock = pi / params.Np;
    R_clock = [cos(phi_clock) -sin(phi_clock) 0; sin(phi_clock) cos(phi_clock) 0; 0 0 1];

    for p = 1:n_pinions
        angle_offset = (p - 1) * 2 * pi / n_pinions;
        c = cos(angle_offset);
        s = sin(angle_offset);
        Rz = [c -s 0; s c 0; 0 0 1];

        % Phase synchronization for each pinion position around ring gear
        phase_angle = angle_offset * (params.Ng / params.Np);
        R_phase = [cos(phase_angle) -sin(phase_angle) 0; sin(phase_angle) cos(phase_angle) 0; 0 0 1];

        R_pinion = Rz * Ry90 * R_clock * R_phase;

        pinion_verts = (R_pinion * pinion_mesh.vertices')';

        color_idx = mod(p-1, size(pinion_colors,1)) + 1;
        patch(ax1, 'Vertices', pinion_verts, ...
              'Faces', pinion_mesh.faces, ...
              'FaceColor', pinion_colors(color_idx,:), ...
              'EdgeColor', 'none', ...
              'FaceAlpha', 0.92, ...
              'FaceLighting', 'gouraud', ...
              'AmbientStrength', 0.35, ...
              'DiffuseStrength', 0.65, ...
              'SpecularStrength', 0.4);
    end

    light(ax1, 'Position', [1 1 1],    'Style', 'infinite');
    light(ax1, 'Position', [-1 -1 0.5], 'Style', 'infinite');

    axis(ax1, 'equal');
    grid(ax1, 'on');
    xlabel(ax1, 'X [mm]'); ylabel(ax1, 'Y [mm]'); zlabel(ax1, 'Z [mm]');
    title(ax1, sprintf('Assembly: %d Pinion(s) + Ring Gear', n_pinions), ...
          'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');
    view(ax1, [-40 25]);
    set(ax1, 'Color', [0.15 0.15 0.19], ...
             'XColor', [0.7 0.7 0.7], ...
             'YColor', [0.7 0.7 0.7], ...
             'ZColor', [0.7 0.7 0.7], ...
             'GridColor', [0.3 0.3 0.3]);

    % Exploded view
    ax2 = subplot(1, 2, 2, 'Parent', fig1);
    hold(ax2, 'on');

    sep = params.Ao * 0.30;

    patch(ax2, 'Vertices', gear_mesh.vertices - [0 0 sep], ...
          'Faces', gear_mesh.faces, ...
          'FaceColor', [0.78 0.52 0.28], ...
          'EdgeColor', [0.5 0.33 0.18], ...
          'EdgeAlpha', 0.15, ...
          'FaceAlpha', 0.90, ...
          'FaceLighting', 'gouraud', ...
          'AmbientStrength', 0.35);

    pinion1_verts = (Ry90 * pinion_mesh.vertices')';
    patch(ax2, 'Vertices', pinion1_verts + [sep 0 0], ...
          'Faces', pinion_mesh.faces, ...
          'FaceColor', [0.45 0.58 0.78], ...
          'EdgeColor', [0.28 0.36 0.48], ...
          'EdgeAlpha', 0.15, ...
          'FaceAlpha', 0.90, ...
          'FaceLighting', 'gouraud', ...
          'AmbientStrength', 0.35);

    light(ax2, 'Position', [1 0.5 1], 'Style', 'infinite');
    light(ax2, 'Position', [-0.5 -1 0.5], 'Style', 'infinite');

    axis(ax2, 'equal');
    grid(ax2, 'on');
    xlabel(ax2, 'X [mm]'); ylabel(ax2, 'Y [mm]'); zlabel(ax2, 'Z [mm]');
    title(ax2, 'Exploded View (Single Pair)', ...
          'Color', 'w', 'FontSize', 14, 'FontWeight', 'bold');
    view(ax2, [-30 20]);
    set(ax2, 'Color', [0.15 0.15 0.19], ...
             'XColor', [0.7 0.7 0.7], ...
             'YColor', [0.7 0.7 0.7], ...
             'ZColor', [0.7 0.7 0.7], ...
             'GridColor', [0.3 0.3 0.3]);

    rotate3d(fig1, 'on');

    % Figure 2 — 2D Tooth Profile Cross-Sections (Gleason Proportions)
    fig2 = figure('Name', 'Zerol Bevel Gear - Tooth Profiles', ...
        'NumberTitle', 'off', ...
        'Position', [150 100 1200 550], ...
        'Color', [0.10 0.10 0.13]);

    for gear_idx = 1:2
        ax = subplot(1, 2, gear_idx, 'Parent', fig2);
        hold(ax, 'on');

        if gear_idx == 1
            N = params.Np;
            label = 'Pinion (Blade - Long Addendum & Thickened)';
            fc = [0.45 0.58 0.78];
            a_curr = a_p;
            b_curr = b_p;
            s_curr = s_p;
        else
            N = params.Ng;
            label = 'Ring Gear (Worm - Short Addendum)';
            fc = [0.78 0.52 0.28];
            a_curr = a_g;
            b_curr = b_g;
            s_curr = s_g;
        end

        r_p = params.m * N / 2;
        r_b = r_p * cos(params.phi);
        r_a = r_p + a_curr;
        r_d = r_p - b_curr;

        [angles, radii] = gear_profile_polar(N, params.m, params.phi, ...
            a_curr, b_curr, n_inv, n_top, n_root, n_rad, [], s_curr);

        px = radii .* cos(angles);
        py = radii .* sin(angles);

        fill(ax, px, py, fc, 'EdgeColor', fc*0.6, 'LineWidth', 0.3, 'FaceAlpha', 0.7);

        theta_circ = linspace(0, 2*pi, 200);
        plot(ax, r_p * cos(theta_circ), r_p * sin(theta_circ), '--', ...
            'Color', [1 1 0.3], 'LineWidth', 1.2);
        plot(ax, r_b * cos(theta_circ), r_b * sin(theta_circ), ':', ...
            'Color', [0.3 1 0.3], 'LineWidth', 1.0);
        plot(ax, r_a * cos(theta_circ), r_a * sin(theta_circ), '-', ...
            'Color', [1 0.4 0.4], 'LineWidth', 1.0);
        plot(ax, r_d * cos(theta_circ), r_d * sin(theta_circ), '-', ...
            'Color', [0.4 0.7 1], 'LineWidth', 1.0);

        legend(ax, {label, 'Pitch circle', 'Base circle', ...
            'Addendum circle', 'Dedendum circle'}, ...
            'TextColor', 'w', 'Color', [0.2 0.2 0.25], ...
            'Location', 'northeast', 'FontSize', 8);

        axis(ax, 'equal');
        grid(ax, 'on');
        xlabel(ax, 'X [mm]'); ylabel(ax, 'Y [mm]');
        title(ax, sprintf('%s (N=%d, m=%g)', label, N, params.m), ...
            'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
        set(ax, 'Color', [0.15 0.15 0.19], ...
            'XColor', [0.7 0.7 0.7], ...
            'YColor', [0.7 0.7 0.7], ...
            'GridColor', [0.3 0.3 0.3]);

        tooth_angle = 2*pi/N;
        zoom_range = r_a * 1.15;
        xlim(ax, [r_d*0.85 zoom_range]);
        ylim(ax, [-zoom_range * sin(1.5*tooth_angle), zoom_range * sin(1.5*tooth_angle)]);
    end

    % Figure 3 — 2D Pinion-Gear Meshing Diagram (Filled Tooth Profiles)
    fig3 = figure('Name', 'Zerol Bevel Gear - 2D Pinion-Gear Meshing Diagram', ...
        'NumberTitle', 'off', ...
        'Position', [120 60 1400 700], ...
        'Color', [0.10 0.10 0.13]);

    % Use actual gear parameters for cross-section profiles
    Np  = params.Np;
    Ng  = params.Ng;
    m   = params.m;
    phi = params.phi;

    r_p_pin = m * Np / 2;   % Pinion pitch radius
    r_p_gear = m * Ng / 2;  % Gear pitch radius
    r_b_pin = r_p_pin * cos(phi);
    r_b_gear = r_p_gear * cos(phi);
    r_a_pin = r_p_pin + a_p;
    r_a_gear = r_p_gear + a_g;
    r_d_pin = r_p_pin - b_p;
    r_d_gear = r_p_gear - b_g;
    C_dist = r_p_pin + r_p_gear;  % Center distance

    % Generate tooth profiles
    [ang_pin, rad_pin] = gear_profile_polar(Np, m, phi, a_p, b_p, n_inv, n_top, n_root, n_rad, [], s_p);
    [ang_gear, rad_gear] = gear_profile_polar(Ng, m, phi, a_g, b_g, n_inv, n_top, n_root, n_rad, [], s_g);

    % Rotate pinion so a tooth points upward toward the gear
    rot_pin = pi/2;
    px_pin = rad_pin .* cos(ang_pin + rot_pin);
    py_pin = rad_pin .* sin(ang_pin + rot_pin);

    % Rotate gear so a tooth gap faces downward toward the pinion
    rot_gear = -pi/2 - pi/Ng;
    px_gear = rad_gear .* cos(ang_gear + rot_gear);
    py_gear = rad_gear .* sin(ang_gear + rot_gear) + C_dist;

    theta_circ = linspace(0, 2*pi, 300);
    fc_pin  = [0.45 0.58 0.78];
    fc_gear = [0.78 0.52 0.28];

    % --- Subplot 1: Full Meshing View ---
    ax3_1 = subplot(1, 2, 1, 'Parent', fig3);
    hold(ax3_1, 'on');

    % Filled tooth profiles
    fill(ax3_1, px_pin, py_pin, fc_pin, 'EdgeColor', fc_pin*0.6, 'LineWidth', 0.3, 'FaceAlpha', 0.7);
    fill(ax3_1, px_gear, py_gear, fc_gear, 'EdgeColor', fc_gear*0.6, 'LineWidth', 0.3, 'FaceAlpha', 0.7);

    % Reference circles — Pinion (centered at origin)
    plot(ax3_1, r_p_pin*cos(theta_circ), r_p_pin*sin(theta_circ), '--', 'Color', [1 1 0.3], 'LineWidth', 1.2);
    plot(ax3_1, r_b_pin*cos(theta_circ), r_b_pin*sin(theta_circ), ':', 'Color', [0.3 1 0.3], 'LineWidth', 1.0);
    plot(ax3_1, r_a_pin*cos(theta_circ), r_a_pin*sin(theta_circ), '-', 'Color', [1 0.4 0.4], 'LineWidth', 1.0);
    plot(ax3_1, r_d_pin*cos(theta_circ), r_d_pin*sin(theta_circ), '-', 'Color', [0.4 0.7 1], 'LineWidth', 1.0);

    % Reference circles — Gear (centered at [0, C_dist])
    plot(ax3_1, r_p_gear*cos(theta_circ), C_dist + r_p_gear*sin(theta_circ), '--', 'Color', [1 1 0.3], 'LineWidth', 1.2);
    plot(ax3_1, r_b_gear*cos(theta_circ), C_dist + r_b_gear*sin(theta_circ), ':', 'Color', [0.3 1 0.3], 'LineWidth', 1.0);
    plot(ax3_1, r_a_gear*cos(theta_circ), C_dist + r_a_gear*sin(theta_circ), '-', 'Color', [1 0.4 0.4], 'LineWidth', 1.0);
    plot(ax3_1, r_d_gear*cos(theta_circ), C_dist + r_d_gear*sin(theta_circ), '-', 'Color', [0.4 0.7 1], 'LineWidth', 1.0);

    % Pitch point marker
    plot(ax3_1, 0, r_p_pin, 'yo', 'MarkerSize', 10, 'MarkerFaceColor', 'y');
    text(ax3_1, 3, r_p_pin, 'Pitch Point (P)', 'Color', 'y', 'FontSize', 10, 'FontWeight', 'bold');

    % Center markers
    plot(ax3_1, 0, 0, 'w+', 'MarkerSize', 10, 'LineWidth', 1.5);
    plot(ax3_1, 0, C_dist, 'w+', 'MarkerSize', 10, 'LineWidth', 1.5);
    text(ax3_1, 3, 0, 'Pinion Center', 'Color', 'w', 'FontSize', 8);
    text(ax3_1, 3, C_dist, 'Gear Center', 'Color', 'w', 'FontSize', 8);

    legend(ax3_1, {'Pinion', 'Ring Gear', 'Pitch circle', 'Base circle', ...
        'Addendum circle', 'Dedendum circle'}, ...
        'TextColor', 'w', 'Color', [0.2 0.2 0.25], ...
        'Location', 'northeast', 'FontSize', 8);

    axis(ax3_1, 'equal');
    grid(ax3_1, 'on');
    xlabel(ax3_1, 'X [mm]'); ylabel(ax3_1, 'Y [mm]');
    title(ax3_1, sprintf('Pinion-Gear Meshing (Np=%d, Ng=%d, m=%g)', Np, Ng, m), ...
        'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    set(ax3_1, 'Color', [0.15 0.15 0.19], ...
        'XColor', [0.7 0.7 0.7], ...
        'YColor', [0.7 0.7 0.7], ...
        'GridColor', [0.3 0.3 0.3]);

    % Zoom to show full pinion and meshing zone
    ylim(ax3_1, [-r_a_pin*1.15, r_p_pin + r_a_gear*0.5]);

    % --- Subplot 2: Zoomed Meshing Zone ---
    ax3_2 = subplot(1, 2, 2, 'Parent', fig3);
    hold(ax3_2, 'on');

    % Filled tooth profiles (zoomed)
    fill(ax3_2, px_pin, py_pin, fc_pin, 'EdgeColor', fc_pin*0.6, 'LineWidth', 0.5, 'FaceAlpha', 0.75);
    fill(ax3_2, px_gear, py_gear, fc_gear, 'EdgeColor', fc_gear*0.6, 'LineWidth', 0.5, 'FaceAlpha', 0.75);

    % Reference circles — Pinion
    plot(ax3_2, r_p_pin*cos(theta_circ), r_p_pin*sin(theta_circ), '--', 'Color', [1 1 0.3], 'LineWidth', 1.2);
    plot(ax3_2, r_a_pin*cos(theta_circ), r_a_pin*sin(theta_circ), '-', 'Color', [1 0.4 0.4], 'LineWidth', 1.0);
    plot(ax3_2, r_d_pin*cos(theta_circ), r_d_pin*sin(theta_circ), '-', 'Color', [0.4 0.7 1], 'LineWidth', 1.0);

    % Reference circles — Gear
    plot(ax3_2, r_p_gear*cos(theta_circ), C_dist + r_p_gear*sin(theta_circ), '--', 'Color', [1 1 0.3], 'LineWidth', 1.2);
    plot(ax3_2, r_a_gear*cos(theta_circ), C_dist + r_a_gear*sin(theta_circ), '-', 'Color', [1 0.4 0.4], 'LineWidth', 1.0);
    plot(ax3_2, r_d_gear*cos(theta_circ), C_dist + r_d_gear*sin(theta_circ), '-', 'Color', [0.4 0.7 1], 'LineWidth', 1.0);

    % Pitch point
    plot(ax3_2, 0, r_p_pin, 'yo', 'MarkerSize', 10, 'MarkerFaceColor', 'y');
    text(ax3_2, 1, r_p_pin - 2, sprintf('Pitch Point\nCR = %.3f', params.CR), ...
        'Color', 'y', 'FontSize', 9, 'FontWeight', 'bold');

    % Backlash annotation
    j_n = params.j_n_nominal;
    text(ax3_2, -r_a_pin*0.9, r_p_pin + 12, ...
        sprintf('Backlash j_n = %.3f mm\n(%.3f - %.3f mm)', j_n, params.j_n_min, params.j_n_max), ...
        'Color', [0.4 0.9 1.0], 'FontSize', 9, 'FontWeight', 'bold');

    legend(ax3_2, {'Pinion', 'Ring Gear', 'Pitch circle', 'Addendum circle', ...
        'Dedendum circle'}, ...
        'TextColor', 'w', 'Color', [0.2 0.2 0.25], ...
        'Location', 'northwest', 'FontSize', 8);

    axis(ax3_2, 'equal');
    grid(ax3_2, 'on');
    xlabel(ax3_2, 'X [mm]'); ylabel(ax3_2, 'Y [mm]');
    title(ax3_2, 'Zoomed Tooth Meshing Zone', ...
        'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    set(ax3_2, 'Color', [0.15 0.15 0.19], ...
        'XColor', [0.7 0.7 0.7], ...
        'YColor', [0.7 0.7 0.7], ...
        'GridColor', [0.3 0.3 0.3]);

    % Zoom to meshing zone — show ~3 teeth around pitch point
    tooth_angle_pin = 2*pi/Np;
    zoom_x = r_a_pin * sin(2.0 * tooth_angle_pin);
    xlim(ax3_2, [-zoom_x zoom_x]);
    ylim(ax3_2, [r_d_pin*0.85, C_dist - r_d_gear*0.85]);

    fprintf('  Figures generated: 3D Assembly, 2D Tooth Profiles, 2D Meshing Diagram.\n');
end


function mesh = build_bevel_mesh(N, m, phi, a, b, gamma, Ao, F, ...
                                  n_inv, n_sec, n_top, n_root, n_rad, r_bore, tooth_thick)
    if nargin < 14 || isempty(r_bore)
        r_bore = 0;   % Default: Solid gear (no center hole)
    end
    if nargin < 15 || isempty(tooth_thick)
        tooth_thick = pi * m / 2;
    end

    [angles, radii] = gear_profile_polar(N, m, phi, a, b, ...
                                          n_inv, n_top, n_root, n_rad, [], tooth_thick);
    M = length(angles);

    Ai = Ao - F;
    cone_dists = linspace(Ai, Ao, n_sec);
    z_positions = cone_dists * cos(gamma);
    scale_factors = cone_dists / Ao;

    % 1. Lateral tooth surface vertices
    n_tooth_verts = n_sec * M;
    tooth_verts = zeros(n_tooth_verts, 3);
    for s = 1:n_sec
        sc = scale_factors(s);
        r_s = radii * sc;
        idx = (s-1)*M + (1:M);
        tooth_verts(idx, 1) = r_s .* cos(angles);
        tooth_verts(idx, 2) = r_s .* sin(angles);
        tooth_verts(idx, 3) = z_positions(s);
    end

    % Lateral tooth faces (outward pointing)
    [S, K] = ndgrid(1:n_sec-1, 1:M);
    K_next = mod(K, M) + 1;

    v1 = (S-1).*M + K;
    v2 = (S-1).*M + K_next;
    v3 = S.*M     + K_next;
    v4 = S.*M     + K;

    v1 = v1(:);  v2 = v2(:);  v3 = v3(:);  v4 = v4(:);
    lat_faces = [v1 v2 v3; v1 v3 v4];

    k_vec = 1:M;
    k_next_vec = mod(k_vec, M) + 1;

    if r_bore > 0
        % 2. Inner & Outer bore circle vertices
        bore_inner_verts = [r_bore * cos(angles(:)), r_bore * sin(angles(:)), repmat(z_positions(1), M, 1)];
        bore_outer_verts = [r_bore * cos(angles(:)), r_bore * sin(angles(:)), repmat(z_positions(end), M, 1)];
        vertices = [tooth_verts; bore_inner_verts; bore_outer_verts];

        % Inner annular cap (between inner teeth and inner bore)
        idx_bore_inner = n_tooth_verts + (1:M);
        t1 = k_vec(:);
        t2 = k_next_vec(:);
        b1 = idx_bore_inner(k_vec)';
        b2 = idx_bore_inner(k_next_vec)';
        inner_cap_faces = [t1, b2, b1; t1, t2, b2];

        % Outer annular cap (between outer teeth and outer bore)
        idx_tooth_outer = (n_sec - 1) * M;
        idx_bore_outer = n_tooth_verts + M + (1:M);
        t1_o = idx_tooth_outer + k_vec(:);
        t2_o = idx_tooth_outer + k_next_vec(:);
        b1_o = idx_bore_outer(k_vec)';
        b2_o = idx_bore_outer(k_next_vec)';
        outer_cap_faces = [t1_o, b1_o, b2_o; t1_o, b2_o, t2_o];

        % Bore inner cylinder faces
        bore_cyl_faces = [b1, b2_o, b1_o; b1, b2, b2_o];

        mesh.vertices = vertices;
        mesh.faces    = [lat_faces; inner_cap_faces; outer_cap_faces; bore_cyl_faces];
    else
        % Solid gear (NO hole) — Cap cleanly to center axis
        c_inner = [0, 0, z_positions(1)];
        c_outer = [0, 0, z_positions(end)];
        vertices = [tooth_verts; c_inner; c_outer];

        idx_c_in  = n_tooth_verts + 1;
        idx_c_out = n_tooth_verts + 2;

        t1 = k_vec(:);
        t2 = k_next_vec(:);
        % Inner cap pointing towards -Z (outward at toe end)
        inner_cap_faces = [t1, repmat(idx_c_in, M, 1), t2];

        % Outer cap pointing towards +Z (outward at heel end)
        idx_tooth_outer = (n_sec - 1) * M;
        t1_o = idx_tooth_outer + k_vec(:);
        t2_o = idx_tooth_outer + k_next_vec(:);
        outer_cap_faces = [t1_o, t2_o, repmat(idx_c_out, M, 1)];

        mesh.vertices = vertices;
        mesh.faces    = [lat_faces; inner_cap_faces; outer_cap_faces];
    end
end


function [angles, radii] = gear_profile_polar(N, m, phi, a, b, ...
                                               n_inv, n_top, n_root, n_rad, backlash, tooth_thick)
    if nargin < 10 || isempty(backlash)
        backlash = 0.22; % [mm] AGMA Class 10 standard normal backlash
    end
    if nargin < 11 || isempty(tooth_thick)
        tooth_thick = pi * m / 2;
    end

    r_p = m * N / 2;
    r_b = r_p * cos(phi);
    r_a = r_p + a;
    r_d = r_p - b;
    if r_d < 0.3 * r_b
        r_d = 0.3 * r_b;
    end

    % Half-tooth angle with AGMA backlash tooth thinning (widens tooth gap space)
    delta_sn = backlash / (2 * cos(phi));
    tau = (tooth_thick - delta_sn) / (2 * r_p);
    if tau < 0.05 * (pi/N)
        tau = 0.05 * (pi/N);
    end

    inv_phi = tan(phi) - phi;

    root_below_base = (r_d < r_b);
    r_inv_start = max(r_b, r_d);

    alpha_add = acos(min(r_b / r_a, 1));
    theta_tip = tau + inv_phi - (tan(alpha_add) - alpha_add);

    if root_below_base
        theta_root_edge = tau + inv_phi;
    else
        alpha_ded = acos(min(r_b / r_d, 1));
        theta_root_edge = tau + inv_phi - (tan(alpha_ded) - alpha_ded);
    end

    theta_next_root = 2*pi/N - theta_root_edge;

    tooth_r = [];
    tooth_t = [];

    if root_below_base
        rr = linspace(r_d, r_b, n_rad);
        tt = -(tau + inv_phi) * ones(1, n_rad);
        tooth_r = [tooth_r, rr];
        tooth_t = [tooth_t, tt];
    end

    rr = linspace(r_inv_start, r_a, n_inv);
    alpha = acos(min(r_b ./ rr, 1));
    inv_alpha = tan(alpha) - alpha;
    tt = -(tau + inv_phi - inv_alpha);
    tooth_r = [tooth_r, rr];
    tooth_t = [tooth_t, tt];

    tt_top = linspace(-theta_tip, theta_tip, n_top + 2);
    tt_top = tt_top(2:end-1);
    rr_top = r_a * ones(1, n_top);
    tooth_r = [tooth_r, rr_top];
    tooth_t = [tooth_t, tt_top];

    rr = linspace(r_a, r_inv_start, n_inv);
    alpha = acos(min(r_b ./ rr, 1));
    inv_alpha = tan(alpha) - alpha;
    tt = (tau + inv_phi - inv_alpha);
    tooth_r = [tooth_r, rr];
    tooth_t = [tooth_t, tt];

    if root_below_base
        rr = linspace(r_b, r_d, n_rad);
        tt = (tau + inv_phi) * ones(1, n_rad);
        tooth_r = [tooth_r, rr];
        tooth_t = [tooth_t, tt];
    end

    tt_root = linspace(theta_root_edge, theta_next_root, n_root + 2);
    tt_root = tt_root(2:end-1);
    rr_root = r_d * ones(1, n_root);
    tooth_r = [tooth_r, rr_root];
    tooth_t = [tooth_t, tt_root];

    M_tooth = length(tooth_r);
    M_total = N * M_tooth;

    angles = zeros(1, M_total);
    radii  = zeros(1, M_total);

    for t = 0:(N-1)
        offset = t * 2*pi/N;
        idx = t * M_tooth + (1:M_tooth);
        angles(idx) = tooth_t + offset;
        radii(idx)  = tooth_r;
    end
end


function export_gear_stl(mesh, filename, header_text)
    vertices = mesh.vertices;
    faces    = mesh.faces;
    n_faces  = size(faces, 1);

    v1 = vertices(faces(:,1), :);
    v2 = vertices(faces(:,2), :);
    v3 = vertices(faces(:,3), :);

    edge1   = v2 - v1;
    edge2   = v3 - v1;
    normals = cross(edge1, edge2, 2);

    mag = sqrt(sum(normals.^2, 2));
    mag(mag < eps) = 1;
    normals = normals ./ mag;

    out_dir = fileparts(filename);
    if ~isempty(out_dir) && ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    fid = fopen(filename, 'wb');
    if fid == -1
        error('export_gear_stl:fileOpen', 'Cannot open file: %s', filename);
    end

    try
        header = char(zeros(1, 80));
        txt = header_text(1:min(end, 79));
        header(1:length(txt)) = txt;
        fwrite(fid, header, 'char');

        fwrite(fid, n_faces, 'uint32');

        for k = 1:n_faces
            fwrite(fid, normals(k,:), 'float32');
            fwrite(fid, v1(k,:),      'float32');
            fwrite(fid, v2(k,:),      'float32');
            fwrite(fid, v3(k,:),      'float32');
            fwrite(fid, 0,            'uint16');
        end
    catch ME
        fclose(fid);
        rethrow(ME);
    end

    fclose(fid);

    info = dir(filename);
    fprintf('  STL saved: %s  (%d triangles, %.1f KB)\n', ...
            filename, n_faces, info.bytes/1024);
end 