
-- Step 6: Initial exploration of laboratory measurements
-- Data source: MIMIC-IV, hosp.labevents
--
-- Purpose:
-- Explore laboratory measurements for the six selected
-- laboratory tests before linking them to hospital admissions.
--
-- The query retrieves patient and admission identifiers,
-- laboratory test IDs, measurement timestamps, numerical
-- results, and measurement units.
--
-- Only measurements with non-null numerical values
-- are included.
--
-- LIMIT 20 is used for initial data exploration only.
-- No admission type or time window restrictions
-- are applied at this stage.

SELECT
  subject_id,
  hadm_id,
  itemid,
  charttime,
  valuenum,
  valueuom
FROM `physionet-data.mimiciv_3_1_hosp.labevents`
WHERE itemid IN (51222, 51301, 50912, 50983, 50971, 50931)
  AND valuenum IS NOT NULL
LIMIT 20;
