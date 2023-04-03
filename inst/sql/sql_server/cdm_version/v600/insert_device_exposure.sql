
INSERT INTO @cdm_schema.device_exposure (
    device_exposure_id,
    person_id,
    device_concept_id,
    device_exposure_start_date,
    device_exposure_start_datetime,
    device_exposure_end_date,
    device_exposure_end_datetime,
    device_type_concept_id,
    unique_device_id,
    quantity,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    device_source_value,
    device_source_concept_id
)
SELECT ROW_NUMBER()OVER(ORDER BY person_id)        device_exposure_id,
       p.person_id                                 person_id,
       srctostdvm.target_concept_id                device_concept_id,
       d.start                                     device_exposure_start_date,
       d.start                                     device_exposure_start_datetime,
       d.stop                                      device_exposure_end_date,
       d.stop                                      device_exposure_end_datetime,
       38000267                                    device_type_concept_id,
       d.udi                                       unique_device_id,
       CAST(NULL AS INT)                           quantity,
       pr.provider_id                              provider_id,
       fv.visit_occurrence_id_new                  visit_occurrence_id,
       fv.visit_occurrence_id_new+1000000          visit_detail_id,
       d.code                                      device_source_value,
       srctosrcvm.source_concept_id                device_source_concept_id
FROM @synthea_schema.devices d
JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
     ON srctostdvm.source_code = d.code
     AND srctostdvm.target_domain_id = 'Device'
     AND srctostdvm.target_vocabulary_id = 'SNOMED'
     AND srctostdvm.source_vocabulary_id = 'SNOMED'
     AND srctostdvm.target_standard_concept = 'S'
     AND srctostdvm.target_invalid_reason IS NULL
JOIN @cdm_schema.source_to_source_vocab_map srctosrcvm
     ON srctosrcvm.source_code = d.code
     AND srctosrcvm.source_vocabulary_id = 'SNOMED'
LEFT JOIN @cdm_schema.final_visit_ids fv
     ON fv.encounter_id = d.encounter
LEFT JOIN @synthea_schema.encounters e
     ON d.encounter = e.id
     AND d.patient = e.patient
LEFT JOIN @cdm_schema.provider pr
     ON e.provider = pr.provider_source_value
JOIN @cdm_schema.person p
     ON p.person_source_value = d.patient
;

