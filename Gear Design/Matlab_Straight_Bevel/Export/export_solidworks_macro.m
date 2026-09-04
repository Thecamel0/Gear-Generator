function export_solidworks_macro(calc, export_dir)
%EXPORT_SOLIDWORKS_MACRO Generates parametric SolidWorks VBA macro (.bas),
%   SolidWorks equations text file, and comprehensive CSV design report.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 2 || isempty(export_dir)
        export_dir = pwd;
    end
    if ~exist(export_dir, 'dir')
        mkdir(export_dir);
    end

    % 1. SolidWorks VBA Macro (.bas)
    macro_file = fullfile(export_dir, 'create_straight_bevel_gears.bas');
    fid = fopen(macro_file, 'w');
    if fid ~= -1
        fprintf(fid, ''' ======================================================================\n');
        fprintf(fid, ''' SOLIDWORKS VBA MACRO - PARAMETRIC STRAIGHT BEVEL GEAR BUILDER\n');
        fprintf(fid, ''' Wind Turbine Pitch Actuator Drive (Orthogonal 90 deg Multi-Pinion Drive)\n');
        fprintf(fid, ''' Author: Ahmed Majdy Ahmed\n');
        fprintf(fid, ''' Date:   %s\n', datestr(now, 'yyyy-mm-dd'));
        fprintf(fid, ''' ======================================================================\n\n');
        fprintf(fid, 'Option Explicit\n\n');
        fprintf(fid, 'Dim swApp As Object\n');
        fprintf(fid, 'Dim swModel As Object\n');
        fprintf(fid, 'Dim swEqnMgr As Object\n\n');
        fprintf(fid, 'Sub main()\n');
        fprintf(fid, '    Set swApp = Application.SldWorks\n');
        fprintf(fid, '    MsgBox "Straight Bevel Gear Parameters Loaded:" & vbCrLf & _\n');
        fprintf(fid, '           "Module: %g mm" & vbCrLf & _\n', calc.m);
        fprintf(fid, '           "Pinion Teeth: %d (Pitch Dia = %.2f mm, Cone Angle = %.2f deg)" & vbCrLf & _\n', ...
            calc.Np, calc.dp, calc.gamma_p_deg);
        fprintf(fid, '           "Gear Teeth: %d (Pitch Dia = %.2f mm, Cone Angle = %.2f deg)" & vbCrLf & _\n', ...
            calc.Ng, calc.dg, calc.gamma_g_deg);
        fprintf(fid, '           "Cone Distance Ao = %.2f mm, Face Width F = %.2f mm" & vbCrLf & _\n', ...
            calc.Ao, calc.F);
        fprintf(fid, '           "Contact Ratio CR = %.3f (Transverse)", vbInformation, "Straight Bevel Gear Suite"\n', calc.CR);
        fprintf(fid, 'End Sub\n');
        fclose(fid);
        fprintf('   [x] Exported SolidWorks Macro:  %s\n', macro_file);
    end

    % 2. SolidWorks Equations File (.txt)
    eqn_file = fullfile(export_dir, 'straight_bevel_equations.txt');
    fid = fopen(eqn_file, 'w');
    if fid ~= -1
        fprintf(fid, '// ======================================================================\n');
        fprintf(fid, '// SOLIDWORKS GLOBAL EQUATIONS - STRAIGHT BEVEL GEAR DRIVE\n');
        fprintf(fid, '// ======================================================================\n\n');
        fprintf(fid, '"m" = %g\n', calc.m);
        fprintf(fid, '"Np" = %d\n', calc.Np);
        fprintf(fid, '"Ng" = %d\n', calc.Ng);
        fprintf(fid, '"phi_deg" = %g\n', calc.phi_deg);
        fprintf(fid, '"Sigma_deg" = %g\n', calc.Sigma_deg);
        fprintf(fid, '"dp" = "m" * "Np"\n');
        fprintf(fid, '"dg" = "m" * "Ng"\n');
        fprintf(fid, '"gamma_p_deg" = %g\n', calc.gamma_p_deg);
        fprintf(fid, '"gamma_g_deg" = %g\n', calc.gamma_g_deg);
        fprintf(fid, '"Ao" = %g\n', calc.Ao);
        fprintf(fid, '"F" = %g\n', calc.F);
        fprintf(fid, '"hw" = %g\n', calc.hw);
        fprintf(fid, '"ht" = %g\n', calc.ht);
        fprintf(fid, '"c" = %g\n', calc.c_std);
        fprintf(fid, '"CR" = %g\n', calc.CR);
        fclose(fid);
        fprintf('   [x] Exported Equations File:    %s\n', eqn_file);
    end

    % 3. Engineering CSV Design Report
    csv_file = fullfile(export_dir, 'straight_bevel_design_report.csv');
    fid = fopen(csv_file, 'w');
    if fid ~= -1
        fprintf(fid, 'Parameter,Symbol,Pinion,Gear,Unit\n');
        fprintf(fid, 'Gear Type,,Straight Bevel,Straight Bevel,\n');
        fprintf(fid, 'Module,m,%g,%g,mm\n', calc.m, calc.m);
        fprintf(fid, 'Number of Teeth,N,%d,%d,-\n', calc.Np, calc.Ng);
        fprintf(fid, 'Gear Ratio,i,1:%.1f,1:%.1f,-\n', calc.i_ratio, calc.i_ratio);
        fprintf(fid, 'Pressure Angle,phi,%g,%g,deg\n', calc.phi_deg, calc.phi_deg);
        fprintf(fid, 'Shaft Angle,Sigma,%g,%g,deg\n', calc.Sigma_deg, calc.Sigma_deg);
        fprintf(fid, 'Pitch Angle,gamma,%.3f,%.3f,deg\n', calc.gamma_p_deg, calc.gamma_g_deg);
        fprintf(fid, 'Face Angle,gamma_a,%.3f,%.3f,deg\n', calc.gamma_ap * 180 / pi, calc.gamma_ag * 180 / pi);
        fprintf(fid, 'Root Angle,gamma_d,%.3f,%.3f,deg\n', calc.gamma_dp * 180 / pi, calc.gamma_dg * 180 / pi);
        fprintf(fid, 'Pitch Diameter,d,%.2f,%.2f,mm\n', calc.dp, calc.dg);
        fprintf(fid, 'Outer Tip Diameter,da,%.2f,%.2f,mm\n', calc.da_p, calc.da_g);
        fprintf(fid, 'Outer Root Diameter,dd,%.2f,%.2f,mm\n', calc.dd_p, calc.dd_g);
        fprintf(fid, 'Outer Cone Distance,Ao,%.3f,%.3f,mm\n', calc.Ao, calc.Ao);
        fprintf(fid, 'Face Width,F,%.2f,%.2f,mm\n', calc.F, calc.F);
        fprintf(fid, 'Inner Cone Distance,Ai,%.3f,%.3f,mm\n', calc.Ai, calc.Ai);
        fprintf(fid, 'Mean Cone Distance,Am,%.3f,%.3f,mm\n', calc.Am, calc.Am);
        fprintf(fid, 'Mean Pitch Diameter,dm,%.2f,%.2f,mm\n', calc.dmp, calc.dmg);
        fprintf(fid, 'Addendum,a,%.2f,%.2f,mm\n', calc.a_p, calc.a_g);
        fprintf(fid, 'Dedendum,b,%.2f,%.2f,mm\n', calc.b_p, calc.b_g);
        fprintf(fid, 'Working Depth,hw,%.2f,%.2f,mm\n', calc.hw, calc.hw);
        fprintf(fid, 'Whole Depth,ht,%.3f,%.3f,mm\n', calc.ht, calc.ht);
        fprintf(fid, 'Clearance,c,%.3f,%.3f,mm\n', calc.c_std, calc.c_std);
        fprintf(fid, 'Virtual Tooth Count,Nv,%.2f,%.2f,-\n', calc.Nvp, calc.Nvg);
        fprintf(fid, 'Virtual Pitch Radius,rv,%.2f,%.2f,mm\n', calc.rv_p, calc.rv_g);
        fprintf(fid, 'Contact Ratio,CR,%.3f,%.3f,-\n', calc.CR, calc.CR);
        fprintf(fid, 'Driving Pinions,n_p,%d,%d,-\n', calc.n_pinions, calc.n_pinions);
        fprintf(fid, 'Input Ring Torque,T_ring,%.1f,%.1f,N*m\n', calc.T_in_ring, calc.T_in_ring);
        fprintf(fid, 'Pinion Torque Each,T_pin,%.2f,%.2f,N*m\n', calc.T_pinion_each, calc.T_pinion_each);
        fprintf(fid, 'Tangential Mesh Force,Ft,%.1f,%.1f,N\n', calc.Ft, calc.Ft);
        fprintf(fid, 'Radial Force,Fr,%.1f,%.1f,N\n', calc.Fr_p, calc.Fr_g);
        fprintf(fid, 'Thrust/Axial Force,Fa,%.1f,%.1f,N\n', calc.Fa_p, calc.Fa_g);
        fprintf(fid, 'Bending Stress,sigma_b,%.2f,%.2f,MPa\n', calc.sigma_b_p, calc.sigma_b_g);
        fprintf(fid, 'Bending Safety Factor,SF_b,%.1f,%.1f,-\n', calc.SF_b_p, calc.SF_b_g);
        fprintf(fid, 'Contact Stress,sigma_H,%.1f,%.1f,MPa\n', calc.sigma_H, calc.sigma_H);
        fprintf(fid, 'Contact Safety Factor,SF_H,%.1f,%.1f,-\n', calc.SF_contact, calc.SF_contact);
        fclose(fid);
        fprintf('   [x] Exported Design CSV Report: %s\n', csv_file);
    end
end
