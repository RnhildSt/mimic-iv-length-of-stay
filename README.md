# mimic-iv-length-of-stay
Prediction of hospital length of stay using admission laboratory tests in MIMIC-IV
# Prediction of Hospital Length of Stay Using MIMIC-IV

## Project overview

This project is part of the NTNU course IT6117 – Health Data Analyses with AI.

The aim is to predict hospital length of stay (LOS) for emergency admissions using laboratory test results obtained around the time of admission.

## Dataset

The project uses MIMIC-IV version 3.1, a de-identified clinical database available through PhysioNet.

Data are extracted from the `hosp` module using Google BigQuery.

The following tables are used:
- `admissions`
- `patients`
- `labevents`
- `d_labitems`

## Study population

The study includes emergency hospital admissions identified by the admission types `EW EMER.` and `DIRECT EMER.`.

Admissions with negative length of stay are excluded.

## Variables

**Outcome variable:**
- Hospital length of stay, calculated as the difference between discharge time and admission time, measured in days.

**Predictor variables:**
- Age
- Creatinine
- Glucose
- Hemoglobin
- Potassium
- Sodium
- White blood cell count

Laboratory measurements are selected within a time window of six hours before to six hours after admission.

## Project workflow

1. Data extraction and cohort selection using SQL in Google BigQuery.
2. Exploratory data analysis (EDA).
3. Data preparation and quality assessment.
4. Development of prediction models.
5. Model evaluation and interpretation.

## Current status

Exploratory data analysis (EDA) and data preparation have been completed. The final analytical dataset contains 56,917 emergency hospital admissions with complete measurements for all six selected laboratory tests.

A Random Forest regression model has been developed to predict hospital length of stay using age and six laboratory measurements obtained around admission.

The model was evaluated using Mean Absolute Error (MAE) and compared with a simple baseline model predicting the median length of stay.

### Model results

| Model | MAE (days) |
|---|---|
| Baseline model (median prediction) | 4.63 |
| Random Forest regression (max depth = 3) | 5.07 |
| Random Forest regression (max depth = 5) | 5.02 |
| Random Forest regression (max depth = 10) | 4.99 |

The baseline model achieved a lower MAE than the Random Forest models. This indicates that the Random Forest models tested did not improve predictive accuracy compared with a simple median-based prediction.

The analyses, model development and evaluation are documented in `notebooks/MIMIC_IV_Random_Forest_Analysis_ryddig.ipynb`.

## Data availability

The underlying MIMIC-IV patient-level data are not included in this repository. Access to the dataset requires appropriate authorization through PhysioNet.
