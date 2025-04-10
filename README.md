# 🧬 UCE-based Machine Learning for Nematode Genus Classification

This repository contains the computational and analytical work developed as part of the project **"Ultra-conserved elements for phylogenomic analysis in Nematoda"**, specifically focusing on the machine learning classification of nematode genera based on presence/absence matrices of Ultra-Conserved Elements (UCEs).

![R version](https://img.shields.io/badge/R-4.2%2B-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Status: Private](https://img.shields.io/badge/status-private-lightgrey)

## 🌱 Project Overview

Nematodes are one of the most diverse metazoan groups, but phylogenetic resolution and classification remain challenging. This project presents a computational framework that:

- Designs family-specific UCE probe sets (Panagrolaimidae and Rhabditidae)
- Constructs presence/absence matrices from UCE data
- Applies machine learning models to classify genera based on genomic patterns

> 🔬 This repository focuses on the **machine learning and data analysis** pipeline, including R and bash scripts, preprocessing, modeling, and result evaluation.

---

## 🗂️ Repository Structure

```bash
uce-ml-analysis/
├── README.md                  # this file
├── LICENSE
├── .gitignore
├── environment.yml            # (optional, for future reproducibility)
├── scripts/                   # R scripts organized by analysis step
│   ├── 01_prepare_matrix.R
│   ├── 02_clean_data.R
│   ├── 03_classification_model.R
│   └── utils/
│       └── plotting_functions.R
├── bash_scripts/              # Bash scripts for data preparation
│   └── download_data.sh
├── data/
│   ├── raw/                   # original input data
│   ├── intermediate/          # cleaned/processed data
│   └── results/               # model outputs and processed results
├── figures/                   # visualizations
│   ├── exploratory/
│   └── final/
└── reproducibility/
    └── run_analysis.R         # script to run the full analysis
```

---

## 🛠️ Requirements

- R >= 4.2
- R packages:
  - `tidyverse`
  - `caret`
  - `xgboost`
  - `randomForest`
  - `glmnet`
  - `pROC`

Install dependencies with:

```R
install.packages(c("tidyverse", "caret", "xgboost", "randomForest", "glmnet", "pROC"))
```

---

## 🚀 How to Run the Analysis

1. Clone the repository:

```bash
git clone https://github.com/<your-username>/uce-ml-analysis.git
cd uce-ml-analysis
```

2. Launch R and run the main pipeline script:

```R
source("reproducibility/run_analysis.R")
```

> 💡 Make sure raw data is placed in `data/raw/` or adjust the paths in the scripts accordingly.

---

## 📊 Key Results

- Presence/absence matrices of UCEs were used to train genus-level classifiers
- XGBoost outperformed other models (AUC ~0.999)
- Reduced UCE sets (46 for Rhabditidae, 63 for Panagrolaimidae) achieved high classification accuracy
- Feature selection improved interpretability and reduced dimensionality

---

## 📄 Related Publication

This work is part of the manuscript:

> Villegas, L., Jimenez, L., et al. (2025). *Ultra-conserved elements for phylogenomic analysis in Nematoda.*

---

## 👩‍💻 Authors

- **Lucy Jimenez** ([@LucyJimenez](https://github.com/LucyJimenez))
- In collaboration with Laura Villegas, Joelle van der Spröng, Oleksand Holovacho, Ann-Marie Waldvoge, and Philipp Schiffer

---

## 📜 License

[MIT License](LICENSE)

---

## 🔒 Repository Status

This repository is currently **private** and will be made public following manuscript acceptance and data deposition.
