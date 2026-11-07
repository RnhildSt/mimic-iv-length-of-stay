
-- Select emergency hospital admissions from MIMIC-IV
-- Dataset: MIMIC-IV version 3.1, hosp module
-- Admission types: EW EMER. and DIRECT EMER.

SELECT
    subject_id,
    hadm_id,
    admittime,
    dischtime,
    admission_type,
    ROUND(
        DATETIME_DIFF(dischtime, admittime, MINUTE) / 1440.0,
        2
    ) AS los_days
FROM
    `physionet-data.mimiciv_3_1_hosp.admissions`
WHERE
    admission_type IN ('EW EMER.', 'DIRECT EMER.')
ORDER BY
    hadm_id;
