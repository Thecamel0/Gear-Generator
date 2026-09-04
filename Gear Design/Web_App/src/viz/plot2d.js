/**
 * 2D TOOTH MESH & CONTACT ANALYSIS (Canvas Renderer)
 * Pixel-perfect recreation of MATLAB's plot_gear_mesh_2d.m:
 *   - Enforces MATLAB's `axis equal` (1:1 data aspect ratio, circular gears without distortion)
 *   - Subplot 1: Full 2D Pitch Engagement Overview (Engineering Axes, Ticks, Grid, Centerline)
 *   - Subplot 2: Close-up High-Magnification Zoom on Active Tooth Mesh Zone (Arcs, Line of Action, Contact Info)
 *
 * Author: Ahmed Majdy Ahmed (Engine Port)
 */

import { generateInternalSpurProfile2D } from '../engine/gearGeometry.js';

export class GearPlot2D {
  constructor(canvasElement) {
    this.canvas = canvasElement;
    this.ctx = canvasElement.getContext('2d');
    this.calc = null;
    this.width = 0;
    this.height = 0;

    window.addEventListener('resize', () => {
      if (this.calc && this.canvas.offsetParent !== null) {
        this.resize();
        this.render();
      }
    });
  }

  resize() {
    if (!this.canvas) return;
    const parent = this.canvas.parentElement;
    if (!parent) return;

    const rect = parent.getBoundingClientRect();
    const dpr = window.devicePixelRatio || 1;
    this.width = Math.max(rect.width, 400);
    this.height = Math.max(rect.height, 300);

    this.canvas.width = Math.round(this.width * dpr);
    this.canvas.height = Math.round(this.height * dpr);
    this.canvas.style.width = `${this.width}px`;
    this.canvas.style.height = `${this.height}px`;

    this.ctx.setTransform(1, 0, 0, 1, 0, 0);
    this.ctx.scale(dpr, dpr);
  }

  updatePlot(calc) {
    this.calc = calc;
    this.resize();
    this.render();
  }

  /**
   * Generates high-resolution closed 2D polygon of all N teeth
   * Exactly replicates MATLAB generate_2d_gear_polygon.m
   */
  generate2DGearPolygon(N, m, phi, a, b, tooth_thick, n_pts = 250) {
    const r_p = (m * N) / 2;
    const r_b = r_p * Math.cos(phi);
    const r_a = r_p + a;
    const r_d = Math.max(r_p - b, 0.3 * r_b);

    const tau = tooth_thick / (2 * r_p);
    const inv_phi = Math.tan(phi) - phi;

    const root_below_base = r_d < r_b;
    const r_inv_start = Math.max(r_b, r_d);

    const alpha_tip = Math.acos(Math.min(r_b / r_a, 1));
    const theta_tip = tau + inv_phi - (Math.tan(alpha_tip) - alpha_tip);

    let theta_root;
    if (root_below_base) {
      theta_root = tau + inv_phi;
    } else {
      const alpha_root = Math.acos(Math.min(r_b / r_d, 1));
      theta_root = tau + inv_phi - (Math.tan(alpha_root) - alpha_root);
    }
    const theta_next_root = (2 * Math.PI) / N - theta_root;

    const xc_tooth = [];
    const yc_tooth = [];

    // Left flank below base circle
    if (root_below_base) {
      const nr = Math.max(5, Math.round(n_pts * 0.1));
      for (let i = 0; i < nr; i++) {
        const rr = r_d + (i / (nr - 1 || 1)) * (r_b - r_d);
        const tt = -(tau + inv_phi);
        xc_tooth.push(rr * Math.cos(tt));
        yc_tooth.push(rr * Math.sin(tt));
      }
    }

    // Left involute flank
    for (let i = 0; i < n_pts; i++) {
      const rr = r_inv_start + (i / (n_pts - 1 || 1)) * (r_a - r_inv_start);
      const alpha = Math.acos(Math.min(r_b / rr, 1));
      const inv_alpha = Math.tan(alpha) - alpha;
      const tt = -(tau + inv_phi - inv_alpha);
      xc_tooth.push(rr * Math.cos(tt));
      yc_tooth.push(rr * Math.sin(tt));
    }

    // Tip arc
    const n_tip = Math.max(10, Math.round(n_pts * 0.1));
    for (let i = 0; i < n_tip; i++) {
      const tt = -theta_tip + (i / (n_tip - 1 || 1)) * (2 * theta_tip);
      xc_tooth.push(r_a * Math.cos(tt));
      yc_tooth.push(r_a * Math.sin(tt));
    }

    // Right involute flank
    for (let i = 0; i < n_pts; i++) {
      const rr = r_a - (i / (n_pts - 1 || 1)) * (r_a - r_inv_start);
      const alpha = Math.acos(Math.min(r_b / rr, 1));
      const inv_alpha = Math.tan(alpha) - alpha;
      const tt = tau + inv_phi - inv_alpha;
      xc_tooth.push(rr * Math.cos(tt));
      yc_tooth.push(rr * Math.sin(tt));
    }

    // Right flank below base circle
    if (root_below_base) {
      const nr = Math.max(5, Math.round(n_pts * 0.1));
      for (let i = 0; i < nr; i++) {
        const rr = r_b - (i / (nr - 1 || 1)) * (r_b - r_d);
        const tt = tau + inv_phi;
        xc_tooth.push(rr * Math.cos(tt));
        yc_tooth.push(rr * Math.sin(tt));
      }
    }

    // Root land arc
    const n_root_pts = Math.max(10, Math.round(n_pts * 0.1));
    for (let i = 0; i < n_root_pts; i++) {
      const tt = theta_root + (i / (n_root_pts - 1 || 1)) * (theta_next_root - theta_root);
      xc_tooth.push(r_d * Math.cos(tt));
      yc_tooth.push(r_d * Math.sin(tt));
    }

    // Replicate for all N teeth around 360 degrees
    const M = xc_tooth.length;
    const xc = [];
    const yc = [];

    for (let t = 0; t < N; t++) {
      const angle = (t * 2 * Math.PI) / N;
      const c = Math.cos(angle);
      const s = Math.sin(angle);
      for (let j = 0; j < M; j++) {
        xc.push(xc_tooth[j] * c - yc_tooth[j] * s);
        yc.push(xc_tooth[j] * s + yc_tooth[j] * c);
      }
    }

    return { xc, yc };
  }

  /**
   * Helper to draw MATLAB-style axes box, ticks, numeric labels, and engineering grid
   */
  drawAxesFrame(x, y, w, h, xMin, xMax, yMin, yMax, xTicks, yTicks, title, xLabel, yLabel) {
    const ctx = this.ctx;

    // Subplot background
    ctx.fillStyle = '#1c1c26'; // MATLAB [0.11 0.11 0.15]
    ctx.fillRect(x, y, w, h);

    // Engineering grid lines
    ctx.strokeStyle = '#2e2e3b'; // MATLAB GridColor [0.22 0.22 0.28]
    ctx.lineWidth = 0.8;

    // Vertical grid lines
    for (const xt of xTicks) {
      if (xt >= xMin && xt <= xMax) {
        const px = x + ((xt - xMin) / (xMax - xMin)) * w;
        ctx.beginPath();
        ctx.moveTo(px, y);
        ctx.lineTo(px, y + h);
        ctx.stroke();
      }
    }

    // Horizontal grid lines
    for (const yt of yTicks) {
      if (yt >= yMin && yt <= yMax) {
        const py = y + h - ((yt - yMin) / (yMax - yMin)) * h;
        ctx.beginPath();
        ctx.moveTo(x, py);
        ctx.lineTo(x + w, py);
        ctx.stroke();
      }
    }

    // Outer bounding border
    ctx.strokeStyle = '#8a8a99'; // MATLAB [0.6 0.6 0.6]
    ctx.lineWidth = 1.0;
    ctx.strokeRect(x, y, w, h);

    // Ticks & tick labels
    ctx.fillStyle = '#9e9ea8';
    ctx.font = '11px "SF Mono", Monaco, Consolas, monospace';

    // Bottom X ticks
    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    for (const xt of xTicks) {
      if (xt >= xMin && xt <= xMax) {
        const px = x + ((xt - xMin) / (xMax - xMin)) * w;
        ctx.beginPath();
        ctx.moveTo(px, y + h);
        ctx.lineTo(px, y + h + 4);
        ctx.stroke();
        ctx.fillText(xt.toString(), px, y + h + 6);
      }
    }

    // Left Y ticks
    ctx.textAlign = 'right';
    ctx.textBaseline = 'middle';
    for (const yt of yTicks) {
      if (yt >= yMin && yt <= yMax) {
        const py = y + h - ((yt - yMin) / (yMax - yMin)) * h;
        ctx.beginPath();
        ctx.moveTo(x, py);
        ctx.lineTo(x - 4, py);
        ctx.stroke();
        ctx.fillText(yt.toString(), x - 6, py);
      }
    }

    // Title
    ctx.fillStyle = '#ffffff';
    ctx.font = 'bold 13px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'bottom';
    ctx.fillText(title, x + w / 2, y - 10);

    // X Axis Label
    ctx.fillStyle = '#b0b0be';
    ctx.font = '12px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    ctx.fillText(xLabel, x + w / 2, y + h + 22);

    // Y Axis Label (Rotated 90 degrees)
    ctx.save();
    ctx.translate(x - 30, y + h / 2);
    ctx.rotate(-Math.PI / 2);
    ctx.textAlign = 'center';
    ctx.textBaseline = 'bottom';
    ctx.fillText(yLabel, 0, 0);
    ctx.restore();
  }

