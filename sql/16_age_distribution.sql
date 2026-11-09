
-- Step 16: Age distribution in the analytical cohort
-- Data sources: MIMIC-IV, hosp.admissions,
-- hosp.patients and hosp.labevents
--
-- Purpose:
-- Examine the age distribution among emergency admissions
-- with all six selected laboratory tests available.
--
-- Age is included as an additional predictor of hospital
-- length of stay (LOS).
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
-- and anchor_year from the patients table,
-- adjusted for the calendar year of admission.
--
-- The query calculates the number of admissions,
-- mean age, median age, minimum age and maximum age.
--
-- Results:
-- Number of admissions: 56917
-- Mean age: 62.6 years
-- Median age: 64 years
--
-- Age will be included alongside the six laboratory
-- measurements in the predictive model.


WITH akutt AS (
  SELECT
    a.subject_id,
    a.hadm_id,
    a.admittime,
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
)

SELECT
  COUNT(*) AS antall_innleggelser,
  ROUND(AVG(a.alder), 1) AS gjennomsnittsalder,
  APPROX_QUANTILES(a.alder, 100)[OFFSET(50)]
    AS medianalder,
  MIN(a.alder) AS laveste_alder,
  MAX(a.alder) AS hoyeste_alder
FROM akutt a
JOIN komplette k
  ON a.hadm_id = k.hadm_id;
