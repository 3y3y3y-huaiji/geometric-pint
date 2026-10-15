import Mathlib.Algebra.Ring.Basic
import Mathlib.Algebra.BigOperators.Intervals
import Mathlib.Data.Fin.Basic
import Mathlib.Tactic.Ring

/-!
# Geometric Parallel-in-Time (PinT) Decoupling via Space-Time Static Networks

This module establishes the foundational mathematical bridge between:
1. **Serial Recurrence**: The classic sequential time-stepping dynamics
   $x_{k+1} = A x_k + b_k$ with serial dependency depth $O(N)$.
2. **Space-Time Static Rigid Network**: The global spatialized linear system
   $K X = B$, treating temporal steps as geometric spatial coordinates.

## Main Results:
- `serialRecurrence`: The sequential step-by-step dynamical evolution.
- `IsSpaceTimeSolution`: Global static equilibrium equations on the space-time grid.
- `spaceTime_soundness`: The sequential trajectory is a valid space-time static solution.
- `spaceTime_uniqueness`: Any static space-time solution is unique and matches
  the serial trajectory.
-/

namespace GeometricPinT

variable {R : Type*} [CommRing R]

/-- The classical serial recurrence relation:
`x₀ = c`
`x_{k+1} = A * x_k + b k` -/
def serialRecurrence (A : R) (b : ℕ → R) (c : R) : ℕ → R
  | 0 => c
  | k + 1 => A * serialRecurrence A b c k + b k

@[simp]
theorem serialRecurrence_zero (A : R) (b : ℕ → R) (c : R) :
    serialRecurrence A b c 0 = c := rfl

@[simp]
theorem serialRecurrence_succ (A : R) (b : ℕ → R) (c : R) (k : ℕ) :
    serialRecurrence A b c (k + 1) = A * serialRecurrence A b c k + b k := rfl

/-- Global space-time static network condition:
A spatialized trajectory `X : Fin N → R` satisfies the static system if:
- At coordinate 0: `X 0 = c`
- At coordinate `k + 1`: `X (k + 1) - A * X k = b k` -/
structure IsSpaceTimeSolution (N : ℕ) [NeZero N] (A : R) (b : ℕ → R) (c : R)
    (X : Fin N → R) : Prop where
  initial : X 0 = c
  step : ∀ (k : ℕ) (hk : k + 1 < N),
    X ⟨k + 1, hk⟩ - A * X ⟨k, Nat.lt_of_succ_lt hk⟩ = b k

/-- **Theorem 1 (Soundness of Space-Time Spatialization)**:
The serial dynamical trajectory strictly satisfies the static space-time rigid network system. -/
theorem spaceTime_soundness (N : ℕ) [NeZero N] (A : R) (b : ℕ → R) (c : R) :
    IsSpaceTimeSolution N A b c (fun i => serialRecurrence A b c i.val) where
  initial := rfl
  step := fun k hk => by
    change serialRecurrence A b c (k + 1) - A * serialRecurrence A b c k = b k
    rw [serialRecurrence_succ]
    ring

/-- **Theorem 2 (Uniqueness of Space-Time Solution)**:
Any static space-time solution is uniquely determined and identically matches
the serial recurrence at every coordinate $0 \le i < N$.
This formally validates that solving the global space-time static system is
mathematically identical to advancing $N$ steps of time-stepping. -/
theorem spaceTime_uniqueness (N : ℕ) [NeZero N] (A : R) (b : ℕ → R) (c : R)
    (X : Fin N → R) (hX : IsSpaceTimeSolution N A b c X) :
    ∀ (i : Fin N), X i = serialRecurrence A b c i.val := by
  intro ⟨i, hi⟩
  induction i with
  | zero =>
    have h0 : (⟨0, hi⟩ : Fin N) = 0 := rfl
    rw [h0, hX.initial]
    rfl
  | succ k ih =>
    have hk : k < N := Nat.lt_of_succ_lt hi
    have h_rec := hX.step k hi
    have h_ih := ih hk
    have h_step : X ⟨k + 1, hi⟩ = b k + A * X ⟨k, hk⟩ := sub_eq_iff_eq_add.mp h_rec
    rw [h_step, h_ih, serialRecurrence_succ]
    ring

end GeometricPinT