  render() {
    if (!this.calc || this.width <= 0 || this.height <= 0) return;
    if (this.calc.gear_type === 'internal_spur') {
      this.renderInternalSpur();
      return;
    }
    if (this.calc.gear_type === 'straight-bevel' || this.calc.gear_type === 'zerol-bevel' || this.calc.gear_type === 'spiral-bevel') {
      this.renderBevelConesAndContact();
      return;
    }
    if (this.calc.gear_type === 'helical') {
      this.renderHelicalTransverseDiagram();
      return;
    }
    const calc = this.calc;
    const ctx = this.ctx;
    const w = this.width;
    const h = this.height;

    // Overall Figure Background: MATLAB [0.07 0.07 0.10]
    ctx.fillStyle = '#12121a';
    ctx.fillRect(0, 0, w, h);

    // Layout configuration
    const marginLeft = 52;
    const marginRight = 35;
    const marginTop = 38;
    const marginBottom = 45;
    const gap = 55;

    const availW = w - marginLeft - marginRight - gap;
    const cellW = Math.floor(availW / 2);
    const cellH = h - marginTop - marginBottom;

    if (cellW <= 50 || cellH <= 50) return;

    // Kinematics & Geometry Parameters matching MATLAB
    const rp_p = (calc.m * calc.Np) / 2; // Pinion pitch radius = 24 mm
    const rp_g = (calc.m * calc.Ng) / 2; // Gear pitch radius   = 72 mm
    const center_dist = rp_p + rp_g;    // 96 mm

    const rb_p = rp_p * Math.cos(calc.phi);
    const ra_p = rp_p + calc.a_p;
    const rd_p = rp_p - calc.b_p;

    const rb_g = rp_g * Math.cos(calc.phi);
    const ra_g = rp_g + calc.a_g;
    const rd_g = rp_g - calc.b_g;

    // Generate accurate 2D tooth polygons
    const polyP = this.generate2DGearPolygon(calc.Np, calc.m, calc.phi, calc.a_p, calc.b_p, calc.s_p, 250);
    const polyG = this.generate2DGearPolygon(calc.Ng, calc.m, calc.phi, calc.a_g, calc.b_g, calc.s_g, 250);

    // Rotate gear to mesh with pinion at pitch point (rp_p, 0)
    const half_pitch_g = Math.PI / calc.Ng;
    const rot_angle = Math.PI + half_pitch_g;
    const cos_r = Math.cos(rot_angle);
    const sin_r = Math.sin(rot_angle);

    const gx_r = [];
    const gy_r = [];
    for (let i = 0; i < polyG.xc.length; i++) {
      gx_r.push(polyG.xc[i] * cos_r - polyG.yc[i] * sin_r + center_dist);
      gy_r.push(polyG.xc[i] * sin_r + polyG.yc[i] * cos_r);
    }

    // Line of Action (passes through pitch point rp_p, 0)
    const loa_len = 25;
    const loa_dir = [Math.sin(calc.phi), Math.cos(calc.phi)];
    const loa_p1 = [rp_p - loa_len * loa_dir[0], 0 - loa_len * loa_dir[1]];
    const loa_p2 = [rp_p + loa_len * loa_dir[0], 0 + loa_len * loa_dir[1]];

    // =========================================================================
    // SUBPLOT 1: Full 2D Gear Engagement Overview (Left Pane)
    // Enforce MATLAB's axis equal (1:1 data aspect ratio)
    // =========================================================================
    // Coordinate bounds matching MATLAB:
    // xlim([-ra_p - 5, center_dist + ra_g + 10]) => [-30, 180] (span = 210)
    // ylim([-48, 48]) (span = 96)
    const xMin1 = -30;
    const xMax1 = 180;
    const yMin1 = -48;
    const yMax1 = 48;
    const xSpan1 = xMax1 - xMin1;
    const ySpan1 = yMax1 - yMin1;

    // Strict 1:1 aspect ratio scaling
    const scale1 = Math.min((cellW - 10) / xSpan1, (cellH - 10) / ySpan1);
    const s1_w = Math.round(xSpan1 * scale1);
    const s1_h = Math.round(ySpan1 * scale1);
    const s1_x = Math.round(marginLeft + (cellW - s1_w) / 2);
    const s1_y = Math.round(marginTop + (cellH - s1_h) / 2);

    const xTicks1 = [-20, 0, 20, 40, 60, 80, 100, 120, 140, 160, 180];
    const yTicks1 = [-40, -30, -20, -10, 0, 10, 20, 30, 40];

    const toScr1 = (wx, wy) => [
      s1_x + (wx - xMin1) * scale1,
      s1_y + s1_h - (wy - yMin1) * scale1
    ];

    const title1 = `2D Overview: ${calc.Np}T / ${calc.Ng}T (Ratio 1:${(calc.Ng / calc.Np).toFixed(0)}, Module = ${calc.m} mm)`;
    this.drawAxesFrame(s1_x, s1_y, s1_w, s1_h, xMin1, xMax1, yMin1, yMax1, xTicks1, yTicks1, title1, 'X [mm]', 'Y [mm]');

    // Clip content to inside Subplot 1
    ctx.save();
    ctx.beginPath();
    ctx.rect(s1_x, s1_y, s1_w, s1_h);
    ctx.clip();

    // 1. Draw Pinion Polygon (Blue: [0.32 0.52 0.78])
    ctx.beginPath();
    for (let i = 0; i < polyP.xc.length; i++) {
      const [px, py] = toScr1(polyP.xc[i], polyP.yc[i]);
      if (i === 0) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    }
    ctx.closePath();
    ctx.fillStyle = 'rgba(82, 133, 199, 0.88)';
    ctx.fill();
    ctx.strokeStyle = '#33598c';
    ctx.lineWidth = 0.8;
    ctx.stroke();

    // 2. Draw Gear Polygon (Bronze: [0.78 0.52 0.28])
    ctx.beginPath();
    for (let i = 0; i < gx_r.length; i++) {
      const [gx, gy] = toScr1(gx_r[i], gy_r[i]);
      if (i === 0) ctx.moveTo(gx, gy);
      else ctx.lineTo(gx, gy);
    }
    ctx.closePath();
    ctx.fillStyle = 'rgba(199, 133, 71, 0.88)';
    ctx.fill();
    ctx.strokeStyle = '#8c592e';
    ctx.lineWidth = 0.8;
    ctx.stroke();

    // 3. Perfect mathematical circles (enabled by axis equal)
    const drawCircle1 = (cx, cy, r, style, dash = [], width = 1.0) => {
      const [sx, sy] = toScr1(cx, cy);
      const sr = r * scale1;
      ctx.save();
      ctx.strokeStyle = style;
      ctx.lineWidth = width;
      ctx.setLineDash(dash);
      ctx.beginPath();
      ctx.arc(sx, sy, sr, 0, 2 * Math.PI);
      ctx.stroke();
      ctx.restore();
    };

    // Pinion circles
    drawCircle1(0, 0, rp_p, '#80bfff', [5, 4], 1.2); // Pitch (dashed)
    drawCircle1(0, 0, rb_p, '#6699e6', [2, 2], 0.8); // Base (dotted)
    drawCircle1(0, 0, ra_p, 'rgba(77, 128, 204, 0.4)', [], 0.5); // Addendum

    // Gear circles
    drawCircle1(center_dist, 0, rp_g, '#ffbf66', [5, 4], 1.2); // Pitch (dashed)
    drawCircle1(center_dist, 0, rb_g, '#e6994d', [2, 2], 0.8); // Base (dotted)
    drawCircle1(center_dist, 0, ra_g, 'rgba(204, 128, 51, 0.4)', [], 0.5); // Addendum

    // 4. Centers & Center Line
    const [c0x, c0y] = toScr1(0, 0);
    const [cgx, cgy] = toScr1(center_dist, 0);

    ctx.save();
    ctx.strokeStyle = '#80808c';
    ctx.lineWidth = 0.8;
    ctx.setLineDash([6, 3, 2, 3]);
    ctx.beginPath();
    ctx.moveTo(c0x, c0y);
    ctx.lineTo(cgx, cgy);
    ctx.stroke();
    ctx.restore();

    // Center Crosses
    const drawCross = (sx, sy, color) => {
      ctx.strokeStyle = color;
      ctx.lineWidth = 2.0;
      ctx.beginPath();
      ctx.moveTo(sx - 6, sy); ctx.lineTo(sx + 6, sy);
      ctx.moveTo(sx, sy - 6); ctx.lineTo(sx, sy + 6);
      ctx.stroke();
    };
    drawCross(c0x, c0y, '#80bfff');
    drawCross(cgx, cgy, '#ffbf66');

    // 5. Line of Action & Pitch Point
    const [lx1, ly1] = toScr1(loa_p1[0], loa_p1[1]);
    const [lx2, ly2] = toScr1(loa_p2[0], loa_p2[1]);
    ctx.strokeStyle = '#ff4d4d';
    ctx.lineWidth = 1.8;
    ctx.beginPath();
    ctx.moveTo(lx1, ly1);
    ctx.lineTo(lx2, ly2);
    ctx.stroke();

    const [ppx, ppy] = toScr1(rp_p, 0);
    ctx.fillStyle = '#ff3333';
    ctx.beginPath();
    ctx.arc(ppx, ppy, 5, 0, 2 * Math.PI);
    ctx.fill();

    // 6. Text Labels matching MATLAB
    ctx.fillStyle = '#80bfff';
    ctx.font = 'bold 10px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'center';
    const [pLblX, pLblY] = toScr1(-2, -8);
    ctx.fillText(`Pinion (${calc.Np}T)`, pLblX, pLblY);
    ctx.fillText(`PD = ${(2 * rp_p).toFixed(0)} mm`, pLblX, pLblY + 13);

    ctx.fillStyle = '#ffbf66';
    const [gLblX, gLblY] = toScr1(center_dist, -8);
    ctx.fillText(`Ring Gear (${calc.Ng}T)`, gLblX, gLblY);
    ctx.fillText(`PD = ${(2 * rp_g).toFixed(0)} mm`, gLblX, gLblY + 13);

    ctx.fillStyle = '#ff6666';
    ctx.font = 'bold 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    const [ptLblX, ptLblY] = toScr1(rp_p + 3, -4);
    ctx.fillText('Pitch Point (P)', ptLblX, ptLblY);

    // 7. Center distance dimension line at dim_y = -35
    const dimY = -35;
    const [d1x, d1y] = toScr1(0, dimY);
    const [d2x, d2y] = toScr1(center_dist, dimY);
    ctx.strokeStyle = '#b3b3b3';
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.moveTo(d1x, d1y); ctx.lineTo(d2x, d2y);
    ctx.moveTo(d1x, d1y - 3); ctx.lineTo(d1x, d1y + 3);
    ctx.moveTo(d2x, d2y - 3); ctx.lineTo(d2x, d2y + 3);
    ctx.stroke();

    ctx.fillStyle = '#cccccc';
    ctx.font = '9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(`Center Distance C = ${center_dist.toFixed(1)} mm`, (d1x + d2x) / 2, d1y + 11);

    ctx.restore(); // Restore clip Subplot 1

    // =========================================================================
    // SUBPLOT 2: Detailed Meshing Zone (Right Pane)
    // Enforce MATLAB's axis equal (1:1 data aspect ratio)
    // =========================================================================
    // High magnification window matching MATLAB:
    // xlim([rp_p - 10, rp_p + 12]) => [14, 36] (span = 22)
    // ylim([-12, 14]) (span = 26)
    const xMin2 = rp_p - 10;
    const xMax2 = rp_p + 12;
    const yMin2 = -12;
    const yMax2 = 14;
    const xSpan2 = xMax2 - xMin2;
    const ySpan2 = yMax2 - yMin2;

    // Strict 1:1 aspect ratio scaling
    const scale2 = Math.min((cellW - 10) / xSpan2, (cellH - 10) / ySpan2);
    const s2_w = Math.round(xSpan2 * scale2);
    const s2_h = Math.round(ySpan2 * scale2);
    const s2_x = Math.round(marginLeft + cellW + gap + (cellW - s2_w) / 2);
    const s2_y = Math.round(marginTop + (cellH - s2_h) / 2);

    const xTicks2 = [14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36];
    const yTicks2 = [-10, -5, 0, 5, 10];

    const toScr2 = (wx, wy) => [
      s2_x + (wx - xMin2) * scale2,
      s2_y + s2_h - (wy - yMin2) * scale2
    ];

    const title2 = 'Detailed Meshing Zone (Tooth Contact & Line of Action)';
    this.drawAxesFrame(s2_x, s2_y, s2_w, s2_h, xMin2, xMax2, yMin2, yMax2, xTicks2, yTicks2, title2, 'X [mm]', 'Y [mm]');

    // Clip content to inside Subplot 2
    ctx.save();
    ctx.beginPath();
    ctx.rect(s2_x, s2_y, s2_w, s2_h);
    ctx.clip();

    // 1. Draw High-Zoom Pinion Polygon
    ctx.beginPath();
    for (let i = 0; i < polyP.xc.length; i++) {
      const [px, py] = toScr2(polyP.xc[i], polyP.yc[i]);
      if (i === 0) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    }
    ctx.closePath();
    ctx.fillStyle = 'rgba(82, 133, 199, 0.90)';
    ctx.fill();
    ctx.strokeStyle = '#33598c';
    ctx.lineWidth = 1.2;
    ctx.stroke();

    // 2. Draw High-Zoom Gear Polygon
    ctx.beginPath();
    for (let i = 0; i < gx_r.length; i++) {
      const [gx, gy] = toScr2(gx_r[i], gy_r[i]);
      if (i === 0) ctx.moveTo(gx, gy);
      else ctx.lineTo(gx, gy);
    }
    ctx.closePath();
    ctx.fillStyle = 'rgba(199, 133, 71, 0.90)';
    ctx.fill();
    ctx.strokeStyle = '#8c592e';
    ctx.lineWidth = 1.2;
    ctx.stroke();

    // 3. Perfect arc overlays in Zoomed Zone
    const drawArc2 = (cx, cy, r, thetaStart, thetaEnd, style, dash = [], width = 1.0) => {
      const [sx, sy] = toScr2(cx, cy);
      const sr = r * scale2;
      ctx.save();
      ctx.strokeStyle = style;
      ctx.lineWidth = width;
      ctx.setLineDash(dash);
      ctx.beginPath();
      // In canvas, screen Y is inverted so angle -th is clockwise
      ctx.arc(sx, sy, sr, -thetaEnd, -thetaStart);
      ctx.stroke();
      ctx.restore();
    };

    // Pinion arcs (theta_z in [-0.6, 0.6])
    drawArc2(0, 0, rp_p, -0.6, 0.6, '#80bfff', [5, 4], 1.5); // Pitch (dashed)
    drawArc2(0, 0, ra_p, -0.6, 0.6, '#4d99e6', [2, 2], 1.0); // Addendum (dotted)
    drawArc2(0, 0, rd_p, -0.6, 0.6, '#4d99e6', [2, 2], 1.0); // Dedendum (dotted)

    // Gear arcs (theta_zg in [pi-0.3, pi+0.3])
    drawArc2(center_dist, 0, rp_g, Math.PI - 0.3, Math.PI + 0.3, '#ffbf66', [5, 4], 1.5); // Pitch (dashed)
    drawArc2(center_dist, 0, ra_g, Math.PI - 0.3, Math.PI + 0.3, '#e6994d', [2, 2], 1.0); // Addendum (dotted)
    drawArc2(center_dist, 0, rd_g, Math.PI - 0.3, Math.PI + 0.3, '#e6994d', [2, 2], 1.0); // Dedendum (dotted)

    // 4. Line of Action across zoom window
    const [zlx1, zly1] = toScr2(loa_p1[0], loa_p1[1]);
    const [zlx2, zly2] = toScr2(loa_p2[0], loa_p2[1]);
    ctx.strokeStyle = '#ff3f3f';
    ctx.lineWidth = 2.0;
    ctx.beginPath();
    ctx.moveTo(zlx1, zly1);
    ctx.lineTo(zlx2, zly2);
    ctx.stroke();

    // 5. Pitch Point (P)
    const [zppx, zppy] = toScr2(rp_p, 0);
    ctx.fillStyle = '#ff1a1a';
    ctx.beginPath();
    ctx.arc(zppx, zppy, 6.5, 0, 2 * Math.PI);
    ctx.fill();

    // 6. Pressure Angle Arc
    const arcR = 5.0;
    const [asx, asy] = toScr2(rp_p, 0);
    ctx.save();
    ctx.strokeStyle = '#ff9999';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.arc(asx, asy, arcR * scale2, -(Math.PI / 2 + calc.phi), -Math.PI / 2);
    ctx.stroke();
    ctx.restore();

    const [atx, aty] = toScr2(rp_p + 1.2, arcR * 0.7);
    ctx.fillStyle = '#ff9999';
    ctx.font = 'bold 10px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    ctx.fillText(`\u03D5 = ${calc.phi_deg.toFixed(1)}\u00B0`, atx, aty);

    // 7. Text labels in Zoom
    ctx.fillStyle = '#ff4d4d';
    ctx.font = 'bold 10px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    const [zptX, zptY] = toScr2(rp_p + 1.2, -1.8);
    ctx.fillText('Pitch Point (P)', zptX, zptY);

    // Rotated "Line of Action" label along line
    const dx = zlx2 - zlx1;
    const dy = zly2 - zly1;
    const rot = Math.atan2(dy, dx);
    ctx.save();
    const [tLoaX, tLoaY] = toScr2(rp_p + loa_len * loa_dir[0] * 0.35, loa_len * loa_dir[1] * 0.35 + 1.2);
    ctx.translate(tLoaX, tLoaY);
    ctx.rotate(rot);
    ctx.fillStyle = '#ff5959';
    ctx.font = 'italic 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText('Line of Action', 0, -4);
    ctx.restore();

    // 8. Info HUD Card in Top-Left of Subplot 2 matching MATLAB text box
    const cardX = s2_x + 12;
    const cardY = s2_y + 12;
    const cardW = 185;
    const cardH = 72;

    ctx.fillStyle = '#242433'; // MATLAB [0.14 0.14 0.20]
    ctx.strokeStyle = '#595973'; // MATLAB [0.35 0.35 0.45]
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.roundRect(cardX, cardY, cardW, cardH, 4);
    ctx.fill();
    ctx.stroke();

    ctx.fillStyle = '#ffffff';
    ctx.font = '9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';

    const c_std = 0.188 * calc.m;
    ctx.fillText(`Working Depth: hw = ${calc.hw.toFixed(2)} mm`, cardX + 8, cardY + 7);
    ctx.fillText(`Whole Depth: ht = ${calc.ht.toFixed(3)} mm`, cardX + 8, cardY + 22);
    ctx.fillText(`Clearance: c = ${c_std.toFixed(3)} mm`, cardX + 8, cardY + 37);
    ctx.fillText(`Contact Ratio: CR = ${calc.CR.toFixed(3)}`, cardX + 8, cardY + 52);

    ctx.restore(); // Restore clip Subplot 2
  }

