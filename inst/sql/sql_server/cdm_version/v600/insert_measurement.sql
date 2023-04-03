-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-29

-- Code taken from Synthea

INSERT INTO @cdm_schema.measurement (
    measurement_id,
    person_id,
    measurement_concept_id,
    measurement_date,
    measurement_datetime,
    measurement_time,
    measurement_type_concept_id,
    operator_concept_id,
    value_as_number,
    value_as_concept_id,
    unit_concept_id,
    range_low,
    range_high,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    measurement_source_value,
    measurement_source_concept_id,
    unit_source_value,
    value_source_value
)
SELECT ROW_NUMBER()OVER(ORDER BY person_id) measurement_id,
       person_id,
       measurement_concept_id,
       measurement_date,
       measurement_datetime,
       measurement_time,
       measurement_type_concept_id,
       operator_concept_id,
       value_as_number,
       value_as_concept_id,
       unit_concept_id,
       range_low,
       range_high,
       provider_id,
       visit_occurrence_id,
       visit_detail_id,
       measurement_source_value,
       measurement_source_concept_id,
       unit_source_value,
       value_source_value
FROM (
    SELECT p.person_id                              person_id,
           srctostdvm.target_concept_id             measurement_concept_id,
           
           {@synthea_version == "2.7.0"} ? {
           pr.date                                  measurement_date,
           pr.date                                  measurement_datetime,
           pr.date                                  measurement_time,
           }
           
           {@synthea_version == "3.0.0"} ? {
           pr.start                                 measurement_date,
           pr.start                                 measurement_datetime,
           pr.start                                 measurement_time,
           }
           
           38000267                                 measurement_type_concept_id,
           0                                        operator_concept_id,
           CAST(NULL AS FLOAT)                      value_as_number,
           0                                        value_as_concept_id,
           0                                        unit_concept_id,
           CAST(NULL AS FLOAT)                      range_low,
           CAST(NULL AS FLOAT)                      range_high,
           prv.provider_id                          provider_id,
           fv.visit_occurrence_id_new               visit_occurrence_id,
           fv.visit_occurrence_id_new + 1000000     visit_detail_id,
           pr.code                                  measurement_source_value,
           srctosrcvm.source_concept_id             measurement_source_concept_id,
           CAST(NULL AS VARCHAR)                    unit_source_value,
           CAST(NULL AS VARCHAR)                    value_source_value
    FROM @synthea_schema.procedures pr
    JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
         ON srctostdvm.source_code = pr.code
         AND srctostdvm.target_domain_id = 'Measurement'
         AND srctostdvm.source_vocabulary_id = 'SNOMED'
         AND srctostdvm.target_standard_concept = 'S'
         AND srctostdvm.target_invalid_reason IS NULL
    JOIN @cdm_schema.source_to_source_vocab_map srctosrcvm
         ON srctosrcvm.source_code = pr.code
         AND srctosrcvm.source_vocabulary_id = 'SNOMED'
    LEFT JOIN @cdm_schema.final_visit_ids fv
         ON fv.encounter_id = pr.encounter
    LEFT JOIN @synthea_schema.encounters e
         ON pr.encounter = e.id
         AND pr.patient = e.patient
    LEFT JOIN @cdm_schema.provider prv
         ON e.provider = prv.provider_source_value
    JOIN @cdm_schema.person p
         ON p.person_source_value = pr.patient
    
    UNION ALL
    
    SELECT p.person_id                               person_id,
           srctostdvm.target_concept_id              measurement_concept_id,
           o.date                                    measurement_date,
           o.date                                    measurement_datetime,
           o.date                                    measurement_time,
           38000267                                  measurement_type_concept_id,
           0                                         operator_concept_id,
           CASE WHEN ISNUMERIC(o.value) = 1
                THEN CAST(o.value AS FLOAT)
                ELSE CAST(NULL AS FLOAT)
           END                                       value_as_number,
           COALESCE(srcmap2.target_concept_id,0)     value_as_concept_id,
           COALESCE(srcmap1.target_concept_id,0)     unit_concept_id,
           CAST(NULL AS FLOAT)                       range_low,
           CAST(NULL AS FLOAT)                       range_high,
           pr.provider_id                            provider_id,
           fv.visit_occurrence_id_new                visit_occurrence_id,
           fv.visit_occurrence_id_new + 1000000      visit_detail_id,
           o.code                                    measurement_source_value,
           COALESCE(srctosrcvm.source_concept_id,0)  measurement_source_concept_id,
           o.units                                   unit_source_value,
           o.value                                   value_source_value
    FROM @synthea_schema.observations o
    JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
         ON srctostdvm.source_code = o.code
         AND srctostdvm.target_domain_id = 'Measurement'
         AND srctostdvm.source_vocabulary_id = 'LOINC'
         AND srctostdvm.target_standard_concept = 'S'
         AND srctostdvm.target_invalid_reason IS NULL
    LEFT JOIN @cdm_schema.source_to_standard_vocab_map srcmap1
         ON srcmap1.source_code = o.units
         AND srcmap1.target_vocabulary_id = 'UCUM'
         AND srcmap1.source_vocabulary_id = 'UCUM'
         AND srcmap1.target_standard_concept = 'S'
         AND srcmap1.target_invalid_reason IS NULL
    LEFT JOIN @cdm_schema.source_to_standard_vocab_map srcmap2
         ON srcmap2.source_code = o.value
         AND srcmap2.target_domain_id = 'Meas value'
         AND srcmap2.target_standard_concept = 'S'
         AND srcmap2.target_invalid_reason IS NULL
    LEFT JOIN @cdm_schema.source_to_source_vocab_map srctosrcvm
         ON srctosrcvm.source_code = o.code
         AND srctosrcvm.source_vocabulary_id = 'LOINC'
    LEFT JOIN @cdm_schema.final_visit_ids fv
         ON fv.encounter_id = o.encounter
    LEFT JOIN @synthea_schema.encounters e
         ON o.encounter = e.id
         AND o.patient = e.patient
    LEFT JOIN @cdm_schema.provider pr
         ON e.provider = pr.provider_source_value
    JOIN @cdm_schema.person p
         ON p.person_source_value = o.patient
    ) tmp
;
