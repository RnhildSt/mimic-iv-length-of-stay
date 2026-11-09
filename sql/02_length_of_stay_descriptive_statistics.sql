SELECT
  COUNT(*) AS antall_innleggelser,
  ROUND(AVG(los_dager), 2) AS gjennomsnitt,
  ROUND(APPROX_QUANTILES(los_dager, 100)[OFFSET(50)], 2) AS median,
  ROUND(MIN(los_dager), 2) AS korteste_opphold,
  ROUND(MAX(los_dager), 2) AS lengste_opphold
FROM (
  SELECT
    DATETIME_DIFF(dischtime, admittime, MINUTE) / 1440.0 AS los_dager
  FROM `physionet-data.mimiciv_3_1_hosp.admissions`
  WHERE admission_type IN ('EW EMER.', 'DIRECT EMER.')
);
