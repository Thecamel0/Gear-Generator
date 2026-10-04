# 🎓 UTM Mechanical Engineering Defense Script & Delivery Guide

**Theme & Branding:** Universiti Teknologi Malaysia (UTM) Modern Technical Deck  
**Faculty:** Faculty of Mechanical Engineering, UTM  
**Target Audience:** Academic Evaluators (UTM), Industry Mentors, and Machine Design Leads  
**Candidate / Intern:** Ahmed Majdy Ahmed  
**Project:** Wind Turbine Blade Pitch Control Drivetrain — Multi-Architecture Gear Kinematics, ISO 6336 Stress & Manufacturing  
**Deliverable PPTX:** [`Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx`](file:///c:/Users/thepr/Desktop/Wind%20Turbine/Pitch%20Control%20System/Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx)  
**Dedicated ME Copy:** [`Wind_Turbine_Pitch_Control_System_Mechanical_Engineering_Presentation.pptx`](file:///c:/Users/thepr/Desktop/Wind%20Turbine/Pitch%20Control%20System/Wind_Turbine_Pitch_Control_System_Mechanical_Engineering_Presentation.pptx)  
**1-Click Launcher:** [`Launch_Presentation.bat`](file:///c:/Users/thepr/Desktop/Wind%20Turbine/Pitch%20Control%20System/Launch_Presentation.bat)

---

## ⏱️ 15-Minute Technical Defense Allotment

| Allotment | Slides Covered | Mechanical Engineering Focus |
|---|---|---|
| **Minutes 00:00 – 02:30** | **Slides 01 – 03** | Operating Conditions, Aerodynamic Load Cases & Drivetrain Architecture |
| **Minutes 02:30 – 05:30** | **Slides 04 – 06** | Gleason Zerol Theory, 60/40 Unequal Addendum & Willis Planetary Mechanics |
| **Minutes 05:30 – 08:30** | **Slides 07 – 08** | Tredgold Virtual Back-Cone Projection & ISO 6336 Stress Verification |
| **Minutes 08:30 – 11:00** | **Slides 09 – 10** | Backlash Tolerancing, Additive Manufacturing Offsets & Conclusions |
| **Minutes 11:00 – 15:00** | **Open Floor** | Technical Defense, Kinematic Derivations & Evaluator Q&A |

---

## 🎯 Evaluator Alignment Strategy

- **For UTM Academic Supervisors:** Emphasize mechanical machine design rigor, involute trigonometry, Gleason circular cutter derivations, ISO 6336 Method B safety factors, and Willis epicyclic speed equations.
- **For Industry Mentors:** Emphasize load allocation across multiple pinions, bearing life extensions from axial thrust cancellation, manufacturing tolerances, and functional 3D printing shrinkage compensation.

---

## 🖥️ Slide-by-Slide Presenter Script & Engineering Cue Cards

---

### Slide 01: Title & Project Identification
- **Timing:** 00:00 – 00:45 (45s)
- **Visual Focus:** Full Deep Maroon cover (`#721422`), Gold accent stripe (`#C58B12`), candidate metadata (**Ahmed Majdy Ahmed**), and Figure 1.1 (Epicyclic Planetary Assembly).
- **Verbatim Script:**
> *"Good morning, respected academic evaluators, supervisors, and mentors. My name is **Ahmed Majdy Ahmed** from the Faculty of Mechanical Engineering at Universiti Teknologi Malaysia. Today, I present the engineering defense of my internship project: the **Design, Kinematic Modeling, and Stress Analysis of a Precision Gear Drivetrain for Wind Turbine Blade Pitch Control**.*
>
> *Throughout this project, my focus has been on core mechanical machine design: resolving high cyclic fatigue, eliminating gearbox axial thrust forces, deriving Gleason circular cutter kinematics, verifying tooth durability under ISO 6336, and calibrating manufacturing backlash. Over the next ten minutes, I will guide you through our mechanical formulations, gear trade-offs, and experimental prototype validation."*

---

### Slide 02: Pitch Mechanism Operating Conditions & Aerodynamic Load Cases
- **Timing:** 00:45 – 02:00 (75s)
- **Visual Focus:** 3-column mechanical cards (Aerodynamic Pitch Demands, Structural Fatigue, Precision Limits).
- **Verbatim Script:**
> *"Slide 2 details the mechanical operating environment inside a wind turbine rotor hub:
> 1. **Aerodynamic Demands:** Utility-scale blades (up to 80 meters long) must continuously micro-pitch between 0° and 30° to maintain the rated power coefficient $C_p(\lambda, \beta)$. Crucially, during storm cut-out gusts exceeding 25 m/s, the mechanism must execute emergency braking by pitching 90 degrees into full feather within under 5 seconds—demanding pitch rates $\dot{\theta} \ge 8^\circ/\text{s}$ against extreme aerodynamic drag moments.
> 2. **Structural Fatigue:** Gravitational bending moments reverse 180 degrees on every rotor revolution, subjecting the drive pinion and blade root bearings to over $10^8$ cyclic stress reversals across a 20-year design life.
> 3. **Kinematic Precision:** High reduction ratios between 50:1 and 150:1 are required to step down 3,000 RPM servomotors to 0.5–2 RPM pitch velocity. Furthermore, normal backlash must be constrained to $j_t \le 0.05\text{ mm}$ to prevent aerodynamic stall flutter from exciting destructive blade resonances."*

---

### Slide 03: Pitch Drivetrain Topology: Central Ring to 3-Blade Pinions
- **Timing:** 02:00 – 03:00 (60s)
- **Visual Focus:** Left mechanical schematic & kinematic table; Right Figure 3.1 (3-pinion load-sharing drive at 120°).
- **Verbatim Script:**
> *"Slide 3 presents our drivetrain architecture.
> To control all three blades synchronously, we implemented a central driver ring gear ($N_g = 48$ teeth, $d_g = 144.0\text{ mm}$, $m = 3.0\text{ mm}$) that meshes simultaneously with three driven pinions ($N_p = 16$ teeth each) positioned at exact 120-degree spatial intervals around the perimeter.
> Notice the mechanical advantage of this load-sharing topology:
> Total input torque of $20\text{ N}\cdot\text{m}$ at 100 RPM is divided equally into three parallel load paths ($6.67\text{ N}\cdot\text{m}$ per mesh). With a transmission ratio of $i = 1:3$, each pinion delivers $2.16\text{ N}\cdot\text{m}$ at 300 RPM to its respective blade shaft at 97% mechanical efficiency. Tangential tooth load at the pitch interface is limited to $101.7\text{ N}$, reducing tooth root bending stress while guaranteeing identical pitch angles across all three blades."*

---

### Slide 04: Gleason Zerol Bevel Gear Theory & Axial Thrust Elimination
- **Timing:** 03:00 – 04:15 (75s)
- **Visual Focus:** Figure 4.1 (Zerol bevel mesh with curved teeth pointing to apex) and bottom comparison table (Straight vs. Zerol vs. Spiral).
- **Verbatim Script:**
> *"Slide 4 addresses one of the central mechanical decisions in this project: why choose Zerol bevel gears over straight or spiral bevels?
> - **Straight bevel gears** produce full line contact across the face width. When wind shear deflects the blade housing, load concentrates at the tooth edges, causing localized tooth chipping.
> - **Spiral bevel gears** provide smooth progressive overlap, but their 35° spiral angle generates massive axial thrust forces ($F_a$), requiring heavy duplex angular-contact bearings and stiffened housings.
> - **Our Zerol Solution:** A Zerol bevel gear is generated with a Gleason face-milling cutter of radius $r_c \approx 76.2\text{ mm}$, but the spiral angle at midface is strictly zero ($\beta_m = 0^\circ$).
> Looking at the force decomposition: because $\tan(\beta_m) = \tan(0^\circ) = 0$, the axial thrust force component cancels out ($F_a \approx 0$). The drive behaves like a straight bevel in terms of zero axial bearing load, while retaining the localized, elliptical crowned contact patch of spiral gears that easily accommodates shaft deflections without edge loading."*

---

### Slide 05: Gleason Unequal Addendum System & Tooth Profile Geometry
- **Timing:** 04:15 – 05:30 (75s)
- **Visual Focus:** Left 60/40 addendum derivation; Right derived bevel cone parameters table ($m = 3\text{ mm}, \Sigma = 90^\circ$).
- **Verbatim Script:**
> *"Slide 5 resolves a fundamental gear geometry constraint: tooth undercutting on small pinions.
> In standard 20° involute gearing, any pinion with fewer than 17 teeth suffers from undercutting during generation, where the hob removes active involute flank and thins the root fillet. Because our pitch pinion has only 16 teeth, standard proportions would fail in bending fatigue.
> We implemented the **Gleason Unequal Addendum System**:
> - We allocate 60% of working depth ($h_w = 6.0\text{ mm}$) to the pinion addendum ($a_p = 3.600\text{ mm}$) and 40% to the gear addendum ($a_g = 2.400\text{ mm}$).
> - Whole depth is $h_t = 6.564\text{ mm}$, with clearance $c = 0.564\text{ mm}$.
> This positive profile shift moves the active line of engagement away from the pinion base circle, completely eliminating undercutting while balancing specific sliding velocities to minimize adhesive wear."*

---

### Slide 06: Epicyclic Planetary Architecture & Willis Velocity Kinematics
- **Timing:** 05:30 – 06:45 (75s)
- **Visual Focus:** Left Willis kinematic equations; Right Figure 6.1 (isolated Sun & Planet gears) and force distribution box.
- **Verbatim Script:**
> *"For high-torque, compact nacelle packaging, we modeled the Epicyclic Planetary Drive:
> 1. **Willis Kinematics:** With a stationary ring gear ($\omega_r = 0$), the speed reduction ratio is $i = 1 + N_r / N_s = 1 + 48/12 = 5.0:1$. Output carrier torque reaches $72.75\text{ N}\cdot\text{m}$.
> 2. **Coaxial Assembly Rule:** We satisfy the coaxial center distance condition $N_r = N_s + 2N_p$ ($48 = 12 + 2\times 18$).
> 3. **Assembly Symmetry:** Symmetrical 120-degree planet spacing requires $(N_s + N_r)/K$ to be an integer. $(12 + 48)/3 = 20$, proving that all three planets mesh with identical tooth phase.
> 4. **Force Balancing:** Radial separating forces ($F_r = 111.2\text{ N}$) cancel out symmetrically at 120-degree vectors on the central sun shaft, completely relieving the motor shaft of transverse bending loads. We also incorporated the AGMA 6123 load-sharing factor $K_\gamma = 1.10$ to account for pitch runout."*

---

### Slide 07: 2D Contact Diagnostics & Tredgold Back-Cone Kinematics
- **Timing:** 06:45 – 07:45 (60s)
- **Visual Focus:** Figure 7.1 (2D contact mesh with base circles and pressure line of action $\alpha = 20^\circ$) and right derivation box.
- **Verbatim Script:**
> *"Slide 7 addresses our kinematic contact verification.
> Because bevel gear teeth lie on intersecting cones, projecting them onto a flat 2D screen skews geometry and produces false interference.
> We implemented the classical **Tredgold Virtual Back-Cone Transformation**:
> - We replace the spherical back-cone with equivalent virtual spur gears: $z_{vp} = 16 / \cos(18.435^\circ) = 16.86$ teeth, and $z_{vg} = 48 / \cos(71.565^\circ) = 151.79$ teeth, with virtual center distance $C_v = 252.99\text{ mm}$.
> - As shown in Figure 7.1, the pressure line of action is drawn tangent to both virtual base circles ($r_b = r_v \cos 20^\circ$).
> During simulation, the contact point tracks smoothly along this line, verifying a continuous transverse contact ratio $\epsilon_\alpha = 1.62$ (well above the 1.20 minimum threshold), confirming smooth conjugate action and zero tooth interference."*

---

### Slide 08: ISO 6336 Tooth Root Bending & Hertzian Contact Durability
- **Timing:** 07:45 – 09:00 (75s)
- **Visual Focus:** Left ISO 6336 Method B equations; Right material properties & safety factor table ($S_F = 2.15, S_H = 1.48$).
- **Verbatim Script:**
> *"Slide 8 presents our structural stress verification adhering strictly to ISO 6336 Method B:
> 1. **Tooth Root Bending Stress:** Using the Lewis form factor $Y_F = 2.45$, stress correction $Y_S = 1.72$, and dynamic factor $K_V = 1.15$, nominal bending stress on the pinion is $\sigma_F = 116.4\text{ MPa}$. Against quenched and tempered 4140 alloy steel ($\sigma_{FP} = 250\text{ MPa}$), this yields a bending safety factor $S_F = 2.15$, comfortably exceeding the ISO 1.4 minimum.
> 2. **Hertzian Surface Contact Stress:** Using zone factor $Z_H = 2.495$ and elasticity factor $Z_E = 189.8\text{ MPa}^{0.5}$, maximum contact pressure is $\sigma_H = 675.8\text{ MPa}$. Against carburized 8620 steel ($\sigma_{HP} = 1,000\text{ MPa}$), this yields a pitting safety factor $S_H = 1.48$ (exceeding the ISO 1.2 requirement).
> This guarantees that the gear teeth will withstand both root fracture and surface fatigue over 175,000 operating hours."*

---

### Slide 09: Backlash Tolerancing, PrintComp Offsets & Prototype Validation
- **Timing:** 09:00 – 10:00 (60s)
- **Visual Focus:** Left PrintComp shrinkage equations; Right Figure 9.1 (STEP AP214 B-Rep export) and 3 manufacturing metric boxes.
- **Verbatim Script:**
> *"Slide 9 bridges machine design theory to physical manufacturing.
> When 3D printing test prototypes in PETG or PLA-CF, cooling from 230°C causes 0.4%–0.7% radial thermal shrinkage, and bead expansion causes teeth to bind tightly if printed from nominal CAD models.
> Our **PrintComp Algorithm** applies two calibrated offsets:
> 1. **Flank Thinning ($0.10\text{ mm}$):** Applied normal to the involute profile to establish operating backlash ($j_n = 0.08–0.12\text{ mm}$) preventing tooth binding across wind turbine thermal swings (-20°C to +45°C).
> 2. **Bore Expansion ($+0.15\text{ mm}$):** Compensates for hole shrinkage, allowing standard 608 ball bearings to press-fit without secondary lathe reaming.
> Finally, Figure 9.1 shows our direct ISO 10303-21 STEP B-Rep solid model export, ready for SolidWorks assemblies and CNC hobbing toolpaths."*

---

### Slide 10: Conclusions, Mechanical Competencies Mastered & Acknowledgments
- **Timing:** 10:00 – 11:00 (60s)
- **Visual Focus:** 2-column layout (Mechanical Contributions vs. Competencies Mastered) and bottom Deep Maroon footer bar.
- **Verbatim Script:**
> *"In conclusion, this internship provided comprehensive, practical mastery of mechanical drive systems and machine design:
> - We formulated the kinematics of 7 pitch gear architectures.
> - We proved Gleason Zerol axial thrust cancellation and modeled Willis planetary kinematics.
> - We validated bending and contact stress safety factors ($S_F = 2.15, S_H = 1.48$) under ISO 6336.
> - We successfully fabricated functional, non-binding physical prototypes using PrintComp compensation.
>
> I want to express my sincere appreciation to the Faculty of Mechanical Engineering at Universiti Teknologi Malaysia (UTM), my academic supervisors, and mentors for their technical leadership throughout this project.
>
> Thank you for your time. The floor is now open for technical discussion and examination questions."*

---

## ❓ Technical Examination Q&A & Model Engineering Answers

### Q1: "Why does the Zerol bevel gear have zero axial thrust if its teeth are curved like a spiral bevel?"
**Authoritative Mechanical Answer:**
> *"In spiral bevel gears, the axial thrust force is directly proportional to $\tan\beta_m \sin\delta$, where $\beta_m$ is the spiral angle at the midface radius.
> In a Gleason Zerol bevel gear, the cutter center is positioned such that at the exact mean cone distance $A_m$, the tangent to the tooth curve points directly toward the cone apex. Therefore, the mean spiral angle is $\beta_m = 0^\circ$.
> Because $\tan(0^\circ) = 0$, the axial thrust component from the spiral angle vanishes ($F_a \approx 0$). The only residual axial load is the minor component from the 20° pressure angle acting on the cone slope ($F_t \tan\phi \sin\delta_p$), which is identical to a straight bevel gear and drastically smaller than a 35° spiral bevel."*

### Q2: "How does the Gleason 60/40 unequal addendum shift affect the contact ratio and sliding velocities?"
**Authoritative Mechanical Answer:**
> *"In a 16-tooth pinion mating with a 48-tooth gear, standard addenda ($1.0m$) produce excessive specific sliding at the pinion root and undercutting below the base circle.
> By enlarging the pinion addendum to $1.2m$ (60% of working depth) and reducing the gear addendum to $0.8m$ (40%), we:
> 1. Move the contact start point outside the pinion base circle radius ($r_b = 22.55\text{ mm}$), eliminating undercutting.
> 2. Equalize the maximum specific sliding velocities ($v_{slide} = |\omega_1 r_1 - \omega_2 r_2|$) between the approach and recess phases, reducing adhesive wear and scuffing risks.
> 3. Maintain a transverse contact ratio $\epsilon_\alpha = 1.62$, which ensures continuous two-pair tooth load sharing over 62% of the engagement cycle."*

### Q3: "In your planetary drive, what ensures that the planets do not collide with each other?"
**Authoritative Mechanical Answer:**
> *"We evaluate the adjacent planet tip clearance condition:
> The center-to-center distance between adjacent planets on the carrier pitch circle radius $C = (d_s + d_p)/2 = 30\text{ mm}$ is:
> $$d_{centers} = 2 C \sin\left(\frac{\pi}{K}\right) = 2(30)\sin\left(60^\circ\right) = 51.96\text{ mm}$$
> The planet tip diameter is $d_{a,p} = d_p + 2m = 36 + 6 = 42.00\text{ mm}$.
> The tip clearance is $51.96 - 42.00 = 9.96\text{ mm} > 0$, guaranteeing generous mechanical clearance between adjacent planet tips during high-speed rotation."*
