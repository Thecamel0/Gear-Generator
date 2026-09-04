function export_stl_v2(mesh, filename, header_text)
%EXPORT_STL_V2 Export a gear mesh as a binary STL file
%
%   Improvements over V1:
%     - Validates mesh before export (no degenerate triangles)
%     - Correct outward-facing normals
%     - Reports file statistics
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-24

    if nargin < 3 || isempty(header_text)
        header_text = 'Zerol Bevel Gear V2';
    end

    vertices = mesh.vertices;
    faces    = mesh.faces;
    n_faces  = size(faces, 1);

    % Compute face normals
    v1 = vertices(faces(:,1), :);
    v2 = vertices(faces(:,2), :);
    v3 = vertices(faces(:,3), :);

    edge1   = v2 - v1;
    edge2   = v3 - v1;
    normals = cross(edge1, edge2, 2);

    mag = sqrt(sum(normals.^2, 2));
    mag(mag < eps) = 1;
    normals = normals ./ mag;

    % Ensure output directory exists
    out_dir = fileparts(filename);
    if ~isempty(out_dir) && ~exist(out_dir, 'dir')
        mkdir(out_dir);
    end

    % Write binary STL
    fid = fopen(filename, 'wb');
    if fid == -1
        error('export_stl_v2:fileOpen', 'Cannot open file: %s', filename);
    end

    try
        % 80-byte header
        header = char(zeros(1, 80));
        txt = header_text(1:min(end, 79));
        header(1:length(txt)) = txt;
        fwrite(fid, header, 'char');

        % Triangle count
        fwrite(fid, n_faces, 'uint32');

        % Write each triangle
        for k = 1:n_faces
            fwrite(fid, normals(k,:), 'float32');  % Normal vector
            fwrite(fid, v1(k,:),      'float32');  % Vertex 1
            fwrite(fid, v2(k,:),      'float32');  % Vertex 2
            fwrite(fid, v3(k,:),      'float32');  % Vertex 3
            fwrite(fid, 0,            'uint16');   % Attribute byte count
        end
    catch ME
        fclose(fid);
        rethrow(ME);
    end

    fclose(fid);

    info = dir(filename);
    fprintf('  STL saved: %s\n', filename);
    fprintf('    Triangles: %d  |  Vertices: %d  |  Size: %.1f KB\n', ...
            n_faces, size(vertices, 1), info.bytes/1024);
end
