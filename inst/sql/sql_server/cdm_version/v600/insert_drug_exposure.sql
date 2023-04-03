-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-29

-- Code taken from Synthea

INSERT INTO @cdm_schema.drug_exposure (
    drug_exposure_id,
    person_id,
    drug_concept_id,
    drug_exposure_start_date,
    drug_exposure_start_datetime,
    drug_exposure_end_date,
    drug_exposure_end_datetime,
    verbatim_end_date,
    drug_type_concept_id,
    stop_reason,
    refills,
    quantity,
    days_supply,
    sig,
    route_concept_id,
    lot_number,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    drug_source_value,
    drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
)

SELECT ROW_NUMBER()OVER(ORDER BY person_id) drug_exposure_id,
       person_id,
       drug_concept_id,
       drug_exposure_start_date,
       drug_exposure_start_datetime,
       drug_exposure_end_date,
       drug_exposure_end_datetime,
       verbatim_end_date,
       drug_type_concept_id,
       stop_reason,
       refills,
       quantity,
       days_supply,
       sig,
       route_concept_id,
       lot_number,
       provider_id,
       visit_occurrence_id,
       visit_detail_id,
       drug_source_value,
       drug_source_concept_id,
       route_source_value,
       dose_unit_source_value
FROM (
    SELECT p.person_id                                  person_id,
           srctostdvm.target_concept_id                 drug_concept_id,
           m.start                                      drug_exposure_start_date,
           m.start                                      drug_exposure_start_datetime,
           COALESCE(m.stop,m.start)                     drug_exposure_end_date,
           COALESCE(m.stop,m.start)                     drug_exposure_end_datetime,
           m.stop                                       verbatim_end_date,
           32869                                        drug_type_concept_id,
           CAST(NULL AS VARCHAR)                        stop_reason,
           0                                            refills,
           0                                            quantity,
           COALESCE(DATEDIFF(DAY,m.start,m.stop),0)     days_supply,
           CAST(NULL AS VARCHAR)                        sig,
           0                                            route_concept_id,
           0                                            lot_number,
           pr.provider_id                               provider_id,
           fv.visit_occurrence_id_new                   visit_occurrence_id,
           fv.visit_occurrence_id_new + 1000000         visit_detail_id,
           m.code                                       drug_source_value,
           srctosrcvm.source_concept_id                 drug_source_concept_id,
           CAST(NULL AS VARCHAR)                        route_source_value,
           CAST(NULL AS VARCHAR)                        dose_unit_source_value
    FROM @synthea_schema.medications m
    JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
         ON srctostdvm.source_code = m.code
         AND srctostdvm.target_domain_id = 'Drug'
         AND srctostdvm.target_vocabulary_id = 'RxNorm'
         AND srctostdvm.target_standard_concept = 'S'
         AND srctostdvm.target_invalid_reason IS NULL
    JOIN @cdm_schema.source_to_source_vocab_map srctosrcvm
         ON srctosrcvm.source_code = m.code
         AND srctosrcvm.source_vocabulary_id = 'RxNorm'
    LEFT JOIN @cdm_schema.final_visit_ids fv
         ON fv.encounter_id = m.encounter
    LEFT JOIN @synthea_schema.encounters e
         ON m.encounter = e.id
         AND m.patient = e.patient
    LEFT JOIN @cdm_schema.provider pr
         ON e.provider = pr.provider_source_value
    JOIN @cdm_schema.person p
         ON p.person_source_value = m.patient

    UNION ALL

    SELECT p.person_id                                 person_id,
           srctostdvm.target_concept_id                drug_concept_id,
           i.date                                      drug_exposure_start_date,
           i.date                                      drug_exposure_start_datetime,
           i.date                                      drug_exposure_end_date,
           i.date                                      drug_exposure_end_datetime,
           i.date                                      verbatim_end_date,
           32869                                       drug_type_concept_id,
           CAST(NULL AS VARCHAR)                       stop_reason,
           0                                           refills,
           0                                           quantity,
           0                                           days_supply,
           CAST(NULL AS VARCHAR)                       sig,
           0                                           route_concept_id,
           0                                           lot_number, 
           pr.provider_id                              provider_id,
           fv.visit_occurrence_id_new                  visit_occurrence_id,
           fv.visit_occurrence_id_new + 1000000        visit_detail_id,
           i.code                                      drug_source_value,
           srctosrcvm.source_concept_id                drug_source_concept_id,
           CAST(NULL AS VARCHAR)                       route_source_value,
           CAST(NULL AS VARCHAR)                       dose_unit_source_value
    FROM @synthea_schema.immunizations i
    JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
         ON srctostdvm.source_code = i.code
         AND srctostdvm.target_domain_id = 'Drug'
         AND srctostdvm.target_vocabulary_id = 'CVX'
         AND srctostdvm.target_standard_concept = 'S'
         AND srctostdvm.target_invalid_reason IS NULL
    JOIN @cdm_schema.source_to_source_vocab_map srctosrcvm
         ON srctosrcvm.source_code = i.code
         AND srctosrcvm.source_vocabulary_id = 'CVX'
    LEFT JOIN @cdm_schema.final_visit_ids fv
         ON fv.encounter_id = i.encounter
    LEFT JOIN @synthea_schema.encounters e
         ON i.encounter = e.id
         AND i.patient = e.patient
    LEFT JOIN @cdm_schema.provider pr
         ON e.provider = pr.provider_source_value
    JOIN @cdm_schema.person p
         ON p.person_source_value = i.patient
 ) tmp
;
