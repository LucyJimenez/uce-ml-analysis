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
├── README.md
├── LICENSE
├── .gitignore
├── code/
├── data/
```

---

## 🛠️ Requirements

- R >= 4.2
- R packages:
  - `tidyverse` (2.0.0)
  - `caret` (6.0-94)
  - `xgboost` (1.7.8.1)
  - `randomForest` (4.7-1.2)
  - `glmnet` (4.1-8)
  - `pROC` (1.18.5)
  - `VennDiagram` (1.7.3)
  - `stringr` (1.5.1)
  - `viridis` (0.6.5)
  - `e1071` (1.7-14)
  - `data.table` (1.15.4)
  - `ggpubr` (0.6.0)
  - `reshape2` (1.4.4)
  - `pheatmap` (1.0.12)
  - `abind` (1.4-8)

Install dependencies with:

```R
install.packages(c(
  "tidyverse", "caret", "xgboost", "randomForest", "glmnet", "pROC",
  "VennDiagram", "stringr", "viridis", "e1071", "data.table",
  "ggpubr", "reshape2", "pheatmap", "abind"
))

---

## 📄 Related Publication

This work is part of the manuscript:

> Villegas, L.I., Jimenez, L., van der Sprong, J., Holovachov, O., Waldvogel, A.-M., & Schiffer, P.H. (2025).  
> *Ultraconserved elements coupled with machine learning approaches resolve the systematics in model nematode species.*  
> bioRxiv. https://doi.org/10.1101/2025.05.06.652396  
> Available at: [https://www.biorxiv.org/content/10.1101/2025.05.06.652396v1](https://www.biorxiv.org/content/10.1101/2025.05.06.652396v1)

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
