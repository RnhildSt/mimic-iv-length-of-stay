
-- Step 5: Identification of laboratory tests
-- Data source: MIMIC-IV, hosp.d_labitems
--
-- Purpose:
-- Identify and verify six laboratory tests selected
-- as predictors of hospital length of stay (LOS).
--
-- The laboratory tests were selected based on their
-- clinical relevance and common use in emergency admissions.
--
-- Selected laboratory tests:
-- 50912: Creatinine
-- 50931: Glucose
-- 51222: Hemoglobin
-- 50971: Potassium
-- 50983: Sodium
-- 51301: White Blood Cells (WBC)
--
-- The query retrieves the item ID, test name,
-- specimen type, and laboratory category.
-- Results are ordered alphabetically by test name.

SELECT
  itemid,
  label,
  fluid,
  category
FROM `physionet-data.mimiciv_3_1_hosp.d_labitems`
WHERE itemid IN (51222, 51301, 50912, 50983, 50971, 50931)
ORDER BY label;
