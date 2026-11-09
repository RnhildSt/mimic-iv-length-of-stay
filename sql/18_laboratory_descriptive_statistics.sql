
-- Step 18: Descriptive statistics for laboratory measurements
-- Data sources: MIMIC-IV, hosp.admissions and hosp.labevents
--
-- Purpose:
-- Examine the distribution of the six selected laboratory
-- measurements in the analytical cohort.
--
-- Inclusion criteria:
-- Emergency admissions (EW EMER. and DIRECT EMER.)
-- Non-negative hospital length of stay
-- All six selected laboratory tests available
-- Non-null numerical laboratory values
-- Measurements within 6 hours before or after admission
--
-- Method:
-- For each admission and laboratory test, the measurement
-- closest to admission time is selected.
--
-- Only admissions with all six laboratory tests are retained.
--
-- Descriptive statistics are calculated for each test:
-- Number of measurements
-- Mean
-- Median
-- Minimum
-- Maximum
--
-- Laboratory tests:
-- Creatinine (50912)
-- Glucose (50931)
-- Hemoglobin (51222)
-- Potassium (50971)
-- Sodium (50983)
-- White blood cells (51301)
--
-- Interpretation:
-- These statistics describe the central tendency and range
-- of laboratory values in the analytical cohort.
--
-- The results can help identify potentially extreme values
-- that may require further investigation before modelling.


WITH akutt AS (
  SELECT
    hadm_id,
    admittime
  FROM `physionet-data.mimiciv_3_1_hosp.admissions`
  WHERE admission_type IN ('EW EMER.', 'DIRECT EMER.')
    AND dischtime >= admittime
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
),

komplette AS (
  SELECT hadm_id
  FROM valgte
  GROUP BY hadm_id
  HAVING COUNT(DISTINCT itemid) = 6
)

SELECT
  CASE v.itemid
    WHEN 50912 THEN 'Kreatinin'
    WHEN 50931 THEN 'Glukose'
    WHEN 51222 THEN 'Hemoglobin'
    WHEN 50971 THEN 'Kalium'
    WHEN 50983 THEN 'Natrium'
    WHEN 51301 THEN 'Leukocytter'
  END AS laboratorieprove,
  COUNT(*) AS antall,
  ROUND(AVG(v.valuenum), 2) AS gjennomsnitt,
  ROUND(
    APPROX_QUANTILES(v.valuenum, 100)[OFFSET(50)], 2
  ) AS median,
  MIN(v.valuenum) AS minimum,
  MAX(v.valuenum) AS maksimum
FROM valgte v
JOIN komplette k
  ON v.hadm_id = k.hadm_id
GROUP BY v.itemid
ORDER BY laboratorieprove;