  renderInternalSpur() {
    const calc = this.calc;
    const ctx = this.ctx;
    const w = this.width;
    const h = this.height;

    // Overall Figure Background: MATLAB [0.07 0.07 0.10]
    ctx.fillStyle = '#12121a';
    ctx.fillRect(0, 0, w, h);

    const marginLeft = 52;
    const marginRight = 35;
    const marginTop = 38;
    const marginBottom = 45;
    const gap = 55;

    const availW = w - marginLeft - marginRight - gap;
    const cellW = Math.floor(availW / 2);
    const cellH = h - marginTop - marginBottom;

    if (cellW <= 50 || cellH <= 50) return;

    const C = calc.center_dist; // 48.0 mm
    const rp_p = calc.rp_p;     // 24.0 mm
    const rp_g = calc.rp_g;     // 72.0 mm
    const rb_p = calc.rb_p;
    const rb_g = calc.rb_g;
    const ra_p = calc.ra_p;
    const ra_g = calc.ra_g_int;

    // Generate accurate polygons
    const polyP = this.generate2DGearPolygon(calc.Np, calc.m, calc.phi, calc.a_p, calc.b_p, calc.s_p, 180);
    const { xc_ring, yc_ring, x_rim, y_rim } = generateInternalSpurProfile2D(calc, 40);

    // Pinion tooth 0 points along +X towards pitch point at (72, 0)
    // Ring gear tooth space is centered at angle 0 at pitch point (72, 0)
    const pinX = [];
    const pinY = [];
    for (let i = 0; i < polyP.xc.length; i++) {
      pinX.push(polyP.xc[i] + C);
      pinY.push(polyP.yc[i]);
    }

    // Line of Action segment
    const loa_len = 22;
    const loa_dir = [Math.sin(calc.phi), Math.cos(calc.phi)];
    const px_pt = rp_g; // 72.0 mm
    const py_pt = 0;
    const loa_p1 = [px_pt - loa_len * loa_dir[0], py_pt - loa_len * loa_dir[1]];
    const loa_p2 = [px_pt + loa_len * loa_dir[0], py_pt + loa_len * loa_dir[1]];

    // =========================================================================
    // SUBPLOT 1: Full 2D Engagement Overview (Left Pane)
    // MATLAB data limits: X in [-95, 105], Y in [-95, 95]
    // =========================================================================
    const s1_xMin = -95, s1_xMax = 105;
    const s1_yMin = -95, s1_yMax = 95;
    const dataSpan1 = Math.max(s1_xMax - s1_xMin, s1_yMax - s1_yMin);
    const scale1 = Math.min(cellW / dataSpan1, cellH / dataSpan1);

    const s1_w = dataSpan1 * scale1;
    const s1_h = dataSpan1 * scale1;
    const s1_x = marginLeft + (cellW - s1_w) / 2;
    const s1_y = marginTop + (cellH - s1_h) / 2;

    this.drawAxesFrame(
      s1_x, s1_y, s1_w, s1_h,
      s1_xMin, s1_xMax, s1_yMin, s1_yMax,
      [-80, -60, -40, -20, 0, 20, 40, 60, 80, 100],
      [-80, -60, -40, -20, 0, 20, 40, 60, 80],
      `2D Overview: Internal Ring (${calc.Ng}T) + Pinion (${calc.Np}T), Ratio 1:${calc.i_ratio.toFixed(0)}, m = ${calc.m} mm`,
      'X [mm]',
      'Y [mm]'
    );

    const mapX1 = x_d => s1_x + ((x_d - s1_xMin) / (s1_xMax - s1_xMin)) * s1_w;
    const mapY1 = y_d => s1_y + s1_h - ((y_d - s1_yMin) / (s1_yMax - s1_yMin)) * s1_h;

    ctx.save();
    ctx.beginPath();
    ctx.rect(s1_x, s1_y, s1_w, s1_h);
    ctx.clip();

    // 1. Draw Ring Gear (Annulus with internal teeth)
    ctx.fillStyle = 'rgba(199, 133, 72, 0.75)'; // Golden Bronze
    ctx.strokeStyle = '#a66633';
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    for (let k = 0; k < x_rim.length; k++) {
      const px = mapX1(x_rim[k]), py = mapY1(y_rim[k]);
      if (k === 0) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    }
    ctx.closePath();
    for (let k = xc_ring.length - 1; k >= 0; k--) {
      const px = mapX1(xc_ring[k]), py = mapY1(yc_ring[k]);
      if (k === xc_ring.length - 1) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    }
    ctx.closePath();
    ctx.fill('evenodd');
    ctx.stroke();

    // 2. Draw Pinion at (C, 0)
    ctx.fillStyle = 'rgba(75, 120, 185, 0.85)'; // Steel Blue
    ctx.strokeStyle = '#38557a';
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    for (let i = 0; i < pinX.length; i++) {
      const px = mapX1(pinX[i]), py = mapY1(pinY[i]);
      if (i === 0) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    }
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // 3. Pitch Circles
    ctx.setLineDash([4, 3]);
    ctx.strokeStyle = '#f0c055'; // Ring pitch circle
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    ctx.arc(mapX1(0), mapY1(0), rp_g * scale1, 0, 2 * Math.PI);
    ctx.stroke();

    ctx.strokeStyle = '#8cb5f0'; // Pinion pitch circle
    ctx.beginPath();
    ctx.arc(mapX1(C), mapY1(0), rp_p * scale1, 0, 2 * Math.PI);
    ctx.stroke();
    ctx.setLineDash([]);

    // 4. Centerline & Center Marks
    ctx.strokeStyle = '#808099';
    ctx.lineWidth = 0.9;
    ctx.beginPath();
    ctx.moveTo(mapX1(-10), mapY1(0));
    ctx.lineTo(mapX1(100), mapY1(0));
    ctx.stroke();

    ctx.strokeStyle = '#f0c055';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(mapX1(0) - 5, mapY1(0)); ctx.lineTo(mapX1(0) + 5, mapY1(0));
    ctx.moveTo(mapX1(0), mapY1(0) - 5); ctx.lineTo(mapX1(0), mapY1(0) + 5);
    ctx.stroke();

    ctx.strokeStyle = '#8cb5f0';
    ctx.beginPath();
    ctx.moveTo(mapX1(C) - 5, mapY1(0)); ctx.lineTo(mapX1(C) + 5, mapY1(0));
    ctx.moveTo(mapX1(C), mapY1(0) - 5); ctx.lineTo(mapX1(C), mapY1(0) + 5);
    ctx.stroke();

    // Pitch Point (P)
    ctx.fillStyle = '#ff2b2b';
    ctx.beginPath();
    ctx.arc(mapX1(px_pt), mapY1(py_pt), 4.5, 0, 2 * Math.PI);
    ctx.fill();

    // Line of Action segment
    ctx.strokeStyle = '#ff2b2b';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(mapX1(loa_p1[0]), mapY1(loa_p1[1]));
    ctx.lineTo(mapX1(loa_p2[0]), mapY1(loa_p2[1]));
    ctx.stroke();

    // Dimension Line: Center Distance C = 48.0 mm
    const dimY = -35;
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.moveTo(mapX1(0), mapY1(dimY));
    ctx.lineTo(mapX1(C), mapY1(dimY));
    ctx.moveTo(mapX1(0), mapY1(dimY - 3));
    ctx.lineTo(mapX1(0), mapY1(dimY + 3));
    ctx.moveTo(mapX1(C), mapY1(dimY - 3));
    ctx.lineTo(mapX1(C), mapY1(dimY + 3));
    ctx.stroke();

    ctx.fillStyle = '#ffffff';
    ctx.font = '9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    ctx.fillText(`Center Distance C = ${C.toFixed(1)} mm`, mapX1(C / 2), mapY1(dimY) + 5);

    // Text labels
    ctx.fillStyle = '#f0c055';
    ctx.font = 'bold 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(`Ring Gear (${calc.Ng}T)\nPD = ${(2 * rp_g).toFixed(0)} mm`, mapX1(0), mapY1(15));

    ctx.fillStyle = '#8cb5f0';
    ctx.fillText(`Pinion (${calc.Np}T)\nPD = ${(2 * rp_p).toFixed(0)} mm`, mapX1(C), mapY1(-15));

    ctx.fillStyle = '#ff6b6b';
    ctx.font = 'bold 8px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    ctx.fillText('Pitch Point (P)', mapX1(px_pt) + 5, mapY1(py_pt) - 4);

    ctx.restore();

    // =========================================================================
    // SUBPLOT 2: Detailed Meshing Zone (Right Pane)
    // MATLAB data limits: X in [60, 86], Y in [-14, 16]
    // =========================================================================
    const s2_xMin = 60, s2_xMax = 86;
    const s2_yMin = -14, s2_yMax = 16;
    const dataSpan2X = s2_xMax - s2_xMin;
    const dataSpan2Y = s2_yMax - s2_yMin;
    const scale2 = Math.min(cellW / dataSpan2X, cellH / dataSpan2Y);

    const s2_w = dataSpan2X * scale2;
    const s2_h = dataSpan2Y * scale2;
    const s2_x = marginLeft + cellW + gap + (cellW - s2_w) / 2;
    const s2_y = marginTop + (cellH - s2_h) / 2;

    this.drawAxesFrame(
      s2_x, s2_y, s2_w, s2_h,
      s2_xMin, s2_xMax, s2_yMin, s2_yMax,
      [60, 65, 70, 75, 80, 85],
      [-10, -5, 0, 5, 10],
      'Detailed Meshing Zone (Internal Tooth Contact & Line of Action)',
      'X [mm]',
      'Y [mm]'
    );

    const mapX2 = x_d => s2_x + ((x_d - s2_xMin) / (s2_xMax - s2_xMin)) * s2_w;
    const mapY2 = y_d => s2_y + s2_h - ((y_d - s2_yMin) / (s2_yMax - s2_yMin)) * s2_h;

    ctx.save();
    ctx.beginPath();
    ctx.rect(s2_x, s2_y, s2_w, s2_h);
    ctx.clip();

    // 1. Draw Pinion in high zoom
    ctx.fillStyle = 'rgba(75, 120, 185, 0.90)';
    ctx.strokeStyle = '#38557a';
    ctx.lineWidth = 1.3;
    ctx.beginPath();
    for (let i = 0; i < pinX.length; i++) {
      const px = mapX2(pinX[i]), py = mapY2(pinY[i]);
      if (i === 0) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    }
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // 2. Draw Ring Gear in high zoom
    ctx.fillStyle = 'rgba(199, 133, 72, 0.85)';
    ctx.strokeStyle = '#a66633';
    ctx.lineWidth = 1.3;
    ctx.beginPath();
    for (let k = 0; k < x_rim.length; k++) {
      const px = mapX2(x_rim[k]), py = mapY2(y_rim[k]);
      if (k === 0) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    }
    ctx.closePath();
    for (let k = xc_ring.length - 1; k >= 0; k--) {
      const px = mapX2(xc_ring[k]), py = mapY2(yc_ring[k]);
      if (k === xc_ring.length - 1) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    }
    ctx.closePath();
    ctx.fill('evenodd');
    ctx.stroke();

    // 3. Arcs in meshing zone
    ctx.setLineDash([4, 3]);
    ctx.strokeStyle = '#f0c055';
    ctx.lineWidth = 1.3;
    ctx.beginPath();
    ctx.arc(mapX2(0), mapY2(0), rp_g * scale2, 0, 2 * Math.PI);
    ctx.stroke();

    ctx.strokeStyle = '#8cb5f0';
    ctx.beginPath();
    ctx.arc(mapX2(C), mapY2(0), rp_p * scale2, 0, 2 * Math.PI);
    ctx.stroke();

    // Base circles (dotted)
    ctx.setLineDash([2, 3]);
    ctx.strokeStyle = '#c0994d';
    ctx.beginPath();
    ctx.arc(mapX2(0), mapY2(0), rb_g * scale2, 0, 2 * Math.PI);
    ctx.stroke();

    ctx.strokeStyle = '#6699cc';
    ctx.beginPath();
    ctx.arc(mapX2(C), mapY2(0), rb_p * scale2, 0, 2 * Math.PI);
    ctx.stroke();

    // Tip circles (solid)
    ctx.setLineDash([]);
    ctx.strokeStyle = '#f5da80';
    ctx.beginPath();
    ctx.arc(mapX2(0), mapY2(0), ra_g * scale2, 0, 2 * Math.PI);
    ctx.stroke();

    ctx.strokeStyle = '#a6d8ff';
    ctx.beginPath();
    ctx.arc(mapX2(C), mapY2(0), ra_p * scale2, 0, 2 * Math.PI);
    ctx.stroke();

    // Pitch Point (P)
    ctx.fillStyle = '#ff2b2b';
    ctx.beginPath();
    ctx.arc(mapX2(px_pt), mapY2(py_pt), 6, 0, 2 * Math.PI);
    ctx.fill();

    // Line of Action
    ctx.strokeStyle = '#ff2b2b';
    ctx.lineWidth = 2.0;
    ctx.beginPath();
    ctx.moveTo(mapX2(loa_p1[0]), mapY2(loa_p1[1]));
    ctx.lineTo(mapX2(loa_p2[0]), mapY2(loa_p2[1]));
    ctx.stroke();

    // Pressure angle arc
    ctx.setLineDash([3, 2]);
    ctx.strokeStyle = '#ff2b2b';
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    const r_arc = 7.0;
    for (let a = 0; a <= 20; a++) {
      const th = (Math.PI / 2 - calc.phi) + (calc.phi * a) / 20;
      const ax = px_pt - r_arc * Math.cos(th);
      const ay = py_pt + r_arc * Math.sin(th);
      if (a === 0) ctx.moveTo(mapX2(ax), mapY2(ay));
      else ctx.lineTo(mapX2(ax), mapY2(ay));
    }
    ctx.stroke();
    ctx.setLineDash([]);

    ctx.fillStyle = '#ff2b2b';
    ctx.font = 'bold 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(`\u03C6 = ${calc.phi_deg.toFixed(1)}\u00B0`, mapX2(px_pt - 4.5), mapY2(5.5));

    // Rotated Label: Line of Action
    ctx.save();
    ctx.translate(mapX2(px_pt + 3), mapY2(-4.5));
    const angleRad = Math.atan2(-(mapY2(loa_p2[1]) - mapY2(loa_p1[1])), mapX2(loa_p2[0]) - mapX2(loa_p1[0]));
    ctx.rotate(angleRad);
    ctx.fillStyle = '#ff6b6b';
    ctx.font = 'bold italic 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText('Line of Action', 0, 0);
    ctx.restore();

    // HUD Card in top-left
    const cardX = s2_x + 12;
    const cardY = s2_y + 12;
    const cardW = 185;
    const cardH = 72;

    ctx.fillStyle = '#242433';
    ctx.strokeStyle = '#595973';
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.roundRect(cardX, cardY, cardW, cardH, 4);
    ctx.fill();
    ctx.stroke();

    ctx.fillStyle = '#ffffff';
    ctx.font = '9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';

    ctx.fillText(`Working Depth: hw = ${calc.hw.toFixed(2)} mm`, cardX + 8, cardY + 7);
    ctx.fillText(`Whole Depth: ht = ${calc.ht.toFixed(3)} mm`, cardX + 8, cardY + 22);
    ctx.fillText(`Clearance: c = ${calc.c_std.toFixed(3)} mm`, cardX + 8, cardY + 37);
    ctx.fillText(`Contact Ratio: CR = ${calc.CR.toFixed(3)}`, cardX + 8, cardY + 52);

    ctx.restore();
  }

