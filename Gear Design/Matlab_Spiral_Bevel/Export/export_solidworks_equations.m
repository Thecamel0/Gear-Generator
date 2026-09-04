function export_solidworks_equations(calc, export_dir)
%EXPORT_SOLIDWORKS_EQUATIONS Generates SolidWorks global variables equations text file (.txt)
%   for import into SolidWorks Tools -> Equations for parametric modeling.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-04

    if nargin < 2 || isempty(export_dir)
        export_dir = pwd;
    end
    if ~exist(export_dir, 'dir')
        mkdir(export_dir);
    end

    eqn_file = fullfile(export_dir, 'spiral_bevel_equations.txt');
    fid = fopen(eqn_file, 'w');
    if fid == -1
        error('Cannot open equations file: %s', eqn_file);
    end

    try
        fprintf(fid, '// ======================================================================\n');
        fprintf(fid, '// SOLIDWORKS GLOBAL EQUATIONS - SPIRAL BEVEL GEAR DRIVE\n');
        fprintf(fid, '// Wind Turbine Pitch Control System (AGMA 2005-D03 / Gleason Standard)\n');
        fprintf(fid, '// ======================================================================\n\n');

        fprintf(fid, '"m" = %g\n', calc.m);
        fprintf(fid, '"Np" = %d\n', calc.Np);
        fprintf(fid, '"Ng" = %d\n', calc.Ng);
        fprintf(fid, '"phi_n_deg" = %g\n', calc.phi_n_deg);
        fprintf(fid, '"beta_m_deg" = %g\n', calc.beta_m_deg);
        fprintf(fid, '"Sigma_deg" = %g\n', calc.Sigma_deg);

        fprintf(fid, '"dp" = "m" * "Np"\n');
        fprintf(fid, '"dg" = "m" * "Ng"\n');
        fprintf(fid, '"gamma_p_deg" = %g\n', calc.gamma_p_deg);
        fprintf(fid, '"gamma_g_deg" = %g\n', calc.gamma_g_deg);
        fprintf(fid, '"Ao" = %g\n', calc.Ao);
        fprintf(fid, '"Am" = %g\n', calc.Am);
        fprintf(fid, '"Ai" = %g\n', calc.Ai);
        fprintf(fid, '"F" = %g\n', calc.F);

        fprintf(fid, '"hw" = %g\n', calc.hw);
        fprintf(fid, '"ht" = %g\n', calc.ht);
        fprintf(fid, '"c_std" = %g\n', calc.c_std);
        fprintf(fid, '"a_p" = %g\n', calc.a_p);
        fprintf(fid, '"a_g" = %g\n', calc.a_g);
        fprintf(fid, '"b_p" = %g\n', calc.b_p);
        fprintf(fid, '"b_g" = %g\n', calc.b_g);

        fprintf(fid, '"da_p" = %g\n', calc.da_p);
        fprintf(fid, '"da_g" = %g\n', calc.da_g);
        fprintf(fid, '"dd_p" = %g\n', calc.dd_p);
        fprintf(fid, '"dd_g" = %g\n', calc.dd_g);

        fprintf(fid, '"r_cutter" = %g\n', calc.r_cutter);
        fprintf(fid, '"CR_total" = %g\n', calc.CR);

        fclose(fid);
        f_info = dir(eqn_file);
        fprintf('    [Equations] Successfully wrote %s (%.2f KB)\n', ...
            eqn_file, f_info.bytes / 1e3);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
end
