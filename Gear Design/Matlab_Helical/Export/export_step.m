function export_step(mesh, filepath, part_name)
%EXPORT_STEP Exports a watertight 3D mesh to standard STEP AP214 format
%   (ISO 10303-21) as a closed faceted B-rep manifold solid.
%
%   Author: Ahmed Majdy Ahmed
%   Date:   2026-09-03

    if nargin < 3 || isempty(part_name)
        part_name = 'HELICAL_GEAR_PART';
    end

    fid = fopen(filepath, 'w');
    if fid == -1
        error('Failed to open file for STEP export: %s', filepath);
    end

    verts = mesh.vertices;
    faces = mesh.faces;
    nV = size(verts, 1);
    nF = size(faces, 1);

    % Unique edges
    edges = [faces(:, [1, 2]); faces(:, [2, 3]); faces(:, [3, 1])];
    edges = sort(edges, 2);
    [unique_edges, ~, ~] = unique(edges, 'rows');
    nE = size(unique_edges, 1);

    time_str = datestr(now, 'yyyy-mm-ddTHH:MM:SS');

    fprintf(fid, 'ISO-10303-21;\n');
    fprintf(fid, 'HEADER;\n');
    fprintf(fid, 'FILE_DESCRIPTION((''STEP AP214 Faceted B-Rep Model''),''2;1'');\n');
    fprintf(fid, 'FILE_NAME(''%s'',''%s'',(''Ahmed Majdy Ahmed''),(''Wind Turbine Pitch System''),''MATLAB Helical Gear Suite'',''MATLAB'',''None'');\n', ...
        part_name, time_str);
    fprintf(fid, 'FILE_SCHEMA((''AUTOMOTIVE_DESIGN { 1 0 10303 214 1 1 1 1 }''));\n');
    fprintf(fid, 'ENDSEC;\n');
    fprintf(fid, 'DATA;\n');

    id = 10;
    fprintf(fid, '#%d = APPLICATION_CONTEXT(''core data for automotive mechanical design processes'');\n', id);
    app_ctx_id = id; id = id + 1;
    fprintf(fid, '#%d = APPLICATION_PROTOCOL_DEFINITION(''international standard'',''automotive_design'',2000,#%d);\n', id, app_ctx_id);
    id = id + 1;
    fprintf(fid, '#%d = PRODUCT_CONTEXT('''',#%d,''mechanical'');\n', id, app_ctx_id);
    prod_ctx_id = id; id = id + 1;
    fprintf(fid, '#%d = PRODUCT(''%s'',''%s'','''',(#%d));\n', id, part_name, part_name, prod_ctx_id);
    prod_id = id; id = id + 1;
    fprintf(fid, '#%d = PRODUCT_DEFINITION_FORMATION('''','''',#%d);\n', id, prod_id);
    prod_def_form_id = id; id = id + 1;
    fprintf(fid, '#%d = PRODUCT_DEFINITION_CONTEXT(''part definition'',#%d,''design'');\n', id, app_ctx_id);
    prod_def_ctx_id = id; id = id + 1;
    fprintf(fid, '#%d = PRODUCT_DEFINITION(''%s'','''',#%d,#%d);\n', id, part_name, prod_def_form_id, prod_def_ctx_id);
    prod_def_id = id; id = id + 1;
    fprintf(fid, '#%d = PRODUCT_DEFINITION_SHAPE('''','''',#%d);\n', id, prod_def_id);
    prod_shape_id = id; id = id + 1;

    % Units & Coordinate System
    fprintf(fid, '#%d = ( LENGTH_UNIT() NAMED_UNIT(*) SI_UNIT(.MILLI.,.METRE.) );\n', id);
    len_unit_id = id; id = id + 1;
    fprintf(fid, '#%d = ( NAMED_UNIT(*) PLANE_ANGLE_UNIT() SI_UNIT($,.RADIAN.) );\n', id);
    angle_unit_id = id; id = id + 1;
    fprintf(fid, '#%d = ( NAMED_UNIT(*) SI_UNIT($,.STERADIAN.) SOLID_ANGLE_UNIT() );\n', id);
    solid_angle_unit_id = id; id = id + 1;
    fprintf(fid, '#%d = UNCERTAINTY_MEASURE_WITH_UNIT(LENGTH_MEASURE(1.0E-05),#%d,''distance_accuracy_value'',''None'');\n', id, len_unit_id);
    uncertainty_id = id; id = id + 1;
    fprintf(fid, '#%d = ( GEOMETRIC_REPRESENTATION_CONTEXT(3) GLOBAL_UNCERTAINTY_ASSIGNED_CONTEXT((#%d)) GLOBAL_UNIT_ASSIGNED_CONTEXT((#%d,#%d,#%d)) REPRESENTATION_CONTEXT(''Context #1'',''3D Context with UNIT and UNCERTAINTY'') );\n', ...
        id, uncertainty_id, len_unit_id, angle_unit_id, solid_angle_unit_id);
    geom_ctx_id = id; id = id + 1;

    % Points (CARTESIAN_POINT)
    pt_ids = zeros(nV, 1);
    for i = 1:nV
        fprintf(fid, '#%d = CARTESIAN_POINT('''',(%g,%g,%g));\n', id, verts(i, 1), verts(i, 2), verts(i, 3));
        pt_ids(i) = id;
        id = id + 1;
    end

    % Vertex points (VERTEX_POINT)
    vert_pt_ids = zeros(nV, 1);
    for i = 1:nV
        fprintf(fid, '#%d = VERTEX_POINT('''',#%d);\n', id, pt_ids(i));
        vert_pt_ids(i) = id;
        id = id + 1;
    end

    % Unique Edges (EDGE_CURVE with LINE geometry)
    edge_ids = zeros(nE, 1);
    for i = 1:nE
        v_start = unique_edges(i, 1);
        v_end   = unique_edges(i, 2);

        % Direction vector
        dir_vec = verts(v_end, :) - verts(v_start, :);
        dir_len = norm(dir_vec);
        if dir_len < 1e-12, dir_vec = [1, 0, 0]; dir_len = 1; else, dir_vec = dir_vec / dir_len; end

        fprintf(fid, '#%d = DIRECTION('''',(%g,%g,%g));\n', id, dir_vec(1), dir_vec(2), dir_vec(3));
        dir_id = id; id = id + 1;
        fprintf(fid, '#%d = VECTOR('''',#%d,%g);\n', id, dir_id, dir_len);
        vec_id = id; id = id + 1;
        fprintf(fid, '#%d = LINE('''',#%d,#%d);\n', id, pt_ids(v_start), vec_id);
        line_id = id; id = id + 1;
        fprintf(fid, '#%d = EDGE_CURVE('''',#%d,#%d,#%d,.T.);\n', id, vert_pt_ids(v_start), vert_pt_ids(v_end), line_id);
        edge_ids(i) = id; id = id + 1;
    end

    % Lookup map for edge IDs
    edge_hash = unique_edges(:, 1) * 1000000 + unique_edges(:, 2);

    % Faces (FACE_SURFACE with TRIANGULATION)
    face_ids = zeros(nF, 1);
    for f = 1:nF
        fv = faces(f, :);
        f_edges = [fv(1), fv(2); fv(2), fv(3); fv(3), fv(1)];
        orientations = true(3, 1);

        for j = 1:3
            e_sort = sort(f_edges(j, :));
            orientations(j) = (f_edges(j, 1) == e_sort(1));
        end

        e_hash_f = min(f_edges, [], 2) * 1000000 + max(f_edges, [], 2);
        [~, e_idx] = ismember(e_hash_f, edge_hash);

        % ORIENTED_EDGE
        oe_ids = zeros(3, 1);
        for j = 1:3
            bool_str = '.T.';
            if ~orientations(j), bool_str = '.F.'; end
            fprintf(fid, '#%d = ORIENTED_EDGE('''',*,*,#%d,%s);\n', id, edge_ids(e_idx(j)), bool_str);
            oe_ids(j) = id; id = id + 1;
        end

        % EDGE_LOOP
        fprintf(fid, '#%d = EDGE_LOOP('''',(#%d,#%d,#%d));\n', id, oe_ids(1), oe_ids(2), oe_ids(3));
        loop_id = id; id = id + 1;

        % FACE_OUTER_BOUND
        fprintf(fid, '#%d = FACE_OUTER_BOUND('''',#%d,.T.);\n', id, loop_id);
        bound_id = id; id = id + 1;

        % PLANE Surface for Face
        v1 = verts(fv(1), :);
        v2 = verts(fv(2), :);
        v3 = verts(fv(3), :);
        fn = cross(v2 - v1, v3 - v1);
        if norm(fn) > 0, fn = fn / norm(fn); else, fn = [0 0 1]; end

        fprintf(fid, '#%d = DIRECTION('''',(%g,%g,%g));\n', id, fn(1), fn(2), fn(3));
        fn_dir_id = id; id = id + 1;
        fprintf(fid, '#%d = AXIS2_PLACEMENT_3D('''',#%d,#%d,$);\n', id, pt_ids(fv(1)), fn_dir_id);
        ax_id = id; id = id + 1;
        fprintf(fid, '#%d = PLANE('''',#%d);\n', id, ax_id);
        plane_id = id; id = id + 1;

        % ADVANCED_FACE
        fprintf(fid, '#%d = ADVANCED_FACE('''',(#%d),#%d,.T.);\n', id, bound_id, plane_id);
        face_ids(f) = id; id = id + 1;
    end

    % CLOSED_SHELL
    fprintf(fid, '#%d = CLOSED_SHELL('''',(');
    for f = 1:nF
        if f == nF
            fprintf(fid, '#%d', face_ids(f));
        else
            fprintf(fid, '#%d,', face_ids(f));
        end
        if mod(f, 20) == 0, fprintf(fid, '\n'); end
    end
    fprintf(fid, '));\n');
    shell_id = id; id = id + 1;

    % MANIFOLD_SOLID_BREP
    fprintf(fid, '#%d = MANIFOLD_SOLID_BREP(''%s'',#%d);\n', id, part_name, shell_id);
    brep_id = id; id = id + 1;

    % ADVANCED_BREP_SHAPE_REPRESENTATION
    fprintf(fid, '#%d = ADVANCED_BREP_SHAPE_REPRESENTATION(''%s'',(#%d),#%d);\n', id, part_name, brep_id, geom_ctx_id);
    shape_rep_id = id; id = id + 1;

    fprintf(fid, '#%d = SHAPE_DEFINITION_REPRESENTATION(#%d,#%d);\n', id, prod_shape_id, shape_rep_id);

    fprintf(fid, 'ENDSEC;\n');
    fprintf(fid, 'END-ISO-10303-21;\n');
    fclose(fid);
end
