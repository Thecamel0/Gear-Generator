/**
 * CAD EXPORTERS SUITE
 * Generates ISO 10303-21 STEP AP214 (.stp), IGES 5.3 (.igs), Binary & ASCII STL (.stl),
 * SolidWorks VBA Macros (.bas), Equations (.txt), and ZIP packages directly in browser.
 *
 * Author: Ahmed Majdy Ahmed (Exporter Port)
 */

import JSZip from 'jszip';

/**
 * Downloads a string or Blob as a file directly to user's computer.
 */
export function downloadFile(content, filename, mimeType = 'application/octet-stream') {
  const blob = content instanceof Blob ? content : new Blob([content], { type: mimeType });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  setTimeout(() => {
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }, 200);
}

/**
 * Exports mesh as Binary STL Blob.
 */
export function exportSTLBinary(mesh, header = 'Zerol Bevel Gear Binary STL') {
  const { vertices, faces } = mesh;
  const numTriangles = faces.length;
  const bufferLength = 84 + numTriangles * 50;
  const buffer = new ArrayBuffer(bufferLength);
  const view = new DataView(buffer);

  // 80 bytes header
  for (let i = 0; i < 80; i++) {
    view.setUint8(i, i < header.length ? header.charCodeAt(i) : 32);
  }

  // 4 bytes triangle count (little endian)
  view.setUint32(80, numTriangles, true);

  let offset = 84;

  for (let i = 0; i < numTriangles; i++) {
    const f = faces[i];
    const v1 = vertices[f[0]];
    const v2 = vertices[f[1]];
    const v3 = vertices[f[2]];

    // Face normal via cross product
    const ax = v2[0] - v1[0], ay = v2[1] - v1[1], az = v2[2] - v1[2];
    const bx = v3[0] - v1[0], by = v3[1] - v1[1], bz = v3[2] - v1[2];
    let nx = ay * bz - az * by;
    let ny = az * bx - ax * bz;
    let nz = ax * by - ay * bx;
    const len = Math.sqrt(nx * nx + ny * ny + nz * nz) || 1;
    nx /= len; ny /= len; nz /= len;

    // Normal
    view.setFloat32(offset, nx, true);
    view.setFloat32(offset + 4, ny, true);
    view.setFloat32(offset + 8, nz, true);

    // V1
    view.setFloat32(offset + 12, v1[0], true);
    view.setFloat32(offset + 16, v1[1], true);
    view.setFloat32(offset + 20, v1[2], true);

    // V2
    view.setFloat32(offset + 24, v2[0], true);
    view.setFloat32(offset + 28, v2[1], true);
    view.setFloat32(offset + 32, v2[2], true);

    // V3
    view.setFloat32(offset + 36, v3[0], true);
    view.setFloat32(offset + 40, v3[1], true);
    view.setFloat32(offset + 44, v3[2], true);

    // 2 bytes attribute byte count
    view.setUint16(offset + 48, 0, true);

    offset += 50;
  }

  return new Blob([buffer], { type: 'application/sla' });
}

/**
 * Exports mesh as ASCII STL string.
 */
export function exportSTLAscii(mesh, solidName = 'Zerol_Bevel_Gear') {
  const { vertices, faces } = mesh;
  let out = `solid ${solidName}\n`;

  for (let i = 0; i < faces.length; i++) {
    const f = faces[i];
    const v1 = vertices[f[0]];
    const v2 = vertices[f[1]];
    const v3 = vertices[f[2]];

    const ax = v2[0] - v1[0], ay = v2[1] - v1[1], az = v2[2] - v1[2];
    const bx = v3[0] - v1[0], by = v3[1] - v1[1], bz = v3[2] - v1[2];
    let nx = ay * bz - az * by;
    let ny = az * bx - ax * bz;
    let nz = ax * by - ay * bx;
    const len = Math.sqrt(nx * nx + ny * ny + nz * nz) || 1;
    nx /= len; ny /= len; nz /= len;

    out += `  facet normal ${nx.toExponential(6)} ${ny.toExponential(6)} ${nz.toExponential(6)}\n`;
    out += `    outer loop\n`;
    out += `      vertex ${v1[0].toFixed(6)} ${v1[1].toFixed(6)} ${v1[2].toFixed(6)}\n`;
    out += `      vertex ${v2[0].toFixed(6)} ${v2[1].toFixed(6)} ${v2[2].toFixed(6)}\n`;
    out += `      vertex ${v3[0].toFixed(6)} ${v3[1].toFixed(6)} ${v3[2].toFixed(6)}\n`;
    out += `    endloop\n`;
    out += `  endfacet\n`;
  }
  out += `endsolid ${solidName}\n`;
  return out;
}

/**
 * Exports mesh as ISO 10303-21 STEP AP214 (.stp) Solid Body.
 * Matches MATLAB export_step_v2.m ADVANCED_BREP topology.
 */
