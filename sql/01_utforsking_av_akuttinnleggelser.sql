-- Steg 1: Utforsking av akuttinnleggelser i MIMIC-IV
-- Tabell: admissions
-- Formål: Kontrollere utvalg av akuttinnleggelser
-- og beregning av liggetid (LOS).
-- LIMIT 10 brukes kun for å vise eksempler.

SELECT
  admission_type,
  admittime,
  dischtime,
  ROUND(
    DATETIME_DIFF(dischtime, admittime, HOUR) / 24.0,
    2
  ) AS los_dager
FROM `physionet-data.mimiciv_3_1_hosp.admissions`
WHERE admission_type IN ('EW EMER.', 'DIRECT EMER.')
LIMIT 10;
