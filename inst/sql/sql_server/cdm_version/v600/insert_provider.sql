-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-28

-- Code taken from Synthea

INSERT INTO @cdm_schema.provider (
    provider_id,
    provider_name,
    npi,
    dea,
    specialty_concept_id,
    care_site_id,
    year_of_birth,
    gender_concept_id,
    provider_source_value,
    specialty_source_value,
    specialty_source_concept_id,
    gender_source_value,
    gender_source_concept_id
)

SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL))  provider_id,
       name                                       provider_name,
       CAST(NULL AS VARCHAR(20))                  npi,
       CAST(NULL AS VARCHAR(20))                  dea,
       38004446                                   specialty_concept_id,
       CAST(NULL AS INTEGER)                      care_site_id,
       CAST(NULL AS INTEGER)                      year_of_birth,
       CASE UPPER(gender)
         WHEN 'M' THEN 8507
         WHEN 'F' THEN 8532
       END                                        gender_concept_id,
       id                                         provider_source_value,
       speciality                                 specialty_source_value,
       38004446                                   specialty_source_concept_id,
       gender                                     gender_source_value,
       CASE UPPER(gender)
         WHEN 'M' THEN 8507
         WHEN 'F' THEN 8532
       END                                        gender_source_concept_id
FROM @synthea_schema.providers
;
