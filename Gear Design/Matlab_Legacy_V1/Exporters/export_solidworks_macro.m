function export_solidworks_macro(params, stl_dir)
%EXPORT_SOLIDWORKS_MACRO Generates SolidWorks VBA Macro (.swp / .bas) & Equations (.txt)
%
%   Generates a SolidWorks VBA Macro script that programmatically builds
%   fully parametric 3D Zerol Bevel Pinion and Ring Gear models in SolidWorks.
%   Also exports an Equations import file (zerol_bevel_equations.txt).
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-06

if nargin < 2 || isempty(stl_dir)
    script_dir = fileparts(mfilename('fullpath'));
    stl_dir = fullfile(script_dir, '..', 'Solidworks');
end

if ~exist(stl_dir, 'dir')
    mkdir(stl_dir);
end

bas_filename = fullfile(stl_dir, 'create_zerol_bevel_gears.bas');
vba_filename = fullfile(stl_dir, 'create_zerol_bevel_gears.swp.txt');
eqn_filename = fullfile(stl_dir, 'zerol_bevel_equations.txt');

% --- Extract Parameters ---
m      = params.m;
Np     = params.Np;
Ng     = params.Ng;
phi    = rad2deg(params.phi);
gp_deg = rad2deg(params.gamma_p);
gg_deg = rad2deg(params.gamma_g);
dp     = params.dp;
dg     = params.dg;
Do_p   = params.Do_p;
Do_g   = params.Do_g;
F      = params.F;
Ao     = params.Ao;
MD_p   = params.MD_p;
MD_g   = params.MD_g;

% Wind turbine pitch drive specific hub & bore dimensions
bore_p = 0.0;   % Solid Pinion (no center hole)
hub_p  = 36.0;   % Pinion outer hub collar diameter [mm]

bore_g = 0.0;   % Solid Ring Gear (no center hole)
hub_g  = 72.0;   % Ring gear inner boss diameter [mm]

% =========================================================================
% 1. WRITE EQUATIONS TXT FILE (For Direct SolidWorks Equations Import)
% =========================================================================
fid_eq = fopen(eqn_filename, 'w');
if fid_eq ~= -1
    fprintf(fid_eq, '"Module" = %gmm\n', m);
    fprintf(fid_eq, '"PinionTeeth" = %d\n', Np);
    fprintf(fid_eq, '"GearTeeth" = %d\n', Ng);
    fprintf(fid_eq, '"PressureAngle" = %gdeg\n', phi);
    fprintf(fid_eq, '"PinionPitchDia" = %gmm\n', dp);
    fprintf(fid_eq, '"GearPitchDia" = %gmm\n', dg);
    fprintf(fid_eq, '"PinionOutDia" = %gmm\n', Do_p);
    fprintf(fid_eq, '"GearOutDia" = %gmm\n', Do_g);
    fprintf(fid_eq, '"PinionConeAngle" = %gdeg\n', gp_deg);
    fprintf(fid_eq, '"GearConeAngle" = %gdeg\n', gg_deg);
    fprintf(fid_eq, '"FaceWidth" = %gmm\n', F);
    if isfield(params, 'hw')
        fprintf(fid_eq, '"WorkingDepth" = %gmm\n', params.hw);
        fprintf(fid_eq, '"WholeDepth" = %gmm\n', params.ht);
        fprintf(fid_eq, '"PinionAddendum" = %gmm\n', params.a_p);
        fprintf(fid_eq, '"GearAddendum" = %gmm\n', params.a_g);
    end
    fprintf(fid_eq, '"PinionMountingDist" = %gmm\n', MD_p);
    fprintf(fid_eq, '"GearMountingDist" = %gmm\n', MD_g);
    fprintf(fid_eq, '"PinionBore" = %gmm\n', bore_p);
    fprintf(fid_eq, '"GearBore" = %gmm\n', bore_g);
    fclose(fid_eq);
end

