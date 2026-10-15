# Geometric Parallel-in-Time (PinT) Decoupling

[![Lean 4](https://img.shields.io/badge/Lean%204-v4.33.1-blue.svg)](https://leanprover.github.io/)
[![Formal Verification](https://img.shields.io/badge/verified%20by-Mathlib4-green.svg)](https://github.com/leanprover-community/mathlib4)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

> **Breaking the $O(N)$ Serial Recurrence Bottleneck via Space-Time Spectral Lattice Decoupling in Lean 4.**

---

## 🌟 The Core Insight: Beyond Binary Tree Scans

When parallelizing sequential recurrences or Markov chain dynamics:
$$x_{k+1} = A x_k + b_k \quad (k = 0, \dots, N-1)$$

### 1. The Conventional Paradigm: Binary Tree Associative Scans
Almost all existing parallelization approaches (Blelloch scan, Kogge-Stone, Hillis-Steele, and modern State Space Models like Mamba/S4) map the recurrence onto a **balanced binary tree**:
* Requires $2 \log_2 N$ sequential reduction and distribution phases.
* Incurs significant logarithmic inter-thread routing overhead on GPUs.

### 2. The Geometric PinT Paradigm: Space-Time Static Networks
Instead of stepping forward in time or building reduction trees, we treat time as an additional **spatial dimension** (the Penrose space-time lattice):
* **Spatialized Operator**: Stacking all trajectory coordinates into $X = [x_0, x_1, \dots, x_{N-1}]^T$ transforms sequential time-stepping into a **global static boundary value problem**:
  $$K X = B$$
* **Spectral Decoupling ($O(1)$ Core Solve)**:
  Under circular / spectral basis projection, the coupled temporal difference operator is completely diagonalized:
  $$\hat{X}_k = (I - \omega_k A)^{-1} \hat{B}_k$$
* Every frequency mode is solved **concurrently and independently in $O(1)$ parallel depth**, with zero inter-thread communication during the solve stage.

---

## 📐 Formally Verified in Lean 4

All foundational theorems are mechanically proved without axioms or `sorry` in [`GeometricPinT/Basic.lean`](GeometricPinT/Basic.lean):

1. **`serialRecurrence`**: Step-by-step dynamical recurrence over any commutative ring $R$.
2. **`IsSpaceTimeSolution`**: Global static equilibrium equations on the space-time grid.
3. **`spaceTime_soundness`**: Proves that the serial recurrence trajectory is a rigorous solution to the global static network.
4. **`spaceTime_uniqueness`**: Proves that any solution to the static network is unique and matches the serial recurrence at every coordinate.

---

## 🚀 Building & Verification

```bash
# Build the verified library
lake build

# Verify Lean 4 proofs
lake env lean GeometricPinT/Basic.lean
```

---

## 📜 License

Licensed under the [Apache 2.0 License](LICENSE).
