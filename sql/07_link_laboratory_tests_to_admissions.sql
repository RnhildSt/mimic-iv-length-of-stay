
-- Step 7: Linking laboratory measurements to emergency admissions
-- Data source: MIMIC-IV, hosp.admissions and hosp.labevents
--
-- Purpose:
-- Link the six selected laboratory tests to emergency
-- hospital admissions using the admission ID (hadm_id).
--
-- Only admissions classified as EW EMER. or DIRECT EMER.
-- and laboratory measurements with numerical values
-- are included.
--
-- Initial time window:
-- From admission time to 6 hours after admission.
--
-- This was an exploratory query to examine laboratory
-- measurements associated with emergency admissions.
--
-- The time window was later expanded to include
-- measurements taken up to 6 hours before admission.
--
-- LIMIT 20 is used for initial exploration only.

SELECT
  a.hadm_id,
  a.admission_type,
  a.admittime,
  l.itemid,
  l.charttime,
  l.valuenum,
  l.valueuom
FROM `physionet-data.mimiciv_3_1_hosp.admissions` AS a
JOIN `physionet-data.mimiciv_3_1_hosp.labevents` AS l
  ON a.hadm_id = l.hadm_id
WHERE a.admission_type IN ('EW EMER.', 'DIRECT EMER.')
  AND l.itemid IN (51222, 51301, 50912, 50983, 50971, 50931)
  AND l.valuenum IS NOT NULL
  AND l.charttime BETWEEN a.admittime
                      AND DATETIME_ADD(a.admittime, INTERVAL 6 HOUR)
LIMIT 20;
