
-- Step 2: Descriptive statistics for hospital length of stay (LOS)
-- Data source: MIMIC-IV, hosp.admissions
-- Cohort: EW EMER. and DIRECT EMER.
--
-- Purpose:
-- Examine the number of emergency admissions and the
-- distribution of hospital length of stay before further
-- data processing.
--
-- Results:
-- Number of admissions: 199432
-- Mean LOS: 6.05 days
-- Median LOS: 3.87 days
-- Minimum LOS: -0.95 days
-- Maximum LOS: 321.58 days
--
-- Negative length-of-stay values were identified
-- and subsequently excluded from the analysis.


SELECT
  COUNT(*) AS antall_innleggelser,
  ROUND(AVG(los_dager), 2) AS gjennomsnitt,
  ROUND(APPROX_QUANTILES(los_dager, 100)[OFFSET(50)], 2) AS median,
  ROUND(MIN(los_dager), 2) AS korteste_opphold,
  ROUND(MAX(los_dager), 2) AS lengste_opphold
FROM (
  SELECT
    DATETIME_DIFF(dischtime, admittime, MINUTE) / 1440.0 AS los_dager
  FROM `physionet-data.mimiciv_3_1_hosp.admissions`
  WHERE admission_type IN ('EW EMER.', 'DIRECT EMER.')
);
