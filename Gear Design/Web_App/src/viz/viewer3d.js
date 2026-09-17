/**
 * 3D INTERACTIVE CAD VIEWER (Three.js)
 * High-performance 3D visualization with PBR shading, OrbitControls,
 * exploded view, dynamic meshing animation, wireframe, and camera presets.
 *
 * Author: Ahmed Majdy Ahmed
 */

import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

// Preallocated reusable matrices to eliminate per-frame allocations during animation
const _Ry90 = new THREE.Matrix4().makeRotationY(Math.PI / 2);
const _Rclock = new THREE.Matrix4();
const _Rz = new THREE.Matrix4();
const _Rphase = new THREE.Matrix4();
const _mat = new THREE.Matrix4();

export class GearViewer3D {
  constructor(containerElement) {
    this.container = containerElement;
    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.controls = null;

    this.calc = null;
    this.pinionMesh = null;
    this.gearMesh = null;

    this.isRotating = false;
    this.rotationSpeedRpm = 10;
    this.showWireframe = false;
    this.showAxes = false;
    this.viewMode = 'assembly';
    this.explodedFactor = 0.0;

    this.rootAssemblyGroup = null;
    this.gearGroup = null;
    this.sunGroup = null;
    this.carrierGroup = null;
    this.pinionGroups = [];
    this.pitchConesGroup = null;
    this.axesHelper = null;

    this.gearAngle = 0;

    this.initScene();
    this.initLights();
    this.initHelpers();
    this.animate = this.animate.bind(this);
    this.handleResize = this.handleResize.bind(this);

    window.addEventListener('resize', this.handleResize);
    this.animate();
  }

