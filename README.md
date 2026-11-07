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

Exploratory data analysis has been performed, and an initial analysis dataset containing 56,917 hospital admissions with complete laboratory measurements has been prepared.

Prediction modelling is the next stage of the project.

## Data availability

The underlying MIMIC-IV patient-level data are not included in this repository. Access to the dataset requires appropriate authorization through PhysioNet.
