function export_solidworks_macro(calc, out_dir)
%EXPORT_SOLIDWORKS_MACRO Generates SolidWorks automation assets:
%   1. create_helical_gears.bas   - Parametric VBA Macro
%   2. helical_equations.txt      - Global Equations file
%   3. helical_design_report.csv  - Comprehensive engineering report
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    %% 1. SolidWorks VBA Macro (.bas)
    macro_file = fullfile(out_dir, 'create_helical_gears.bas');
    fid = fopen(macro_file, 'w');
    if fid ~= -1
        fprintf(fid, ''' ======================================================================\n');
        fprintf(fid, ''' SOLIDWORKS VBA MACRO - PARAMETRIC HELICAL GEAR CREATOR\n');
        fprintf(fid, ''' Wind Turbine Pitch Control System (Parallel-Axis Drive)\n');
        fprintf(fid, ''' Generated automatically by MATLAB Helical Gear Suite\n');
        fprintf(fid, ''' ======================================================================\n\n');
        fprintf(fid, 'Option Explicit\n\n');
        fprintf(fid, 'Dim swApp As Object\n');
        fprintf(fid, 'Dim swModel As Object\n');
        fprintf(fid, 'Dim swModelExt As Object\n');
        fprintf(fid, 'Dim swFeatMgr As Object\n');
        fprintf(fid, 'Dim swSketchMgr As Object\n');
        fprintf(fid, 'Dim swEqnMgr As Object\n');
        fprintf(fid, 'Dim boolstatus As Boolean\n\n');
        fprintf(fid, 'Sub main()\n');
        fprintf(fid, '    Set swApp = Application.SldWorks\n\n');
        fprintf(fid, '    '' 1. Create Pinion (Np = %d, mn = %g mm, beta = %g deg, F = %g mm, C = %.2f mm)\n', ...
            calc.Np, calc.mn, calc.beta_deg, calc.F, calc.center_dist);
        fprintf(fid, '    CreateHelicalGear %g#, %d, %d, %g#, %g#, %g#, %g#, %g#, %g#, 16#, "Helical_Pinion_%dT"\n\n', ...
            calc.mn, calc.Np, calc.Ng, calc.beta_deg, calc.phi_n_deg, calc.dp, calc.da_p, calc.dd_p, calc.F, calc.Np);
        fprintf(fid, '    '' 2. Create Central Gear (Ng = %d, mn = %g mm, beta = %g deg, F = %g mm)\n', ...
            calc.Ng, calc.mn, calc.beta_deg, calc.F);
        fprintf(fid, '    CreateHelicalGear %g#, %d, %d, %g#, %g#, %g#, %g#, %g#, %g#, 50#, "Helical_Gear_%dT"\n\n', ...
            calc.mn, calc.Ng, calc.Np, -calc.beta_deg, calc.phi_n_deg, calc.dg, calc.da_g, calc.dd_g, calc.F, calc.Ng);
        fprintf(fid, '    MsgBox "Parametric Helical Gear Generation Complete!" & vbCrLf & _\n');
        fprintf(fid, '           "Generated: Pinion (%dT, PD=%.2fmm, RH) and Central Gear (%dT, PD=%.2fmm, LH)" & vbCrLf & _\n', ...
            calc.Np, calc.dp, calc.Ng, calc.dg);
        fprintf(fid, '           "Center Distance = %.2f mm", vbInformation, "Success"\n', calc.center_dist);
        fprintf(fid, 'End Sub\n\n');

        fprintf(fid, 'Sub CreateHelicalGear(mn As Double, N As Integer, N_match As Integer, beta As Double, phi_n As Double, _\n');
        fprintf(fid, '                      d_pitch As Double, d_tip As Double, d_root As Double, _\n');
        fprintf(fid, '                      face_w As Double, bore_d As Double, partName As String)\n\n');
        fprintf(fid, '    Set swModel = swApp.NewDocument(swApp.GetUserPreferenceStringValue(1), 0, 0, 0)\n');
        fprintf(fid, '    If swModel Is Nothing Then Set swModel = swApp.NewPart()\n');
        fprintf(fid, '    Set swModelExt = swModel.Extension\n');
        fprintf(fid, '    Set swFeatMgr = swModel.FeatureManager\n');
        fprintf(fid, '    Set swSketchMgr = swModel.SketchManager\n');
        fprintf(fid, '    Set swEqnMgr = swModel.GetEquationMgr\n\n');
        fprintf(fid, '    '' Global Variables / Parameters\n');
        fprintf(fid, '    swEqnMgr.Add -1, """NormalModule"" = " & mn\n');
        fprintf(fid, '    swEqnMgr.Add -1, """Teeth"" = " & N\n');
        fprintf(fid, '    swEqnMgr.Add -1, """HelixAngle"" = " & beta\n');
        fprintf(fid, '    swEqnMgr.Add -1, """NormalPressureAngle"" = " & phi_n\n');
        fprintf(fid, '    swEqnMgr.Add -1, """PitchDiameter"" = " & d_pitch\n');
        fprintf(fid, '    swEqnMgr.Add -1, """TipDiameter"" = " & d_tip\n');
        fprintf(fid, '    swEqnMgr.Add -1, """RootDiameter"" = " & d_root\n');
        fprintf(fid, '    swEqnMgr.Add -1, """FaceWidth"" = " & face_w\n');
        fprintf(fid, '    swEqnMgr.Add -1, """BoreDiameter"" = " & bore_d\n');
        fprintf(fid, '    swModel.EditRebuild3\n\n');
        fprintf(fid, '    '' Create Cylindrical Blank on Front Plane\n');
        fprintf(fid, '    boolstatus = swModelExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)\n');
        fprintf(fid, '    swSketchMgr.InsertSketch True\n\n');
        fprintf(fid, '    Dim r_tip_m As Double, r_bore_m As Double, fw_m As Double\n');
        fprintf(fid, '    r_tip_m = (d_tip / 2) / 1000\n');
        fprintf(fid, '    r_bore_m = (bore_d / 2) / 1000\n');
        fprintf(fid, '    fw_m = face_w / 1000\n\n');
        fprintf(fid, '    swSketchMgr.CreateCircleByRadius 0, 0, 0, r_tip_m\n');
        fprintf(fid, '    If bore_d > 0 Then\n');
        fprintf(fid, '        swSketchMgr.CreateCircleByRadius 0, 0, 0, r_bore_m\n');
        fprintf(fid, '    End If\n\n');
        fprintf(fid, '    swFeatMgr.FeatureExtrusion3 True, False, False, 0, 0, fw_m, 0.01, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False\n');
        fprintf(fid, '    swModel.ViewZoomtofit2\n');
        fprintf(fid, 'End Sub\n');
        fclose(fid);
    end

    %% 2. SolidWorks Equations File (.txt)
    eqn_file = fullfile(out_dir, 'helical_equations.txt');
    fid = fopen(eqn_file, 'w');
    if fid ~= -1
        fprintf(fid, '"NormalModule" = %gmm\n', calc.mn);
        fprintf(fid, '"PinionTeeth" = %d\n', calc.Np);
        fprintf(fid, '"GearTeeth" = %d\n', calc.Ng);
        fprintf(fid, '"HelixAngle" = %gdeg\n', calc.beta_deg);
        fprintf(fid, '"NormalPressureAngle" = %gdeg\n', calc.phi_n_deg);
        fprintf(fid, '"TransversePressureAngle" = %.3fdeg\n', calc.phi_t_deg);
        fprintf(fid, '"TransverseModule" = %.4fmm\n', calc.mt);
        fprintf(fid, '"CenterDistance" = %.3fmm\n', calc.center_dist);
        fprintf(fid, '"FaceWidth" = %.3fmm\n', calc.F);
        fprintf(fid, '"PinionPitchDia" = %.3fmm\n', calc.dp);
        fprintf(fid, '"GearPitchDia" = %.3fmm\n', calc.dg);
        fprintf(fid, '"PinionTipDia" = %.3fmm\n', calc.da_p);
        fprintf(fid, '"GearTipDia" = %.3fmm\n', calc.da_g);
        fprintf(fid, '"PinionRootDia" = %.3fmm\n', calc.dd_p);
        fprintf(fid, '"GearRootDia" = %.3fmm\n', calc.dd_g);
        fprintf(fid, '"PinionBore" = 16.0mm\n');
        fprintf(fid, '"GearBore" = 50.0mm\n');
        fclose(fid);
    end

    %% 3. Engineering Design Report (.csv)
    csv_file = fullfile(out_dir, 'helical_design_report.csv');
    fid = fopen(csv_file, 'w');
    if fid ~= -1
        fprintf(fid, 'Parameter,Value,Unit,Notes\n');
        fprintf(fid, 'Gear Type,External Helical Gear,-,Parallel shaft wind turbine pitch actuator\n');
        fprintf(fid, 'Normal Module (mn),%g,mm,Standard metric normal module\n', calc.mn);
        fprintf(fid, 'Transverse Module (mt),%.4f,mm,mt = mn / cos(beta)\n', calc.mt);
        fprintf(fid, 'Pinion Tooth Count (Np),%d,-,Driving blade pitch pinion\n', calc.Np);
        fprintf(fid, 'Gear Tooth Count (Ng),%d,-,Central pitch actuator bull gear\n', calc.Ng);
        fprintf(fid, 'Gear Ratio (i),%.2f,-,1:%.1f reduction\n', calc.i_ratio, calc.i_ratio);
        fprintf(fid, 'Helix Angle (beta),%g,deg,Pinion RH / Gear LH\n', calc.beta_deg);
        fprintf(fid, 'Normal Pressure Angle (phi_n),%g,deg,Standard 20 deg normal cutter\n', calc.phi_n_deg);
        fprintf(fid, 'Transverse Pressure Angle (phi_t),%.3f,deg,tan(phi_t) = tan(phi_n)/cos(beta)\n', calc.phi_t_deg);
        fprintf(fid, 'Center Distance (C),%.3f,mm,C = (dp + dg) / 2\n', calc.center_dist);
        fprintf(fid, 'Face Width (F),%.3f,mm,F >= px for continuous overlap\n', calc.F);
        fprintf(fid, 'Driving Pinions Count,%d,-,3 pinions spaced at 120 deg\n', calc.n_pinions);
        fprintf(fid, 'Pinion Pitch Diameter (dp),%.3f,mm,dp = mt * Np\n', calc.dp);
        fprintf(fid, 'Gear Pitch Diameter (dg),%.3f,mm,dg = mt * Ng\n', calc.dg);
        fprintf(fid, 'Pinion Tip Diameter (da_p),%.3f,mm,da_p = dp + 2*mn\n', calc.da_p);
        fprintf(fid, 'Gear Tip Diameter (da_g),%.3f,mm,da_g = dg + 2*mn\n', calc.da_g);
        fprintf(fid, 'Working Depth (hw),%.3f,mm,hw = 2.0 * mn\n', calc.hw);
        fprintf(fid, 'Whole Depth (ht),%.3f,mm,ht = 2.25 * mn\n', calc.ht);
        fprintf(fid, 'Clearance (c),%.3f,mm,c = 0.25 * mn\n', calc.c_std);
        fprintf(fid, 'Transverse Contact Ratio (eps_alpha),%.3f,-,Transverse plane profile overlap\n', calc.eps_alpha);
        fprintf(fid, 'Axial Overlap Ratio (eps_beta),%.3f,-,eps_beta = F * sin(beta) / (pi * mn)\n', calc.eps_beta);
        fprintf(fid, 'Total Contact Ratio (eps_gamma),%.3f,-,eps_gamma = eps_alpha + eps_beta\n', calc.eps_gamma);
        fprintf(fid, 'Input Ring Torque,%g,N*m,Pitch ring torque\n', calc.T_in_ring);
        fprintf(fid, 'Ring Speed,%g,RPM,Pitch ring operational speed\n', calc.n_in_ring);
        fprintf(fid, 'Output Pinion Speed,%.1f,RPM,Pinion shaft speed\n', calc.n_pinion_out);
        fprintf(fid, 'Torque per Pinion,%.3f,N*m,Torque divided across 3 pinions\n', calc.T_pinion_each);
        fprintf(fid, 'Tangential Force (Ft),%.2f,N,Ft = 2 * T_mesh / dg\n', calc.Ft);
        fprintf(fid, 'Radial Force (Fr),%.2f,N,Fr = Ft * tan(phi_t)\n', calc.Fr);
        fprintf(fid, 'Axial Thrust Force (Fa),%.2f,N,Fa = Ft * tan(beta)\n', calc.Fa);
        fprintf(fid, 'Resultant Mesh Force (Fres),%.2f,N,Fres = sqrt(Ft^2 + Fr^2 + Fa^2)\n', calc.F_resultant);
        fprintf(fid, 'Pinion Bending Stress,%.2f,MPa,Bending stress at root fillet\n', calc.sigma_b_p);
        fprintf(fid, 'Gear Bending Stress,%.2f,MPa,Bending stress at root fillet\n', calc.sigma_b_g);
        fprintf(fid, 'Hertzian Contact Stress,%.2f,MPa,Contact stress along tooth flank\n', calc.sigma_H);
        fclose(fid);
    end
end
