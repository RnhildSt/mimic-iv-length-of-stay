
-- Step 19: Create the analytical dataset
-- Data sources: MIMIC-IV, hosp.admissions,
-- hosp.patients and hosp.labevents
--
-- Purpose:
-- Prepare the analytical dataset for predicting
-- hospital length of stay (LOS).
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
-- For each admission and laboratory test, the measurement
-- closest to admission time is selected.
--
-- Laboratory measurements are transformed into columns,
-- resulting in one row per hospital admission.
--
-- Variables:
-- subject_id: Patient identifier
-- hadm_id: Hospital admission identifier
-- alder: Estimated age at admission
-- kreatinin: Creatinine
-- glukose: Glucose
-- hemoglobin: Hemoglobin
-- kalium: Potassium
-- natrium: Sodium
-- leukocytter: White blood cell count
-- los: Hospital length of stay in days
--
-- Quality control:
-- A temporary table named analyse_data is created.
-- The query checks the total number of admissions,
-- distinct admission IDs and distinct patient IDs.
--
-- The resulting dataset will be used for predictive modelling.

CREATE TEMP TABLE analyse_data AS

WITH akutt AS (
  SELECT
    a.subject_id,
    a.hadm_id,
    a.admittime,
    p.anchor_age +
      (EXTRACT(YEAR FROM a.admittime) - p.anchor_year)
      AS alder,
    DATETIME_DIFF(a.dischtime, a.admittime, MINUTE)
      / 1440.0 AS los
  FROM `physionet-data.mimiciv_3_1_hosp.admissions` a
  JOIN `physionet-data.mimiciv_3_1_hosp.patients` p
    ON a.subject_id = p.subject_id
  WHERE a.admission_type IN ('EW EMER.', 'DIRECT EMER.')
    AND a.dischtime >= a.admittime
),

lab AS (
  SELECT
    a.hadm_id,
    l.itemid,
    l.valuenum,
    ROW_NUMBER() OVER (
      PARTITION BY a.hadm_id, l.itemid
      ORDER BY
        ABS(DATETIME_DIFF(
          l.charttime, a.admittime, SECOND
        )),
        l.charttime,
        l.labevent_id
    ) AS rn
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
),

valgte AS (
  SELECT hadm_id, itemid, valuenum
  FROM lab
  WHERE rn = 1
)

SELECT
  a.subject_id,
  a.hadm_id,
  a.alder,
  MAX(IF(v.itemid = 50912, v.valuenum, NULL))
    AS kreatinin,
  MAX(IF(v.itemid = 50931, v.valuenum, NULL))
    AS glukose,
  MAX(IF(v.itemid = 51222, v.valuenum, NULL))
    AS hemoglobin,
  MAX(IF(v.itemid = 50971, v.valuenum, NULL))
    AS kalium,
  MAX(IF(v.itemid = 50983, v.valuenum, NULL))
    AS natrium,
  MAX(IF(v.itemid = 51301, v.valuenum, NULL))
    AS leukocytter,
  a.los
FROM akutt a
JOIN valgte v
  ON a.hadm_id = v.hadm_id
GROUP BY
  a.subject_id, a.hadm_id, a.alder, a.los
HAVING COUNT(DISTINCT v.itemid) = 6;

SELECT
  COUNT(*) AS antall_innleggelser,
  COUNT(DISTINCT hadm_id) AS unike_innleggelser,
  COUNT(DISTINCT subject_id) AS unike_pasienter
FROM analyse_data;