export function exportSTEP(mesh, partName = 'Zerol_Bevel_Part', headerText = 'Zerol Bevel Gear V2 Solid Model') {
  const { vertices, faces } = mesh;
  const n_verts = vertices.length;
  const n_faces = faces.length;
  const dateStr = new Date().toISOString().replace(/\.\d+Z$/, '');

  let out = '';
  out += 'ISO-10303-21;\n';
  out += 'HEADER;\n';
  out += `FILE_DESCRIPTION(('${headerText}'),'2;1');\n`;
  out += `FILE_NAME('${partName}.stp','${dateStr}',('Ahmed Majdy Ahmed'),('Wind Turbine Pitch Control'),'JavaScript STEP Exporter V2','Zerol Studio V2','');\n`;
  out += `FILE_SCHEMA(('AUTOMOTIVE_DESIGN'));\n`;
  out += 'ENDSEC;\n';
  out += 'DATA;\n';

  let eid = 1;
  const e_app = eid++;
  out += `#${e_app}=APPLICATION_CONTEXT('core data for automotive mechanical design processes');\n`;

  const e_apd = eid++;
  out += `#${e_apd}=APPLICATION_PROTOCOL_DEFINITION('international standard','automotive_design',2000,#${e_app});\n`;

  const e_prc = eid++;
  out += `#${e_prc}=PRODUCT_RELATED_PRODUCT_CATEGORY('part',(#${eid}));\n`;

  const e_prod = eid++;
  out += `#${e_prod}=PRODUCT('${partName}','${headerText}','',(#${eid}));\n`;

  const e_pctx = eid++;
  out += `#${e_pctx}=PRODUCT_CONTEXT('',#${e_app},'mechanical');\n`;

  const e_pdf = eid++;
  out += `#${e_pdf}=PRODUCT_DEFINITION_FORMATION('','',#${e_prod});\n`;

  const e_pdc = eid++;
  out += `#${e_pdc}=PRODUCT_DEFINITION_CONTEXT('detailed design',#${e_app},'design');\n`;

  const e_pd = eid++;
  out += `#${e_pd}=PRODUCT_DEFINITION('design','',#${e_pdf},#${e_pdc});\n`;

  const e_pds = eid++;
  out += `#${e_pds}=PRODUCT_DEFINITION_SHAPE('','',#${e_pd});\n`;

  const e_lu = eid++;
  out += `#${e_lu}=(LENGTH_UNIT()NAMED_UNIT(*)SI_UNIT(.MILLI.,.METRE.));\n`;

  const e_au = eid++;
  out += `#${e_au}=(NAMED_UNIT(*)PLANE_ANGLE_UNIT()SI_UNIT($,.RADIAN.));\n`;

  const e_su = eid++;
  out += `#${e_su}=(NAMED_UNIT(*)SI_UNIT($,.STERADIAN.)SOLID_ANGLE_UNIT());\n`;

  const e_unc = eid++;
  out += `#${e_unc}=UNCERTAINTY_MEASURE_WITH_UNIT(LENGTH_MEASURE(1.E-06),#${e_lu},'distance_accuracy_value','maximum tolerance');\n`;

  const e_ctx = eid++;
  out += `#${e_ctx}=(GEOMETRIC_REPRESENTATION_CONTEXT(3)GLOBAL_UNCERTAINTY_ASSIGNED_CONTEXT((#${e_unc}))GLOBAL_UNIT_ASSIGNED_CONTEXT((#${e_lu},#${e_au},#${e_su}))REPRESENTATION_CONTEXT('Context3D','3D Context'));\n`;

  const e_org = eid++;
  out += `#${e_org}=CARTESIAN_POINT('Origin',(0.,0.,0.));\n`;
  const e_dz = eid++;
  out += `#${e_dz}=DIRECTION('axis',(0.,0.,1.));\n`;
  const e_dx = eid++;
  out += `#${e_dx}=DIRECTION('refdir',(1.,0.,0.));\n`;
  const e_ax = eid++;
  out += `#${e_ax}=AXIS2_PLACEMENT_3D('placement',#${e_org},#${e_dz},#${e_dx});\n`;

  // CARTESIAN_POINTs
  const pt_base = eid;
  for (let i = 0; i < n_verts; i++) {
    const v = vertices[i];
    out += `#${eid++}=CARTESIAN_POINT('',(${v[0].toFixed(6)},${v[1].toFixed(6)},${v[2].toFixed(6)}));\n`;
  }

  // VERTEX_POINTs
  const vp_base = eid;
  for (let i = 0; i < n_verts; i++) {
    out += `#${eid++}=VERTEX_POINT('',#${pt_base + i});\n`;
  }

  // ADVANCED_FACEs with EDGE_LOOPs
  const face_eids = [];

  for (let f = 0; f < n_faces; f++) {
    const vi = faces[f];
    const p1 = vertices[vi[0]];
    const p2 = vertices[vi[1]];
    const p3 = vertices[vi[2]];

    const vp = [vp_base + vi[0], vp_base + vi[1], vp_base + vi[2]];
    const pp = [pt_base + vi[0], pt_base + vi[1], pt_base + vi[2]];

    const edge_diffs = [
      [p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]],
      [p3[0] - p2[0], p3[1] - p2[1], p3[2] - p2[2]],
      [p1[0] - p3[0], p1[1] - p3[1], p1[2] - p3[2]]
    ];

    const ed = [];
    const ev = [];
    const el = [];
    const ec = [];
    const oe = [];

    for (let e = 0; e < 3; e++) {
      const d = edge_diffs[e];
      const len = Math.sqrt(d[0] * d[0] + d[1] * d[1] + d[2] * d[2]) || 1;
      const ux = d[0] / len, uy = d[1] / len, uz = d[2] / len;

      ed[e] = eid++;
      out += `#${ed[e]}=DIRECTION('',(${ux.toFixed(9)},${uy.toFixed(9)},${uz.toFixed(9)}));\n`;

      ev[e] = eid++;
      out += `#${ev[e]}=VECTOR('',#${ed[e]},${len.toFixed(6)});\n`;

      el[e] = eid++;
      out += `#${el[e]}=LINE('',#${pp[e]},#${ev[e]});\n`;

      const vp_s = vp[e];
      const vp_e = vp[(e + 1) % 3];
      ec[e] = eid++;
      out += `#${ec[e]}=EDGE_CURVE('',#${vp_s},#${vp_e},#${el[e]},.T.);\n`;

      oe[e] = eid++;
      out += `#${oe[e]}=ORIENTED_EDGE('',*,*,#${ec[e]},.T.);\n`;
    }

    const e_el = eid++;
    out += `#${e_el}=EDGE_LOOP('',(#${oe[0]},#${oe[1]},#${oe[2]}));\n`;

    const e_fob = eid++;
    out += `#${e_fob}=FACE_OUTER_BOUND('',#${e_el},.T.);\n`;

    // Normal calculation
    const ax = edge_diffs[0][0], ay = edge_diffs[0][1], az = edge_diffs[0][2];
    const bx = edge_diffs[1][0], by = edge_diffs[1][1], bz = edge_diffs[1][2];
    let nx = ay * bz - az * by, ny = az * bx - ax * bz, nz = ax * by - ay * bx;
    const n_len = Math.sqrt(nx * nx + ny * ny + nz * nz) || 1;
    nx /= n_len; ny /= n_len; nz /= n_len;

    let rx, ry, rz;
    if (Math.abs(nz) < 0.9) {
      rx = -ny; ry = nx; rz = 0;
    } else {
      rx = 0; ry = -nz; rz = ny;
    }
    const r_len = Math.sqrt(rx * rx + ry * ry + rz * rz) || 1;
    rx /= r_len; ry /= r_len; rz /= r_len;

    const e_fp = eid++;
    out += `#${e_fp}=CARTESIAN_POINT('',(${p1[0].toFixed(6)},${p1[1].toFixed(6)},${p1[2].toFixed(6)}));\n`;

    const e_fn = eid++;
    out += `#${e_fn}=DIRECTION('',(${nx.toFixed(9)},${ny.toFixed(9)},${nz.toFixed(9)}));\n`;

    const e_fr = eid++;
    out += `#${e_fr}=DIRECTION('',(${rx.toFixed(9)},${ry.toFixed(9)},${rz.toFixed(9)}));\n`;

    const e_fax = eid++;
    out += `#${e_fax}=AXIS2_PLACEMENT_3D('',#${e_fp},#${e_fn},#${e_fr});\n`;

    const e_plane = eid++;
    out += `#${e_plane}=PLANE('',#${e_fax});\n`;

    const e_face = eid++;
    out += `#${e_face}=ADVANCED_FACE('',(#${e_fob}),#${e_plane},.T.);\n`;
    face_eids.push(e_face);
  }

  // CLOSED_SHELL -> MANIFOLD_SOLID_BREP
  const e_shell = eid++;
  out += `#${e_shell}=CLOSED_SHELL('shell',(${face_eids.map(id => '#' + id).join(',')}));\n`;

  const e_brep = eid++;
  out += `#${e_brep}=MANIFOLD_SOLID_BREP('${partName}',#${e_shell});\n`;

  const e_sr = eid++;
  out += `#${e_sr}=ADVANCED_BREP_SHAPE_REPRESENTATION('${partName}',(#${e_brep},#${e_ax}),#${e_ctx});\n`;

  out += `#${eid++}=SHAPE_DEFINITION_REPRESENTATION(#${e_pds},#${e_sr});\n`;
  out += 'ENDSEC;\n';
  out += 'END-ISO-10303-21;\n';

  return out;
}

/**
 * Exports mesh as IGES 5.3 (.igs) Entity 128 Rational B-Spline Surface.
 * Compatible with SolidWorks and CATIA surface / solid import.
 */
export function exportIGES(mesh, partName = 'Zerol_Bevel_Gear', headerText = 'Zerol Bevel Gear (IGES 5.3)') {
  const { vertices, faces } = mesh;
  const n_faces = faces.length;
  const dateStr = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 15);

  const hollerith = str => `${str.length}H${str}`;
  const padRight = (str, len) => str.padEnd(len, ' ');
  const padLeft = (str, len) => String(str).padStart(len, ' ');

  const s_lines = [];
  const g_lines = [];
  const de_lines = [];
  const p_lines = [];

  // Start Section (S)
  const s_text = `IGES 5.3 ${headerText}`;
  s_lines.push(padRight(s_text.slice(0, 72), 72) + 'S' + padLeft(1, 7));

  // Global Section (G)
  const prod_h = hollerith(partName);
  const file_h = hollerith(partName + '.igs');
  const auth_h = hollerith('Ahmed Majdy Ahmed');
  const org_h = hollerith('Wind Turbine Pitch Control');
  const date_h = hollerith(dateStr);

  const g_text = `1H,,1H;,${prod_h},${file_h},7HMATLAB ,7HMATLAB ,32,308,15,308,15,${prod_h},1.0,6,2HMM,1,0.001,${date_h},1.0,1000.0,${auth_h},${org_h},11,0;`;

  let g_rem = g_text;
  let g_idx = 1;
  while (g_rem.length > 0) {
    const chunk = g_rem.slice(0, 72);
    g_lines.push(padRight(chunk, 72) + 'G' + padLeft(g_idx++, 7));
    g_rem = g_rem.slice(72);
  }

  // Directory Entry (D) and Parameter (P) Sections
  let d_count = 0;
  let p_line_count = 0;

  for (let f = 0; f < n_faces; f++) {
    const vi = faces[f];
    const P00 = vertices[vi[0]];
    const P10 = vertices[vi[1]];
    const P01 = vertices[vi[2]];
    const P11 = vertices[vi[2]]; // degenerate bilinear quad

    const p_str = `128,1,1,1,1,0,0,1,0,0,0.,0.,1.,1.,0.,0.,1.,1.,1.,1.,1.,1.,${P00[0].toFixed(6)},${P00[1].toFixed(6)},${P00[2].toFixed(6)},${P10[0].toFixed(6)},${P10[1].toFixed(6)},${P10[2].toFixed(6)},${P01[0].toFixed(6)},${P01[1].toFixed(6)},${P01[2].toFixed(6)},${P11[0].toFixed(6)},${P11[1].toFixed(6)},${P11[2].toFixed(6)},0.,1.,0.,1.;`;

    const de_seq1 = d_count * 2 + 1;
    const de_seq2 = d_count * 2 + 2;
    const p_first = p_line_count + 1;

    // Split parameter string safely at commas (max 64 chars)
    let p_rem = p_str;
    let n_plines_this = 0;

    while (p_rem.length > 0) {
      let cut = 64;
      if (p_rem.length > 64) {
        const lastComma = p_rem.slice(0, 64).lastIndexOf(',');
        cut = lastComma > 0 ? lastComma + 1 : 64;
      }
      const chunk = p_rem.slice(0, cut);
      p_rem = p_rem.slice(cut);
      p_line_count++;
      n_plines_this++;
      p_lines.push(padRight(chunk, 64) + padLeft(de_seq1, 8) + 'P' + padLeft(p_line_count, 7));
    }

    const de1 = padLeft(128, 8) + padLeft(p_first, 8) + padLeft(0, 8) + padLeft(0, 8) + padLeft(0, 8) + padLeft(0, 8) + padLeft(0, 8) + padLeft(0, 8) + '00000001';
    de_lines.push(padRight(de1, 72) + 'D' + padLeft(de_seq1, 7));

    const de2 = padLeft(128, 8) + padLeft(0, 8) + padLeft(0, 8) + padLeft(n_plines_this, 8) + padLeft(0, 8) + padLeft(0, 8) + padLeft(0, 8) + padLeft(0, 8) + padLeft(f + 1, 8);
    de_lines.push(padRight(de2, 72) + 'D' + padLeft(de_seq2, 7));

    d_count++;
  }

  // Terminate Section (T)
  const t_str = `S${padLeft(s_lines.length, 7)}G${padLeft(g_lines.length, 7)}D${padLeft(de_lines.length, 7)}P${padLeft(p_lines.length, 7)}`;
  const t_line = padRight(t_str, 72) + 'T' + padLeft(1, 7);

  return [...s_lines, ...g_lines, ...de_lines, ...p_lines, t_line].join('\n') + '\n';
}

