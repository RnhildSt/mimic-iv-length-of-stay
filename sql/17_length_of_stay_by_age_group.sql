
-- Step 17: Length of stay by age group
-- Data sources: MIMIC-IV, hosp.admissions,
-- hosp.patients and hosp.labevents
--
-- Purpose:
-- Investigate how hospital length of stay (LOS)
-- varies across different age groups.
--
-- Inclusion criteria:
-- Emergency admissions (EW EMER. and DIRECT EMER.)
-- Non-negative hospital length of stay
-- All six selected laboratory tests available
-- Non-null numerical laboratory values
-- Measurements within 6 hours before or after admission
--
-- Method:
-- Age at admission is estimated using anchor_age
-- and anchor_year from the patients table.
--
-- Admissions are divided into four age groups:
-- 18-39 years
-- 40-59 years
-- 60-79 years
-- 80 years and older
--
-- For each age group, the query calculates:
-- Number of admissions
-- Mean length of stay
-- Median length of stay
--
-- Purpose of the analysis:
-- Explore whether length of stay differs by age
-- and assess the relevance of including age
-- as a predictor in the predictive model.


WITH akutt AS (
  SELECT
    a.subject_id,
    a.hadm_id,
    a.admittime,
    DATETIME_DIFF(a.dischtime, a.admittime, MINUTE)
      / 1440.0 AS los,
    p.anchor_age +
      (EXTRACT(YEAR FROM a.admittime) - p.anchor_year)
      AS alder
  FROM `physionet-data.mimiciv_3_1_hosp.admissions` a
  JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
    ON a.subject_id = p.subject_id
  WHERE a.admission_type IN ('EW EMER.', 'DIRECT EMER.')
    AND a.dischtime >= a.admittime
),

komplette AS (
  SELECT
    a.hadm_id
  FROM akutt a
  JOIN `physionet-data.mimiciv_3_1_hosp.labevents` l
    ON a.hadm_id = l.hadm_id
  WHERE l.itemid IN (
    50912, 50931, 51222,
    50971, 50983, 51301
  )
    AND l.charttime BETWEEN
      DATETIME_SUB(a.admittime, INTERVAL 6 HOUR)
      AND DATETIME_ADD(a.admittime, INTERVAL 6 HOUR)
    AND l.valuenum IS NOT NULL
  GROUP BY a.hadm_id
  HAVING COUNT(DISTINCT l.itemid) = 6
),

aldersgrupper AS (
  SELECT
    a.los,
    CASE
      WHEN a.alder BETWEEN 18 AND 39 THEN '18-39'
      WHEN a.alder BETWEEN 40 AND 59 THEN '40-59'
      WHEN a.alder BETWEEN 60 AND 79 THEN '60-79'
      ELSE '80+'
    END AS aldersgruppe
  FROM akutt a
  JOIN komplette k
    ON a.hadm_id = k.hadm_id
)

SELECT
  aldersgruppe,
  COUNT(*) AS antall,
  ROUND(AVG(los), 2) AS gjennomsnitt_los,
  ROUND(
    APPROX_QUANTILES(los, 100)[OFFSET(50)], 2
  ) AS median_los
FROM aldersgrupper
GROUP BY aldersgruppe
ORDER BY aldersgruppe;

