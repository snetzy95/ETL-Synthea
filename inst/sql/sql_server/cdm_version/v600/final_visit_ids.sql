-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-28

-- Code taken from Synthea

IF OBJECT_ID('@cdm_schema.FINAL_VISIT_IDS', 'U') IS NOT NULL DROP TABLE @cdm_schema.FINAL_VISIT_IDS;


SELECT encounter_id, VISIT_OCCURRENCE_ID_NEW
INTO @cdm_schema.FINAL_VISIT_IDS
FROM(
	SELECT *, ROW_NUMBER () OVER (PARTITION BY encounter_id ORDER BY PRIORITY) AS RN
	FROM (
		SELECT *,
			CASE
				WHEN encounterclass IN ('emergency','urgent')
					THEN (
						CASE
							WHEN VISIT_TYPE = 'inpatient' AND VISIT_OCCURRENCE_ID_NEW IS NOT NULL
								THEN 1
							WHEN VISIT_TYPE IN ('emergency','urgent') AND VISIT_OCCURRENCE_ID_NEW IS NOT NULL
								THEN 2
							ELSE 99
						END
					)
				WHEN encounterclass IN ('ambulatory', 'wellness', 'outpatient')
					THEN (
						CASE
							WHEN VISIT_TYPE = 'inpatient' AND VISIT_OCCURRENCE_ID_NEW IS NOT NULL
								THEN  1
							WHEN VISIT_TYPE IN ('ambulatory', 'wellness', 'outpatient') AND VISIT_OCCURRENCE_ID_NEW IS NOT NULL
								THEN 2
							ELSE 99
						END
					)
				WHEN encounterclass = 'inpatient' AND VISIT_TYPE = 'inpatient' AND VISIT_OCCURRENCE_ID_NEW IS NOT NULL
					THEN 1
				ELSE 99
			END AS PRIORITY
	FROM @cdm_schema.ASSIGN_ALL_VISIT_IDS
	) T1
) T2
WHERE RN=1
