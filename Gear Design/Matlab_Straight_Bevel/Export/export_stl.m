function export_stl(mesh, filename, header_text)
%EXPORT_STL Export a 3D gear mesh as a binary STL file
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 3 || isempty(header_text)
        header_text = 'Straight Bevel Gear Model';
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
        error('export_stl:fileOpen', 'Cannot open file: %s', filename);
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

        fclose(fid);
        f_info = dir(filename);
        fprintf('   [x] Exported Binary STL: %s (%.2f MB, %d triangles)\n', ...
            filename, f_info.bytes / (1024*1024), n_faces);
    catch err
        fclose(fid);
        rethrow(err);
    end
end
