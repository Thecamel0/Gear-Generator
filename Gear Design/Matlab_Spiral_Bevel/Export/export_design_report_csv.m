function export_design_report_csv(calc, export_dir)
%EXPORT_DESIGN_REPORT_CSV Generates comprehensive CSV engineering design report
%   for Spiral Bevel Gear pitch actuator drive (AGMA 2005-D03 / Gleason standard).
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-04

    if nargin < 2 || isempty(export_dir)
        export_dir = pwd;
    end
    if ~exist(export_dir, 'dir')
        mkdir(export_dir);
    end

    csv_file = fullfile(export_dir, 'spiral_bevel_design_report.csv');
    fid = fopen(csv_file, 'w');
    if fid == -1
        error('Cannot open CSV report file: %s', csv_file);
    end

    try
        fprintf(fid, 'Parameter,Symbol,Pinion,Gear,Unit\n');
        fprintf(fid, 'Gear Type,,Spiral Bevel (RH),Spiral Bevel (LH),\n');
        fprintf(fid, 'Module,m,%g,%g,mm\n', calc.m, calc.m);
        fprintf(fid, 'Number of Teeth,N,%d,%d,-\n', calc.Np, calc.Ng);
        fprintf(fid, 'Gear Ratio,i,1:%.1f,1:%.1f,-\n', calc.i_ratio, calc.i_ratio);
        fprintf(fid, 'Normal Pressure Angle,phi_n,%g,%g,deg\n', calc.phi_n_deg, calc.phi_n_deg);
        fprintf(fid, 'Transverse Pressure Angle,phi_t,%.3f,%.3f,deg\n', calc.phi_t_deg, calc.phi_t_deg);
        fprintf(fid, 'Mean Spiral Angle,beta_m,%.2f,%.2f,deg\n', calc.beta_m_deg, calc.beta_m_deg);
        fprintf(fid, 'Outer Spiral Angle,beta_o,%.2f,%.2f,deg\n', calc.beta_o_deg, calc.beta_o_deg);
        fprintf(fid, 'Inner Spiral Angle,beta_i,%.2f,%.2f,deg\n', calc.beta_i_deg, calc.beta_i_deg);
        fprintf(fid, 'Shaft Angle,Sigma,%g,%g,deg\n', calc.Sigma_deg, calc.Sigma_deg);
        fprintf(fid, 'Cutter Radius,r_cutter,%.2f,%.2f,mm\n', calc.r_cutter, calc.r_cutter);
        fprintf(fid, 'Pitch Cone Angle,gamma,%.3f,%.3f,deg\n', calc.gamma_p_deg, calc.gamma_g_deg);
        fprintf(fid, 'Face Cone Angle,gamma_a,%.3f,%.3f,deg\n', calc.gamma_ap_deg, calc.gamma_ag_deg);
        fprintf(fid, 'Root Cone Angle,gamma_d,%.3f,%.3f,deg\n', calc.gamma_dp_deg, calc.gamma_dg_deg);
        fprintf(fid, 'Pitch Diameter,d,%.2f,%.2f,mm\n', calc.dp, calc.dg);
        fprintf(fid, 'Mean Pitch Diameter,dm,%.2f,%.2f,mm\n', calc.dmp, calc.dmg);
        fprintf(fid, 'Outer Tip Diameter,da,%.2f,%.2f,mm\n', calc.da_p, calc.da_g);
        fprintf(fid, 'Outer Root Diameter,dd,%.2f,%.2f,mm\n', calc.dd_p, calc.dd_g);
        fprintf(fid, 'Outer Cone Distance,Ao,%.3f,%.3f,mm\n', calc.Ao, calc.Ao);
        fprintf(fid, 'Face Width,F,%.2f,%.2f,mm\n', calc.F, calc.F);
        fprintf(fid, 'Inner Cone Distance,Ai,%.3f,%.3f,mm\n', calc.Ai, calc.Ai);
        fprintf(fid, 'Mean Cone Distance,Am,%.3f,%.3f,mm\n', calc.Am, calc.Am);
        fprintf(fid, 'Addendum,a,%.2f,%.2f,mm\n', calc.a_p, calc.a_g);
        fprintf(fid, 'Dedendum,b,%.2f,%.2f,mm\n', calc.b_p, calc.b_g);
        fprintf(fid, 'Working Depth,hw,%.2f,%.2f,mm\n', calc.hw, calc.hw);
        fprintf(fid, 'Whole Depth,ht,%.3f,%.3f,mm\n', calc.ht, calc.ht);
        fprintf(fid, 'Clearance,c,%.3f,%.3f,mm\n', calc.c_std, calc.c_std);
        fprintf(fid, 'Outer Tooth Thickness,s,%.3f,%.3f,mm\n', calc.s_p, calc.s_g);
        fprintf(fid, 'Virtual Tooth Count,Nv,%.2f,%.2f,-\n', calc.Nvp, calc.Nvg);
        fprintf(fid, 'Transverse Contact Ratio,eps_alpha,%.3f,%.3f,-\n', calc.eps_alpha, calc.eps_alpha);
        fprintf(fid, 'Face Overlap Ratio,eps_beta,%.3f,%.3f,-\n', calc.eps_beta, calc.eps_beta);
        fprintf(fid, 'Total Contact Ratio,eps_gamma,%.3f,%.3f,-\n', calc.CR, calc.CR);
        fprintf(fid, 'Driving Pinions,n_p,%d,%d,-\n', calc.n_pinions, calc.n_pinions);
        fprintf(fid, 'Input Ring Torque,T_ring,%.1f,%.1f,N*m\n', calc.T_in_ring, calc.T_in_ring);
        fprintf(fid, 'Pinion Torque Each,T_pin,%.2f,%.2f,N*m\n', calc.T_pinion_each, calc.T_pinion_each);
        fprintf(fid, 'Pinion Speed,n_pin,%.1f,%.1f,RPM\n', calc.n_pinion_out, calc.n_in_ring);
        fprintf(fid, 'Tangential Mesh Force,Ft,%.1f,%.1f,N\n', calc.Ft, calc.Ft);
        fprintf(fid, 'Radial Force,Fr,%.1f,%.1f,N\n', calc.Fr_p, calc.Fr_g);
        fprintf(fid, 'Thrust/Axial Force,Fa,%.1f,%.1f,N\n', calc.Fa_p, calc.Fa_g);
        fprintf(fid, 'Resultant Force,Fres,%.1f,%.1f,N\n', calc.F_resultant, calc.F_resultant);
        fprintf(fid, 'Bending Stress,sigma_b,%.2f,%.2f,MPa\n', calc.sigma_b_p, calc.sigma_b_g);
        fprintf(fid, 'Bending Safety Factor,SF_b,%.1f,%.1f,-\n', calc.SF_b_p, calc.SF_b_g);
        fprintf(fid, 'Contact Stress,sigma_H,%.1f,%.1f,MPa\n', calc.sigma_H, calc.sigma_H);
        fprintf(fid, 'Contact Safety Factor,SF_H,%.1f,%.1f,-\n', calc.SF_contact, calc.SF_contact);

        fclose(fid);
        f_info = dir(csv_file);
        fprintf('    [Report] Successfully wrote %s (%.2f KB)\n', ...
            csv_file, f_info.bytes / 1e3);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
end
