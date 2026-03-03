---
remark-name: ImaiKeane_replication
tier: 2
title-original-paper: "Intertemporal Labor Supply and Human Capital Accumulation"
github_repo_url: https://github.com/econ-ark/ImaiKeane_replication
notebooks:
  - Imai_and_Keane_2004.ipynb
dashboards: []
tags:
  - REMARK
  - Replication
  - Notebook
keywords:
  - labor supply
  - human capital accumulation
  - intertemporal elasticity of substitution
  - lifecycle model
  - dynamic programming
  - endogenous grid method
  - NLSY
---

# Replication of Imai and Keane (2004)

This repository replicates the lifecycle labor supply and savings model from Imai and Keane (2004), "Intertemporal Labor Supply and Human Capital Accumulation," published in the *International Economic Review*, Vol. 45, No. 2, pp. 601--641.

## Abstract

Imai and Keane (2004) solve and estimate a dynamic model in which agents optimally choose labor hours and consumption while accumulating human capital through learning by doing. Using white male data from the NLSY79, they estimate the model by maximum likelihood based on a full solution of the agents' continuous-variable dynamic programming problem. Their key finding is that the intertemporal elasticity of substitution (IES) in labor supply is 3.82---far higher than the conventional micro estimates of roughly 0.1 to 1.7 obtained from methods that ignore human capital accumulation. The downward bias in conventional estimates arises because the shadow wage (marginal rate of substitution between labor and consumption) is much higher than the observed wage for young workers, owing to the returns to human capital investment. The shadow wage profile is relatively flat even though observed wages rise steeply with age, which reconciles a high IES with the observed near-flat lifecycle hours profile.

## What This Replication Does

This replication solves the agent's dynamic programming problem for three parameter configurations that illustrate the model's core mechanisms:

1. **No uncertainty, no wage growth** (sigma=0, G=0): a deterministic baseline
2. **Uncertainty, no wage growth** (sigma>0, G=0): introduces stochastic human capital shocks
3. **Uncertainty with wage growth** (sigma>0, G>0): the full model with both shocks and exogenous wage growth

For each configuration the code solves for optimal policy functions (consumption, hours, end-of-period human capital, and market resources) via backward induction on a grid, then simulates 10,000 agents forward from age 20 to retirement. The resulting lifecycle profiles of assets, consumption, and labor supply are plotted and saved.