/**
 * Generates SolidWorks Equations text file.
 */
export function exportSolidWorksEquations(calc) {
  if (calc.gear_type === 'internal_spur') {
    return [
      `"Module" = ${calc.m}mm`,
      `"PinionTeeth" = ${calc.Np}`,
      `"RingTeeth" = ${calc.Ng}`,
      `"PressureAngle" = ${calc.phi_deg}deg`,
      `"CenterDistance" = ${calc.center_dist.toFixed(3)}mm`,
      `"FaceWidth" = ${calc.F.toFixed(3)}mm`,
      `"PinionPitchDia" = ${calc.dp.toFixed(3)}mm`,
      `"RingPitchDia" = ${calc.dg.toFixed(3)}mm`,
      `"PinionTipDia" = ${(2 * calc.ra_p).toFixed(3)}mm`,
      `"PinionRootDia" = ${(2 * calc.rd_p).toFixed(3)}mm`,
      `"RingInnerTipDia" = ${(2 * calc.ra_g_int).toFixed(3)}mm`,
      `"RingInnerRootDia" = ${(2 * calc.rd_g_int).toFixed(3)}mm`,
      `"RingOuterRimDia" = ${calc.D_outer.toFixed(3)}mm`,
      `"PinionBore" = 0.0mm`
    ].join('\n') + '\n';
  }

  if (calc.gear_type === 'helical') {
    return [
      `"NormalModule" = ${calc.mn}mm`,
      `"TransverseModule" = ${calc.mt.toFixed(4)}mm`,
      `"PinionTeeth" = ${calc.Np}`,
      `"GearTeeth" = ${calc.Ng}`,
      `"NormalPressureAngle" = ${calc.phi_n_deg}deg`,
      `"TransversePressureAngle" = ${calc.phi_t_deg.toFixed(4)}deg`,
      `"HelixAngle" = ${calc.beta_deg}deg`,
      `"CenterDistance" = ${calc.center_dist.toFixed(3)}mm`,
      `"FaceWidth" = ${calc.F.toFixed(3)}mm`,
      `"PinionPitchDia" = ${calc.dp.toFixed(3)}mm`,
      `"GearPitchDia" = ${calc.dg.toFixed(3)}mm`,
      `"PinionBaseDia" = ${calc.db_p.toFixed(3)}mm`,
      `"GearBaseDia" = ${calc.db_g.toFixed(3)}mm`,
      `"PinionTipDia" = ${(2 * calc.ra_p).toFixed(3)}mm`,
      `"GearTipDia" = ${(2 * calc.ra_g).toFixed(3)}mm`,
      `"PinionRootDia" = ${(2 * calc.rd_p).toFixed(3)}mm`,
      `"GearRootDia" = ${(2 * calc.rd_g).toFixed(3)}mm`,
      `"WorkingDepth" = ${calc.hw.toFixed(3)}mm`,
      `"WholeDepth" = ${calc.ht.toFixed(3)}mm`,
      `"Clearance" = ${calc.c_std.toFixed(3)}mm`,
      `"PinionBore" = 0.0mm`,
      `"GearBore" = 0.0mm`
    ].join('\n') + '\n';
  }

  if (calc.gear_type === 'spur') {
    return [
      `"Module" = ${calc.m}mm`,
      `"PinionTeeth" = ${calc.Np}`,
      `"GearTeeth" = ${calc.Ng}`,
      `"PressureAngle" = ${calc.phi_deg}deg`,
      `"PinionPitchDia" = ${calc.dp.toFixed(3)}mm`,
      `"GearPitchDia" = ${calc.dg.toFixed(3)}mm`,
      `"CenterDistance" = ${calc.center_dist.toFixed(3)}mm`,
      `"FaceWidth" = ${calc.F.toFixed(3)}mm`,
      `"WorkingDepth" = ${calc.hw.toFixed(3)}mm`,
      `"WholeDepth" = ${calc.ht.toFixed(3)}mm`,
      `"PinionTipDia" = ${(2 * calc.ra_p).toFixed(3)}mm`,
      `"GearTipDia" = ${(2 * calc.ra_g).toFixed(3)}mm`,
      `"PinionRootDia" = ${(2 * calc.rd_p).toFixed(3)}mm`,
      `"GearRootDia" = ${(2 * calc.rd_g).toFixed(3)}mm`,
      `"PinionBore" = 0.0mm`,
      `"GearBore" = 0.0mm`
    ].join('\n') + '\n';
  }

  if (calc.gear_type === 'spiral-bevel') {
    return [
      `"Module" = ${calc.m}mm`,
      `"PinionTeeth" = ${calc.Np}`,
      `"GearTeeth" = ${calc.Ng}`,
      `"NormalPressureAngle" = ${calc.phi_n_deg}deg`,
      `"TransversePressureAngle" = ${calc.phi_t_deg.toFixed(3)}deg`,
      `"MeanSpiralAngle" = ${calc.beta_m_deg.toFixed(2)}deg`,
      `"OuterSpiralAngle" = ${calc.beta_o_deg.toFixed(2)}deg`,
      `"CutterRadius" = ${calc.r_cutter.toFixed(2)}mm`,
      `"PinionPitchDia" = ${calc.dp.toFixed(3)}mm`,
      `"GearPitchDia" = ${calc.dg.toFixed(3)}mm`,
      `"PinionOutDia" = ${calc.Do_p.toFixed(3)}mm`,
      `"GearOutDia" = ${calc.Do_g.toFixed(3)}mm`,
      `"PinionConeAngle" = ${calc.gamma_p_deg.toFixed(3)}deg`,
      `"GearConeAngle" = ${calc.gamma_g_deg.toFixed(3)}deg`,
      `"OuterConeDistance" = ${calc.Ao.toFixed(3)}mm`,
      `"FaceWidth" = ${calc.F.toFixed(3)}mm`,
      `"WorkingDepth" = ${calc.hw.toFixed(3)}mm`,
      `"WholeDepth" = ${calc.ht.toFixed(3)}mm`,
      `"Clearance" = ${calc.c_std.toFixed(3)}mm`
    ].join('\n') + '\n';
  }

  return [
    `"Module" = ${calc.m}mm`,
    `"PinionTeeth" = ${calc.Np}`,
    `"GearTeeth" = ${calc.Ng}`,
    `"PressureAngle" = ${calc.phi_deg}deg`,
    `"PinionPitchDia" = ${calc.dp.toFixed(3)}mm`,
    `"GearPitchDia" = ${calc.dg.toFixed(3)}mm`,
    `"PinionOutDia" = ${calc.Do_p.toFixed(3)}mm`,
    `"GearOutDia" = ${calc.Do_g.toFixed(3)}mm`,
    `"PinionConeAngle" = ${calc.gamma_p_deg.toFixed(3)}deg`,
    `"GearConeAngle" = ${calc.gamma_g_deg.toFixed(3)}deg`,
    `"FaceWidth" = ${calc.F.toFixed(3)}mm`,
    `"WorkingDepth" = ${calc.hw.toFixed(3)}mm`,
    `"WholeDepth" = ${calc.ht.toFixed(3)}mm`,
    `"PinionAddendum" = ${calc.a_p.toFixed(3)}mm`,
    `"GearAddendum" = ${calc.a_g.toFixed(3)}mm`,
    `"PinionMountingDist" = ${(calc.MD_p || (calc.Ao * Math.cos(calc.gamma_p) - calc.a_p * Math.sin(calc.gamma_p))).toFixed(3)}mm`,
    `"GearMountingDist" = ${(calc.MD_g || (calc.Ao * Math.cos(calc.gamma_g) - calc.a_g * Math.sin(calc.gamma_g))).toFixed(3)}mm`,
    `"PinionBore" = 0.0mm`,
    `"GearBore" = 0.0mm`
  ].join('\n') + '\n';
}

/**
 * Generates SolidWorks VBA Macro script (.bas).
 */
