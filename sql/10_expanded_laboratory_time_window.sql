
-- Step 10: Expanded laboratory time window
-- Data sources: MIMIC-IV, hosp.admissions and hosp.labevents
--
-- Purpose:
-- Identify emergency hospital admissions with numerical
-- measurements for all six selected laboratory tests
-- within 6 hours before or after admission.
--
-- Methodological decision:
-- The initial time window of 0 to 6 hours after admission
-- was expanded to -6 to +6 hours relative to admission.
--
-- This adjustment was made because laboratory tests may
-- be collected before the formal hospital admission time.
--
-- Inclusion criteria:
-- Emergency admissions (EW EMER. and DIRECT EMER.)
-- Six selected laboratory tests
-- Non-null numerical laboratory values
-- Measurements within -6 to +6 hours of admission
--
-- Method:
-- Admissions are grouped by admission ID (hadm_id).
-- Only admissions with all six laboratory tests are counted.
--
-- This query assesses complete laboratory availability.
-- It does not yet select one measurement per test
-- or exclude admissions with negative length of stay.

SELECT
  COUNT(*) AS innleggelser_med_alle_seks
FROM (
  SELECT
    a.hadm_id
  FROM `physionet-data.mimiciv_3_1_hosp.admissions` AS a
  JOIN `physionet-data.mimiciv_3_1_hosp.labevents` AS l
    ON a.hadm_id = l.hadm_id
  WHERE a.admission_type IN ('EW EMER.', 'DIRECT EMER.')
    AND l.itemid IN (51222, 51301, 50912, 50983, 50971, 50931)
    AND l.valuenum IS NOT NULL
    AND l.charttime BETWEEN
        DATETIME_SUB(a.admittime, INTERVAL 6 HOUR)
        AND DATETIME_ADD(a.admittime, INTERVAL 6 HOUR)
  GROUP BY a.hadm_id
  HAVING COUNT(DISTINCT l.itemid) = 6
);
