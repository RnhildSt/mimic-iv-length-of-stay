
-- Step 9: Identification of complete laboratory cases
-- Data sources: MIMIC-IV, hosp.admissions and hosp.labevents
--
-- Purpose:
-- Identify emergency hospital admissions with available
-- numerical measurements for all six selected laboratory tests.
--
-- Inclusion criteria:
-- Emergency admissions (EW EMER. and DIRECT EMER.)
-- Six selected laboratory tests
-- Non-null numerical laboratory values
-- Measurements recorded within 6 hours after admission
--
-- Method:
-- Admissions are grouped by admission ID (hadm_id).
-- COUNT(DISTINCT itemid) is used to identify admissions
-- with at least one measurement for each of the six tests.
--
-- Only admissions with all six tests are counted.
--
-- This is an initial complete-case assessment.
-- The laboratory time window was subsequently expanded
-- to include measurements up to 6 hours before admission.
--
-- Note:
-- This query does not yet select one measurement per test
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
    AND l.charttime BETWEEN a.admittime
                        AND DATETIME_ADD(a.admittime, INTERVAL 6 HOUR)
  GROUP BY a.hadm_id
  HAVING COUNT(DISTINCT l.itemid) = 6
);
