

SELECT
  COUNTIF(los_dager < 0) AS negative_opphold,
  COUNTIF(los_dager > 30) AS over_30_dager,
  COUNTIF(los_dager > 90) AS over_90_dager
FROM (
  SELECT
    DATETIME_DIFF(dischtime, admittime, MINUTE) / 1440.0 AS los_dager
  FROM `physionet-data.mimiciv_3_1_hosp.admissions`
  WHERE admission_type IN ('EW EMER.', 'DIRECT EMER.')
);
