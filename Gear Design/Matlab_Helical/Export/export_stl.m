function export_stl(mesh, filepath, header_str)
%EXPORT_STL Exports a watertight 3D mesh to standard binary STL format.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 3 || isempty(header_str)
        header_str = 'Helical Gear Model - Binary STL';
    end

    fid = fopen(filepath, 'wb');
    if fid == -1
        error('Failed to open file for binary STL write: %s', filepath);
    end

    % 1. 80-byte header
    header_bytes = uint8(zeros(1, 80));
    header_raw   = uint8(header_str);
    n_copy       = min(length(header_raw), 80);
    header_bytes(1:n_copy) = header_raw(1:n_copy);
    fwrite(fid, header_bytes, 'uint8');

    % 2. Number of triangles (uint32)
    n_triangles = size(mesh.faces, 1);
    fwrite(fid, uint32(n_triangles), 'uint32');

    % 3. Triangle records: Normal (3x float32), V1, V2, V3 (3x float32 each), attr byte (uint16 = 0)
    v1 = mesh.vertices(mesh.faces(:, 1), :);
    v2 = mesh.vertices(mesh.faces(:, 2), :);
    v3 = mesh.vertices(mesh.faces(:, 3), :);

    e1 = v2 - v1;
    e2 = v3 - v1;
    fn = cross(e1, e2, 2);
    fn_len = sqrt(sum(fn.^2, 2));
    fn_len(fn_len == 0) = 1;
    fn = fn ./ fn_len;

    record_data = zeros(50, n_triangles, 'uint8');
    attr_zero = uint16(0);

    for i = 1:n_triangles
        buf = [typecast(single(fn(i, :)), 'uint8'), ...
               typecast(single(v1(i, :)), 'uint8'), ...
               typecast(single(v2(i, :)), 'uint8'), ...
               typecast(single(v3(i, :)), 'uint8'), ...
               typecast(attr_zero, 'uint8')];
        record_data(:, i) = buf(:);
    end

    fwrite(fid, record_data(:), 'uint8');
    fclose(fid);
end