  renderBevelConesAndContact() {
    const calc = this.calc;
    const ctx = this.ctx;
    const w = this.width;
    const h = this.height;

    // Background
    ctx.fillStyle = '#12121a';
    ctx.fillRect(0, 0, w, h);

    const marginLeft = 52;
    const marginRight = 35;
    const marginTop = 38;
    const marginBottom = 45;
    const gap = 55;

    const availW = w - marginLeft - marginRight - gap;
    const cellW = Math.floor(availW / 2);
    const cellH = h - marginTop - marginBottom;

    if (cellW <= 50 || cellH <= 50) return;

    const m = calc.m;
    const Np = calc.Np;
    const Ng = calc.Ng;
    const phi = calc.phi;
    const Ao = calc.Ao;
    const F = calc.F;
    const Ai = calc.Ai;
    const gamma_p = calc.gamma_p;
    const gamma_g = calc.gamma_g;

    // =========================================================================
    // SUBPLOT 1: Pitch Cones & Orthogonal Shafts (Left Pane)
    // Data limits: X in [-15, 95], Y in [-30, 85]
    // =========================================================================
    const s1_xMin = -15, s1_xMax = Math.max(95, Ao * 1.2);
    const s1_yMin = -30, s1_yMax = Math.max(85, Ao * 1.1);
    const dataSpan1X = s1_xMax - s1_xMin;
    const dataSpan1Y = s1_yMax - s1_yMin;
    const scale1 = Math.min((cellW - 10) / dataSpan1X, (cellH - 10) / dataSpan1Y);

    const s1_w = dataSpan1X * scale1;
    const s1_h = dataSpan1Y * scale1;
    const s1_x = marginLeft + (cellW - s1_w) / 2;
    const s1_y = marginTop + (cellH - s1_h) / 2;

    const isSpiral = calc.gear_type === 'spiral-bevel';
    const gearLabel = isSpiral ? `Spiral Bevel (\u03B2m=${(calc.beta_m_deg || 35).toFixed(0)}\u00B0)` : calc.gear_type === 'straight-bevel' ? 'Straight Bevel Cones' : 'Zerol Bevel Cones';
    this.drawAxesFrame(
      s1_x, s1_y, s1_w, s1_h,
      s1_xMin, s1_xMax, s1_yMin, s1_yMax,
      [-10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90],
      [-20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80],
      `2D Overview: ${gearLabel} (${Np}T/${Ng}T), \u03A3 = 90\u00B0, m = ${m} mm`,
      'Pinion Shaft X [mm]',
      'Gear Shaft Y [mm]'
    );

    const mapX1 = x => s1_x + ((x - s1_xMin) / dataSpan1X) * s1_w;
    const mapY1 = y => s1_y + s1_h - ((y - s1_yMin) / dataSpan1Y) * s1_h;

    ctx.save();
    ctx.beginPath();
    ctx.rect(s1_x, s1_y, s1_w, s1_h);
    ctx.clip();

    // Shaft Centerlines
    ctx.strokeStyle = 'rgba(140, 190, 240, 0.5)';
    ctx.lineWidth = 1.0;
    ctx.setLineDash([4, 4]);
    ctx.beginPath();
    ctx.moveTo(mapX1(-10), mapY1(0));
    ctx.lineTo(mapX1(Ao * 1.15), mapY1(0));
    ctx.stroke();

    ctx.strokeStyle = 'rgba(240, 190, 90, 0.5)';
    ctx.beginPath();
    ctx.moveTo(mapX1(0), mapY1(-10));
    ctx.lineTo(mapX1(0), mapY1(Ao * 1.15));
    ctx.stroke();
    ctx.setLineDash([]);

    // Pitch Cones Generators
    const px_P = Ao * Math.cos(gamma_p);
    const py_P = Ao * Math.sin(gamma_p);

    // Common pitch line
    ctx.strokeStyle = '#f1c40f'; // Yellow
    ctx.lineWidth = 2.0;
    ctx.beginPath();
    ctx.moveTo(mapX1(0), mapY1(0));
    ctx.lineTo(mapX1(px_P), mapY1(py_P));
    ctx.stroke();

    // Lower pinion cone
    ctx.strokeStyle = 'rgba(140, 190, 240, 0.6)';
    ctx.lineWidth = 1.2;
    ctx.setLineDash([5, 5]);
    ctx.beginPath();
    ctx.moveTo(mapX1(0), mapY1(0));
    ctx.lineTo(mapX1(Ao * Math.cos(-gamma_p)), mapY1(Ao * Math.sin(-gamma_p)));
    ctx.stroke();

    // Gear outer cone
    ctx.strokeStyle = 'rgba(240, 190, 90, 0.6)';
    ctx.beginPath();
    ctx.moveTo(mapX1(0), mapY1(0));
    ctx.lineTo(mapX1(Ao * Math.cos(Math.PI / 2 + gamma_g)), mapY1(Ao * Math.sin(Math.PI / 2 + gamma_g)));
    ctx.stroke();
    ctx.setLineDash([]);

    // Active Face Width Band (Red bold line)
    ctx.strokeStyle = '#e74c3c';
    ctx.lineWidth = 4.0;
    ctx.beginPath();
    ctx.moveTo(mapX1(Ai * Math.cos(gamma_p)), mapY1(Ai * Math.sin(gamma_p)));
    ctx.lineTo(mapX1(px_P), mapY1(py_P));
    ctx.stroke();

    // Spiral Angle Tangent at Mean Point (for Spiral Bevel)
    if (isSpiral) {
      const Am = calc.Am || (Ao - F / 2);
      const beta_m = calc.beta_m || (35 * Math.PI / 180);
      const px_Pm = Am * Math.cos(gamma_p);
      const py_Pm = Am * Math.sin(gamma_p);

      // Mean point marker
      ctx.fillStyle = '#2ecc71';
      ctx.beginPath();
      ctx.arc(mapX1(px_Pm), mapY1(py_Pm), 4.0, 0, 2 * Math.PI);
      ctx.fill();

      // Spiral tangent line
      const tang_len = 16;
      const tang_angle = gamma_p + beta_m;
      ctx.strokeStyle = '#2ecc71';
      ctx.lineWidth = 2.0;
      ctx.beginPath();
      ctx.moveTo(mapX1(px_Pm - tang_len * Math.cos(tang_angle)), mapY1(py_Pm - tang_len * Math.sin(tang_angle)));
      ctx.lineTo(mapX1(px_Pm + tang_len * Math.cos(tang_angle)), mapY1(py_Pm + tang_len * Math.sin(tang_angle)));
      ctx.stroke();

      ctx.fillStyle = '#2ecc71';
      ctx.font = 'bold 8.5px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText(`Spiral \u03B2m = ${(calc.beta_m_deg || 35).toFixed(1)}\u00B0`, mapX1(px_Pm + 4), mapY1(py_Pm - 6));
    }

    // Back-cone perpendicular line at outer heel
    const back_len = (calc.a_p || m) + (calc.b_p || 1.25 * m);
    const nx = -Math.sin(gamma_p);
    const ny = Math.cos(gamma_p);
    ctx.strokeStyle = '#8ecae6';
    ctx.lineWidth = 2.0;
    ctx.beginPath();
    ctx.moveTo(mapX1(px_P - back_len * nx), mapY1(py_P - back_len * ny));
    ctx.lineTo(mapX1(px_P + back_len * nx), mapY1(py_P + back_len * ny));
    ctx.stroke();

    // Apex (0, 0)
    ctx.fillStyle = '#ffffff';
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(mapX1(-3), mapY1(0));
    ctx.lineTo(mapX1(3), mapY1(0));
    ctx.moveTo(mapX1(0), mapY1(-3));
    ctx.lineTo(mapX1(0), mapY1(3));
    ctx.stroke();
    ctx.font = 'bold 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText('Apex (0, 0)', mapX1(-2), mapY1(-6));

    // Pitch point P
    ctx.fillStyle = '#ff4d4d';
    ctx.beginPath();
    ctx.arc(mapX1(px_P), mapY1(py_P), 4.5, 0, 2 * Math.PI);
    ctx.fill();
    ctx.fillText('Pitch Point (P)', mapX1(px_P + 3), mapY1(py_P + 4));

    // Outer Cone Distance Ao Dimension
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 0.9;
    const dimY = py_P + 14;
    ctx.beginPath();
    ctx.moveTo(mapX1(0), mapY1(dimY));
    ctx.lineTo(mapX1(px_P), mapY1(dimY));
    ctx.moveTo(mapX1(0), mapY1(dimY - 3));
    ctx.lineTo(mapX1(0), mapY1(dimY + 3));
    ctx.moveTo(mapX1(px_P), mapY1(dimY - 3));
    ctx.lineTo(mapX1(px_P), mapY1(dimY + 3));
    ctx.stroke();
    ctx.textAlign = 'center';
    ctx.fillText(`Outer Cone Dist Ao = ${Ao.toFixed(1)} mm`, mapX1(px_P / 2), mapY1(dimY + 5));

    // Face Width F Dimension
    const dimFy = -18;
    ctx.strokeStyle = '#f1c40f';
    ctx.fillStyle = '#f1c40f';
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    ctx.moveTo(mapX1(Ai * Math.cos(gamma_p)), mapY1(dimFy));
    ctx.lineTo(mapX1(Ao * Math.cos(gamma_p)), mapY1(dimFy));
    ctx.moveTo(mapX1(Ai * Math.cos(gamma_p)), mapY1(dimFy - 3));
    ctx.lineTo(mapX1(Ai * Math.cos(gamma_p)), mapY1(dimFy + 3));
    ctx.moveTo(mapX1(Ao * Math.cos(gamma_p)), mapY1(dimFy - 3));
    ctx.lineTo(mapX1(Ao * Math.cos(gamma_p)), mapY1(dimFy + 3));
    ctx.stroke();
    ctx.fillText(`Face Width F = ${F.toFixed(1)} mm`, mapX1(((Ai + Ao) / 2) * Math.cos(gamma_p)), mapY1(dimFy - 7));

    // Angle Arcs
    ctx.strokeStyle = '#00ffff';
    ctx.fillStyle = '#00ffff';
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    const r_arc = 28;
    ctx.arc(mapX1(0), mapY1(0), r_arc * scale1, -gamma_p, 0, false);
    ctx.stroke();
    ctx.textAlign = 'left';
    ctx.fillText(`\u03B3p = ${calc.gamma_p_deg.toFixed(1)}\u00B0`, mapX1(32 * Math.cos(gamma_p / 2)), mapY1(32 * Math.sin(gamma_p / 2)));

    ctx.strokeStyle = '#e67e22';
    ctx.fillStyle = '#e67e22';
    ctx.beginPath();
    ctx.arc(mapX1(0), mapY1(0), r_arc * scale1, -Math.PI / 2, -gamma_p, false);
    ctx.stroke();
    ctx.fillText(`\u03B3g = ${calc.gamma_g_deg.toFixed(1)}\u00B0`, mapX1(32 * Math.cos((gamma_p + Math.PI / 2) / 2)), mapY1(32 * Math.sin((gamma_p + Math.PI / 2) / 2)));

    ctx.restore();

    // =========================================================================
    // SUBPLOT 2: Detailed Tredgold Meshing Zone (Right Pane)
    // Tredgold back cone plane coordinates around pitch point (rv_p, 0)
    // =========================================================================
    const rv_p = calc.rv_p || (calc.m * (calc.Nv_p || 16.86)) / 2;
    const rv_g = calc.rv_g || (calc.m * (calc.Nv_g || 151.79)) / 2;
    const center_v = rv_p + rv_g;

    const s2_xMin = rv_p - 12;
    const s2_xMax = rv_p + 14;
    const s2_yMin = -13;
    const s2_yMax = 13;
    const s2_xSpan = s2_xMax - s2_xMin;
    const s2_ySpan = s2_yMax - s2_yMin;
    const scale2 = Math.min((cellW - 10) / s2_xSpan, (cellH - 10) / s2_ySpan);

    const s2_w = s2_xSpan * scale2;
    const s2_h = s2_ySpan * scale2;
    const s2_x = marginLeft + cellW + gap + (cellW - s2_w) / 2;
    const s2_y = marginTop + (cellH - s2_h) / 2;

    this.drawAxesFrame(
      s2_x, s2_y, s2_w, s2_h,
      s2_xMin, s2_xMax, s2_yMin, s2_yMax,
      [15, 20, 25, 30, 35],
      [-10, -5, 0, 5, 10],
      'Detailed Meshing Zone (Tredgold Equivalent Contact & Line of Action)',
      'Tredgold Plane X [mm]',
      'Tredgold Plane Y [mm]'
    );

    const mapX2 = x => s2_x + ((x - s2_xMin) / s2_xSpan) * s2_w;
    const mapY2 = y => s2_y + s2_h - ((y - s2_yMin) / s2_ySpan) * s2_h;

    ctx.save();
    ctx.beginPath();
    ctx.rect(s2_x, s2_y, s2_w, s2_h);
    ctx.clip();

    // In Tredgold plane, generate equivalent pinion and gear teeth
    const polyP = this.generate2DGearPolygon(calc.Np, calc.m, calc.phi, calc.a_p, calc.b_p, calc.s_p, 200);
    const polyG = this.generate2DGearPolygon(calc.Ng, calc.m, calc.phi, calc.a_g, calc.b_g, calc.s_g, 200);

    const scale_p = 1 / Math.cos(gamma_p);
    const scale_g = 1 / Math.cos(gamma_g);

    // Draw Tredgold Pinion
    ctx.fillStyle = 'rgba(74, 144, 226, 0.65)';
    ctx.strokeStyle = '#2d5a88';
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    for (let i = 0; i < polyP.xc.length; i++) {
      const sx = polyP.xc[i] * scale_p;
      const sy = polyP.yc[i] * scale_p;
      const mx = mapX2(sx);
      const my = mapY2(sy);
      if (i === 0) ctx.moveTo(mx, my);
      else ctx.lineTo(mx, my);
    }
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // Draw Tredgold Gear
    const half_pitch_g = Math.PI / calc.Ng;
    const rot_g = Math.PI + half_pitch_g;
    const cos_rg = Math.cos(rot_g);
    const sin_rg = Math.sin(rot_g);

    ctx.fillStyle = 'rgba(199, 133, 72, 0.65)';
    ctx.strokeStyle = '#8c5023';
    ctx.beginPath();
    for (let i = 0; i < polyG.xc.length; i++) {
      const gx_scaled = polyG.xc[i] * scale_g;
      const gy_scaled = polyG.yc[i] * scale_g;
      const rx = gx_scaled * cos_rg - gy_scaled * sin_rg + center_v;
      const ry = gx_scaled * sin_rg + gy_scaled * cos_rg;
      const mx = mapX2(rx);
      const my = mapY2(ry);
      if (i === 0) ctx.moveTo(mx, my);
      else ctx.lineTo(mx, my);
    }
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // Pitch Circles in Tredgold Plane
    ctx.strokeStyle = '#f1c40f';
    ctx.lineWidth = 1.5;
    ctx.setLineDash([6, 4]);
    ctx.beginPath();
    ctx.arc(mapX2(0), mapY2(0), rv_p * scale2, 0, 2 * Math.PI);
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(mapX2(center_v), mapY2(0), rv_g * scale2, 0, 2 * Math.PI);
    ctx.stroke();
    ctx.setLineDash([]);

    // Line of Action (passes through rv_p, 0 at angle phi)
    const loa_len = 22;
    const loa_x1 = rv_p - loa_len * Math.sin(phi);
    const loa_y1 = 0 - loa_len * Math.cos(phi);
    const loa_x2 = rv_p + loa_len * Math.sin(phi);
    const loa_y2 = 0 + loa_len * Math.cos(phi);

    ctx.strokeStyle = '#e74c3c';
    ctx.lineWidth = 2.0;
    ctx.beginPath();
    ctx.moveTo(mapX2(loa_x1), mapY2(loa_y1));
    ctx.lineTo(mapX2(loa_x2), mapY2(loa_y2));
    ctx.stroke();

    // Pitch Point P at (rv_p, 0)
    ctx.fillStyle = '#ff3838';
    ctx.beginPath();
    ctx.arc(mapX2(rv_p), mapY2(0), 4.5, 0, 2 * Math.PI);
    ctx.fill();

    // Line of Action rotated label
    ctx.save();
    ctx.translate(mapX2(rv_p + 3), mapY2(8));
    ctx.rotate(Math.atan2(-(mapY2(loa_y2) - mapY2(loa_y1)), mapX2(loa_x2) - mapX2(loa_x1)));
    ctx.fillStyle = '#ff6b6b';
    ctx.font = 'bold italic 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText('Line of Action', 0, 0);
    ctx.restore();

    // Contact HUD Card
    const cardX = s2_x + 12;
    const cardY = s2_y + 12;
    const cardW = isSpiral ? 205 : 180;
    const cardH = isSpiral ? 92 : 72;

    ctx.fillStyle = '#242433';
    ctx.strokeStyle = '#595973';
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.roundRect(cardX, cardY, cardW, cardH, 4);
    ctx.fill();
    ctx.stroke();

    ctx.fillStyle = '#ffffff';
    ctx.font = '9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';

    ctx.fillText(`Working Depth: hw = ${calc.hw.toFixed(2)} mm`, cardX + 8, cardY + 7);
    ctx.fillText(`Whole Depth: ht = ${calc.ht.toFixed(3)} mm`, cardX + 8, cardY + 22);
    ctx.fillText(`Clearance: c = ${calc.c_std.toFixed(3)} mm`, cardX + 8, cardY + 37);
    if (isSpiral) {
      ctx.fillText(`Transverse \u03B5\u03B1: ${(calc.eps_alpha || 1.306).toFixed(3)} | Overlap \u03B5\u03B2: ${(calc.eps_beta || 2.224).toFixed(3)}`, cardX + 8, cardY + 52);
      ctx.fillStyle = '#2ecc71';
      ctx.font = 'bold 9.5px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText(`Total Contact Ratio: \u03B5\u03B3 = ${calc.CR.toFixed(3)}`, cardX + 8, cardY + 68);
    } else {
      ctx.fillStyle = '#2ecc71'; // Green for safe CR
      ctx.font = 'bold 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText(`Contact Ratio: CR = ${calc.CR.toFixed(3)}`, cardX + 8, cardY + 52);
    }

    ctx.restore();
  }

