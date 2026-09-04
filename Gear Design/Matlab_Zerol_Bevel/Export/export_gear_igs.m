function export_gear_igs(mesh, filename, header_text)
%EXPORT_GEAR_IGS  Export gear mesh as IGES 5.3 file compatible with CATIA V5/V6 and SolidWorks
%
%   export_gear_igs(mesh, filename, header_text)
%
%   Inputs:
%       mesh        - struct with .vertices (Vx3 double, mm) and .faces (Fx3 int)
%       filename    - full path for the output .igs file
%       header_text - description string for the IGES Start Section (optional)
%
%   Output format:
%       ASCII IGES 5.3 using Entity 128 (Rational B-Spline Surface, bilinear quad patch)
%       Each triangular mesh face is exported as a degenerate 2x2 bilinear patch.
%       CATIA V5/V6 and SolidWorks import this as a Surface Body (shell).
%
%   IGES line format (fixed-width ASCII, exactly 80 chars per line):
%       cols  1-72  : section data
%       col   73    : section identifier  S/G/D/P/T
%       cols 74-80  : 7-digit sequence number (right-justified)
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-07

if nargin < 3 || isempty(header_text)
    header_text = 'Zerol Bevel Gear Model (IGES 5.3 Entity 128)';
end

% -------------------------------------------------------------------------
%  Pre-process mesh: remove degenerate faces, fix normal orientation
% -------------------------------------------------------------------------
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
if any(~valid)
    fprintf('  [IGS] Removed %d degenerate faces\n', sum(~valid));
end
faces   = faces(valid, :);
areas   = areas(valid);    % now filtered — same length as faces
xprods2 = xprods(valid, :); % filtered cross products

% Ensure outward-facing normals (consistent winding)
centroid     = mean(vertices, 1);
face_centers = (vertices(faces(:,1),:) + vertices(faces(:,2),:) + vertices(faces(:,3),:)) / 3;
xnorms       = xprods2 ./ areas;   % areas already filtered, no re-indexing needed
outward_vec  = face_centers - centroid;
dot_prod     = sum(xnorms .* outward_vec, 2);
flip_mask    = dot_prod < 0;
if any(flip_mask)
    tmp = faces(flip_mask, 2);
    faces(flip_mask, 2) = faces(flip_mask, 3);
    faces(flip_mask, 3) = tmp;
    fprintf('  [IGS] Corrected %d inward-facing normals\n', sum(flip_mask));
end

n_faces = size(faces, 1);

% -------------------------------------------------------------------------
%  Open file
% -------------------------------------------------------------------------
out_dir = fileparts(filename);
if ~isempty(out_dir) && ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

fid = fopen(filename, 'w');
if fid == -1
    error('export_gear_igs:fileOpen', 'Cannot open file: %s', filename);
end

