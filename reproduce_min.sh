#!/usr/bin/env bash
# Minimal reproduction: runs only the first scenario (sigma=0, G=0) with a
# coarser grid (nM=20, nK=20, nq=3) for quick validation (~2-3 minutes).

cd "$(dirname "$0")"

pip install -r ./binder/requirements.txt

python -c "
import os, sys
os.chdir('$(pwd)')
sys.path.append('./auxcode')

import numpy as np
import pandas as pd
from scipy import stats
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.interpolate import LinearNDInterpolator, interpn, RegularGridInterpolator
from scipy.optimize import curve_fit, fsolve, brentq, minimize
from sklearn.linear_model import LinearRegression

nM = 20
nK = 20
nq = 3
T = 66
t0 = 20
lifespan = T - t0
cmin = 1e-8
R = 1.04

startingHCmean = pd.read_csv('./data/startingHCmean97.csv')
startingHCsd = pd.read_csv('./data/startingHCsd.csv')
startingAmean = pd.read_csv('./data/startingAmean97.csv')
startingAsd = pd.read_csv('./data/startingAsd.csv')
start = pd.concat([startingHCmean, startingHCsd, startingAmean, startingAsd], axis=1)
start.columns = ['HCmean', 'HCsd', 'Amean', 'Asd']

with open('./auxcode/getGrid.py') as f: exec(f.read())
Mmin = 50 * np.ones(lifespan)
Mmax = np.linspace(1e5, 5e5, lifespan)
M_grid = np.ascontiguousarray(GetGrid(Mmin, Mmax, nM, 'power', 2)) * 1e-5
M_grid = np.vstack(((2 * cmin) * np.ones((1, M_grid.shape[1])), M_grid))
M_grid = np.vstack((M_grid, 200 * np.ones((1, M_grid.shape[1]))))

kmin = np.repeat([4], lifespan)
kmax = np.linspace(25, 70, lifespan)
k_grid = np.ascontiguousarray(GetGrid(kmin, kmax, nK, 'power', 1.5)) / 1e3
minwage = 0.00001
k_grid = np.vstack((minwage * np.ones((1, k_grid.shape[1])), k_grid))

with open('./auxcode/discretize_log_distribution.py') as f: exec(f.read())
with open('./auxcode/getH.py') as f: exec(f.read())
with open('./auxcode/solveproblem.py') as f: exec(f.read())
with open('./auxcode/simulate.py') as f: exec(f.read())

print('Minimal reproduction: solving scenario 1 (sigma=0, G=0) with coarse grid...')
params = dict(phi=3, beta=0.98, gamma=0.75, sigma=0.00, alpha=0.02, eta=1.25,
              growth=np.linspace(0.00, 0.00, 45))
out1 = solveProblem(M_grid, k_grid, **params)

params_sim = dict(numSims=1e3, simlifespan=65, startage=20, simseed=1032024,
                  A_mean=start.Amean[1], V_A=start.Asd[1],
                  HCt0_mean=start.HCmean[1], HCt0_sd=start.HCsd[1],
                  sigma=params['sigma'], growth=params['growth'])
simdf1 = simulate(out1[0], out1[1], out1[2], out1[3], params_sim)

os.makedirs('./results/output1', exist_ok=True)
np.save('./results/output1/policyC.npy', out1[0])
simdf1.to_csv('./results/output1/simdf.csv', index=False)
print('Minimal reproduction completed successfully.')
"
