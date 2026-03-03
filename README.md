# Imai and Keane (2004) Replication

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/econ-ark/ImaiKeane_replication/HEAD)

**Replication of**: Imai, S. and Keane, M. P. (2004), "Intertemporal Labor Supply and Human Capital Accumulation," *International Economic Review*, 45(2), 601--641. [DOI: 10.1111/j.1468-2354.2004.00138.x](https://doi.org/10.1111/j.1468-2354.2004.00138.x)

**Status**: Reproducible REMARK (Tier 2)

---

## Table of Contents

1. [Overview](#overview)
2. [The Model](#the-model)
3. [Installation](#installation)
4. [Reproduction Instructions](#reproduction-instructions)
5. [Code Organization](#code-organization)
6. [Output Guide](#output-guide)
7. [Parameter Modification Guide](#parameter-modification-guide)
8. [Data](#data)
9. [System Requirements](#system-requirements)
10. [Citation](#citation)
11. [License](#license)

---

## Overview

This repository replicates the lifecycle savings and labor supply model of [Imai and Keane (2004)](https://doi.org/10.1111/j.1468-2354.2004.00138.x) in Python. It is a contribution to the [REMARK](https://github.com/econ-ark/REMARK) project at [Econ-ARK](https://github.com/econ-ark).

### Research Question

Why do conventional microeconometric estimates of the intertemporal elasticity of substitution (IES) in labor supply yield values near zero, while macroeconomic models require values of 2 or higher to match business-cycle facts?

### Methods

Imai and Keane solve a continuous-variable dynamic programming problem in which agents choose consumption and labor hours each period, accumulating human capital through learning by doing. They estimate the model by maximum likelihood on white male data from the NLSY79, using a backward-induction algorithm with Chebyshev polynomial interpolation and Gauss-Hermite quadrature.

This replication solves the same dynamic programming problem for three progressively richer parameter configurations and simulates 10,000 agents forward from age 20 to retirement.

### Key Results

The estimated IES is 3.82, far above conventional micro estimates (0.1--1.7). The bias in conventional estimates arises because human capital accumulation makes the shadow wage (marginal rate of substitution between labor and consumption) much higher than the observed wage for young workers. The shadow wage profile is relatively flat over the lifecycle even though observed wages rise steeply, which reconciles a high IES with the near-flat observed hours profile.

---

## The Model

Agents maximize discounted expected lifetime utility over a working horizon from age 20 to 65:

$$E_t \sum_{\tau=t}^{T} \beta^\tau \left[ u(C_\tau, \tau) - v(h_\tau, \varepsilon_{2,\tau}) \right]$$

where consumption utility is CRRA with age effects, $u(C,t) = A(t) C^{a_1}/a_1$, and disutility of labor is $v(h, \varepsilon_2) = \varepsilon_2 b h^{a_2}/a_2$. The IES equals $1/(a_2 - 1)$.

The budget constraint is $A_{t+1} = (1+r)A_t + W_t h_t - C_t$, with wages $W_t = R_s K_t$ determined by a competitive rental rate on human capital $K_t$.

Human capital evolves via a production function that features complementarity between current hours and current human capital:

$$K_{t+1} = \left[k_0 + \delta K_t + A_0(1 + A_1(t-19))(B_1 + K_t)\left[(h_t + d_1)^\alpha - B_2(h_t + d_1)\right]\right] \varepsilon_{1,t+1}$$

The age effects $A(t)$ are a linear spline: $A(t) = C_0 C_1$ at age 20, rising to $C_0 C_2$ at age 25, then to $C_0$ at age 33 where it remains constant.

This replication imposes a no-borrowing constraint ($M_t > 0$) and handles the resulting credit-constrained region via interpolation at the boundary where the agent's consumption equals market resources.

---

## Installation

### Option 1: Docker (Recommended)

```bash
git clone https://github.com/econ-ark/ImaiKeane_replication.git
cd ImaiKeane_replication
docker build -t imai_keane .
docker run --rm imai_keane
```

### Option 2: Conda

```bash
git clone https://github.com/econ-ark/ImaiKeane_replication.git
cd ImaiKeane_replication
conda env create -f binder/environment.yml
conda activate imaikeane-replication
./reproduce.sh
```

### Option 3: pip (native)

```bash
git clone https://github.com/econ-ark/ImaiKeane_replication.git
cd ImaiKeane_replication
python -m venv .venv && source .venv/bin/activate
pip install -r binder/requirements.txt
./reproduce.sh
```

---

## Reproduction Instructions

### Full Reproduction

```bash
./reproduce.sh
```

**Expected runtime**: ~22 minutes on a modern laptop.

The script installs dependencies (if not already present) and runs `do_all.py`, which solves the model under three parameter configurations, simulates agents, and generates figures.

### Step-by-Step Manual Reproduction

```bash
pip install -r binder/requirements.txt
python do_all.py
```

`do_all.py` executes five stages:
1. Setup: load data, build grids, import auxiliary functions
2. Solve and simulate with no uncertainty and no wage growth (sigma=0, G=0)
3. Solve and simulate with uncertainty and no wage growth (sigma=0.05, G=0)
4. Solve and simulate with uncertainty and wage growth (sigma=0.05, G>0)
5. Generate and save comparison figures

### Interactive Exploration

Launch the Jupyter notebook for an annotated walkthrough:

```bash
jupyter notebook Imai_and_Keane_2004.ipynb
```

---

## Code Organization

```
.
├── do_all.py                     # Main orchestration script
├── reproduce.sh                  # Entry point for full reproduction
├── Imai_and_Keane_2004.ipynb     # Annotated Jupyter notebook
├── auxcode/
│   ├── solveproblem.py           # Backward-induction solver (EGM, credit constraints, quadrature)
│   ├── simulate.py               # Forward simulation of agents using policy functions
│   ├── getGrid.py                # Grid construction (log, linear, power spacing)
│   ├── discretize_log_distribution.py  # Log-normal quadrature nodes and weights
│   ├── getH.py                   # Optimal labor at the credit constraint boundary
│   └── getmeanpath.py            # Mean path and moment-matching utilities
├── data/
│   ├── startingHCmean97.csv      # Mean initial human capital (NLSY97)
│   ├── startingHCsd.csv          # Std dev of initial human capital
│   ├── startingAmean97.csv       # Mean initial assets
│   └── startingAsd.csv           # Std dev of initial assets
├── results/
│   ├── output1/                  # Scenario 1: sigma=0, G=0
│   ├── output2/                  # Scenario 2: sigma>0, G=0
│   ├── output3/                  # Scenario 3: sigma>0, G>0
│   └── figs/                     # Generated figures
├── binder/
│   ├── environment.yml           # Conda environment specification
│   └── requirements.txt          # Pinned pip dependencies
├── Dockerfile                    # Docker configuration
├── REMARK.md                     # REMARK metadata
├── CITATION.cff                  # Citation metadata
├── ImaiKeaneLifeCycle.bib        # BibTeX for the original paper
├── myst.yml                      # MyST documentation config
└── LICENSE                       # MIT License
```

---

## Output Guide

Running `reproduce.sh` generates the following outputs:

### Policy Functions and Simulation Data (per scenario)

Each `results/outputN/` directory contains:
- `policyC.npy` -- optimal consumption policy (grid: market resources x human capital x age)
- `policyH.npy` -- optimal hours policy
- `endk.npy` -- end-of-period human capital
- `policyM.npy` -- market resources mapping
- `simdf.csv` -- simulated panel of 10,000 agents (columns: age, assets, consumption, hours, human capital)

### Figures

- `results/figs/assets_consumption_across_age.png` -- mean assets and consumption by age across all three scenarios
- `results/figs/laborsupply_across_age.png` -- mean labor supply by age across all three scenarios

---

## Parameter Modification Guide

Key model parameters are defined in `do_all.py`:

**Preferences** (line 88):
- `phi` (=3): CRRA consumption parameter
- `beta` (=0.98): discount factor
- `gamma` (=0.75): related to age effects
- `sigma`: std dev of human capital shock (0 or 0.05)
- `alpha` (=0.02): human capital production elasticity
- `eta` (=1.25): disutility of labor curvature

**Grid resolution** (line 33):
- `nM` (=100): grid points for market resources
- `nK` (=100): grid points for human capital
- `nq` (=6): quadrature points

To run a quick test, reduce `nM` and `nK` to 20 and `nq` to 3.

---

## Data

The `data/` directory contains initial conditions drawn from the NLSY97:
- `startingHCmean97.csv` / `startingHCsd.csv`: mean and standard deviation of initial human capital by education group
- `startingAmean97.csv` / `startingAsd.csv`: mean and standard deviation of initial asset holdings by education group

These calibration targets pin down the distribution of agents at age 20.

---

## System Requirements

- **Python**: 3.10+
- **Key packages**: numpy 1.24, scipy 1.10, pandas 2.1, matplotlib 3.8, scikit-learn 1.3
- **RAM**: ~2 GB
- **Disk**: ~100 MB (results)
- **Runtime**: ~22 minutes (full), ~3 minutes (reduced grid)
- **Docker**: 20.0+ (if using containerized reproduction)

---

## Citation

If you use this code, please cite both the replication and the original paper. See `CITATION.cff` for machine-readable metadata.

**Original paper**:
> Imai, S. and Keane, M. P. (2004). "Intertemporal Labor Supply and Human Capital Accumulation." *International Economic Review*, 45(2), 601--641. DOI: [10.1111/j.1468-2354.2004.00138.x](https://doi.org/10.1111/j.1468-2354.2004.00138.x)

---

## License

This project is distributed under the MIT License. See [LICENSE](LICENSE) for details.