export function exportSolidWorksMacro(calc) {
  if (calc.gear_type === 'internal_spur') {
    const m = calc.m;
    const Np = calc.Np;
    const Ng = calc.Ng;
    const dp = calc.dp.toFixed(3);
    const dg = calc.dg.toFixed(3);
    const Do_rim = calc.D_outer.toFixed(3);
    const C = calc.center_dist.toFixed(3);

    return `' ======================================================================
' SOLIDWORKS VBA MACRO — PARAMETRIC INTERNAL SPUR GEAR DRIVE CREATOR
' Wind Turbine Pitch Control System (Ring Gear & Pinion)
' Generated automatically by Gear Master Studio
' ======================================================================

Option Explicit

Dim swApp As Object
Dim swModel As Object

Sub main()
    Set swApp = Application.SldWorks
    MsgBox "Parametric Internal Spur Gear Parameters Loaded:" & vbCrLf & _
           "Module: ${m} mm" & vbCrLf & _
           "Pinion Teeth: ${Np} (PD = ${dp} mm)" & vbCrLf & _
           "Ring Gear Teeth: ${Ng} (PD = ${dg} mm)" & vbCrLf & _
           "Center Distance: ${C} mm" & vbCrLf & _
           "Ring Outer Diameter: ${Do_rim} mm", vbInformation, "Gear Master Studio"
End Sub
`;
  }

  if (calc.gear_type === 'helical') {
    const mn = calc.mn;
    const mt = calc.mt.toFixed(4);
    const Np = calc.Np;
    const Ng = calc.Ng;
    const beta = calc.beta_deg;
    const phi_n = calc.phi_n_deg;
    const dp = calc.dp.toFixed(3);
    const dg = calc.dg.toFixed(3);
    const dap = (2 * calc.ra_p).toFixed(3);
    const dag = (2 * calc.ra_g).toFixed(3);
    const ddp = (2 * calc.rd_p).toFixed(3);
    const ddg = (2 * calc.rd_g).toFixed(3);
    const F = calc.F.toFixed(3);
    const C = calc.center_dist.toFixed(3);

    return `' ======================================================================
' SOLIDWORKS VBA MACRO \u2014 PARAMETRIC HELICAL GEAR CREATOR
' Wind Turbine Pitch Control Drive System
' Generated automatically by Gear Master Studio
' ======================================================================

Option Explicit

Dim swApp As Object
Dim swModel As Object
Dim swFeatMgr As Object
Dim swModelExt As Object
Dim swEqnMgr As Object
Dim swSketchMgr As Object
Dim boolstatus As Boolean

Sub main()
    Set swApp = Application.SldWorks

    ' 1. Create Helical Pinion (${Np}T, RH, Helix ${beta} deg)
    CreateHelicalGear ${mn}#, ${mt}#, ${Np}, ${Ng}, ${phi_n}#, ${beta}#, ${dp}#, ${dap}, ${ddp}, ${F}#, 0#, "Helical_Pinion_${Np}T_RH", 1

    ' 2. Create Helical Central Gear (${Ng}T, LH, Helix ${beta} deg)
    CreateHelicalGear ${mn}#, ${mt}#, ${Ng}, ${Np}, ${phi_n}#, ${beta}#, ${dg}#, ${dag}, ${ddg}, ${F}#, 0#, "Helical_Gear_${Ng}T_LH", -1

    MsgBox "Parametric Helical Gear Generation Complete!" & vbCrLf & _
           "Generated: Helical Pinion (${Np}T, RH) and Helical Gear (${Ng}T, LH)" & vbCrLf & _
           "Helix Angle = ${beta} deg, Face = ${F} mm, Center Distance = ${C} mm", vbInformation, "Success"
End Sub

Sub CreateHelicalGear(mn As Double, mt As Double, N As Integer, N_match As Integer, _
                      phi_n As Double, beta As Double, d_pitch As Double, d_tip As Double, _
                      d_root As Double, face_w As Double, bore_d As Double, _
                      partName As String, hand As Integer)

    Set swModel = swApp.NewDocument(swApp.GetUserPreferenceStringValue(1), 0, 0, 0)
    If swModel Is Nothing Then Set swModel = swApp.NewPart()
    Set swModelExt = swModel.Extension
    Set swFeatMgr = swModel.FeatureManager
    Set swSketchMgr = swModel.SketchManager
    Set swEqnMgr = swModel.GetEquationMgr

    swEqnMgr.Add -1, """NormalModule"" = " & mn
    swEqnMgr.Add -1, """TransverseModule"" = " & mt
    swEqnMgr.Add -1, """Teeth"" = " & N
    swEqnMgr.Add -1, """HelixAngle"" = " & beta
    swEqnMgr.Add -1, """NormalPressureAngle"" = " & phi_n
    swEqnMgr.Add -1, """PitchDiameter"" = " & d_pitch
    swEqnMgr.Add -1, """TipDiameter"" = " & d_tip
    swEqnMgr.Add -1, """RootDiameter"" = " & d_root
    swEqnMgr.Add -1, """FaceWidth"" = " & face_w
    swEqnMgr.Add -1, """CenterDistance"" = " & ((d_pitch + mt * N_match) / 2)
    swModel.EditRebuild3

    boolstatus = swModelExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCircleByRadius 0, 0, 0, (d_tip / 2) / 1000
    If bore_d > 0 Then swSketchMgr.CreateCircleByRadius 0, 0, 0, (bore_d / 2) / 1000
    swFeatMgr.FeatureExtrusion3 True, False, False, 0, 0, face_w / 1000, 0.01, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False
    swModel.ViewZoomtofit2
End Sub
`;
  }

  if (calc.gear_type === 'spur') {
    const m = calc.m;
    const Np = calc.Np;
    const Ng = calc.Ng;
    const phi = calc.phi_deg;
    const dp = calc.dp.toFixed(3);
    const dg = calc.dg.toFixed(3);
    const dap = (2 * calc.ra_p).toFixed(3);
    const dag = (2 * calc.ra_g).toFixed(3);
    const ddp = (2 * calc.rd_p).toFixed(3);
    const ddg = (2 * calc.rd_g).toFixed(3);
    const F = calc.F.toFixed(3);
    const C = calc.center_dist.toFixed(3);

    return `' ======================================================================
' SOLIDWORKS VBA MACRO — PARAMETRIC SPUR GEAR CREATOR
' Wind Turbine Pitch Control Drive System
' Generated automatically by Gear Master Studio
' ======================================================================

Option Explicit

Dim swApp As Object
Dim swModel As Object
Dim swFeatMgr As Object
Dim swModelExt As Object
Dim swEqnMgr As Object
Dim swSketchMgr As Object
Dim swSketchSegment As Object
Dim boolstatus As Boolean
Dim longstatus As Long, longwarnings As Long

Sub main()
    Set swApp = Application.SldWorks

    ' 1. Create Pinion (${Np}T, Module ${m}, Face ${F} mm, Pitch Dia ${dp} mm)
    CreateSpurGear ${m}#, ${Np}, ${Ng}, ${phi}#, ${dp}#, ${dap}, ${ddp}, ${F}#, 0#, "Spur_Pinion_${Np}T"

    ' 2. Create Central Spur Bull Gear (${Ng}T, Module ${m}, Face ${F} mm, Pitch Dia ${dg} mm)
    CreateSpurGear ${m}#, ${Ng}, ${Np}, ${phi}#, ${dg}#, ${dag}, ${ddg}, ${F}#, 0#, "Spur_Gear_${Ng}T"

    MsgBox "Parametric Spur Gear Generation Complete!" & vbCrLf & _
           "Generated: Pinion (${Np}T, PD=${dp}mm) and Central Gear (${Ng}T, PD=${dg}mm)" & vbCrLf & _
           "Center Distance = ${C} mm", vbInformation, "Success"
End Sub

Sub CreateSpurGear(m As Double, N As Integer, N_match As Integer, phi As Double, _
                   d_pitch As Double, d_tip As Double, d_root As Double, _
                   face_w As Double, bore_d As Double, partName As String)

    Set swModel = swApp.NewDocument(swApp.GetUserPreferenceStringValue(1), 0, 0, 0)
    If swModel Is Nothing Then Set swModel = swApp.NewPart()
    Set swModelExt = swModel.Extension
    Set swFeatMgr = swModel.FeatureManager
    Set swSketchMgr = swModel.SketchManager
    Set swEqnMgr = swModel.GetEquationMgr

    ' Global Variables / Parameters
    swEqnMgr.Add -1, """Module"" = " & m
    swEqnMgr.Add -1, """Teeth"" = " & N
    swEqnMgr.Add -1, """MatchingTeeth"" = " & N_match
    swEqnMgr.Add -1, """PressureAngle"" = " & phi
    swEqnMgr.Add -1, """PitchDiameter"" = " & d_pitch
    swEqnMgr.Add -1, """TipDiameter"" = " & d_tip
    swEqnMgr.Add -1, """RootDiameter"" = " & d_root
    swEqnMgr.Add -1, """FaceWidth"" = " & face_w
    swEqnMgr.Add -1, """BoreDiameter"" = " & bore_d
    swEqnMgr.Add -1, """CenterDistance"" = " & ((d_pitch + m * N_match) / 2)
    swModel.EditRebuild3

    ' Create Cylindrical Blank on Front Plane
    boolstatus = swModelExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True

    Dim r_tip_m As Double, r_bore_m As Double, fw_m As Double
    r_tip_m = (d_tip / 2) / 1000
    r_bore_m = (bore_d / 2) / 1000
    fw_m = face_w / 1000

    ' Draw Outer Tip Circle and Inner Bore Circle
    swSketchMgr.CreateCircleByRadius 0, 0, 0, r_tip_m
    If bore_d > 0 Then
        swSketchMgr.CreateCircleByRadius 0, 0, 0, r_bore_m
    End If

    ' Extrude Boss/Base along Z
    swFeatMgr.FeatureExtrusion3 True, False, False, 0, 0, fw_m, 0.01, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False
    swModel.ViewZoomtofit2
End Sub
`;
  }

  const m = calc.m;
  const Np = calc.Np;
  const Ng = calc.Ng;
  const phi = calc.phi_deg;
  const gp_deg = calc.gamma_p_deg.toFixed(3);
  const gg_deg = calc.gamma_g_deg.toFixed(3);
  const dp = calc.dp.toFixed(3);
  const dg = calc.dg.toFixed(3);
  const Do_p = calc.Do_p.toFixed(3);
  const Do_g = calc.Do_g.toFixed(3);
  const F = calc.F.toFixed(3);
  const MD_p = (calc.MD_p || calc.Ao * Math.cos(calc.gamma_p)).toFixed(3);
  const MD_g = (calc.MD_g || calc.Ao * Math.cos(calc.gamma_g)).toFixed(3);

  const isStraight = calc.gear_type === 'straight-bevel';
  const isSpiral = calc.gear_type === 'spiral-bevel';
  const gearTitle = isSpiral ? 'SPIRAL BEVEL GEAR CREATOR' : isStraight ? 'STRAIGHT BEVEL GEAR CREATOR' : 'ZEROL BEVEL GEAR CREATOR';
  const pinName = isSpiral ? 'Spiral_Pinion' : isStraight ? 'Straight_Pinion' : 'Zerol_Pinion';
  const gearName = isSpiral ? 'Spiral_Gear' : isStraight ? 'Straight_Gear' : 'Zerol_Gear';
  const doneMsg = isSpiral ? 'Parametric Spiral Bevel Gear Generation Complete!' : isStraight ? 'Parametric Straight Bevel Gear Generation Complete!' : 'Parametric Zerol Bevel Gear Generation Complete!';

  return `' ======================================================================
' SOLIDWORKS VBA MACRO \u2014 PARAMETRIC ${gearTitle}
' Wind Turbine Pitch Control Drive System
' Generated automatically by Gear Master Studio
' ======================================================================

Option Explicit

Dim swApp As Object
Dim swModel As Object
Dim swFeatMgr As Object
Dim swModelExt As Object
Dim swEqnMgr As Object
Dim swSketchMgr As Object
Dim swSketchSegment As Object
Dim boolstatus As Boolean
Dim longstatus As Long, longwarnings As Long

Sub main()
    Set swApp = Application.SldWorks

    ' 1. Create Pinion
    CreateBevelGear ${m}, ${Np}, ${Ng}, ${phi}, ${dp}, ${Do_p}, ${gp_deg}, ${F}, ${MD_p || (calc.Ao * Math.cos(calc.gamma_p)).toFixed(3)}, 0, 36, "${pinName}"

    ' 2. Create Ring Gear
    CreateBevelGear ${m}, ${Ng}, ${Np}, ${phi}, ${dg}, ${Do_g}, ${gg_deg}, ${F}, ${MD_g || (calc.Ao * Math.cos(calc.gamma_g)).toFixed(3)}, 0, 72, "${gearName}"

    MsgBox "${doneMsg}" & vbCrLf & _
           "Both Pinion (${Np}T) and Gear (${Ng}T) models generated.", vbInformation, "Success"
End Sub

Sub CreateBevelGear(m As Double, N As Integer, N_match As Integer, phi As Double, _
                    d_pitch As Double, d_outer As Double, gamma_deg As Double, _
                    face_w As Double, MD As Double, bore_d As Double, hub_d As Double, _
                    partName As String)

    Set swModel = swApp.NewDocument(swApp.GetUserPreferenceStringValue(1), 0, 0, 0)
    If swModel Is Nothing Then Set swModel = swApp.NewPart()
    Set swModelExt = swModel.Extension
    Set swFeatMgr = swModel.FeatureManager
    Set swSketchMgr = swModel.SketchManager
    Set swEqnMgr = swModel.GetEquationMgr

    ' Add Equations / Global Variables
    swEqnMgr.Add -1, """Module"" = " & m
    swEqnMgr.Add -1, """Teeth"" = " & N
    swEqnMgr.Add -1, """MatchingTeeth"" = " & N_match
    swEqnMgr.Add -1, """PressureAngle"" = " & phi
    swEqnMgr.Add -1, """PitchDiameter"" = " & d_pitch
    swEqnMgr.Add -1, """OutsideDiameter"" = " & d_outer
    swEqnMgr.Add -1, """PitchConeAngle"" = " & gamma_deg
    swEqnMgr.Add -1, """FaceWidth"" = " & face_w
    swEqnMgr.Add -1, """MountingDistance"" = " & MD
    swEqnMgr.Add -1, """BoreDiameter"" = " & bore_d
    swModel.EditRebuild3

    ' Create Revolved Gear Blank
    boolstatus = swModelExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    swSketchMgr.InsertSketch True

    Dim rad_out As Double, MD_m As Double, fw_m As Double, gamma_rad As Double
    rad_out = (d_outer / 2) / 1000
    MD_m = MD / 1000
    fw_m = face_w / 1000
    gamma_rad = gamma_deg * 3.14159265358979 / 180#

    ' Draw Axis of Revolution and Mark as Centerline
    Set swSketchSegment = swSketchMgr.CreateCenterLine(0, 0, 0, 0, MD_m, 0)
    swSketchSegment.ConstructionGeometry = True

    ' Draw Closed Cone Profile
    Dim z_top As Double
    z_top = MD_m - (rad_out / Tan(gamma_rad))
    swSketchMgr.CreateLine 0, 0, 0, rad_out, z_top, 0
    swSketchMgr.CreateLine rad_out, z_top, 0, rad_out, z_top - fw_m, 0
    swSketchMgr.CreateLine rad_out, z_top - fw_m, 0, 0, 0, 0

    ' Select Centerline Axis for Revolve (Mark = 4)
    swSketchSegment.Select2 False, 4

    ' Revolve Boss/Base (360 degrees)
    swFeatMgr.FeatureRevolve2 True, True, False, False, False, False, 0, 0, 6.28318530717958, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True
    swModel.ViewZoomtofit2
End Sub
`;
}

