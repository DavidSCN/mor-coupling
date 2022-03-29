# mor-coupling

[![Building](https://github.com/DavidSCN/mor-coupling/actions/workflows/building.yml/badge.svg)](https://github.com/DavidSCN/mor-coupling/actions/workflows/building.yml)

This project uses the coupling library [preCICE](https://precice.org/) in order to couple PDE (Partial Differential Equation) solver packages relying on model order reduction techniques as provided by [pyMOR](https://pymor.org/). The two coupled PDE packages are in particular [FEniCS](https://fenicsproject.org/) and [deal.II](https://dealii.org/).

## Description

The repository contains a ready-to-run example in the `example` directory. It consists of a simplified and adapted version of the [partitioned-heat tutorial](https://precice.org/tutorials-partitioned-heat-conduction.html), where we split a domain artificially into two parts, solve in each subdomain the same problem and carry out a Dirichlet-Neumann coupling across a common coupling interface in order to recover a global solution. However, instead of the time-dependent heat equation, we solve here a stationary Laplace problem with Dirichlet boundary conditions on the left side of the domain `u_D = 3` and homogeneous Dirichlet boundary conditions on `u_D = 0` on the right side of the domain. The left side ('Dirichlet participant') is computed using FeniCS and the right side ('Neumann participant') is computed using deal.II.

In a first step, the model order reduction was applied to the deal.II (Neumann) participant. Since deal.II is written in `C++` and the model order reduction through pyMOR is carried out through the python programming language, we compile the `C++` functions of deal.II into a python compatible library using `pybin11`, which is already included as a submodule within this project. Therefore, the deal.II source code can be found in the `lib` directory and the function calls for the deal.II heat problem as well as the pyMOR model order reduction are located in `example/neumann-reduced/heat_equation_reduced.py`. Although model order reduction with FEniCS is supported by pyMOR, we don't apply any model order reduction on the FEniCS side, i.e., the example code `example/dirichlet-fenics/heat.py` solves always the full order model.

In order to apply the model order reduction on the Neumann side, we parametrize the diffusion coefficient within this participant: we split the squared domain on the right side once more into a square and an L-shaped remainder. In the offline phase, we perform multiple coupled simulations between the Dirichlet and Neumann participant using a different diffusion coefficient in the sub-square on the Neumann side. The FEniCS side computes during the offline phase always the same computational setup. By default, the sub-square with the varying diffusion coefficient is part of the coupling interface. The motivation for such a setup is the runtime reduction for the reduced order model during the online phase: Building the deal.II code in `Release` mode results in a speedup factor of around 10 for 8 global refinements, which corresponds to 66.049 degrees of freedom.

## Installation

The setup requires a variety of software packages. Install [`preCICE`](https://precice.org/installation-overview.html) (v2.4.0 or greater), [`pyMOR`](https://github.com/pymor/pymor#installation-via-pip) (at least version [ef3242c](https://github.com/pymor/pymor/commit/ef3242c9aebd9c1046fb6d2b80d414284abca1ad) as set in the `requirements.txt` is required), [`FEniCS`](https://fenicsproject.org/download/archive/) (legacy version as set in the `requirements.txt`) and [`deal.II`](https://dealii.org/current/readme.html) (v9.2 or greater). Afterwards, install the [`pyMOR-deal.II wrapper`](https://github.com/pymor/pymor-deal.II) using

```bash
git clone --recurse-submodules https://github.com/pymor/pymor-deal.II.git
python3 -m pip install ./pymor-deal.II
```
and clone this repository using

```bash
git clone --recurse-submodules https://github.com/DavidSCN/mor-coupling.git
```

The deal.II-based executable can be compiled using

```bash
cmake -B ./mor-coupling/build -S ./mor-coupling
cmake --build ./mor-coupling/build
```

## Running a simulation

The example setup is located in the `example` directory. In a first step, the offline phase, multiple coupled simulations need to be performed in order to generate the parametrized reduced basis later on. By default the coupled simulation is performed `5` times using uniform samples of the diffusion coefficient. Afterwards, `5` random diffusion coefficients are used in order to compare the full order model and the reduced order model. In order to execute all simulations, execute

```bash
./run.sh -n 15
```

from the `dirichlet-fenics` directory and

```bash
python3 heat_equation_reduced.py
```

from the `neumann-reduced` directory. The Neumann participant prints out statistics regarding the error and speedup of the reduced basis.
