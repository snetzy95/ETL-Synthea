-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-28

-- Code taken from Synthea

INSERT INTO @cdm_schema.person
            (person_id,
             gender_concept_id,
             year_of_birth,
             month_of_birth,
             day_of_birth,
             birth_datetime,
             death_datetime,
             race_concept_id,
             ethnicity_concept_id,
             location_id,
             provider_id,
             care_site_id,
             person_source_value,
             gender_source_value,
             gender_source_concept_id,
             race_source_value,
             race_source_concept_id,
             ethnicity_source_value,
             ethnicity_source_concept_id)
SELECT ROW_NUMBER() OVER(ORDER BY p.id),
       CASE UPPER(p.gender)
         WHEN 'M' THEN 8507
         WHEN 'F' THEN 8532
       END,
       YEAR(p.birthdate),
       MONTH(p.birthdate),
       DAY(p.birthdate),
       p.birthdate,
       e.start,
       CASE UPPER(p.race)
         WHEN 'WHITE' THEN 8527
         WHEN 'BLACK' THEN 8516
         WHEN 'ASIAN' THEN 8515
         ELSE 0
       END,
       CASE
         WHEN UPPER(p.ethnicity) = 'HISPANIC'    THEN 38003563
         WHEN UPPER(p.ethnicity) = 'NONHISPANIC' THEN 38003564
         ELSE 0 
       END,
       NULL,
       NULL,
       NULL,
       p.id,
       p.gender,
       0,
       p.race,
       0,
       p.ethnicity,
       0
FROM @synthea_schema.patients p
LEFT JOIN @synthea_schema.encounters e
     ON p.id = e.patient
     AND e.code = '308646001'
LEFT JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
     ON srctostdvm.source_code = e.reasoncode
     AND srctostdvm.target_domain_id = 'Condition'
     AND srctostdvm.source_domain_id = 'Condition'
     AND srctostdvm.target_vocabulary_id = 'SNOMED'
     AND srctostdvm.source_vocabulary_id = 'SNOMED'
     AND srctostdvm.target_standard_concept = 'S'
     AND srctostdvm.target_invalid_reason IS NULL
WHERE p.gender IS NOT NULL;