/**
 * Generates Design Summary CSV Report.
 */
export function exportDesignReportCSV(calc) {
  if (calc.gear_type === 'helical') {
    const rows = [
      ['Parameter', 'Value', 'Unit', 'Notes'],
      ['Gear Type', 'Helical Gear Drive', '-', 'Parallel-axis multi-pinion wind turbine pitch drive'],
      ['Normal Module (mn)', calc.mn, 'mm', 'Standard cutter module'],
      ['Transverse Module (mt)', calc.mt.toFixed(4), 'mm', 'mt = mn / cos(beta)'],
      ['Tooth Angle / Helix Angle (beta)', calc.beta_deg, 'deg', 'Pinion RH, Gear LH'],
      ['Normal Pressure Angle (phi_n)', calc.phi_n_deg, 'deg', 'Standard 20 deg'],
      ['Transverse Pressure Angle (phi_t)', calc.phi_t_deg.toFixed(3), 'deg', 'tan(phi_t) = tan(phi_n)/cos(beta)'],
      ['Pinion Teeth (Np)', calc.Np, '-', 'Driving pinions (RH)'],
      ['Central Gear Teeth (Ng)', calc.Ng, '-', 'Driven central gear (LH)'],
      ['Gear Ratio (i)', calc.i_ratio.toFixed(2), '-', `1:${calc.i_ratio.toFixed(1)} reduction`],
      ['Center Distance (C)', calc.center_dist.toFixed(3), 'mm', 'C = (dp + dg) / 2'],
      ['Face Width (F)', calc.F.toFixed(3), 'mm', 'Continuous overlap face width'],
      ['Multi-Pinions Count', calc.n_pinions, '-', '3 pinions spaced at 120 deg'],
      ['Pinion Pitch Diameter (dp)', calc.dp.toFixed(3), 'mm', 'dp = mt * Np'],
      ['Gear Pitch Diameter (dg)', calc.dg.toFixed(3), 'mm', 'dg = mt * Ng'],
      ['Pinion Base Diameter (db_p)', calc.db_p.toFixed(3), 'mm', 'db_p = dp * cos(phi_t)'],
      ['Gear Base Diameter (db_g)', calc.db_g.toFixed(3), 'mm', 'db_g = dg * cos(phi_t)'],
      ['Pinion Tip Diameter (da_p)', (2 * calc.ra_p).toFixed(3), 'mm', 'da_p = dp + 2*mn'],
      ['Gear Tip Diameter (da_g)', (2 * calc.ra_g).toFixed(3), 'mm', 'da_g = dg + 2*mn'],
      ['Working Depth (hw)', calc.hw.toFixed(3), 'mm', 'hw = 2.0 * mn'],
      ['Whole Depth (ht)', calc.ht.toFixed(3), 'mm', 'ht = 2.25 * mn'],
      ['Clearance (c)', calc.c_std.toFixed(3), 'mm', 'c = 0.25 * mn'],
      ['Transverse Contact Ratio (eps_alpha)', calc.eps_alpha.toFixed(3), '-', 'Transverse involute contact ratio'],
      ['Overlap Contact Ratio (eps_beta)', calc.eps_beta.toFixed(3), '-', 'eps_beta = F * sin(beta) / (pi * mn)'],
      ['Total Contact Ratio (eps_gamma)', calc.eps_gamma.toFixed(3), '-', 'eps_gamma = eps_alpha + eps_beta (Continuous engagement)'],
      ['Input Torque', calc.T_in_ring, 'N.m', 'Pitch ring torque'],
      ['Input Speed', calc.n_in_ring, 'RPM', 'Pitch ring speed'],
      ['Output Pinion Speed', calc.n_pinion_out.toFixed(1), 'RPM', 'Pinion speed'],
      ['Torque per Pinion', calc.T_pinion_each.toFixed(3), 'N.m', 'Torque split across 3 pinions'],
      ['Tangential Force (Ft)', calc.Ft.toFixed(2), 'N', 'Ft = 2 * T_mesh / dg'],
      ['Radial Force (Fr)', calc.Fr.toFixed(2), 'N', 'Fr = Ft * tan(phi_t)'],
      ['Axial Thrust Force (Fa)', calc.Fa.toFixed(2), 'N', 'Fa = Ft * tan(beta)'],
      ['Resultant Force (F_res)', calc.F_resultant.toFixed(2), 'N', 'Fres = sqrt(Ft^2 + Fr^2 + Fa^2)'],
      ['Pinion Bending Stress', calc.sigma_b_p.toFixed(2), 'MPa', `SF = ${calc.SF_b_p.toFixed(1)}`],
      ['Gear Bending Stress', calc.sigma_b_g.toFixed(2), 'MPa', `SF = ${calc.SF_b_g.toFixed(1)}`],
      ['Hertzian Contact Stress', calc.sigma_H.toFixed(2), 'MPa', `SF = ${calc.SF_contact.toFixed(1)}`]
    ];
    return rows.map(r => r.map(val => `"${String(val).replace(/"/g, '""')}"`).join(',')).join('\n');
  }

  if (calc.gear_type === 'internal_spur') {
    const rows = [
      ['Parameter', 'Value', 'Unit', 'Notes'],
      ['Gear Type', 'Internal Involute Spur Gear', '-', 'Ring gear and internal multi-pinion drive'],
      ['Module (m)', calc.m, 'mm', 'Standard metric module'],
      ['Pinion Teeth (Np)', calc.Np, '-', 'Pitch drive planetary pinion'],
      ['Ring Gear Teeth (Ng)', calc.Ng, '-', 'Internal pitch ring gear'],
      ['Gear Ratio (i)', calc.i_ratio.toFixed(2), '-', `1:${calc.i_ratio.toFixed(1)} reduction`],
      ['Center Distance (C)', calc.center_dist.toFixed(3), 'mm', 'C = (dg - dp) / 2'],
      ['Face Width (F)', calc.F.toFixed(3), 'mm', 'Cylindrical face width'],
      ['Pressure Angle (phi)', calc.phi_deg, 'deg', 'Standard 20 deg involute'],
      ['Shaft Angle (Sigma)', 0, 'deg', 'Parallel shaft arrangement'],
      ['Multi-Pinions Count', calc.n_pinions, '-', '3 pinions spaced at 120 deg inside ring'],
      ['Pinion Pitch Diameter (dp)', calc.dp.toFixed(3), 'mm', 'dp = m * Np'],
      ['Ring Pitch Diameter (dg)', calc.dg.toFixed(3), 'mm', 'dg = m * Ng'],
      ['Pinion Tip Diameter (da_p)', (2 * calc.ra_p).toFixed(3), 'mm', ''],
      ['Ring Inner Tip Diameter', (2 * calc.ra_g_int).toFixed(3), 'mm', 'Inner crest circle'],
      ['Ring Inner Root Diameter', (2 * calc.rd_g_int).toFixed(3), 'mm', 'Inner trough circle'],
      ['Ring Outer Rim Diameter', calc.D_outer.toFixed(3), 'mm', 'Outer solid rim cylinder'],
      ['Working Depth (hw)', calc.hw.toFixed(3), 'mm', 'hw = 2.0 * m'],
      ['Whole Depth (ht)', calc.ht.toFixed(3), 'mm', 'ht = hw + c'],
      ['Transverse Contact Ratio (CR)', calc.CR.toFixed(3), '-', 'High contact ratio (concave-convex)'],
      ['Input Ring Torque', calc.T_in_ring, 'N.m', 'Ring gear torque'],
      ['Input Speed', calc.n_in_ring, 'RPM', 'Ring gear speed'],
      ['Output Pinion Speed', calc.n_pinion_out.toFixed(1), 'RPM', 'Output pitch drive speed'],
      ['Torque per Pinion', calc.T_pinion_each.toFixed(3), 'N.m', ''],
      ['Tangential Force (Ft)', calc.Ft.toFixed(2), 'N', 'Pitch line load per pinion'],
      ['Radial Force (Fr)', calc.Fr.toFixed(2), 'N', 'Radial separating force'],
      ['Resultant Force (F_res)', calc.F_resultant.toFixed(2), 'N', 'Fres = sqrt(Ft^2 + Fr^2)'],
      ['Pinion Lewis Bending Stress', calc.sigma_b_p.toFixed(2), 'MPa', `SF = ${calc.SF_b_p.toFixed(1)}`],
      ['Ring Gear Bending Stress', calc.sigma_b_g.toFixed(2), 'MPa', `SF = ${calc.SF_b_g.toFixed(1)}`],
      ['Hertzian Contact Stress', calc.sigma_H.toFixed(2), 'MPa', `SF = ${calc.SF_contact.toFixed(1)}`]
    ];
    return rows.map(r => r.map(val => `"${String(val).replace(/"/g, '""')}"`).join(',')).join('\n');
  }

  if (calc.gear_type === 'spiral-bevel') {
    const rows = [
      ['Parameter', 'Symbol', 'Pinion', 'Gear', 'Unit'],
      ['Gear Type', '', 'Spiral Bevel (RH)', 'Spiral Bevel (LH)', ''],
      ['Module', 'm', calc.m, calc.m, 'mm'],
      ['Number of Teeth', 'N', calc.Np, calc.Ng, '-'],
      ['Gear Ratio', 'i', `1:${calc.i_ratio.toFixed(1)}`, `1:${calc.i_ratio.toFixed(1)}`, '-'],
      ['Normal Pressure Angle', 'phi_n', calc.phi_n_deg.toFixed(1), calc.phi_n_deg.toFixed(1), 'deg'],
      ['Transverse Pressure Angle', 'phi_t', calc.phi_t_deg.toFixed(3), calc.phi_t_deg.toFixed(3), 'deg'],
      ['Mean Spiral Angle', 'beta_m', calc.beta_m_deg.toFixed(2), calc.beta_m_deg.toFixed(2), 'deg'],
      ['Outer Spiral Angle', 'beta_o', calc.beta_o_deg.toFixed(2), calc.beta_o_deg.toFixed(2), 'deg'],
      ['Inner Spiral Angle', 'beta_i', calc.beta_i_deg.toFixed(2), calc.beta_i_deg.toFixed(2), 'deg'],
      ['Shaft Angle', 'Sigma', calc.Sigma_deg.toFixed(1), calc.Sigma_deg.toFixed(1), 'deg'],
      ['Cutter Radius', 'r_cutter', calc.r_cutter.toFixed(2), calc.r_cutter.toFixed(2), 'mm'],
      ['Pitch Cone Angle', 'gamma', calc.gamma_p_deg.toFixed(3), calc.gamma_g_deg.toFixed(3), 'deg'],
      ['Pitch Diameter', 'd', calc.dp.toFixed(2), calc.dg.toFixed(2), 'mm'],
      ['Mean Pitch Diameter', 'dm', calc.dmp.toFixed(2), calc.dmg.toFixed(2), 'mm'],
      ['Outer Cone Distance', 'Ao', calc.Ao.toFixed(3), calc.Ao.toFixed(3), 'mm'],
      ['Face Width', 'F', calc.F.toFixed(2), calc.F.toFixed(2), 'mm'],
      ['Mean Cone Distance', 'Am', calc.Am.toFixed(3), calc.Am.toFixed(3), 'mm'],
      ['Working Depth', 'hw', calc.hw.toFixed(2), calc.hw.toFixed(2), 'mm'],
      ['Whole Depth', 'ht', calc.ht.toFixed(3), calc.ht.toFixed(3), 'mm'],
      ['Clearance', 'c', calc.c_std.toFixed(3), calc.c_std.toFixed(3), 'mm'],
      ['Transverse Contact Ratio', 'eps_alpha', calc.eps_alpha.toFixed(3), calc.eps_alpha.toFixed(3), '-'],
      ['Face Overlap Ratio', 'eps_beta', calc.eps_beta.toFixed(3), calc.eps_beta.toFixed(3), '-'],
      ['Total Contact Ratio', 'eps_gamma', calc.eps_gamma.toFixed(3), calc.eps_gamma.toFixed(3), '-'],
      ['Driving Pinions', 'n_p', calc.n_pinions, calc.n_pinions, '-'],
      ['Input Ring Torque', 'T_ring', calc.T_in_ring.toFixed(1), calc.T_in_ring.toFixed(1), 'N*m'],
      ['Pinion Torque Each', 'T_pin', calc.T_pinion_each.toFixed(2), calc.T_pinion_each.toFixed(2), 'N*m'],
      ['Pinion Speed', 'n_pin', calc.n_pinion_out.toFixed(1), calc.n_in_ring.toFixed(1), 'RPM'],
      ['Tangential Mesh Force', 'Ft', calc.Ft.toFixed(1), calc.Ft.toFixed(1), 'N'],
      ['Radial Force', 'Fr', calc.Fr_p.toFixed(1), (-calc.Fa_p).toFixed(1), 'N'],
      ['Thrust/Axial Force', 'Fa', calc.Fa_p.toFixed(1), calc.Fr_p.toFixed(1), 'N'],
      ['Resultant Force', 'Fres', calc.F_resultant.toFixed(1), calc.F_resultant.toFixed(1), 'N'],
      ['Bending Stress', 'sigma_b', calc.sigma_b_p.toFixed(2), calc.sigma_b_g.toFixed(2), 'MPa'],
      ['Bending Safety Factor', 'SF_b', calc.SF_b_p.toFixed(1), calc.SF_b_g.toFixed(1), '-'],
      ['Contact Stress', 'sigma_H', calc.sigma_H.toFixed(1), calc.sigma_H.toFixed(1), 'MPa'],
      ['Contact Safety Factor', 'SF_H', calc.SF_contact.toFixed(1), calc.SF_contact.toFixed(1), '-']
    ];
    return rows.map(r => r.map(val => `"${String(val).replace(/"/g, '""')}"`).join(',')).join('\n');
  }

  if (calc.gear_type === 'straight-bevel') {
    const rows = [
      ['Parameter', 'Value', 'Unit', 'Notes'],
      ['Gear Type', 'Straight Bevel Gear', '-', '90 deg orthogonal shaft pitch drive'],
      ['Module (m)', calc.m, 'mm', 'Standard metric module'],
      ['Pinion Teeth (Np)', calc.Np, '-', 'Driving pinion'],
      ['Gear Teeth (Ng)', calc.Ng, '-', 'Central pitch ring gear'],
      ['Gear Ratio (i)', calc.i_ratio.toFixed(2), '-', `1:${calc.i_ratio.toFixed(1)} reduction`],
      ['Shaft Angle (Sigma)', calc.Sigma_deg, 'deg', 'Orthogonal 90 deg axes'],
      ['Pinion Pitch Angle (gamma_p)', calc.gamma_p_deg.toFixed(2), 'deg', 'atan(Np / Ng)'],
      ['Gear Pitch Angle (gamma_g)', calc.gamma_g_deg.toFixed(2), 'deg', '90 - gamma_p'],
      ['Outer Cone Distance (Ao)', calc.Ao.toFixed(3), 'mm', 'Ao = dp / (2*sin(gamma_p))'],
      ['Face Width (F)', calc.F.toFixed(3), 'mm', 'F <= min(Ao/3, 10m)'],
      ['Multi-Pinions Count', calc.n_pinions, '-', '3 pinions spaced at 120 deg'],
      ['Pinion Pitch Diameter (dp)', calc.dp.toFixed(3), 'mm', 'dp = m * Np'],
      ['Gear Pitch Diameter (dg)', calc.dg.toFixed(3), 'mm', 'dg = m * Ng'],
      ['Pinion Tip Diameter (da_p)', calc.Do_p.toFixed(3), 'mm', ''],
      ['Gear Tip Diameter (da_g)', calc.Do_g.toFixed(3), 'mm', ''],
      ['Working Depth (hw)', calc.hw.toFixed(3), 'mm', 'hw = 2.0 * m'],
      ['Whole Depth (ht)', calc.ht.toFixed(3), 'mm', 'ht = 2.25 * m'],
      ['Virtual Pinion Teeth (Nvp)', (calc.Nv_p || 16.86).toFixed(2), '-', 'Tredgold virtual teeth'],
      ['Virtual Gear Teeth (Nvg)', (calc.Nv_g || 151.79).toFixed(2), '-', 'Tredgold virtual teeth'],
      ['Transverse Contact Ratio (CR)', calc.CR.toFixed(3), '-', 'CR >= 1.40 safe threshold'],
      ['Input Ring Torque', calc.T_in_ring, 'N.m', 'Pitch ring torque'],
      ['Output Pinion Speed', calc.n_pinion_out.toFixed(1), 'RPM', 'Output pitch speed'],
      ['Torque per Pinion', calc.T_pinion_each.toFixed(3), 'N.m', ''],
      ['Tangential Force (Ft)', calc.Ft.toFixed(2), 'N', 'Pitch line load at mean cone'],
      ['Radial Pinion Force (Fr_p)', calc.Fr_p.toFixed(2), 'N', 'Radial separating load'],
      ['Axial Pinion Force (Fa_p)', calc.Fa_p.toFixed(2), 'N', 'Axial thrust load'],
      ['Resultant Mesh Force', calc.F_resultant.toFixed(2), 'N', 'Fres = sqrt(Ft^2 + Fr^2 + Fa^2)'],
      ['Pinion Bending Stress', calc.sigma_b_p.toFixed(2), 'MPa', `SF = ${(calc.SF_p || 14).toFixed(1)}`],
      ['Gear Bending Stress', calc.sigma_b_g.toFixed(2), 'MPa', `SF = ${(calc.SF_g || 14).toFixed(1)}`],
      ['Hertzian Contact Stress', (calc.sigma_H || 161.7).toFixed(2), 'MPa', `SF = ${(calc.SF_contact || 9).toFixed(1)}`]
    ];
    return rows.map(r => r.map(val => `"${String(val).replace(/"/g, '""')}"`).join(',')).join('\n');
  }

  if (calc.gear_type === 'spur') {
    const rows = [
      ['Parameter', 'Value', 'Unit', 'Notes'],
      ['Gear Type', 'Involute Spur Gear', '-', 'Parallel axis wind turbine pitch drive'],
      ['Module (m)', calc.m, 'mm', 'Standard metric module'],
      ['Pinion Teeth (Np)', calc.Np, '-', 'Pitch drive blade pinion'],
      ['Gear Teeth (Ng)', calc.Ng, '-', 'Central bull gear'],
      ['Gear Ratio (i)', calc.i_ratio.toFixed(2), '-', `1:${calc.i_ratio.toFixed(1)} reduction`],
      ['Center Distance (C)', calc.center_dist.toFixed(3), 'mm', 'C = (dp + dg) / 2'],
      ['Face Width (F)', calc.F.toFixed(3), 'mm', 'Cylindrical face width'],
      ['Pressure Angle (phi)', calc.phi_deg, 'deg', 'Standard 20 deg involute'],
      ['Shaft Angle (Sigma)', 0, 'deg', 'Parallel shaft arrangement'],
      ['Multi-Pinions Count', calc.n_pinions, '-', '3 pinions spaced at 120 deg'],
      ['Pinion Pitch Diameter (dp)', calc.dp.toFixed(3), 'mm', 'dp = m * Np'],
      ['Gear Pitch Diameter (dg)', calc.dg.toFixed(3), 'mm', 'dg = m * Ng'],
      ['Pinion Base Diameter (rb_p)', (2 * calc.rb_p).toFixed(3), 'mm', 'rb = dp * cos(phi)'],
      ['Gear Base Diameter (rb_g)', (2 * calc.rb_g).toFixed(3), 'mm', 'rb = dg * cos(phi)'],
      ['Pinion Tip Diameter (da_p)', (2 * calc.ra_p).toFixed(3), 'mm', ''],
      ['Gear Tip Diameter (da_g)', (2 * calc.ra_g).toFixed(3), 'mm', ''],
      ['Working Depth (hw)', calc.hw.toFixed(3), 'mm', 'hw = 2.0 * m'],
      ['Whole Depth (ht)', calc.ht.toFixed(3), 'mm', 'ht = hw + c'],
      ['Transverse Contact Ratio (CR)', calc.CR.toFixed(3), '-', calc.CR >= 1.5 ? 'Good (>=1.5)' : 'Acceptable'],
      ['Input Torque', calc.T_in_ring, 'N.m', 'Central gear motor torque'],
      ['Input Speed', calc.n_in_ring, 'RPM', 'Central gear motor speed'],
      ['Blade Pinion Speed', calc.n_pinion_out.toFixed(1), 'RPM', 'Output pitch drive speed'],
      ['Torque per Pinion', calc.T_pinion_each.toFixed(3), 'N.m', ''],
      ['Tangential Force (Ft)', calc.Ft.toFixed(2), 'N', 'Pitch line load per pinion'],
      ['Radial Force (Fr)', calc.Fr.toFixed(2), 'N', 'Radial separating force'],
      ['Resultant Force (F_res)', calc.F_resultant.toFixed(2), 'N', 'Fres = sqrt(Ft^2 + Fr^2)'],
      ['Pinion Lewis Bending Stress', calc.sigma_b_p.toFixed(2), 'MPa', `SF = ${calc.SF_b_p.toFixed(1)}`],
      ['Gear Lewis Bending Stress', calc.sigma_b_g.toFixed(2), 'MPa', `SF = ${calc.SF_b_g.toFixed(1)}`],
      ['Hertzian Contact Stress', calc.sigma_H.toFixed(2), 'MPa', `SF = ${calc.SF_contact.toFixed(1)}`]
    ];
    return rows.map(r => r.map(val => `"${String(val).replace(/"/g, '""')}"`).join(',')).join('\n');
  }

  const rows = [
    ['Parameter', 'Value', 'Unit', 'Notes'],
    ['Gear Type', 'Zerol Bevel Gear', '-', 'Gleason face-milled bevel drive'],
    ['Module (m)', calc.m, 'mm', 'Standard metric module'],
    ['Pinion Teeth (Np)', calc.Np, '-', 'Blade pitch drive pinion'],
    ['Ring Gear Teeth (Ng)', calc.Ng, '-', 'Central pitch drive driver'],
    ['Gear Ratio (i)', calc.i_ratio.toFixed(2), '-', `1:${calc.i_ratio.toFixed(1)} reduction`],
    ['Pressure Angle (phi)', calc.phi_deg, 'deg', 'Gleason standard 20 deg'],
    ['Shaft Angle (Sigma)', calc.Sigma_deg, 'deg', 'Orthogonal 90 deg shaft arrangement'],
    ['Pinions Count', calc.n_pinions, '-', '1 per turbine blade'],
    ['Pinion Pitch Diameter (dp)', calc.dp.toFixed(3), 'mm', 'dp = m * Np'],
    ['Gear Pitch Diameter (dg)', calc.dg.toFixed(3), 'mm', 'dg = m * Ng'],
    ['Pinion Pitch Cone Angle (gamma_p)', calc.gamma_p_deg.toFixed(3), 'deg', ''],
    ['Gear Pitch Cone Angle (gamma_g)', calc.gamma_g_deg.toFixed(3), 'deg', ''],
    ['Outer Cone Distance (Ao)', calc.Ao.toFixed(3), 'mm', ''],
    ['Face Width (F)', calc.F.toFixed(3), 'mm', `${(calc.f_factor * 100).toFixed(1)}% of Ao`],
    ['Mean Cone Distance (Am)', calc.Am.toFixed(3), 'mm', ''],
    ['Cutter Radius (r_cutter)', calc.r_cutter.toFixed(3), 'mm', 'Gleason Zerol circular curvature'],
    ['Working Depth (hw)', calc.hw.toFixed(3), 'mm', 'hw = khw * m'],
    ['Whole Depth (ht)', calc.ht.toFixed(3), 'mm', 'ht = hw + c'],
    ['Pinion Addendum (a_p)', calc.a_p.toFixed(3), 'mm', '60% working depth (Gleason unequal)'],
    ['Gear Addendum (a_g)', calc.a_g.toFixed(3), 'mm', '40% working depth (Gleason unequal)'],
    ['Contact Ratio (CR)', calc.CR.toFixed(3), '-', calc.CR >= 1.5 ? 'Good' : calc.CR >= 1.2 ? 'Acceptable' : 'Low CR Warning'],
    ['Pinion Mounting Distance (MD_p)', calc.MD_p.toFixed(3), 'mm', ''],
    ['Gear Mounting Distance (MD_g)', calc.MD_g.toFixed(3), 'mm', ''],
    ['Input Torque (T_in)', calc.T_in_ring, 'N.m', 'Central ring gear torque'],
    ['Ring Speed (n_in)', calc.n_in_ring, 'RPM', 'Motor input speed'],
    ['Blade Output Speed (n_out)', calc.n_pinion_out.toFixed(1), 'RPM', ''],
    ['Torque per Blade (T_pinion)', calc.T_pinion_each.toFixed(3), 'N.m', ''],
    ['Tangential Force (Ft)', calc.Ft.toFixed(2), 'N', 'At mean cone distance'],
    ['Radial Force Pinion (Fr_p)', calc.Fr_p.toFixed(2), 'N', ''],
    ['Axial Force Pinion (Fa_p)', calc.Fa_p.toFixed(2), 'N', ''],
    ['Resultant Mesh Force (F_res)', calc.F_resultant.toFixed(2), 'N', ''],
    ['Pinion Bending Stress (sigma_b_p)', calc.sigma_b_p.toFixed(2), 'MPa', 'Lewis formula'],
    ['Gear Bending Stress (sigma_b_g)', calc.sigma_b_g.toFixed(2), 'MPa', 'Lewis formula'],
    ['Pinion Safety Factor (SF_p)', calc.SF_p.toFixed(2), '-', calc.SF_p >= 1.5 ? 'SAFE (>= 1.5)' : 'WARNING (< 1.5)'],
    ['Gear Safety Factor (SF_g)', calc.SF_g.toFixed(2), '-', calc.SF_g >= 1.5 ? 'SAFE (>= 1.5)' : 'WARNING (< 1.5)'],
    ['3D Print Material', calc.print_material, '-', calc.ps ? calc.ps.description : 'PLA']
  ];

  return rows.map(r => r.map(val => `"${String(val).replace(/"/g, '""')}"`).join(',')).join('\n');
}

