# ⚙️ Wind Turbine Pitch Control System — Custom Gear Design Studio

**Comprehensive Multi-Gear Engineering Design, Simulation, & CAD Suite**

---

## 🌟 Overview

The **Wind Turbine Pitch Control System — Gear Design Studio** is an advanced engineering platform designed to model, analyze, and generate precision gear drives for utility-scale and research wind turbine blade pitch actuation systems.

The suite provides two synchronized design environments:
1. **🌐 Interactive Web CAD Studio (`Web_App`)**: Modern client-side Three.js CAD application featuring real-time 3D parametric assembly rendering, kinematic multi-pinion rotation simulation, 2D meshing & line-of-action diagrams, and instant client-side downloads of **STEP AP214**, **IGES 5.3**, **STL**, **SolidWorks VBA Macros (`.bas`)**, equations, and engineering reports.
2. **📐 Native MATLAB Engineering Suites (`Matlab_*`)**: Modular computational suites and interactive GUI (`zerol_bevel_gui.m`) implementing exact mathematical tooth surface generators, ISO 6336 / AGMA 2003 stress analysis, Lewis bending ratings, and direct disk CAD exporters.

---

## ⚙️ Supported Gear Architectures

The platform natively supports all six primary gear architectures used in wind turbine pitch and yaw drives:

| Gear Type | Kinematics & Configuration | Analytical Model | Primary Wind Turbine Application |
|---|---|---|---|
| **Zerol Bevel Gear** | $\Sigma = 90^\circ$ Orthogonal, Curved teeth, $\beta_m = 0^\circ$ | Gleason face-milling, localized contact crowning | Pitch actuator bevel box (zero axial thrust with spiral contact smoothness) |
| **Straight Bevel Gear** | $\Sigma = 90^\circ$ Orthogonal, Straight conical teeth | Tredgold spherical back-cone projection | Right-angle blade pitch gearbox |
| **Spiral Bevel Gear** | $\Sigma = 90^\circ$ Orthogonal, Spiral teeth ($\beta_m = 35^\circ$) | Curved circular spiral flank, high overlap ratio $\varepsilon_\beta > 2.0$ | Heavy-duty, low-noise pitch drives under extreme aerodynamic turbulence |
| **External Involute Spur Gear** | $\Sigma = 0^\circ$ Parallel shaft, 3-pinion planet cluster | Exact involute profile with root trochoid fillets | High-efficiency multi-pinion pitch drive |
| **Internal Spur Ring Gear** | $\Sigma = 0^\circ$ Parallel shaft, Internal annular teeth | Internal involute geometry, internal tooth clearance | Direct blade root pitch bearing slewing ring drive |
| **Helical Gear** | $\Sigma = 0^\circ$ Parallel shaft, Helical teeth ($\beta = 15^\circ - 20^\circ$) | Normal/transverse plane transformation, overlap $\varepsilon_\beta$ | High contact ratio, smooth-engagement pitch reducers |

---

## 📁 Repository Architecture & Directory Structure