  initScene() {
    this.scene = new THREE.Scene();
    const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
    this.scene.background = new THREE.Color(isDark ? 0x0d111c : 0xf8fafc);

    const width = this.container.clientWidth || 800;
    const height = this.container.clientHeight || 600;

    this.camera = new THREE.PerspectiveCamera(40, width / height, 0.5, 3000);
    this.camera.position.set(-160, 120, 190);

    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false, powerPreference: 'high-performance' });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
    // Disable shadow maps to save GPU render targets (no meshes cast shadows)
    this.renderer.shadowMap.enabled = false;

    this.container.innerHTML = '';
    this.container.appendChild(this.renderer.domElement);

    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;
    this.controls.dampingFactor = 0.05;
    this.controls.maxDistance = 1500;
    this.controls.minDistance = 10;
    this.controls.target.set(0, 12, 0);
  }

  initLights() {
    const isDark = document.documentElement.getAttribute('data-theme') === 'dark';

    // Ambient light - strong enough to illuminate all sides
    const ambientLight = new THREE.AmbientLight(0xffffff, isDark ? 0.9 : 1.1);
    this.scene.add(ambientLight);

    // Top key light
    const mainLight = new THREE.DirectionalLight(0xffffff, isDark ? 1.4 : 1.6);
    mainLight.position.set(150, 250, 200);
    this.scene.add(mainLight);

    // Bottom-up fill light (illuminates the teeth & pinions from below, matching MATLAB's [-1 -1 0.5])
    const bottomLight = new THREE.DirectionalLight(0xffffff, isDark ? 1.3 : 1.5);
    bottomLight.position.set(-150, -200, 150);
    this.scene.add(bottomLight);

    // Front fill light
    const frontLight = new THREE.DirectionalLight(0xffffff, 0.8);
    frontLight.position.set(0, 50, 250);
    this.scene.add(frontLight);

    // Horizontal CAD Blueprint grid helper (matches MATLAB XY ground plane)
    this.gridHelper = new THREE.GridHelper(400, 40, isDark ? 0x2a3346 : 0xcbd5e1, isDark ? 0x1a2130 : 0xe2e8f0);
    this.gridHelper.position.y = -25;
    this.scene.add(this.gridHelper);
  }

  initHelpers() {
    this.axesHelper = new THREE.AxesHelper(60);
    this.axesHelper.visible = this.showAxes;
    this.scene.add(this.axesHelper);

    this.rootAssemblyGroup = new THREE.Group();
    // Rotate root assembly by -90° around X so MATLAB Z-axis (gear axis) maps to Three.js Y-axis (UP)!
    this.rootAssemblyGroup.rotation.x = -Math.PI / 2;
    this.scene.add(this.rootAssemblyGroup);
  }

  convertMeshToThreeBufferGeometry(customMesh) {
    const geometry = new THREE.BufferGeometry();
    const { vertices, faces } = customMesh;
    const n_faces = faces.length;
    const n_verts = vertices.length;

    // For bevel gears (Zerol, Spiral, Straight Bevel):
    // Accumulate smooth normals for lateral tooth flanks exclusively from lateral faces,
    // and assign dedicated planar normals [0, 0, 1] / [0, 0, -1] for heel and toe end caps.
    // Completely eliminates diagonal crease artifacts and surface faceting across the end caps.
    if (customMesh.isBevel) {
      const n_lat_faces = customMesh.n_lat_faces || 0;
      const latNormals = new Float32Array(n_verts * 3);
      const latCounts = new Uint16Array(n_verts);

      for (let f = 0; f < n_lat_faces; f++) {
        const [i1, i2, i3] = faces[f];
        const v1 = vertices[i1], v2 = vertices[i2], v3 = vertices[i3];
        const ax = v2[0] - v1[0], ay = v2[1] - v1[1], az = v2[2] - v1[2];
        const bx = v3[0] - v1[0], by = v3[1] - v1[1], bz = v3[2] - v1[2];
        let nx = ay * bz - az * by;
        let ny = az * bx - ax * bz;
        let nz = ax * by - ay * bx;
        const len = Math.sqrt(nx * nx + ny * ny + nz * nz) || 1;
        nx /= len; ny /= len; nz /= len;

        for (const idx of [i1, i2, i3]) {
          latNormals[idx * 3] += nx;
          latNormals[idx * 3 + 1] += ny;
          latNormals[idx * 3 + 2] += nz;
          latCounts[idx]++;
        }
      }

      for (let i = 0; i < n_verts; i++) {
        if (latCounts[i] > 0) {
          const nx = latNormals[i * 3];
          const ny = latNormals[i * 3 + 1];
          const nz = latNormals[i * 3 + 2];
          const len = Math.sqrt(nx * nx + ny * ny + nz * nz) || 1;
          latNormals[i * 3] /= len;
          latNormals[i * 3 + 1] /= len;
          latNormals[i * 3 + 2] /= len;
        }
      }

      const positions = [];
      const normals = [];
      const indices = [];

      for (let i = 0; i < n_verts; i++) {
        positions.push(vertices[i][0], vertices[i][1], vertices[i][2]);
        normals.push(latNormals[i * 3], latNormals[i * 3 + 1], latNormals[i * 3 + 2]);
      }

      for (let f = 0; f < n_lat_faces; f++) {
        indices.push(faces[f][0], faces[f][1], faces[f][2]);
      }

      for (let f = n_lat_faces; f < n_faces; f++) {
        const [i1, i2, i3] = faces[f];
        const v1 = vertices[i1], v2 = vertices[i2], v3 = vertices[i3];
        const ax = v2[0] - v1[0], ay = v2[1] - v1[1], az = v2[2] - v1[2];
        const bx = v3[0] - v1[0], by = v3[1] - v1[1], bz = v3[2] - v1[2];
        const nz = ax * by - ay * bx;
        const capNormZ = nz >= 0 ? 1.0 : -1.0;

        for (const idx of [i1, i2, i3]) {
          const v = vertices[idx];
          const newIdx = positions.length / 3;
          positions.push(v[0], v[1], v[2]);
          normals.push(0, 0, capNormZ);
          indices.push(newIdx);
        }
      }

      geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
      geometry.setAttribute('normal', new THREE.Float32BufferAttribute(normals, 3));
      geometry.setIndex(indices);
      return geometry;
    }

    // Cylindrical gears (Spur, Internal Spur, Helical):
    // 1. Calculate face normals and classify faces (cap vs lateral)
    const isBevel = false;
    const n_lat_faces = 0;
    const faceNormals = [];
    const isCap = new Uint8Array(n_faces);

    for (let f = 0; f < n_faces; f++) {
      const [i1, i2, i3] = faces[f];
      const v1 = vertices[i1], v2 = vertices[i2], v3 = vertices[i3];
      const ax = v2[0] - v1[0], ay = v2[1] - v1[1], az = v2[2] - v1[2];
      const bx = v3[0] - v1[0], by = v3[1] - v1[1], bz = v3[2] - v1[2];
      let nx = ay * bz - az * by;
      let ny = az * bx - ax * bz;
      let nz = ax * by - ay * bx;
      const len = Math.sqrt(nx * nx + ny * ny + nz * nz) || 1;
      nx /= len; ny /= len; nz /= len;
      faceNormals.push([nx, ny, nz]);

      if (Math.abs(nz) > 0.65) isCap[f] = 1;
    }

    // 2. Accumulate lateral normals ONLY among lateral faces
    const latNormals = new Float32Array(n_verts * 3);
    const latCounts = new Uint16Array(n_verts);

    for (let f = 0; f < n_faces; f++) {
      if (isCap[f]) continue;
      const [i1, i2, i3] = faces[f];
      const [nx, ny, nz] = faceNormals[f];
      for (const idx of [i1, i2, i3]) {
        latNormals[idx * 3] += nx;
        latNormals[idx * 3 + 1] += ny;
        latNormals[idx * 3 + 2] += nz;
        latCounts[idx]++;
      }
    }

    for (let i = 0; i < n_verts; i++) {
      if (latCounts[i] > 0) {
        const nx = latNormals[i * 3];
        const ny = latNormals[i * 3 + 1];
        const nz = latNormals[i * 3 + 2];
        const len = Math.sqrt(nx * nx + ny * ny + nz * nz) || 1;
        latNormals[i * 3] /= len;
        latNormals[i * 3 + 1] /= len;
        latNormals[i * 3 + 2] /= len;
      }
    }

    // 3. Build vertex attributes with split cap normals
    const positions = [];
    const normals = [];
    const indices = [];

    for (let i = 0; i < n_verts; i++) {
      positions.push(vertices[i][0], vertices[i][1], vertices[i][2]);
      normals.push(latNormals[i * 3], latNormals[i * 3 + 1], latNormals[i * 3 + 2]);
    }

    for (let f = 0; f < n_faces; f++) {
      if (!isCap[f]) {
        indices.push(faces[f][0], faces[f][1], faces[f][2]);
      }
    }

    // Dedicated cap vertices with pure planar normals [0, 0, 1] or [0, 0, -1]
    for (let f = 0; f < n_faces; f++) {
      if (isCap[f]) {
        const [i1, i2, i3] = faces[f];
        const nz = faceNormals[f][2];
        const capNormZ = nz >= 0 ? 1.0 : -1.0;

        for (const idx of [i1, i2, i3]) {
          const v = vertices[idx];
          const newIdx = positions.length / 3;
          positions.push(v[0], v[1], v[2]);
          normals.push(0, 0, capNormZ);
          indices.push(newIdx);
        }
      }
    }

    geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
    geometry.setAttribute('normal', new THREE.Float32BufferAttribute(normals, 3));
    geometry.setIndex(indices);
    return geometry;
  }

  disposeGears() {
    if (!this.rootAssemblyGroup) return;

    // Deep traverse and dispose all GPU geometries, attributes, and shader programs
    this.rootAssemblyGroup.traverse((child) => {
      if (child.isMesh) {
        if (child.geometry) {
          child.geometry.dispose();
        }
        if (child.material) {
          if (Array.isArray(child.material)) {
            child.material.forEach(m => m.dispose());
          } else {
            child.material.dispose();
          }
        }
      }
    });

    while (this.rootAssemblyGroup.children.length > 0) {
      this.rootAssemblyGroup.remove(this.rootAssemblyGroup.children[0]);
    }

    this.gearGroup = null;
    this.sunGroup = null;
    this.carrierGroup = null;
    this.pinionGroups = [];
  }

  updateGears(calc, pinionMesh, gearMesh, extraMeshes = {}) {
    this.calc = calc;
    this.pinionMesh = pinionMesh;
    this.gearMesh = gearMesh;

    // Deep dispose previous geometries and materials to prevent memory accumulation
    this.disposeGears();

    const isPlanetary = calc.gear_type === 'planetary';
    const gearGeo = this.convertMeshToThreeBufferGeometry(gearMesh);
    const pinionGeo = this.convertMeshToThreeBufferGeometry(pinionMesh);

    // Materials matching MATLAB's Gouraud shading:
    // Central Ring Gear: Bronze [0.78 0.52 0.28]
    const gearMaterial = new THREE.MeshStandardMaterial({
      color: 0xc88548,
      metalness: 0.45,
      roughness: 0.45,
      wireframe: this.showWireframe,
      side: THREE.DoubleSide
    });

    // Pinion palette matching MATLAB's exact colors:
    // [0.45 0.58 0.78; 0.55 0.75 0.55; 0.72 0.48 0.65; 0.78 0.68 0.45; 0.50 0.70 0.75; 0.70 0.55 0.55]
    const pinionColors = [
      0x7394c7, // Pinion 1: Steel Blue
      0x8cbf8c, // Pinion 2: Sage Green
      0xb87ba6, // Pinion 3: Dusty Lavender
      0xc7ad73, // Pinion 4: Warm Ochre
      0x7fc2cc, // Pinion 5: Cyan Teal
      0xcc8c8c, // Pinion 6: Terra Cotta
      0xa67bcc, // Pinion 7: Amethyst Violet
      0xc29b7f  // Pinion 8: Amber Bronze
    ];

    // 1. Build Ring Gear
    this.gearGroup = new THREE.Group();
    const gearMeshObj = new THREE.Mesh(gearGeo, gearMaterial);
    this.gearGroup.add(gearMeshObj);
    this.rootAssemblyGroup.add(this.gearGroup);

    // 1B. If Planetary, Build Sun Gear & Carrier
    if (isPlanetary) {
      const sunSourceMesh = extraMeshes.sunMesh || calc.sunMesh;
      if (sunSourceMesh) {
        const sunGeo = this.convertMeshToThreeBufferGeometry(sunSourceMesh);
        const sunMaterial = new THREE.MeshStandardMaterial({
          color: 0xdde2ea, // Metallic Chrome Silver
          metalness: 0.65,
          roughness: 0.35,
          wireframe: this.showWireframe,
          side: THREE.DoubleSide
        });
        this.sunGroup = new THREE.Group();
        const sunMeshObj = new THREE.Mesh(sunGeo, sunMaterial);
        this.sunGroup.add(sunMeshObj);
        this.rootAssemblyGroup.add(this.sunGroup);
      }

      const carrierSourceMesh = extraMeshes.carrierMesh || calc.carrierMesh;
      if (carrierSourceMesh) {
        const carrierGeo = this.convertMeshToThreeBufferGeometry(carrierSourceMesh);
        const carrierMaterial = new THREE.MeshStandardMaterial({
          color: 0x4e5461, // Sleek Graphite Grey
          metalness: 0.45,
          roughness: 0.45,
          transparent: true,
          opacity: 0.85,
          wireframe: this.showWireframe,
          side: THREE.DoubleSide
        });
        this.carrierGroup = new THREE.Group();
        const carrierMeshObj = new THREE.Mesh(carrierGeo, carrierMaterial);
        this.carrierGroup.add(carrierMeshObj);
        this.rootAssemblyGroup.add(this.carrierGroup);
      }
    }

    // 2. Build Multi-Pinions / Planets
    const n_pinions = isPlanetary ? (calc.K || 3) : (calc.n_pinions || 3);
    const Ry90 = new THREE.Matrix4().makeRotationY(Math.PI / 2);
    const Rclock = new THREE.Matrix4().makeRotationZ(Math.PI / (calc.Np || 18));

    for (let p = 0; p < n_pinions; p++) {
      const pColor = pinionColors[p % pinionColors.length];
      const pinMaterial = new THREE.MeshStandardMaterial({
        color: pColor,
        metalness: 0.35,
        roughness: 0.45,
        wireframe: this.showWireframe,
        side: THREE.DoubleSide
      });

      const pinionMeshObj = new THREE.Mesh(pinionGeo, pinMaterial);
      const pGroup = new THREE.Group();
      pGroup.add(pinionMeshObj);

      const angleOffset = (isPlanetary && calc.planet_angles && calc.planet_angles[p] !== undefined)
        ? calc.planet_angles[p]
        : (p * 2 * Math.PI) / n_pinions;
      const initialClock = (isPlanetary && calc.planet_clocks && calc.planet_clocks[p] !== undefined)
        ? calc.planet_clocks[p]
        : (angleOffset + angleOffset * ((calc.Ns || 12) / (calc.Np || 18)));
      const phaseAngle = angleOffset * ((calc.Ng || calc.Nr || 48) / (calc.Np || 18));

      pGroup.userData = {
        pinionIndex: p,
        angleOffset: angleOffset,
        initialClock: initialClock,
        phaseAngle: phaseAngle,
        meshObj: pinionMeshObj
      };

      this.pinionGroups.push(pGroup);
      this.rootAssemblyGroup.add(pGroup);
    }

    this.updateExplodedTransforms();
    this.updateVisibilityMode();
  }

  setExplodedFactor(val) {
    this.explodedFactor = Math.max(0, Math.min(1, Number(val) || 0));
    this.updateExplodedTransforms();
  }

  updateExplodedTransforms() {
    if (!this.calc || !this.gearGroup) return;

    const isPlanetary = this.calc.gear_type === 'planetary';
    const isSpur = this.calc.gear_type === 'spur' || this.calc.gear_type === 'helical';
    const isInternalSpur = this.calc.gear_type === 'internal_spur';
    const isBevel = !isSpur && !isInternalSpur && !isPlanetary;

    // PLANETARY GEAR: True Willis orbital kinematics and axial exploded view
    if (isPlanetary) {
      const C = this.calc.center_dist || 45.0;
      const Ns = this.calc.Ns || 12;
      const Np = this.calc.Np || 18;
      const Nr = this.calc.Nr || 48;
      const sep = (this.calc.F || 25.0) * 1.5 * this.explodedFactor;

      // Willis Kinematics:
      // Sun rotates at gearAngle, Carrier rotates at gearAngle / i_ratio
      const theta_s = this.gearAngle;
      const theta_c = theta_s / (1 + Nr / Ns);

      // Ring Gear is fixed to frame (stationary)
      this.gearGroup.position.set(0, 0, 0);
      this.gearGroup.rotation.set(0, 0, 0);

      // Carrier moves along -Z and rotates at carrier speed
      if (this.carrierGroup) {
        this.carrierGroup.position.set(0, 0, -sep * 1.4);
        this.carrierGroup.rotation.set(0, 0, theta_c);
      }

      // Sun moves along +Z and rotates at sun speed
      if (this.sunGroup) {
        this.sunGroup.position.set(0, 0, sep * 1.2);
        this.sunGroup.rotation.set(0, 0, theta_s + (Math.PI / Ns));
      }

      // Planets orbit with carrier and rotate on their pins
      for (let i = 0; i < this.pinionGroups.length; i++) {
        const pGroup = this.pinionGroups[i];
        const { angleOffset, initialClock, meshObj } = pGroup.userData;

        const currentOrbitAngle = angleOffset + theta_c;
        // Initial clocking plus relative spin: omega_p/c = -omega_c * (Nr / Np)
        const clock = initialClock !== undefined ? initialClock : (angleOffset + angleOffset * (Ns / Np));
        const currentSpinAngle = clock + theta_c * (1 - Nr / Np);

        meshObj.matrixAutoUpdate = true;
        meshObj.rotation.set(0, 0, currentSpinAngle);

        const r_curr = C + sep * 0.25;
        pGroup.position.set(
          Math.cos(currentOrbitAngle) * r_curr,
          Math.sin(currentOrbitAngle) * r_curr,
          sep * 0.4
        );
      }
      return;
    }

    // Single-Pair Exploded View matching MATLAB's ax2: Exploded View (Single Pair)
    if (isBevel && this.viewMode === 'single-pair') {
      const sep = (this.calc.Ao || 75.89) * 0.30;
      this.gearGroup.position.set(0, 0, -sep);
      this.gearGroup.rotation.z = 0;

      _Ry90.makeRotationY(Math.PI / 2);
      for (let i = 0; i < this.pinionGroups.length; i++) {
        const pGroup = this.pinionGroups[i];
        if (i === 0) {
          pGroup.visible = true;
          pGroup.userData.meshObj.matrix.copy(_Ry90);
          pGroup.userData.meshObj.matrixAutoUpdate = false;
          pGroup.position.set(sep, 0, 0);
        } else {
          pGroup.visible = false;
        }
      }
      return;
    }

    const baseDist = (isSpur || isInternalSpur) ? (this.calc.center_dist || 48.0) : (this.calc.Ao || 100.0);
    const sep = baseDist * 0.35 * this.explodedFactor;

    // Gear moves axially along -Z in MATLAB frame
    this.gearGroup.position.set(0, 0, -sep);

    if (isInternalSpur) {
      // INTERNAL SPUR: Pinions sit INSIDE Ring Gear at parallel radius C = (dg - dp) / 2
      const C = this.calc.center_dist || 48.0;
      const Ng = this.calc.Ng;
      const Np = this.calc.Np;

      for (let i = 0; i < this.pinionGroups.length; i++) {
        const pGroup = this.pinionGroups[i];
        const { angleOffset, meshObj } = pGroup.userData;

        // Internal mesh: same sense rotation
        const rot_phase = angleOffset + angleOffset * (Ng / Np);
        const currentPinionAngle = this.gearAngle * (Ng / Np) + rot_phase;

        meshObj.matrixAutoUpdate = true;
        meshObj.rotation.set(0, 0, currentPinionAngle);

        // Pinions elevate along +Z in exploded view
        pGroup.position.set(
          Math.cos(angleOffset) * C,
          Math.sin(angleOffset) * C,
          +sep
        );
      }
    } else if (isSpur) {
      // SPUR GEAR: Parallel shafts along Z (Three.js vertical)
      const C = this.calc.center_dist || (this.calc.dp + this.calc.dg) / 2;
      const Ng = this.calc.Ng;
      const Np = this.calc.Np;

      for (let i = 0; i < this.pinionGroups.length; i++) {
        const pGroup = this.pinionGroups[i];
        const { angleOffset, meshObj } = pGroup.userData;

        // Rotational phase clocking matching MATLAB:
        // rot_phase = pi + th_p - th_p * (Ng/Np) + (pi/Np)
        const rot_phase = Math.PI + angleOffset - angleOffset * (Ng / Np) + (Math.PI / Np);
        const currentPinionAngle = -this.gearAngle * (Ng / Np) + rot_phase;

        meshObj.matrixAutoUpdate = true;
        meshObj.rotation.set(0, 0, currentPinionAngle);

        // Radial displacement outward along shaft ray
        const r_curr = C + sep;
        pGroup.position.set(
          Math.cos(angleOffset) * r_curr,
          Math.sin(angleOffset) * r_curr,
          0
        );
      }
    } else {
      // ZEROL / SPIRAL / STRAIGHT BEVEL GEAR: 90° intersecting shafts
      _Ry90.makeRotationY(Math.PI / 2);
      _Rclock.makeRotationZ(Math.PI / this.calc.Np);

      for (let i = 0; i < this.pinionGroups.length; i++) {
        const pGroup = this.pinionGroups[i];
        const { angleOffset, phaseAngle, meshObj } = pGroup.userData;

        _Rz.makeRotationZ(angleOffset);
        const currentPinionAngle = -this.gearAngle * (this.calc.Ng / this.calc.Np) + phaseAngle;
        _Rphase.makeRotationZ(currentPinionAngle);

        _mat.identity();
        _mat.multiply(_Rz);
        _mat.multiply(_Ry90);
        _mat.multiply(_Rclock);
        _mat.multiply(_Rphase);

        meshObj.matrix.copy(_mat);
        meshObj.matrixAutoUpdate = false;

        // Radial displacement along shaft axis
        const expX = Math.cos(angleOffset) * sep;
        const expY = Math.sin(angleOffset) * sep;
        pGroup.position.set(expX, expY, 0);
      }
    }

    // Apply rotation to central gear
    this.gearGroup.rotation.z = this.gearAngle;
  }

  setViewMode(mode) {
    this.viewMode = mode;
    this.updateVisibilityMode();
    this.updateExplodedTransforms();
  }

  updateVisibilityMode() {
    if (!this.gearGroup) return;
    const hasSun = !!this.sunGroup;
    const hasCarrier = !!this.carrierGroup;

    if (this.viewMode === 'assembly') {
      this.gearGroup.visible = true;
      if (hasSun) this.sunGroup.visible = true;
      if (hasCarrier) this.carrierGroup.visible = true;
      this.pinionGroups.forEach(pg => (pg.visible = true));
    } else if (this.viewMode === 'single-pair') {
      this.gearGroup.visible = true;
      if (hasSun) this.sunGroup.visible = true;
      if (hasCarrier) this.carrierGroup.visible = false;
      this.pinionGroups.forEach((pg, idx) => (pg.visible = idx === 0));
    } else if (this.viewMode === 'sun') {
      this.gearGroup.visible = false;
      if (hasSun) this.sunGroup.visible = true;
      if (hasCarrier) this.carrierGroup.visible = false;
      this.pinionGroups.forEach(pg => (pg.visible = false));
    } else if (this.viewMode === 'carrier') {
      this.gearGroup.visible = false;
      if (hasSun) this.sunGroup.visible = false;
      if (hasCarrier) this.carrierGroup.visible = true;
      this.pinionGroups.forEach(pg => (pg.visible = false));
    } else if (this.viewMode === 'planet') {
      this.gearGroup.visible = false;
      if (hasSun) this.sunGroup.visible = false;
      if (hasCarrier) this.carrierGroup.visible = false;
      this.pinionGroups.forEach(pg => (pg.visible = true));
    } else if (this.viewMode === 'pinion') {
      this.gearGroup.visible = false;
      if (hasSun) this.sunGroup.visible = true;
      if (hasCarrier) this.carrierGroup.visible = false;
      this.pinionGroups.forEach(pg => (pg.visible = true));
    } else if (this.viewMode === 'ring' || this.viewMode === 'gear') {
      this.gearGroup.visible = true;
      if (hasSun) this.sunGroup.visible = false;
      if (hasCarrier) this.carrierGroup.visible = false;
      this.pinionGroups.forEach(pg => (pg.visible = false));
    }
  }

  setWireframe(enabled) {
    this.showWireframe = !!enabled;
    if (this.gearGroup) {
      this.gearGroup.children[0].material.wireframe = this.showWireframe;
      if (this.sunGroup && this.sunGroup.children[0]) {
        this.sunGroup.children[0].material.wireframe = this.showWireframe;
      }
      if (this.carrierGroup && this.carrierGroup.children[0]) {
        this.carrierGroup.children[0].material.wireframe = this.showWireframe;
      }
      this.pinionGroups.forEach(pg => {
        pg.userData.meshObj.material.wireframe = this.showWireframe;
      });
    }
  }

  setAxesVisible(enabled) {
    this.showAxes = !!enabled;
    if (this.axesHelper) this.axesHelper.visible = this.showAxes;
  }

  setRotation(enabled, rpm = 10) {
    this.isRotating = !!enabled;
    this.rotationSpeedRpm = Number(rpm) || 10;
  }

  setCameraPreset(preset) {
    if (!this.calc) return;
    const isPlanetary = this.calc.gear_type === 'planetary';
    const isInternalSpur = this.calc.gear_type === 'internal_spur';
    const isSpur = this.calc.gear_type === 'spur' || this.calc.gear_type === 'helical';
    const refDist = (isPlanetary || isInternalSpur)
      ? (this.calc.D_outer || (this.calc.r_rim ? this.calc.r_rim * 2 : 180))
      : (isSpur
          ? ((this.calc.dp + this.calc.dg) * 0.8 || 150)
          : Math.max((this.calc.dg || 144) + (this.calc.dp || 48), (this.calc.Ao * 2 || 150)));
    const d = Math.max(refDist * 1.35, 160);

    const targetY = (isSpur || isInternalSpur || isPlanetary) ? 0 : 12;

    switch (preset) {
      case 'iso':
        // Exactly matches MATLAB view(ax1, [-40 25])
        this.camera.position.set(-d * 0.58, d * 0.42, d * 0.69);
        this.controls.target.set(0, targetY, 0);
        break;
      case 'top':
        // Looking directly down onto the gear plane
        this.camera.position.set(0, d * 1.4, 0);
        this.controls.target.set(0, targetY, 0);
        break;
      case 'front':
        // Front view across the gear plane
        this.camera.position.set(0, 15, d * 1.2);
        this.controls.target.set(0, targetY, 0);
        break;
      case 'mesh-zoom':
        if (isInternalSpur) {
          const ptX = this.calc.rp_g || 72;
          this.camera.position.set(ptX + 25, 45, 30);
          this.controls.target.set(ptX, 0, 0);
        } else if (isSpur) {
          const ptX = (this.calc.dp || 48) / 2;
          this.camera.position.set(ptX + 25, 35, 25);
          this.controls.target.set(ptX, 0, 0);
        } else {
          this.camera.position.set((this.calc.dp || 48) * 1.1, 40, 30);
          this.controls.target.set((this.calc.dp || 48) * 0.6, 18, 0);
        }
        break;
      default:
        this.camera.position.set(-160, 120, 190);
        this.controls.target.set(0, 12, 0);
    }
    this.controls.update();
  }

  handleResize() {
    const width = this.container.clientWidth || 800;
    const height = this.container.clientHeight || 600;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }

  animate() {
    requestAnimationFrame(this.animate);

    if (this.isRotating && this.calc) {
      const deltaRad = (this.rotationSpeedRpm * 2 * Math.PI) / (60 * 60);
      this.gearAngle += deltaRad;
      this.updateExplodedTransforms();
    }

    this.controls.update();
    this.renderer.render(this.scene, this.camera);
  }

  setTheme(theme) {
    const isDark = theme === 'dark';
    this.scene.background = new THREE.Color(isDark ? 0x0d111c : 0xf8fafc);
    if (this.gridHelper) {
      this.scene.remove(this.gridHelper);
      if (this.gridHelper.geometry) this.gridHelper.geometry.dispose();
      if (this.gridHelper.material) this.gridHelper.material.dispose();
    }
    this.gridHelper = new THREE.GridHelper(400, 40, isDark ? 0x2a3346 : 0xcbd5e1, isDark ? 0x1a2130 : 0xe2e8f0);
    this.gridHelper.position.y = 0;
    this.scene.add(this.gridHelper);
  }

  zoomIn() {
    this.camera.position.multiplyScalar(0.82);
    this.controls.update();
  }

  zoomOut() {
    this.camera.position.multiplyScalar(1.22);
    this.controls.update();
  }

  resetView() {
    this.setCameraPreset('iso');
  }

  dispose() {
    window.removeEventListener('resize', this.handleResize);
    this.disposeGears();
    if (this.gridHelper) {
      if (this.gridHelper.geometry) this.gridHelper.geometry.dispose();
      if (this.gridHelper.material) this.gridHelper.material.dispose();
    }
    if (this.axesHelper) {
      if (this.axesHelper.geometry) this.axesHelper.geometry.dispose();
      if (this.axesHelper.material) this.axesHelper.material.dispose();
    }
    this.renderer.dispose();
  }
}
