
-- Step 13: Adding length of stay to laboratory data
-- Data sources: MIMIC-IV, hosp.admissions and hosp.labevents
--
-- Purpose:
-- Combine the six selected laboratory measurements
-- with hospital length of stay (LOS) for emergency admissions.
--
-- Inclusion criteria:
-- Emergency admissions (EW EMER. and DIRECT EMER.)
-- All six selected laboratory tests available
-- Non-null numerical laboratory values
-- Measurements within 6 hours before or after admission
-- Non-negative hospital length of stay
--
-- Method:
-- The earliest measurement for each laboratory test
-- is selected using ROW_NUMBER().
--
-- Laboratory measurements are transformed into
-- six separate columns, with one row per admission.
--
-- LOS is calculated as the difference between
-- discharge time and admission time, expressed in days.
--
-- Admissions with negative LOS are excluded.
--
-- Methodological development:
-- The selection of the earliest laboratory measurement
-- was later revised to select the measurement closest
-- to admission time.
--
-- LIMIT 20 is used to inspect example records.
-- This query does not yet create the final analytical dataset.

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
),

labdata AS (
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
)

SELECT
  l.*,
  ROUND(
    DATETIME_DIFF(a.dischtime, a.admittime, MINUTE) / 1440.0,
    2
  ) AS los_dager
FROM labdata AS l
JOIN `physionet-data.mimiciv_3_1_hosp.admissions` AS a
  ON l.hadm_id = a.hadm_id
WHERE a.dischtime >= a.admittime
ORDER BY l.hadm_id
LIMIT 20;
