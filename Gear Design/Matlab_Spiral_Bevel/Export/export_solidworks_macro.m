function export_solidworks_macro(calc, export_dir)
%EXPORT_SOLIDWORKS_MACRO Generates parametric SolidWorks VBA macro (.bas)
%   for Spiral Bevel Gear pitch actuator drive system.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-04

    if nargin < 2 || isempty(export_dir)
        export_dir = pwd;
    end
    if ~exist(export_dir, 'dir')
        mkdir(export_dir);
    end

    macro_file = fullfile(export_dir, 'create_spiral_bevel_gears.bas');
    fid = fopen(macro_file, 'w');
    if fid == -1
        error('Cannot open macro file: %s', macro_file);
    end

    try
        fprintf(fid, ''' ======================================================================\n');
        fprintf(fid, ''' SOLIDWORKS VBA MACRO - PARAMETRIC SPIRAL BEVEL GEAR BUILDER\n');
        fprintf(fid, ''' Wind Turbine Pitch Control Actuator (90 deg Multi-Pinion Drive)\n');
        fprintf(fid, ''' Author: Ahmed Majdy Ahmed\n');
        fprintf(fid, ''' Date:   %s\n', datestr(now, 'yyyy-mm-dd'));
        fprintf(fid, ''' ======================================================================\n\n');
        fprintf(fid, 'Option Explicit\n\n');
        fprintf(fid, 'Dim swApp As Object\n');
        fprintf(fid, 'Dim swModel As Object\n');
        fprintf(fid, 'Dim swEqnMgr As Object\n\n');
        fprintf(fid, 'Sub main()\n');
        fprintf(fid, '    Set swApp = Application.SldWorks\n\n');
        fprintf(fid, '    '' 1. Create Pinion (Right Hand, %d Teeth, Helix %g deg)\n', calc.Np, calc.beta_m_deg);
        fprintf(fid, '    CreateSpiralBevelComponent "Spiral_Bevel_Pinion_%dT_RH", %g, %d, %g, %g, %g, %g, %g, 1\n\n', ...
            calc.Np, calc.m, calc.Np, calc.phi_n_deg, calc.beta_m_deg, calc.gamma_p_deg, calc.Ao, calc.F);
        fprintf(fid, '    '' 2. Create Central Ring Gear (Left Hand, %d Teeth, Helix %g deg)\n', calc.Ng, calc.beta_m_deg);
        fprintf(fid, '    CreateSpiralBevelComponent "Spiral_Bevel_Gear_%dT_LH", %g, %d, %g, %g, %g, %g, %g, -1\n\n', ...
            calc.Ng, calc.m, calc.Ng, calc.phi_n_deg, calc.beta_m_deg, calc.gamma_g_deg, calc.Ao, calc.F);
        fprintf(fid, '    MsgBox "Spiral Bevel Gear Assembly generated successfully!" & vbCrLf & _\n');
        fprintf(fid, '           "Module: %g mm" & vbCrLf & _\n', calc.m);
        fprintf(fid, '           "Pinion Teeth: %d (Pitch Dia = %.2f mm, Pitch Cone = %.2f deg)" & vbCrLf & _\n', ...
            calc.Np, calc.dp, calc.gamma_p_deg);
        fprintf(fid, '           "Gear Teeth: %d (Pitch Dia = %.2f mm, Pitch Cone = %.2f deg)" & vbCrLf & _\n', ...
            calc.Ng, calc.dg, calc.gamma_g_deg);
        fprintf(fid, '           "Mean Spiral Angle: %.1f deg (RH Pinion / LH Gear)" & vbCrLf & _\n', calc.beta_m_deg);
        fprintf(fid, '           "Cone Distance Ao: %.2f mm, Face Width F: %.2f mm" & vbCrLf & _\n', calc.Ao, calc.F);
        fprintf(fid, '           "Total Contact Ratio CR: %.3f (Transverse %.2f + Overlap %.2f)", vbInformation, "Spiral Bevel Gear Suite"\n', ...
            calc.CR, calc.eps_alpha, calc.eps_beta);
        fprintf(fid, 'End Sub\n\n');

        fprintf(fid, 'Sub CreateSpiralBevelComponent(partName As String, m As Double, N As Long, phi_n As Double, beta_m As Double, gamma As Double, Ao As Double, F As Double, hand As Long)\n');
        fprintf(fid, '    Dim partDoc As Object\n');
        fprintf(fid, '    Set partDoc = swApp.NewDocument(swApp.GetUserPreferenceStringValue(0), 0, 0, 0)\n');
        fprintf(fid, '    If partDoc Is Nothing Then Exit Sub\n\n');
        fprintf(fid, '    Dim eqnMgr As Object\n');
        fprintf(fid, '    Set eqnMgr = partDoc.GetEquationMgr\n');
        fprintf(fid, '    eqnMgr.Add -1, """m"" = " & Str(m)\n');
        fprintf(fid, '    eqnMgr.Add -1, """N"" = " & Str(N)\n');
        fprintf(fid, '    eqnMgr.Add -1, """phi_n"" = " & Str(phi_n)\n');
        fprintf(fid, '    eqnMgr.Add -1, """beta_m"" = " & Str(beta_m)\n');
        fprintf(fid, '    eqnMgr.Add -1, """gamma"" = " & Str(gamma)\n');
        fprintf(fid, '    eqnMgr.Add -1, """Ao"" = " & Str(Ao)\n');
        fprintf(fid, '    eqnMgr.Add -1, """F"" = " & Str(F)\n');
        fprintf(fid, '    eqnMgr.Add -1, """dp"" = ""m"" * ""N"""\n');
        fprintf(fid, '    eqnMgr.EvaluateAll\n');
        fprintf(fid, 'End Sub\n');

        fclose(fid);
        f_info = dir(macro_file);
        fprintf('    [SolidWorks] Successfully wrote %s (%.2f KB)\n', ...
            macro_file, f_info.bytes / 1e3);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
end
