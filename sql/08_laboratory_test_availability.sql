
-- Step 8: Laboratory test availability
-- Data sources: MIMIC-IV, hosp.admissions,
-- hosp.labevents and hosp.d_labitems
--
-- Purpose:
-- Assess the availability of the six selected laboratory
-- tests among emergency hospital admissions.
--
-- The query counts the number of distinct admissions
-- with at least one valid numerical measurement for
-- each laboratory test.
--
-- Inclusion criteria:
-- Emergency admissions (EW EMER. and DIRECT EMER.)
-- Six selected laboratory tests
-- Non-null numerical laboratory values
-- Measurements recorded within 6 hours after admission
--
-- Results:
-- Potassium: 57905 admissions
-- Sodium: 57304 admissions
-- Creatinine: 56588 admissions
-- Glucose: 55569 admissions
-- Hemoglobin: 53570 admissions
-- White Blood Cells: 53427 admissions
--
-- These results were used to assess data availability
-- before defining the final analytical cohort.
--
-- The laboratory time window was subsequently expanded
-- to include measurements up to 6 hours before admission.

SELECT
  l.itemid,
  d.label,
  COUNT(DISTINCT a.hadm_id) AS antall_innleggelser
FROM `physionet-data.mimiciv_3_1_hosp.admissions` AS a
JOIN `physionet-data.mimiciv_3_1_hosp.labevents` AS l
  ON a.hadm_id = l.hadm_id
JOIN `physionet-data.mimiciv_3_1_hosp.d_labitems` AS d
  ON l.itemid = d.itemid
WHERE a.admission_type IN ('EW EMER.', 'DIRECT EMER.')
  AND l.itemid IN (51222, 51301, 50912, 50983, 50971, 50931)
  AND l.valuenum IS NOT NULL
  AND l.charttime BETWEEN a.admittime
                      AND DATETIME_ADD(a.admittime, INTERVAL 6 HOUR)
GROUP BY l.itemid, d.label
ORDER BY antall_innleggelser DESC;