% =========================================================================
% 2. WRITE SOLIDWORKS VBA MACRO FILE (.bas / .swp)
% =========================================================================
fid = fopen(bas_filename, 'w');
if fid == -1
    error('export_solidworks_macro:fileOpen', 'Cannot create macro file: %s', bas_filename);
end

q = "'"; % Single quote character for VBA comments

fprintf(fid, '%s ======================================================================\n', q);
fprintf(fid, '%s SOLIDWORKS VBA MACRO — PARAMETRIC ZEROL BEVEL GEAR CREATOR\n', q);
fprintf(fid, '%s Wind Turbine Pitch Control Drive System\n', q);
fprintf(fid, '%s Generated automatically by MATLAB Zerol Bevel Design Suite\n', q);
fprintf(fid, '%s ======================================================================\n\n', q);

fprintf(fid, 'Option Explicit\n\n');
fprintf(fid, 'Dim swApp As Object\n');
fprintf(fid, 'Dim swModel As Object\n');
fprintf(fid, 'Dim swFeatMgr As Object\n');
fprintf(fid, 'Dim swModelExt As Object\n');
fprintf(fid, 'Dim swEqnMgr As Object\n');
fprintf(fid, 'Dim swSketchMgr As Object\n');
fprintf(fid, 'Dim swSketchSegment As Object\n');
fprintf(fid, 'Dim boolstatus As Boolean\n');
fprintf(fid, 'Dim longstatus As Long, longwarnings As Long\n\n');

fprintf(fid, 'Sub main()\n');
fprintf(fid, '    Set swApp = Application.SldWorks\n\n');
fprintf(fid, '    %s 1. Create Pinion\n', q);
fprintf(fid, '    CreateBevelGear %g, %d, %d, %g, %g, %g, %g, %g, %g, %g, %g, "Zerol_Pinion"\n\n', ...
    m, Np, Ng, phi, dp, Do_p, gp_deg, F, MD_p, bore_p, hub_p);

fprintf(fid, '    %s 2. Create Ring Gear\n', q);
fprintf(fid, '    CreateBevelGear %g, %d, %d, %g, %g, %g, %g, %g, %g, %g, %g, "Zerol_Gear"\n\n', ...
    m, Ng, Np, phi, dg, Do_g, gg_deg, F, MD_g, bore_g, hub_g);

fprintf(fid, '    MsgBox "Parametric Zerol Bevel Gear Generation Complete!" & vbCrLf & _\n');
fprintf(fid, '           "Both Pinion (20T) and Gear (60T) models generated.", vbInformation, "Success"\n');
fprintf(fid, 'End Sub\n\n');

fprintf(fid, 'Sub CreateBevelGear(m As Double, N As Integer, N_match As Integer, phi As Double, _\n');
fprintf(fid, '                    d_pitch As Double, d_outer As Double, gamma_deg As Double, _\n');
fprintf(fid, '                    face_w As Double, MD As Double, bore_d As Double, hub_d As Double, _\n');
fprintf(fid, '                    partName As String)\n\n');

fprintf(fid, '    Set swModel = swApp.NewDocument(swApp.GetUserPreferenceStringValue(1), 0, 0, 0)\n');
fprintf(fid, '    If swModel Is Nothing Then Set swModel = swApp.NewPart()\n');
fprintf(fid, '    Set swModelExt = swModel.Extension\n');
fprintf(fid, '    Set swFeatMgr = swModel.FeatureManager\n');
fprintf(fid, '    Set swSketchMgr = swModel.SketchManager\n');
fprintf(fid, '    Set swEqnMgr = swModel.GetEquationMgr\n\n');

