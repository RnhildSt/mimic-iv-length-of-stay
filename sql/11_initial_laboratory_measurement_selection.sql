
-- Step 11: Initial selection of laboratory measurements
-- Data sources: MIMIC-IV, hosp.admissions and hosp.labevents
--
-- Purpose:
-- Select one numerical measurement per laboratory test
-- for each emergency hospital admission.
--
-- Inclusion criteria:
-- Emergency admissions (EW EMER. and DIRECT EMER.)
-- Six selected laboratory tests
-- Non-null numerical laboratory values
-- Measurements within 6 hours before or after admission
--
-- Method:
-- ROW_NUMBER() assigns a rank to measurements within
-- each combination of admission ID and laboratory test.
--
-- Measurements are ordered chronologically by charttime,
-- with labevent_id used to resolve ties.
-- The earliest measurement is selected (nr = 1).
--
-- Methodological development:
-- This was an initial approach. It was later revised
-- to select the measurement closest to admission time,
-- rather than the earliest measurement.
--
-- LIMIT 30 is used to inspect example records.
-- This query does not yet create the final analytical dataset.

WITH prover AS (
  SELECT
    a.hadm_id,
    a.admittime,
    l.itemid,
    l.charttime,
    l.valuenum,
    ROW_NUMBER() OVER (
      PARTITION BY a.hadm_id, l.itemid
      ORDER BY l.charttime, l.labevent_id
    ) AS nr
  FROM `physionet-data.mimiciv_3_1_hosp.admissions` AS a
  JOIN `physionet-data.mimiciv_3_1_hosp.labevents` AS l
    ON a.hadm_id = l.hadm_id
  WHERE a.admission_type IN ('EW EMER.', 'DIRECT EMER.')
    AND l.itemid IN (51222, 51301, 50912, 50983, 50971, 50931)
    AND l.valuenum IS NOT NULL
    AND l.charttime BETWEEN
        DATETIME_SUB(a.admittime, INTERVAL 6 HOUR)
        AND DATETIME_ADD(a.admittime, INTERVAL 6 HOUR)
)

SELECT
  hadm_id,
  itemid,
  charttime,
  valuenum
FROM prover
WHERE nr = 1
ORDER BY hadm_id, itemid
LIMIT 30;
