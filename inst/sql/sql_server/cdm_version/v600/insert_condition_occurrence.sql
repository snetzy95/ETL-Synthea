-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-29

-- Code taken from Synthea

INSERT INTO @cdm_schema.condition_occurrence (
    condition_occurrence_id,
    person_id,
    condition_concept_id,
    condition_start_date,
    condition_start_datetime,
    condition_end_date,
    condition_end_datetime,
    condition_type_concept_id,
    condition_status_concept_id,
    stop_reason,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    condition_source_value,
    condition_source_concept_id,
    condition_status_source_value
)

SELECT ROW_NUMBER()OVER(ORDER BY p.person_id)     condition_occurrence_id,
       p.person_id                                person_id,
       srctostdvm.target_concept_id               condition_concept_id,
       c.start                                    condition_start_date,
       c.start                                    condition_start_datetime,
       c.stop                                     condition_end_date,
       c.stop                                     condition_end_datetime,
       38000175                                   condition_type_concept_id,
       0                                          condition_status_concept_id,
       CAST(NULL AS VARCHAR)                      stop_reason,
       pr.provider_id                             provider_id,
       fv.visit_occurrence_id_new                 visit_occurrence_id,
       fv.visit_occurrence_id_new + 1000000       visit_detail_id,
       c.code                                     condition_source_value,
       srctosrcvm.source_concept_id               condition_source_concept_id,
       NULL                                       condition_status_source_value
FROM @synthea_schema.conditions c
JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
     ON srctostdvm.source_code = c.code
     AND srctostdvm.target_domain_id = 'Condition'
     AND srctostdvm.target_vocabulary_id = 'SNOMED'
     AND srctostdvm.source_vocabulary_id = 'SNOMED'
     AND srctostdvm.target_standard_concept = 'S'
     AND srctostdvm.target_invalid_reason IS NULL
JOIN @cdm_schema.source_to_source_vocab_map srctosrcvm
     ON srctosrcvm.source_code = c.code
     AND srctosrcvm.source_vocabulary_id = 'SNOMED'
     AND srctosrcvm.source_domain_id = 'Condition'
LEFT JOIN @cdm_schema.final_visit_ids fv
     ON fv.encounter_id = c.encounter
LEFT JOIN @synthea_schema.encounters e
     ON c.encounter = e.id
     AND c.patient = e.patient
LEFT JOIN @cdm_schema.provider pr
     ON e.provider = pr.provider_source_value
JOIN @cdm_schema.person p
     ON c.patient = p.person_source_value
;