```
Pitch Control System/
│
├── .gitignore                                 # Production ignore rules (Node, MATLAB, CAD, OS)
├── README.md                                  # Master system documentation & GitHub branch guide
│
├── Launch_Web_Studio.bat                      # [1-Click] Launch Web CAD Studio (all 6 gears)
├── Launch_MATLAB_GUI.bat                      # [1-Click] Launch Zerol Bevel MATLAB GUI
├── Launch_All_MATLAB_Suites.bat               # [1-Click] Interactive menu for all MATLAB suites
│
└── Gear Design/
    ├── Launch_Web_Studio.bat                  # Web App launcher
    ├── Launch_Zerol_Bevel_MATLAB.bat          # Zerol Bevel launcher
    ├── Launch_Straight_Bevel_MATLAB.bat       # Straight Bevel launcher
    ├── Launch_Spiral_Bevel_MATLAB.bat         # Spiral Bevel launcher
    ├── Launch_Spur_MATLAB.bat                 # Involute Spur launcher
    ├── Launch_Internal_Spur_MATLAB.bat        # Internal Spur launcher
    ├── Launch_Helical_MATLAB.bat              # Helical launcher
    ├── Launch_MATLAB_GUI.bat                  # Backward-compatible Zerol GUI launcher
    │
    ├── Web_App/                               # 🌐 Standalone Three.js + Vite Web Application
    │   ├── index.html                         # Engineering UI layout (dark mode glassmorphism)
    │   ├── package.json                       # Dependencies (three, jszip, vite)
    │   └── src/
    │       ├── main.js                        # App state, event orchestration, presets
    │       ├── engine/
    │       │   ├── gearGeometry.js            # Analytical math for all 6 gear geometries
    │       │   └── cadExporters.js            # STEP AP214, IGES 5.3, STL, SolidWorks macros
    │       ├── viz/
    │       │   ├── viewer3d.js                # Three.js 3D viewport & kinematics
    │       │   └── plot2d.js                  # 2D contact & line-of-action diagrams
    │       └── styles/
    │           └── app.css                    # Engineering styling & responsive UI
    │
    ├── Matlab_Zerol_Bevel/                    # 📐 Zerol Bevel Gear MATLAB Suite
    │   ├── zerol_bevel_gui.m                  # Native MATLAB GUI (uifigure)
    │   ├── zerol_bevel_design_v2.m            # Full design calculation & CAD export
    │   ├── DESIGN_DOCUMENTATION.md            # Detailed technical specification
    │   ├── Core/                              # Gleason tooth surface & 3D mesh reconstruction
    │   ├── Viz/                               # 2D contact & 3D assembly figure generators
    │   ├── Export/                            # STEP, IGES, STL, & Macro exporters
    │   └── PrintComp/                         # 3D printer shrinkage & clearance compensations
    │
    ├── Matlab_Straight_Bevel/                 # 📐 Straight Bevel Gear MATLAB Suite
    │   ├── straight_bevel_gear_design.m
    │   ├── Core/
    │   ├── Viz/
    │   └── Export/
    │
    ├── Matlab_Spiral_Bevel/                   # 📐 Spiral Bevel Gear MATLAB Suite
    │   ├── spiral_bevel_gear_design.m
    │   ├── Core/
    │   ├── Viz/
    │   └── Export/
    │
    ├── Matlab_Spur/                           # 📐 External Involute Spur Suite
    │   ├── spur_gear_design.m
    │   ├── Core/
    │   ├── Viz/
    │   └── Export/
    │
    ├── Matlab_Internal_Spur/                  # 📐 Internal Spur Ring Gear Suite
    │   ├── internal_spur_gear_design.m
    │   ├── Core/
    │   ├── Viz/
    │   └── Export/
    │
    ├── Matlab_Helical/                        # 📐 Helical Gear Suite
    │   ├── helical_gear_design.m
    │   ├── Core/
    │   ├── Viz/
    │   └── Export/
    │
    ├── Matlab_Legacy_V1/                      # 📦 Archived Early Prototypes
    │   ├── Core_Generators/
    │   ├── Exporters/
    │   ├── Solidworks/
    │   └── Prototype_Root/                    # Initial standalone root scripts
    │
    ├── Solidworks/                            # 🛠️ SolidWorks CAD Models, Macros & Equations
    │   ├── Exported_Models_Zerol_Bevel/       # Direct CAD exports for Zerol Bevel
    │   ├── Exported_Models_Straight_Bevel/    # Direct CAD exports for Straight Bevel
    │   ├── Exported_Models_Spiral_Bevel/      # Direct CAD exports for Spiral Bevel
    │   ├── Exported_Models_Spur/              # Direct CAD exports for Involute Spur
    │   ├── Exported_Models_Internal_Spur/      # Direct CAD exports for Internal Spur
    │   ├── Exported_Models_Helical/            # Direct CAD exports for Helical Gear
    │   ├── Macros/                            # Parameterized SolidWorks VBA macros
    │   ├── Parts/                             # SolidWorks .SLDPRT part files
    │   ├── Trails/                            # Iteration CAD files
    │   └── motion_simulation_guide.md
    │
    ├── 3D Printer/                            # 🖨️ Additive Manufacturing Files
    │   ├── Gcode/                             # Sliced G-codes
    │   └── STL/                               # Printable STL meshes
    │
    └── Research/                              # 📚 Engineering Papers & Reference Literature
```