  // =========================================================================
  // HELICAL GEAR 2D TRANSVERSE ENGAGEMENT & CONTACT DIAGRAM
  // =========================================================================
  renderHelicalTransverseDiagram() {
    const calc = this.calc;
    const ctx = this.ctx;
    const w = this.width;
    const h = this.height;

    ctx.fillStyle = '#12121a';
    ctx.fillRect(0, 0, w, h);

    const marginLeft = 52;
    const marginRight = 35;
    const marginTop = 38;
    const marginBottom = 45;
    const gap = 55;

    const availW = w - marginLeft - marginRight - gap;
    const cellW = Math.floor(availW / 2);
    const cellH = h - marginTop - marginBottom;

    if (cellW <= 50 || cellH <= 50) return;

    const C = calc.center_dist;
    const rp_p = calc.rp_p;
    const rp_g = calc.rp_g;
    const rb_p = calc.rb_p;
    const rb_g = calc.rb_g;
    const ra_p = calc.ra_p;
    const ra_g = calc.ra_g;
    const rd_p = calc.rd_p;
    const rd_g = calc.rd_g;
    const phi_t = calc.phi_t;

    // Generate accurate 2D transverse tooth polygons
    const polyP = this.generate2DGearPolygon(calc.Np, calc.mt, calc.phi_t, calc.a_p, calc.b_p, calc.st_p, 250);
    const polyG = this.generate2DGearPolygon(calc.Ng, calc.mt, calc.phi_t, calc.a_g, calc.b_g, calc.st_g, 250);

    const half_pitch_g = Math.PI / calc.Ng;
    const rot_angle = Math.PI + half_pitch_g;
    const cos_r = Math.cos(rot_angle);
    const sin_r = Math.sin(rot_angle);

    const gx_r = [];
    const gy_r = [];
    for (let i = 0; i < polyG.xc.length; i++) {
      gx_r.push(polyG.xc[i] * cos_r - polyG.yc[i] * sin_r + C);
      gy_r.push(polyG.xc[i] * sin_r + polyG.yc[i] * cos_r);
    }

    const loa_len = 28;
    const loa_p1 = [rp_p - loa_len * Math.sin(phi_t), -loa_len * Math.cos(phi_t)];
    const loa_p2 = [rp_p + loa_len * Math.sin(phi_t),  loa_len * Math.cos(phi_t)];

    // -----------------------------------------------------------------------
    // SUBPLOT 1: Full 2D Engagement Overview (Left Pane)
    // -----------------------------------------------------------------------
    const xMin1 = -ra_p - 10;
    const xMax1 = C + ra_g + 10;
    const yMin1 = -ra_g - 15;
    const yMax1 = ra_g + 15;
    const xSpan1 = xMax1 - xMin1;
    const ySpan1 = yMax1 - yMin1;

    const scale1 = Math.min((cellW - 10) / xSpan1, (cellH - 10) / ySpan1);
    const s1_w = Math.round(xSpan1 * scale1);
    const s1_h = Math.round(ySpan1 * scale1);
    const s1_x = Math.round(marginLeft + (cellW - s1_w) / 2);
    const s1_y = Math.round(marginTop + (cellH - s1_h) / 2);

    const toScr1 = (wx, wy) => [
      s1_x + (wx - xMin1) * scale1,
      s1_y + s1_h - (wy - yMin1) * scale1
    ];

    const xTicks1 = [-20, 0, 20, 40, 60, 80, 100, 120, 140, 160, 180];
    const yTicks1 = [-80, -60, -40, -20, 0, 20, 40, 60, 80];

    const title1 = `2D Overview: Helical Engagement (${calc.Np}T/${calc.Ng}T), \u03B2 = ${calc.beta_deg}\u00B0, mn = ${calc.mn} mm`;
    this.drawAxesFrame(s1_x, s1_y, s1_w, s1_h, xMin1, xMax1, yMin1, yMax1, xTicks1, yTicks1, title1, 'X [mm]', 'Y [mm]');

    ctx.save();
    ctx.beginPath();
    ctx.rect(s1_x, s1_y, s1_w, s1_h);
    ctx.clip();

    const drawCircle1 = (cx, cy, r, strokeStyle, lineWidth, dash = []) => {
      ctx.strokeStyle = strokeStyle;
      ctx.lineWidth = lineWidth;
      ctx.setLineDash(dash);
      ctx.beginPath();
      const nSteps = 120;
      for (let i = 0; i <= nSteps; i++) {
        const a = (i * 2 * Math.PI) / nSteps;
        const [sx, sy] = toScr1(cx + r * Math.cos(a), cy + r * Math.sin(a));
        if (i === 0) ctx.moveTo(sx, sy);
        else ctx.lineTo(sx, sy);
      }
      ctx.stroke();
      ctx.setLineDash([]);
    };

    // Pitch circles (Yellow dashed)
    drawCircle1(0, 0, rp_p, '#f1c40f', 1.5, [4, 3]);
    drawCircle1(C, 0, rp_g, '#f1c40f', 1.5, [4, 3]);

    // Base circles (Dotted)
    drawCircle1(0, 0, rb_p, '#7fb3d5', 1.0, [2, 2]);
    drawCircle1(C, 0, rb_g, '#f39c12', 1.0, [2, 2]);

    // Tip circles (Solid)
    drawCircle1(0, 0, ra_p, '#3498db', 1.2);
    drawCircle1(C, 0, ra_g, '#e67e22', 1.2);

    // Root circles (Dash-dot)
    drawCircle1(0, 0, rd_p, '#2980b9', 0.8, [5, 2, 1, 2]);
    drawCircle1(C, 0, rd_g, '#d35400', 0.8, [5, 2, 1, 2]);

    // Line of Action
    const [la1x, la1y] = toScr1(loa_p1[0], loa_p1[1]);
    const [la2x, la2y] = toScr1(loa_p2[0], loa_p2[1]);
    ctx.strokeStyle = '#e74c3c';
    ctx.lineWidth = 2.0;
    ctx.beginPath();
    ctx.moveTo(la1x, la1y);
    ctx.lineTo(la2x, la2y);
    ctx.stroke();

    // Pitch Point P
    const [ppx, ppy] = toScr1(rp_p, 0);
    ctx.fillStyle = '#e74c3c';
    ctx.beginPath();
    ctx.arc(ppx, ppy, 4.5, 0, 2 * Math.PI);
    ctx.fill();

    ctx.fillStyle = '#ff7675';
    ctx.font = 'bold 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    ctx.fillText('Pitch Point (P)', ppx + 6, ppy - 5);

    // Shaft line of centers
    const [c0x, c0y] = toScr1(0, 0);
    const [cgx, cgy] = toScr1(C, 0);
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.0;
    ctx.setLineDash([4, 4]);
    ctx.beginPath();
    ctx.moveTo(c0x, c0y);
    ctx.lineTo(cgx, cgy);
    ctx.stroke();
    ctx.setLineDash([]);

    // Shaft markers
    ctx.strokeStyle = '#00ffff';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(c0x - 5, c0y); ctx.lineTo(c0x + 5, c0y);
    ctx.moveTo(c0x, c0y - 5); ctx.lineTo(c0x, c0y + 5);
    ctx.stroke();

    ctx.strokeStyle = '#ff00ff';
    ctx.beginPath();
    ctx.moveTo(cgx - 5, cgy); ctx.lineTo(cgx + 5, cgy);
    ctx.moveTo(cgx, cgy - 5); ctx.lineTo(cgx, cgy + 5);
    ctx.stroke();

    // Center distance dimension line
    const dimY = -ra_p - 14;
    const [d1x, d1y] = toScr1(0, dimY);
    const [d2x, d2y] = toScr1(C, dimY);
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.moveTo(d1x, d1y); ctx.lineTo(d2x, d2y);
    ctx.moveTo(d1x, d1y - 3); ctx.lineTo(d1x, d1y + 3);
    ctx.moveTo(d2x, d2y - 3); ctx.lineTo(d2x, d2y + 3);
    ctx.stroke();

    ctx.fillStyle = '#ffffff';
    ctx.font = 'bold 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(`Center Distance C = ${C.toFixed(2)} mm`, (d1x + d2x) / 2, d1y - 5);

    ctx.restore();

    // -----------------------------------------------------------------------
    // SUBPLOT 2: Detailed Meshing Zone & Line of Action (Right Pane)
    // -----------------------------------------------------------------------
    const xMin2 = rp_p - 12;
    const xMax2 = rp_p + 14;
    const yMin2 = -12;
    const yMax2 = 12;
    const xSpan2 = xMax2 - xMin2;
    const ySpan2 = yMax2 - yMin2;

    const scale2 = Math.min((cellW - 10) / xSpan2, (cellH - 10) / ySpan2);
    const s2_w = Math.round(xSpan2 * scale2);
    const s2_h = Math.round(ySpan2 * scale2);
    const s2_x = Math.round(marginLeft + cellW + gap + (cellW - s2_w) / 2);
    const s2_y = Math.round(marginTop + (cellH - s2_h) / 2);

    const toScr2 = (wx, wy) => [
      s2_x + (wx - xMin2) * scale2,
      s2_y + s2_h - (wy - yMin2) * scale2
    ];

    const xTicks2 = [15, 20, 25, 30, 35];
    const yTicks2 = [-10, -5, 0, 5, 10];

    const title2 = 'Detailed Meshing Zone (Transverse Contact & Line of Action)';
    this.drawAxesFrame(s2_x, s2_y, s2_w, s2_h, xMin2, xMax2, yMin2, yMax2, xTicks2, yTicks2, title2, 'Transverse X [mm]', 'Transverse Y [mm]');

    ctx.save();
    ctx.beginPath();
    ctx.rect(s2_x, s2_y, s2_w, s2_h);
    ctx.clip();

    // Fill Pinion Teeth (Steel Blue)
    ctx.fillStyle = 'rgba(73, 115, 179, 0.65)';
    ctx.strokeStyle = '#416399';
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    for (let i = 0; i < polyP.xc.length; i++) {
      const [sx, sy] = toScr2(polyP.xc[i], polyP.yc[i]);
      if (i === 0) ctx.moveTo(sx, sy);
      else ctx.lineTo(sx, sy);
    }
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // Fill Central Gear Teeth (Golden Bronze)
    ctx.fillStyle = 'rgba(199, 133, 71, 0.65)';
    ctx.strokeStyle = '#995924';
    ctx.lineWidth = 1.2;
    ctx.beginPath();
    for (let i = 0; i < gx_r.length; i++) {
      const [sx, sy] = toScr2(gx_r[i], gy_r[i]);
      if (i === 0) ctx.moveTo(sx, sy);
      else ctx.lineTo(sx, sy);
    }
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    // Pitch arcs in zoom
    const drawArc2 = (cx, cy, r, strokeStyle) => {
      ctx.strokeStyle = strokeStyle;
      ctx.lineWidth = 1.5;
      ctx.setLineDash([4, 3]);
      ctx.beginPath();
      const nSteps = 50;
      for (let i = 0; i <= nSteps; i++) {
        const a = -0.4 + (i / nSteps) * 0.8;
        const [sx, sy] = toScr2(cx + r * Math.cos(a), cy + r * Math.sin(a));
        if (i === 0) ctx.moveTo(sx, sy);
        else ctx.lineTo(sx, sy);
      }
      ctx.stroke();
      ctx.setLineDash([]);
    };
    drawArc2(0, 0, rp_p, '#f1c40f');
    drawArc2(C, 0, -rp_g, '#f1c40f');

    // Transverse Line of Action
    const [zla1x, zla1y] = toScr2(loa_p1[0], loa_p1[1]);
    const [zla2x, zla2y] = toScr2(loa_p2[0], loa_p2[1]);
    ctx.strokeStyle = '#e74c3c';
    ctx.lineWidth = 2.5;
    ctx.beginPath();
    ctx.moveTo(zla1x, zla1y);
    ctx.lineTo(zla2x, zla2y);
    ctx.stroke();

    ctx.fillStyle = '#ff7675';
    ctx.font = 'bold 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    ctx.fillText(`Line of Action (\u03C6t = ${calc.phi_t_deg.toFixed(2)}\u00B0)`, zla2x - 70, zla2y - 8);

    // Transverse Base Pitch p_bt Vector
    const pbt_p2 = [rp_p + calc.p_bt * Math.sin(phi_t), calc.p_bt * Math.cos(phi_t)];
    const [pbt1x, pbt1y] = toScr2(rp_p, 0);
    const [pbt2x, pbt2y] = toScr2(pbt_p2[0], pbt_p2[1]);
    ctx.strokeStyle = '#2ecc71';
    ctx.lineWidth = 3.0;
    ctx.beginPath();
    ctx.moveTo(pbt1x, pbt1y);
    ctx.lineTo(pbt2x, pbt2y);
    ctx.stroke();

    ctx.fillStyle = '#2ecc71';
    ctx.font = 'bold 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    ctx.fillText(`pbt = ${calc.p_bt.toFixed(2)} mm`, (pbt1x + pbt2x) / 2 + 8, (pbt1y + pbt2y) / 2);

    // Pitch Point P
    const [zppx, zppy] = toScr2(rp_p, 0);
    ctx.fillStyle = '#e74c3c';
    ctx.beginPath();
    ctx.arc(zppx, zppy, 5, 0, 2 * Math.PI);
    ctx.fill();

    // Contact HUD Card
    const cardX = s2_x + 12;
    const cardY = s2_y + 12;
    const cardW = 185;
    const cardH = 80;

    ctx.fillStyle = '#242433';
    ctx.strokeStyle = '#595973';
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.roundRect(cardX, cardY, cardW, cardH, 4);
    ctx.fill();
    ctx.stroke();

    ctx.fillStyle = '#ffffff';
    ctx.font = '9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';

    ctx.fillText(`Working Depth: hw = ${calc.hw.toFixed(2)} mm`, cardX + 8, cardY + 7);
    ctx.fillText(`Whole Depth: ht = ${calc.ht.toFixed(3)} mm`, cardX + 8, cardY + 21);
    ctx.fillText(`Clearance: c = ${calc.c_std.toFixed(3)} mm`, cardX + 8, cardY + 35);
    ctx.fillText(`Transverse CR: \u03B5\u03B1 = ${calc.eps_alpha.toFixed(3)}`, cardX + 8, cardY + 49);
    ctx.fillStyle = '#2ecc71';
    ctx.font = 'bold 9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(`Total CR: \u03B5\u03B3 = ${calc.eps_gamma.toFixed(3)} (Overlap \u03B5\u03B2 = ${calc.eps_beta.toFixed(2)})`, cardX + 8, cardY + 63);

    ctx.restore();
  }

  exportPNG() {
    return this.canvas.toDataURL('image/png');
  }
}
