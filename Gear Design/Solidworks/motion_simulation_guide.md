# Wind Turbine Pitch Control — SolidWorks Motion Simulation Guide

This guide details how to assemble the Zerol bevel gears and simulate dynamic pitch motion in **SolidWorks Motion Analysis**.

---

## 1. Assembly & Mating Setup

### Step 1: Insert Components into SolidWorks Assembly
1. Open SolidWorks and create a new **Assembly** (`.sldasm`).
2. Insert **`zerol_gear.stp`** (Central Ring Gear, 48 Teeth).
3. Insert **3 instances** of **`zerol_pinion.stp`** (Blade Pinions, 16 Teeth).

### Step 2: Coordinate Alignment & Standard Mates
1. **Ring Gear Mounting:**
   * Mate Ring Gear Central Axis $\rightarrow$ Assembly Top Axis (Z-axis).
   * Fix Ring Gear apex / face coincident with the horizontal XY plane ($Z = 0$).
2. **3 Pinions Positioning (120° Symmetry):**
   * Mate each Pinion shaft axis perpendicular to Ring Gear axis ($90^\circ$ orthogonal shaft angle).
   * Mate each Pinion axis to pass through the central coordinate apex $(0, 0, 0)$.
   * Use angular plane mates:
     * **Pinion 1:** $0^\circ$ (along $+X$ axis)
     * **Pinion 2:** $120^\circ$
     * **Pinion 3:** $240^\circ$
   * **Mounting Distance (Cone Apex to Back Cone Face):**
     * Pinion Mounting Distance: **$MD_p = 70.86\text{ mm}$**
     * Ring Gear Mounting Distance: **$MD_g = 21.72\text{ mm}$**

---

## 2. Setting Up Gear Mates

1. Go to **Mate > Mechanical Mates > Gear**.
2. Select the cylindrical shaft/revolute surface of **Ring Gear** and **Pinion 1**.
3. Set **Ratio**:
   $$\text{Ratio} = 48\text{ : }16 \quad (\text{or } 3\text{ : }1)$$
4. Check **Reverse** direction if required so the teeth rotate in mesh.
5. Repeat the **Gear Mate** for **Pinion 2** and **Pinion 3**.

---

## 3. SolidWorks Motion Analysis (Dynamic Study)

1. Turn on the **SolidWorks Motion** Add-In (`Tools > Add-Ins > SolidWorks Motion`).
2. Change study type from *Animation* to **Motion Analysis**.
3. **Add Rotary Motor to Ring Gear:**
   * Select Central Ring Gear axis.
   * Motion Type: **Constant Speed** $\rightarrow$ `15 RPM`.
   * (Alternatively, for a **Pitch Maneuver Study**, select **Oscillating** or **Data Points / Step**: $0^\circ \to 30^\circ$ pitch change).
4. **Add Resistance Torque (Blade Aerodynamic Load):**
   * Add a **Torque load** of `53.9 N*m` resisting each pinion shaft.
5. **Run Simulation:**
   * Set frame rate: `60 frames/sec`.
   * Click **Calculate** to simulate pitch motion, verify smooth tooth mesh engagement, and measure reaction forces.
