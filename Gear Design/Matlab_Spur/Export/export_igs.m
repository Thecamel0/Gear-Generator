function export_igs(mesh, filename, header_text)
%EXPORT_IGS Export gear mesh as IGES 5.3 file compatible with SolidWorks / CATIA
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 3 || isempty(header_text)
        header_text = 'Spur Gear Model (IGES 5.3 Entity 128)';
    end

    vertices = mesh.vertices;
    faces    = mesh.faces;

    v1 = vertices(faces(:,1), :);
    v2 = vertices(faces(:,2), :);
    v3 = vertices(faces(:,3), :);
    edge1  = v2 - v1;
    edge2  = v3 - v1;
    xprods = cross(edge1, edge2, 2);
    areas  = sqrt(sum(xprods.^2, 2));

    valid = areas > 1e-10;
    faces = faces(valid, :);
    n_faces = size(faces, 1);

    out_dir = fileparts(filename);
    if ~isempty(out_dir) && ~exist(out_dir, 'dir'), mkdir(out_dir); end

    fid = fopen(filename, 'w');
    if fid == -1, error('Cannot open file: %s', filename); end

    try
        [~, name_only, ~] = fileparts(filename);
        now_str = datestr(now, 'yyyymmdd.HHMMSS');

        % START SECTION
        s_line = sprintf('%-72sS%07d\n', header_text, 1);
        fwrite(fid, s_line);

        % GLOBAL SECTION
        g_lines = {
            sprintf('1H,,1H;,%dH%s,%dH%s,', length(name_only), name_only, length(filename), filename);
            '32HMATLAB IGES 5.3 Exporter,32HMATLAB R2026a,32,38,6,308,15,';
            sprintf('1.0,1,2HM,,1.0,%dH%s,1.0E-04,', length(now_str), now_str);
            '1000.0,16HAhmed Majdy Ahmed,26HWind Turbine Pitch Control,11,0;';
        };
        for i = 1:numel(g_lines)
            txt = g_lines{i};
            fwrite(fid, sprintf('%-72sG%07d\n', txt, i));
        end

        % DIRECTORY & PARAMETER SECTIONS
        % Entity 128 (B-Spline surface patch for each triangular face)
        p_seq = 1;
        p_start_indices = zeros(n_faces, 1);

        % Write Parameters first into temporary file
        temp_param_file = [filename, '.ptmp'];
        fid_p = fopen(temp_param_file, 'w');

        for f = 1:n_faces
            p_start_indices(f) = p_seq;
            pt1 = vertices(faces(f,1), :);
            pt2 = vertices(faces(f,2), :);
            pt3 = vertices(faces(f,3), :);

            % Bilinear patch: 128, 1, 1, 0, 0, 1, 0, 0, 0, 0
            p_str1 = '128,1,1,0,0,1,0,0,0,0,';
            fwrite(fid_p, sprintf('%-64s%8dP%07d\n', p_str1, 2*f-1, p_seq));
            p_seq = p_seq + 1;

            p_str2 = '0.,0.,1.,1.,0.,0.,1.,1.,1.,1.,1.,1.,';
            fwrite(fid_p, sprintf('%-64s%8dP%07d\n', p_str2, 2*f-1, p_seq));
            p_seq = p_seq + 1;

            p_str3 = sprintf('%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,', pt1(1), pt1(2), pt1(3), pt2(1), pt2(2), pt2(3));
            fwrite(fid_p, sprintf('%-64s%8dP%07d\n', p_str3, 2*f-1, p_seq));
            p_seq = p_seq + 1;

            p_str4 = sprintf('%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,0.,1.,0.,1.;', pt1(1), pt1(2), pt1(3), pt3(1), pt3(2), pt3(3));
            fwrite(fid_p, sprintf('%-64s%8dP%07d\n', p_str4, 2*f-1, p_seq));
            p_seq = p_seq + 1;
        end
        fclose(fid_p);

        % Write Directory Entries
        d_seq = 1;
        for f = 1:n_faces
            pid = p_start_indices(f);
            line1 = sprintf('%8d%8d%8d%8d%8d%8d%8d%8d%8s', 128, pid, 0, 0, 0, 0, 0, 0, '00010001');
            fwrite(fid, sprintf('%-72sD%07d\n', line1, d_seq));
            d_seq = d_seq + 1;

            line2 = sprintf('%8d%8d%8d%8d%8d%8d%8d%8d%8s', 128, 0, 0, 4, 0, 0, 0, 0, '');
            fwrite(fid, sprintf('%-72sD%07d\n', line2, d_seq));
            d_seq = d_seq + 1;
        end

        % Append Parameter lines
        fid_p = fopen(temp_param_file, 'r');
        while ~feof(fid_p)
            line = fgets(fid_p);
            if ischar(line), fwrite(fid, line); end
        end
        fclose(fid_p);
        delete(temp_param_file);

        % TERMINATE SECTION
        t_line = sprintf('S%07dG%07dD%07dP%07d%-40sT0000001\n', 1, numel(g_lines), 2*n_faces, p_seq-1, '');
        fwrite(fid, t_line);
        fclose(fid);

        f_info = dir(filename);
        fprintf('  [IGES] Saved: %s (%.1f MB, %d patches)\n', ...
            filename, f_info.bytes / 1e6, n_faces);
    catch ME
        if exist('fid_p', 'var') && fid_p ~= -1, fclose(fid_p); end
        fclose(fid);
        rethrow(ME);
    end
end