fprintf(fid, '    %s Add Equations / Global Variables\n', q);
fprintf(fid, '    swEqnMgr.Add -1, """Module"" = " & m\n');
fprintf(fid, '    swEqnMgr.Add -1, """Teeth"" = " & N\n');
fprintf(fid, '    swEqnMgr.Add -1, """MatchingTeeth"" = " & N_match\n');
fprintf(fid, '    swEqnMgr.Add -1, """PressureAngle"" = " & phi\n');
fprintf(fid, '    swEqnMgr.Add -1, """PitchDiameter"" = " & d_pitch\n');
fprintf(fid, '    swEqnMgr.Add -1, """OutsideDiameter"" = " & d_outer\n');
fprintf(fid, '    swEqnMgr.Add -1, """PitchConeAngle"" = " & gamma_deg\n');
fprintf(fid, '    swEqnMgr.Add -1, """FaceWidth"" = " & face_w\n');
fprintf(fid, '    swEqnMgr.Add -1, """MountingDistance"" = " & MD\n');
fprintf(fid, '    swEqnMgr.Add -1, """BoreDiameter"" = " & bore_d\n');
fprintf(fid, '    swModel.EditRebuild3\n\n');

fprintf(fid, '    %s Create Revolved Gear Blank\n', q);
fprintf(fid, '    boolstatus = swModelExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)\n');
fprintf(fid, '    swSketchMgr.InsertSketch True\n\n');

fprintf(fid, '    Dim rad_out As Double, MD_m As Double, fw_m As Double, gamma_rad As Double\n');
fprintf(fid, '    rad_out = (d_outer / 2) / 1000\n');
fprintf(fid, '    MD_m = MD / 1000\n');
fprintf(fid, '    fw_m = face_w / 1000\n');
fprintf(fid, '    gamma_rad = gamma_deg * 3.14159265358979 / 180#\n\n');

fprintf(fid, '    %s Draw Axis of Revolution and Mark as Centerline\n', q);
fprintf(fid, '    Set swSketchSegment = swSketchMgr.CreateCenterLine(0, 0, 0, 0, MD_m, 0)\n');
fprintf(fid, '    swSketchSegment.ConstructionGeometry = True\n\n');

fprintf(fid, '    %s Draw Closed Cone Profile\n', q);
fprintf(fid, '    Dim z_top As Double\n');
fprintf(fid, '    z_top = MD_m - (rad_out / Tan(gamma_rad))\n');
fprintf(fid, '    swSketchMgr.CreateLine 0, 0, 0, rad_out, z_top, 0\n');
fprintf(fid, '    swSketchMgr.CreateLine rad_out, z_top, 0, rad_out, z_top - fw_m, 0\n');
fprintf(fid, '    swSketchMgr.CreateLine rad_out, z_top - fw_m, 0, 0, 0, 0\n\n');

fprintf(fid, '    %s Select Centerline Axis for Revolve (Mark = 4)\n', q);
fprintf(fid, '    swSketchSegment.Select2 False, 4\n\n');

fprintf(fid, '    %s Revolve Boss/Base (360 degrees = 6.283185 rad)\n', q);
fprintf(fid, '    swFeatMgr.FeatureRevolve2 True, True, False, False, False, False, 0, 0, 6.28318530717958, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True\n');
fprintf(fid, '    swModel.ViewZoomtofit2\n\n');

fprintf(fid, '    %s Cut Bore Through All (only if bore > 0)\n', q);
fprintf(fid, '    If bore_d > 0 Then\n');
fprintf(fid, '        boolstatus = swModelExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)\n');
fprintf(fid, '        swSketchMgr.InsertSketch True\n');
fprintf(fid, '        swSketchMgr.CreateCircle 0, 0, 0, (bore_d / 2) / 1000, 0, 0\n');
fprintf(fid, '        swFeatMgr.FeatureCut3 True, False, False, 4, 0, 0.1, 0.1, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False\n');
fprintf(fid, '    End If\n');
fprintf(fid, 'End Sub\n');

fclose(fid);

copyfile(bas_filename, vba_filename);

fprintf('  SolidWorks Macro saved: %s\n', bas_filename);
fprintf('  SolidWorks Equations saved: %s\n', eqn_filename);
end