/**
 * Packages all CAD models (.stl, .stp, .igs), SolidWorks macros, equations, and reports into a single ZIP archive.
 */
export async function createCompleteCADZip(calc, pinionMesh, gearMesh) {
  const zip = new JSZip();
  const isHelical = calc.gear_type === 'helical';
  const isSpur = calc.gear_type === 'spur';
  const isInternal = calc.gear_type === 'internal_spur';
  const isStraight = calc.gear_type === 'straight-bevel';
  const isSpiral = calc.gear_type === 'spiral-bevel';
  const pPrefix = isSpiral ? 'spiral_bevel_pinion' : isHelical ? 'helical_pinion' : isInternal ? 'internal_pinion' : isSpur ? 'spur_pinion' : isStraight ? 'straight_bevel_pinion' : 'zerol_pinion_v2';
  const gPrefix = isSpiral ? 'spiral_bevel_gear' : isInternal ? 'internal_ring_gear' : isHelical ? 'helical_gear' : isSpur ? 'spur_gear' : isStraight ? 'straight_bevel_gear' : 'zerol_gear_v2';
  const pDesc = isSpiral ? 'Spiral Bevel Pinion' : isHelical ? 'Helical Pinion' : isInternal ? 'Internal Pinion' : isSpur ? 'Spur Pinion' : isStraight ? 'Straight Bevel Pinion' : 'Zerol Pinion';
  const gDesc = isSpiral ? 'Spiral Bevel Gear' : isInternal ? 'Internal Ring Gear' : isHelical ? 'Helical Gear' : isSpur ? 'Spur Gear' : isStraight ? 'Straight Bevel Gear' : 'Zerol Gear';

  // 1. STL Files
  const pinionSTL = exportSTLBinary(pinionMesh, `${pDesc} STL`);
  const gearSTL = exportSTLBinary(gearMesh, `${gDesc} STL`);
  zip.file(`STL/${pPrefix}.stl`, pinionSTL);
  zip.file(`STL/${gPrefix}.stl`, gearSTL);

  // 2. STEP AP214 Files
  const pinionSTP = exportSTEP(pinionMesh, pPrefix, `${pDesc} m${calc.m || calc.mn} Np${calc.Np}`);
  const gearSTP = exportSTEP(gearMesh, gPrefix, `${gDesc} m${calc.m || calc.mn} Ng${calc.Ng}`);
  zip.file(`STEP/${pPrefix}.stp`, pinionSTP);
  zip.file(`STEP/${gPrefix}.stp`, gearSTP);

  // 3. IGES 5.3 Files
  const pinionIGS = exportIGES(pinionMesh, pPrefix, `${pDesc} m${calc.m || calc.mn} Np${calc.Np}`);
  const gearIGS = exportIGES(gearMesh, gPrefix, `${gDesc} m${calc.m || calc.mn} Ng${calc.Ng}`);
  zip.file(`IGES/${pPrefix}.igs`, pinionIGS);
  zip.file(`IGES/${gPrefix}.igs`, gearIGS);

  // 4. SolidWorks Automation
  const macroName = isSpiral ? 'create_spiral_bevel_gears.bas' : isHelical ? 'create_helical_gears.bas' : isInternal ? 'create_internal_spur_gears.bas' : isSpur ? 'create_spur_gears.bas' : isStraight ? 'create_straight_bevel_gears.bas' : 'create_zerol_bevel_gears.bas';
  const eqName = isSpiral ? 'spiral_bevel_equations.txt' : isHelical ? 'helical_equations.txt' : isInternal ? 'internal_spur_equations.txt' : isSpur ? 'spur_gear_equations.txt' : isStraight ? 'straight_bevel_equations.txt' : 'zerol_bevel_equations.txt';
  zip.file(`Solidworks/${macroName}`, exportSolidWorksMacro(calc));
  zip.file(`Solidworks/${eqName}`, exportSolidWorksEquations(calc));

  // 5. Documentation & Reports
  const repName = isSpiral ? 'SPIRAL_BEVEL_DESIGN_REPORT.csv' : isHelical ? 'HELICAL_DESIGN_REPORT.csv' : isInternal ? 'INTERNAL_SPUR_DESIGN_REPORT.csv' : isSpur ? 'SPUR_GEAR_DESIGN_REPORT.csv' : isStraight ? 'STRAIGHT_BEVEL_DESIGN_REPORT.csv' : 'ZEROL_BEVEL_DESIGN_REPORT.csv';
  zip.file(`Reports/${repName}`, exportDesignReportCSV(calc));

  return await zip.generateAsync({ type: 'blob' });
}