try
    % =====================================================================
    %  IGES SECTION 1 -- Start Section (S)
    % =====================================================================
    s_lines = {};
    s_count = 0;

    txt_s = sprintf('IGES 5.3  %s', header_text);
    chunks = split_to_72(txt_s);
    for k = 1:length(chunks)
        s_count = s_count + 1;
        s_lines{end+1} = sprintf('%-72sS%7d', chunks{k}, s_count); %#ok<AGROW>
    end

    % =====================================================================
    %  IGES SECTION 2 -- Global Section (G)
    % =====================================================================
    [~, fname_only, fext] = fileparts(filename);
    file_basename = [fname_only, fext];
    prod_name     = fname_only;

    file_h = hollerith(file_basename);
    prod_h = hollerith(prod_name);
    auth_h = hollerith('Ahmed Majdy Ahmed');
    org_h  = hollerith('Wind Turbine Pitch Control');

    try
        dt = datetime('now', 'Format', 'yyyyMMdd.HHmmss');
        date_str = char(dt);
    catch
        date_str = datestr(now, 'yyyymmdd.HHMMSS'); %#ok<DATST>
    end
    date_h = hollerith(date_str);

    % IGES 5.3 Global Section fields (comma-separated, terminated with ;)
    % Field 11 = 6 means millimetres (MM)
    g_text = sprintf(['1H,,1H;,%s,%s,7HMATLAB ,7HMATLAB ,32,308,15,308,15,'...
                      '%s,1.0,6,2HMM,1,0.001,%s,1.0,1000.0,'...
                      '%s,%s,11,0;'], ...
        prod_h, file_h, prod_h, date_h, auth_h, org_h);

    g_lines = {};
    g_count = 0;
    chunks = split_to_72(g_text);
    for k = 1:length(chunks)
        g_count = g_count + 1;
        g_lines{end+1} = sprintf('%-72sG%7d', chunks{k}, g_count); %#ok<AGROW>
    end

    % =====================================================================
    %  IGES SECTIONS 3 & 4 -- Directory Entry (D) and Parameter Data (P)
    % =====================================================================
    %  Entity 128 -- Rational B-Spline Surface (bilinear 2x2 patch)
    %  K1=1, K2=1, M1=1, M2=1
    %  Knots u: 0,0,1,1   Knots v: 0,0,1,1
    %  Weights: 1,1,1,1
    %  Control points: P00,P10,P01,P11
    %  For triangle (v1,v2,v3): P00=v1, P10=v2, P01=v3, P11=v3 (degenerate)
    %
    %  DE line format (2 lines per entity, each exactly 80 cols):
    %    Cols  1-8   Field 1
    %    Cols  9-16  Field 2
    %    ...
    %    Cols 65-72  Field 9
    %    Col  73     'D'
    %    Cols 74-80  Sequence# (odd for line 1, even for line 2)
    %
    %  P line format:
    %    Cols  1-64  Parameter data
    %    Cols 65-72  DE sequence# (the odd number pointing to this entity)
    %    Col  73     'P'
    %    Cols 74-80  Sequence#

    de_lines = {};
    p_lines  = {};

    d_entity_count = 0;   % counts entities (not lines)
    p_line_count   = 0;   % counts P-section lines

    for f = 1:n_faces
        vi  = faces(f, :);
        P00 = vertices(vi(1), :);
        P10 = vertices(vi(2), :);
        P01 = vertices(vi(3), :);
        P11 = vertices(vi(3), :);   % degenerate edge for triangle

        % Build Entity 128 parameter data string
        p_str = sprintf(['128,1,1,1,1,0,0,1,0,0,'...
                         '0.,0.,1.,1.,0.,0.,1.,1.,'...
                         '1.,1.,1.,1.,'...
                         '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,'...
                         '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,'...
                         '0.,1.,0.,1.;'], ...
            P00(1),P00(2),P00(3), ...
            P10(1),P10(2),P10(3), ...
            P01(1),P01(2),P01(3), ...
            P11(1),P11(2),P11(3));

        % DE sequence numbers (1-indexed, odd for line-1, even for line-2)
        de_seq1 = d_entity_count * 2 + 1;
        de_seq2 = d_entity_count * 2 + 2;
        p_first = p_line_count + 1;   % first P-section line for this entity

        % Build P-section lines (64-char data field)
        p_strs   = split_to_64(p_str);
        n_plines = length(p_strs);

        for k = 1:n_plines
            p_line_count = p_line_count + 1;
            p_lines{end+1} = sprintf('%-64s%8dP%7d', ...
                p_strs{k}, de_seq1, p_line_count); %#ok<AGROW>
        end

        % DE line 1 (9 fields x 8 chars = 72 chars total)
        de_data1 = sprintf('%8d%8d%8d%8d%8d%8d%8d%8d%8s', ...
            128, p_first, 0, 0, 0, 0, 0, 0, '00000001');
        de_lines{end+1} = sprintf('%-72sD%7d', de_data1, de_seq1); %#ok<AGROW>

        % DE line 2 (entity type, lineweight, color, param-line-count,
        %            form#, reserved, reserved, entity-label, entity-subscript)
        de_data2 = sprintf('%8d%8d%8d%8d%8d%8d%8d%8d%8d', ...
            128, 0, 0, n_plines, 0, 0, 0, 0, f);
        de_lines{end+1} = sprintf('%-72sD%7d', de_data2, de_seq2); %#ok<AGROW>

        d_entity_count = d_entity_count + 1;
    end

    % =====================================================================
    %  Write all sections to file
    % =====================================================================
    for k = 1:length(s_lines)
        fprintf(fid, '%s\n', s_lines{k});
    end
    for k = 1:length(g_lines)
        fprintf(fid, '%s\n', g_lines{k});
    end
    for k = 1:length(de_lines)
        fprintf(fid, '%s\n', de_lines{k});
    end
    for k = 1:length(p_lines)
        fprintf(fid, '%s\n', p_lines{k});
    end

    % Terminate (T) section
    t_str = sprintf('S%7dG%7dD%7dP%7d', ...
        length(s_lines), length(g_lines), length(de_lines), length(p_lines));
    fprintf(fid, '%-72sT%7d\n', t_str, 1);

catch ME
    fclose(fid);
    rethrow(ME);
end

fclose(fid);

info = dir(filename);
fprintf('  IGES 5.3 saved: %s\n', filename);
fprintf('    Entities:  %d Entity-128 B-Spline Surface patches\n', n_faces);
fprintf('    File size: %.1f KB\n', info.bytes / 1024);
fprintf('    Import in SolidWorks: File > Open > *.igs\n');
fprintf('    Import in CATIA V5:   File > Open > *.igs\n');

end


% =========================================================================
%  Helper: Hollerith string encoding  "nHstr"
% =========================================================================
function h = hollerith(str)
% Build an IGES Hollerith literal: nHstring where n = character count.
str = strrep(str, ',', ' ');
str = strrep(str, ';', ' ');
n = length(str);
h = sprintf('%dH%s', n, str);
end


% =========================================================================
%  Helper: Split text into chunks of max 72 chars (S and G sections)
% =========================================================================
function chunks = split_to_72(str)
chunks = {};
while length(str) > 72
    chunks{end+1} = str(1:72); %#ok<AGROW>
    str = str(73:end);
end
if ~isempty(str)
    chunks{end+1} = str;
end
end


% =========================================================================
%  Helper: Split text into chunks of max 64 chars at comma boundaries (P section)
% =========================================================================
function chunks = split_to_64(str)
% P-section data field is cols 1-64 (64 chars).
% We split at the last comma within the 64-char window to avoid
% splitting inside a number, which would produce invalid IGES.
chunks = {};
while length(str) > 64
    cut = find(str(1:64) == ',', 1, 'last');
    if isempty(cut)
        cut = 64;   % emergency hard cut (should not occur with valid data)
    end
    chunks{end+1} = str(1:cut); %#ok<AGROW>
    str = str(cut+1:end);
end
if ~isempty(str)
    chunks{end+1} = str;
end
end
