# -TotTag-Feasibility-Acceptability

De-identified data and Stata code accompanying:

Barnett, W., Bouthillier, S., Piersiak, H. A., Rasmussen, H. F., Brown, V., & Humphreys, K. L. (2026). Measuring caregiver–child proximity in daily life: Feasibility and acceptability of the TotTag wearable sensor. Infant Behavior and Development. https://doi.org/10.1016/j.infbeh.2026.102221

Overview

This repository provides the de-identified analytic dataset and Stata code sufficient to reproduce the descriptive statistics, correlation matrix, regression model, and supplemental tables reported in the manuscript. The study evaluated the feasibility and acceptability of the TotTag — an ultra-wideband (UWB) wearable proximity sensor — deployed in the homes of 129 families with 12-month-old infants for a 7-day recording period.

## Repository structure

```
.
├── README.md
├── LICENSE
├── data/
│   ├── tottag_acceptability_data.csv    ← de-identified analytic dataset (N = 129, wide format)
│   ├── tottag_acceptability_data.dta    ← Stata version of the same data
│   └── codebook.md                      ← variable definitions and value labels
└── code/
    └── tottag_analysis.do               ← reproduces Tables 1–5 and Supplemental Tables S2, S3, S6
```

## Reproducing the analyses

**Software.** All analyses were conducted in Stata 18.0. Earlier versions of Stata (≥ 15) should also work without modification.

**Steps:**

1. Clone the repository (or download as a ZIP).
2. Open Stata and `cd` into the repository directory.
3. Run: tottag_analysis.do

Console output will reproduce cell values for Tables 1–5 (manuscript) and Tables S2, S3, and S6 (supplement).

**Expected runtime:** under one minute on a standard laptop.

## Data-sharing notes

The dataset in this repository is a de-identified version of the original working file. The following changes were made before public release:

1. **Participant IDs** were replaced with sequential anonymized identifiers (`anon_id`). The mapping between original study IDs and `anon_id` is retained on the lab's secure server.
2. **Free-text responses** to open-ended items (items 2, 13, and 15) were removed. Thematic summaries of these responses are reported in Supplemental Table S4 of the manuscript.
3. **Specific dates** (dates of birth, TotTag deployment dates) were removed. Child age is provided in months (`age_months`); deployment timing is provided as a tertile indicator (`deploy_tertile`).
4. **Race and ethnicity variables** for individual caregivers are aggregated at the study level in Table 1 of the manuscript but are not included in this repository.

If you identify a privacy concern in the dataset, please contact the corresponding author.

## License

- **Data** are released under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) (public domain dedication).
- **Code** is released under the [MIT License](https://opensource.org/licenses/MIT).

## Citation

If you use these materials, please cite the paper (see top of this file).

## Acknowledgements

This work was supported by the National Institutes of Health (K01HD112541 to WB), the National Science Foundation (2322837), and the National Institutes of Health (R21HD111744). We thank the families who participated and the study team members who contributed to data collection, processing, and protocol refinement.

## Changelog

- **v1.0** (2026-07-20) — Initial release alongside publication.

