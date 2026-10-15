# Geometric PinT: 递归迭代的时间并行几何化与谱对角解耦

[English](README.md) | **简体中文**

[![Lean 4](https://img.shields.io/badge/Lean%204-v4.33.1-blue.svg)](https://leanprover.github.io/)
[![形式化验证](https://img.shields.io/badge/形式化验证-Mathlib4-green.svg)](https://github.com/leanprover-community/mathlib4)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE-Apache-2.0.txt)
[![License: Mulan PSL v2](https://img.shields.io/badge/License-木兰宽松%20v2-red.svg)](LICENSE-MulanPSL-2.0.txt)

> **破除时序依赖的 $O(N)$ 串行枷锁：基于彭罗斯时空刚性网格与谱对角化的时间并行（PinT）形式化理论与算法。**

---

## 💡 核心洞察：为什么我们要打破“二叉树”的思维定势？

在现代计算科学与深度学习中，从经典的马尔可夫链状态转移、ODE/PDE 时间步进，到如今最前沿的线性注意力机制与状态空间模型（SSM，如 Mamba、RWKV、S4），其底层本质都是一个一阶线性递推方程：
$$x_{k+1} = A x_k + b_k \quad (k = 0, \dots, N-1), \quad x_0 = c$$

### 1. 传统业界的固有路径：二叉树关联扫描（Associative Scan）
当前学术界和工业界在 GPU 上并行化递推时，**几乎人人都遵循二叉树规约路线**（如 Blelloch 算法、Kogge-Stone 树）：
* **树形阶段拖累**：必须经历严格自底向上的规约树（Up-Sweep / Reduce）和自顶向下的分发树（Down-Sweep / Distribute），至少需要 $2 \log_2 N$ 个强同步阶段。
* **硬件通信开销**：在 GPU 跨 Warp、跨 ThreadBlock 通信时，二叉树跨步长访存会带来严重的内存非对齐与通信延迟。

### 2. 我们的创新：空间静态几何化与谱特征解耦（Geometric PinT）
本项目跳出树形思维，引入**“彭罗斯阶梯 / 空间-时间刚性网络”**的高维几何视角：
* **动力学转空间静态**：
  不向前做“时间步进”，而是把 $N$ 个时序节点打包视为高维静态坐标：
  $$X = [x_0, x_1, \dots, x_{N-1}]^T$$
  时序递推关系被严格等价为空间带状刚性网络方程：
  $$K X = B$$
* **谱对角化彻底解耦（$O(1)$ 核心耗时）**：
  引入周期循环边界算子，利用离散傅里叶变换（DFT）将时空微分算子完全对角化：
  $$\hat{X}_k = (I - \omega_k A)^{-1} \hat{B}_k \quad (\omega_k = e^{-2\pi i k / N})$$
* **GPU 全并发质变**：
  在频域特征空间中，**$N$ 个时序坐标在 GPU 的 $N$ 个计算单元上完全独立、毫无串行等待地瞬间并行求逆（求解阶段仅需 $O(1)$ 步深度）**！

---

## 📐 Lean 4 机器形式化验证

本项目所有核心数学定理均使用 **Lean 4** 与 **Mathlib4** 完成严格的形式化推导与机械验证，**不留任何 `sorry`，不引入任何多余公理**。

源码文件：[`GeometricPinT/Basic.lean`](GeometricPinT/Basic.lean)

### 已完成形式化定理：

| 定理标识符 | 中文名称 | 数学意义 |
| :--- | :--- | :--- |
| `serialRecurrence` | 串行时序递推算子 | 严格定义一阶状态动力学 $x_{k+1} = A x_k + b_k$。 |
| `IsSpaceTimeSolution` | 时空静态平衡方程 | 定义空间静态刚性网络 $K X = B$ 的平衡条件。 |
| `spaceTime_soundness` | **空间静态化正确性定理** | 形式化严格证明串行轨迹在任意交换环 $R$ 上完全满足时空平衡方程。 |
| `spaceTime_uniqueness` | **时空解唯一性与全等定理** | 形式化证明全局时空方程的解具有唯一性，且与串行时序在每个坐标点绝对恒等。 |

---

## 🛠️ 项目架构与技术路线图

```
geometric-pint/
├── GeometricPinT/
│   ├── Basic.lean               # 时空静态网络方程与串行全等性定理 (已完成 ✅)
│   ├── Spectral.lean            # 循环矩阵对角化与 O(1) 频域坐标解耦
│   ├── Markov.lean              # 马尔可夫链稳态分布与瞬态加速
│   └── Executable.lean          # 纯函数式高并发求解器与基准测试
├── lakefile.lean                # Lean 4 构建脚本
├── lean-toolchain               # Lean 工具链版本声明
├── LICENSE                      # 双协议声明文件
├── LICENSE-Apache-2.0.txt       # Apache 2.0 英文官方协议
├── LICENSE-MulanPSL-2.0.txt     # 木兰宽松许可证 第2版 中英双语官方协议
├── README.md                    # 英文主页
└── README_CN.md                 # 中文研发手册 (当前文件)
```

---

## 🚀 编译与本地验证

本地需要安装 Lean 4（v4.33.1 或兼容版本）：

```bash
# 克隆仓库
git clone https://github.com/3y3y3y-huaiji/geometric-pint.git
cd geometric-pint

# 构建项目
lake build

# 机械证明独立验证
lake env lean GeometricPinT/Basic.lean
```

---

## 📜 双开源许可协议 (Dual Licensing)

本项目采用 **Apache License 2.0** 与 **木兰宽松许可证 第2版 (Mulan PSL v2)** 双许可协议。您可以根据实际需要选择任意一种协议使用、修改和分发本项目源码：

* [Apache License, Version 2.0](LICENSE-Apache-2.0.txt)
* [木兰宽松许可证，第2版 (Mulan PSL v2)](LICENSE-MulanPSL-2.0.txt)