---

## 🚀 1-Click Quick Start Launchers

Launch any part of the suite without typing terminal commands:

| Launcher Script | Description |
|---|---|
| 🌐 **`Launch_Web_Studio.bat`** | Starts the Vite dev server and opens **Gear Master CAD Studio** in your default browser (`http://localhost:5173`). |
| 📐 **`Launch_MATLAB_GUI.bat`** | Launches MATLAB and opens the native **Zerol Bevel GUI** (`zerol_bevel_gui.m`). |
| 📋 **`Launch_All_MATLAB_Suites.bat`** | Opens an interactive terminal menu to run any of the 6 MATLAB gear suites, the GUI, or the Web Studio. |

---

## 🌿 GitHub Branching Strategy (Version Management)

When publishing to GitHub, maintain separate branches for each application version to preserve developmental milestones and allow users to checkout specific editions:

```
                  ┌─► [v1.0-matlab-zerol]      (Initial Zerol Bevel MATLAB code & GUI)
                  │
[Initial Commit] ─┼─► [v2.0-matlab-suite]      (Full 6-gear modular MATLAB suites)
                  │
                  ├─► [v3.0-web-studio]        (Standalone Three.js Web CAD Studio)
                  │
                  └─► [main]                   (Unified Engineering Studio — Complete)
```

### Step-by-Step Git Commands to Initialize and Publish

#### 1. Initialize Git Repository
```bash
git init
git add .
git commit -m "feat: complete unified wind turbine pitch control gear studio (web + matlab suites)"
```

#### 2. Create the `v1.0-matlab-zerol` Branch (Baseline Zerol Bevel)
```bash
git checkout -b v1.0-matlab-zerol
# This branch represents the initial Zerol Bevel MATLAB GUI and calculation suite
git tag -a v1.0.0 -m "Release v1.0.0: Zerol Bevel Gear MATLAB Suite & SolidWorks Integration"
```

#### 3. Create the `v2.0-matlab-suite` Branch (Multi-Gear MATLAB Suites)
```bash
git checkout -b v2.0-matlab-suite
# This branch encompasses all 6 MATLAB suites (Zerol, Straight, Spiral, Spur, Internal, Helical)
git tag -a v2.0.0 -m "Release v2.0.0: Multi-Gear MATLAB Engineering Design Suites"
```

#### 4. Create the `v3.0-web-studio` Branch (Interactive Web CAD App)
```bash
git checkout -b v3.0-web-studio
# This branch focuses on the interactive browser-based Three.js CAD Studio
git tag -a v3.0.0 -m "Release v3.0.0: Interactive Web CAD Studio (Three.js + Vite)"
```

#### 5. Return to `main` and Push to GitHub
```bash
git checkout main
git remote add origin https://github.com/<YOUR_GITHUB_USERNAME>/<YOUR_REPOSITORY_NAME>.git
git branch -M main

# Push main branch and all version branches + tags
git push -u origin main
git push origin v1.0-matlab-zerol
git push origin v2.0-matlab-suite
git push origin v3.0-web-studio
git push --tags
```

---

## 💻 Tech Stack & Requirements

- **Web CAD Studio**: Node.js v18+, Vite, Three.js, JSZip.
- **MATLAB Suites**: MATLAB R2020b or newer (tested on R2024b) with Image Processing or Visualization Toolboxes.
- **CAD Interoperability**: SolidWorks 2020+, Autodesk Inventor, CATIA V5/V6, Fusion 360, Siemens NX, FreeCAD.
