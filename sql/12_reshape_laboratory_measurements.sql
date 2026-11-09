
-- Step 12: Reshaping laboratory measurements
-- Data sources: MIMIC-IV, hosp.admissions and hosp.labevents
--
-- Purpose:
-- Transform laboratory measurements from long format
-- to wide format, with one row per hospital admission
-- and one column for each of the six laboratory tests.
--
-- Inclusion criteria:
-- Emergency admissions (EW EMER. and DIRECT EMER.)
-- Six selected laboratory tests
-- Non-null numerical laboratory values
-- Measurements within 6 hours before or after admission
--
-- Method:
-- ROW_NUMBER() identifies the earliest measurement
-- for each laboratory test within each admission.
--
-- Conditional aggregation using MAX(IF(...)) transforms
-- laboratory measurements into separate columns.
--
-- HAVING COUNT(DISTINCT itemid) = 6 ensures that only
-- admissions with all six laboratory tests are included.
--
-- Methodological development:
-- The selection of the earliest measurement was later
-- revised to select the measurement closest to admission.
--
-- LIMIT 20 is used to inspect example records.
-- This is not yet the final analytical dataset.

WITH prover AS (
  SELECT
    a.hadm_id,
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
  MAX(IF(itemid = 50912, valuenum, NULL)) AS kreatinin,
  MAX(IF(itemid = 50931, valuenum, NULL)) AS glukose,
  MAX(IF(itemid = 50971, valuenum, NULL)) AS kalium,
  MAX(IF(itemid = 50983, valuenum, NULL)) AS natrium,
  MAX(IF(itemid = 51222, valuenum, NULL)) AS hemoglobin,
  MAX(IF(itemid = 51301, valuenum, NULL)) AS leukocytter
FROM prover
WHERE nr = 1
GROUP BY hadm_id
HAVING COUNT(DISTINCT itemid) = 6
ORDER BY hadm_id
LIMIT 20;
