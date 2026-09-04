function export_gear_obj(mesh, filename, header_text)
%EXPORT_GEAR_OBJ Export gear mesh as Wavefront OBJ (.obj) file for SolidWorks
%
%   Includes vertex normals (vn) for smooth shading and proper solid
%   interpretation in SolidWorks. Removes degenerate triangles and
%   ensures consistent outward-facing normals.
%
%   Author:  Ahmed Majdy Ahmed
%   Date:    2026-08-06

if nargin < 3 || isempty(header_text)
    header_text = 'Zerol Bevel Gear Model';
end

vertices = mesh.vertices;
faces    = mesh.faces;
n_verts  = size(vertices, 1);

% --- Remove degenerate triangles ---
v1 = vertices(faces(:,1), :);
v2 = vertices(faces(:,2), :);
v3 = vertices(faces(:,3), :);
raw_normals = cross(v2 - v1, v3 - v1, 2);
areas = sqrt(sum(raw_normals.^2, 2));
valid = areas > 1e-10;
if sum(~valid) > 0
    fprintf('  [OBJ Fix] Removed %d degenerate triangles\n', sum(~valid));
end
faces = faces(valid, :);
v1 = v1(valid, :);
v2 = v2(valid, :);
v3 = v3(valid, :);
raw_normals = raw_normals(valid, :);
areas = areas(valid);
n_faces = size(faces, 1);

% --- Ensure outward normals (same as STEP/STL exporters) ---
normals = raw_normals ./ areas;
centroid = mean(vertices, 1);
face_centers = (v1 + v2 + v3) / 3;
outward_vec = face_centers - centroid;
dot_prod = sum(normals .* outward_vec, 2);
flip_mask = dot_prod < 0;

% Swap vertex winding for inward-facing faces
temp = faces(flip_mask, 2);
faces(flip_mask, 2) = faces(flip_mask, 3);
faces(flip_mask, 3) = temp;

if sum(flip_mask) > 0
    fprintf('  [OBJ Fix] Corrected %d / %d inward-facing normals\n', sum(flip_mask), n_faces);
end

% --- Compute per-vertex normals (area-weighted average of adjacent faces) ---
% Recompute face normals from corrected winding
v1 = vertices(faces(:,1), :);
v2 = vertices(faces(:,2), :);
v3 = vertices(faces(:,3), :);
face_normals = cross(v2 - v1, v3 - v1, 2); % area-weighted (not normalized)

vertex_normals = zeros(n_verts, 3);
for f = 1:n_faces
    for vi = 1:3
        vertex_normals(faces(f, vi), :) = vertex_normals(faces(f, vi), :) + face_normals(f, :);
    end
end
vn_mag = sqrt(sum(vertex_normals.^2, 2));
vn_mag(vn_mag < eps) = 1;
vertex_normals = vertex_normals ./ vn_mag;

% --- Write OBJ file ---
out_dir = fileparts(filename);
if ~isempty(out_dir) && ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

fid = fopen(filename, 'w');
if fid == -1
    error('export_gear_obj:fileOpen', 'Cannot open file: %s', filename);
end

try
    fprintf(fid, '# Wavefront OBJ file - %s\n', header_text);
    fprintf(fid, '# Vertices: %d  Faces: %d\n', n_verts, n_faces);
    fprintf(fid, '# Units: millimeters\n');
    fprintf(fid, 'g ZerolGear\n\n');

    % Vertices
    fprintf(fid, 'v %.6f %.6f %.6f\n', vertices');
    fprintf(fid, '\n');

    % Vertex normals
    fprintf(fid, 'vn %.6f %.6f %.6f\n', vertex_normals');
    fprintf(fid, '\n');

    % Faces with vertex normal references (f v1//vn1 v2//vn2 v3//vn3)
    fprintf(fid, 'f %d//%d %d//%d %d//%d\n', ...
        [faces(:,1), faces(:,1), faces(:,2), faces(:,2), faces(:,3), faces(:,3)]');

catch ME
    fclose(fid);
    rethrow(ME);
end

fclose(fid);

info = dir(filename);
fprintf('  OBJ saved: %s  (%d faces, %.1f KB)\n', filename, n_faces, info.bytes/1024);
end
