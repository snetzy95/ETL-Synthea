-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-29

-- Code taken from Synthea

INSERT INTO @cdm_schema.procedure_occurrence (
    procedure_occurrence_id,
    person_id,
    procedure_concept_id,
    procedure_date,
    procedure_datetime,
    procedure_type_concept_id,
    modifier_concept_id,
    quantity,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    procedure_source_value,
    procedure_source_concept_id,
    modifier_source_value
)
SELECT ROW_NUMBER()OVER(ORDER BY p.person_id)   procedure_occurrence_id,
       p.person_id                              person_id,
       srctostdvm.target_concept_id             procedure_concept_id,

       {@synthea_version == "2.7.0"} ? {
       pr.date                                  procedure_date,
       pr.date                                  procedure_datetime,
       }

       {@synthea_version == "3.0.0"} ? {
       pr.start                                 procedure_date,
       pr.start                                 procedure_datetime,
       }

       38000267                                 procedure_type_concept_id,
       0                                        modifier_concept_id,
       CAST(NULL AS INTEGER)                    quantity,
       prv.provider_id                          provider_id,
       fv.visit_occurrence_id_new               visit_occurrence_id,
       fv.visit_occurrence_id_new + 1000000     visit_detail_id,
       pr.code                                  procedure_source_value,
       srctosrcvm.source_concept_id             procedure_source_concept_id,
       CAST(NULL AS VARCHAR)                    modifier_source_value
FROM @synthea_schema.procedures pr
JOIN @cdm_schema.source_to_standard_vocab_map srctostdvm
     ON srctostdvm.source_code = pr.code
     AND srctostdvm.target_domain_id = 'Procedure'
     AND srctostdvm.target_vocabulary_id = 'SNOMED'
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
;
