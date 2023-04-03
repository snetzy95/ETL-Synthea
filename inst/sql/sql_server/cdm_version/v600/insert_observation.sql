
INSERT INTO @cdm_schema.observation (
    observation_id,
    person_id,
    observation_concept_id,
    observation_date,
    observation_datetime,
    observation_type_concept_id,
    value_as_number,
    value_as_string,
    value_as_concept_id,
    qualifier_concept_id,
    unit_concept_id,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    observation_source_value,
    observation_source_concept_id,
    unit_source_value,
    qualifier_source_value,
    observation_event_id,
    obs_event_field_concept_id,
    value_as_datetime
)
SELECT ROW_NUMBER()OVER(ORDER BY person_id) observation_id,
       person_id,
       observation_concept_id,
       observation_date,
       observation_datetime,
       observation_type_concept_id,
       value_as_number,
       value_as_string,
       value_as_concept_id,
       qualifier_concept_id,
       unit_concept_id,
       provider_id,
       visit_occurrence_id,
       visit_detail_id,
       observation_source_value,
       observation_source_concept_id,
       unit_source_value,
       qualifier_source_value,
       observation_event_id,
       obs_event_field_concept_id,
       value_as_datetime
FROM (
SELECT p.person_id                              person_id,
       srctostdvm.target_concept_id             observation_concept_id,
       a.start                                  observation_date,
       a.start                                  observation_datetime,
       38000280                                 observation_type_concept_id,
       CAST(NULL AS FLOAT)                      value_as_number,
       CAST(NULL AS VARCHAR)                    value_as_string,
       0                                        value_as_concept_id,
       0                                        qualifier_concept_id,
       0                                        unit_concept_id,
       pr.provider_id                           provider_id,
       fv.visit_occurrence_id_new               visit_occurrence_id,
       fv.visit_occurrence_id_new + 1000000     visit_detail_id,
       a.code                                   observation_source_value,
       srctosrcvm.source_concept_id             observation_source_concept_id,
       CAST(NULL AS VARCHAR)                    unit_source_value,
       CAST(NULL AS VARCHAR)                    qualifier_source_value,
       CAST(NULL AS BIGINT)                     observation_event_id,
       CAST(NULL AS INT)                        obs_event_field_concept_id,
       CAST(NULL AS DATETIME)                   value_as_datetime
FROM @synthea_schema.allergies a
JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
     ON srctostdvm.source_code = a.code
     AND srctostdvm.target_domain_id = 'Observation'
     AND srctostdvm.target_vocabulary_id = 'SNOMED'
     AND srctostdvm.target_standard_concept = 'S'
     AND srctostdvm.target_invalid_reason IS NULL
JOIN @cdm_schema.source_to_source_vocab_map srctosrcvm
     ON srctosrcvm.source_code = a.code
     AND srctosrcvm.source_vocabulary_id = 'SNOMED'
     AND srctosrcvm.source_domain_id = 'Observation'
LEFT JOIN @cdm_schema.final_visit_ids fv
     ON fv.encounter_id = a.encounter
LEFT JOIN @synthea_schema.encounters e
     ON a.encounter = e.id
     AND a.patient = e.patient
LEFT JOIN @cdm_schema.provider pr
     ON e.provider = pr.provider_source_value
JOIN @cdm_schema.person p
     ON p.person_source_value = a.patient

UNION ALL

SELECT p.person_id                              person_id,
       srctostdvm.target_concept_id             observation_concept_id,
       c.start                                  observation_date,
       c.start                                  observation_datetime,
       38000280                                 observation_type_concept_id,
       CAST(NULL AS FLOAT)                      value_as_number,
       CAST(NULL AS VARCHAR)                    value_as_string,
       0                                        value_as_concept_id,
       0                                        qualifier_concept_id,
       0                                        unit_concept_id,
       pr.provider_id                           provider_id,
       fv.visit_occurrence_id_new               visit_occurrence_id,
       fv.visit_occurrence_id_new + 1000000     visit_detail_id,
       c.code                                   observation_source_value,
       srctosrcvm.source_concept_id             observation_source_concept_id,
       CAST(NULL AS VARCHAR)                    unit_source_value,
       CAST(NULL AS VARCHAR)                    qualifier_source_value,
       CAST(NULL AS BIGINT)                     observation_event_id,
       CAST(NULL AS INT)                        obs_event_field_concept_id,
       CAST(NULL AS DATETIME)                   value_as_datetime
FROM @synthea_schema.conditions c
JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
     ON srctostdvm.source_code = c.code
     AND srctostdvm.target_domain_id = 'Observation'
     AND srctostdvm.target_vocabulary_id = 'SNOMED'
     AND srctostdvm.target_standard_concept = 'S'
     AND srctostdvm.target_invalid_reason IS NULL
JOIN @cdm_schema.source_to_source_vocab_map srctosrcvm
     ON srctosrcvm.source_code = c.code
     AND srctosrcvm.source_vocabulary_id = 'SNOMED'
     AND srctosrcvm.source_domain_id = 'Observation'
LEFT JOIN @cdm_schema.final_visit_ids fv
     ON fv.encounter_id = c.encounter
LEFT JOIN @synthea_schema.encounters e
     ON c.encounter = e.id
     AND c.patient = e.patient
LEFT JOIN @cdm_schema.provider pr 
     ON e.provider = pr.provider_source_value
JOIN @cdm_schema.person p
     ON p.person_source_value = c.patient

UNION ALL

SELECT p.person_id                              person_id,
       srctostdvm.target_concept_id             observation_concept_id,
       o.date                                   observation_date,
       o.date                                   observation_datetime,
       38000280                                 observation_type_concept_id,
       CAST(NULL AS FLOAT)                      value_as_number,
       CAST(NULL AS VARCHAR)                    value_as_string,
       0                                        value_as_concept_id,
       0                                        qualifier_concept_id,
       0                                        unit_concept_id,
       pr.provider_id                           provider_id,
       fv.visit_occurrence_id_new               visit_occurrence_id,
       fv.visit_occurrence_id_new + 1000000     visit_detail_id,
       o.code                                   observation_source_value,
       srctosrcvm.source_concept_id             observation_source_concept_id,
       CAST(NULL AS VARCHAR)                    unit_source_value,
       CAST(NULL AS VARCHAR)                    qualifier_source_value,
       CAST(NULL AS BIGINT)                     observation_event_id,
       CAST(NULL AS INT)                        obs_event_field_concept_id,
       CAST(NULL AS DATETIME)                   value_as_datetime
FROM @synthea_schema.observations o
JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
     ON srctostdvm.source_code = o.code
     AND srctostdvm.target_domain_id = 'Observation'
     AND srctostdvm.target_vocabulary_id = 'LOINC'
     AND srctostdvm.target_standard_concept = 'S'
     AND srctostdvm.target_invalid_reason IS NULL
JOIN @cdm_schema.source_to_source_vocab_map srctosrcvm
     ON srctosrcvm.source_code = o.code
     AND srctosrcvm.source_vocabulary_id = 'LOINC'
     AND srctosrcvm.source_domain_id = 'Observation'
LEFT JOIN @cdm_schema.final_visit_ids fv
     ON fv.encounter_id = o.encounter
LEFT JOIN @synthea_schema.encounters e
     ON o.encounter = e.id
     AND o.patient = e.patient
LEFT JOIN @cdm_schema.provider pr 
     ON e.provider = pr.provider_source_value
JOIN @cdm_schema.person p
     ON p.person_source_value = o.patient

--for death view OMOP CDM v6.0
UNION ALL

SELECT p.person_id                              person_id,
       srctostdvm.target_concept_id             observation_concept_id,
       CAST(p.death_datetime AS DATE)           observation_date,
       p.death_datetime                         observation_datetime,
       38003566                                 observation_type_concept_id,
       CAST(NULL AS FLOAT)                      value_as_number,
       CAST(NULL AS VARCHAR)                    value_as_string,
       0                                        value_as_concept_id,
       0                                        qualifier_concept_id,
       0                                        unit_concept_id,
       pr.provider_id                           provider_id,
       fv.visit_occurrence_id_new               visit_occurrence_id,
       fv.visit_occurrence_id_new + 1000000     visit_detail_id,
       e.code                                   observation_source_value,
       0                                        observation_source_concept_id,
       CAST(NULL AS VARCHAR)                    unit_source_value,
       CAST(NULL AS VARCHAR)                    qualifier_source_value,
       p.person_id                              observation_event_id,
       1147800                                  obs_event_field_concept_id,
       p.death_datetime                         value_as_datetime
FROM @synthea_schema.encounters e
JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
     ON srctostdvm.source_code = e.reasoncode
     AND srctostdvm.target_domain_id = 'Condition'
     AND srctostdvm.source_domain_id = 'Condition'
     AND srctostdvm.target_vocabulary_id = 'SNOMED'
     AND srctostdvm.source_vocabulary_id = 'SNOMED'
     AND srctostdvm.target_standard_concept = 'S'
     AND srctostdvm.target_invalid_reason IS NULL
LEFT JOIN @cdm_schema.final_visit_ids fv
     ON fv.encounter_id = e.id
LEFT JOIN @cdm_schema.provider pr
     ON e.provider = pr.provider_source_value
JOIN @cdm_schema.person p
     ON e.patient = p.person_source_value
WHERE e.code = '308646001'
 ) tmp
;
