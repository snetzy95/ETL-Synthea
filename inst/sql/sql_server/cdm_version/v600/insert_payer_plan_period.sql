-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-28

-- Code taken from Synthea

INSERT INTO @cdm_schema.payer_plan_period (
    payer_plan_period_id,
    person_id,
    contract_person_id,
    payer_plan_period_start_date,
    payer_plan_period_end_date,
    payer_concept_id,
    plan_concept_id,
    contract_concept_id,
    sponsor_concept_id,
    stop_reason_concept_id,
    payer_source_value,
    payer_source_concept_id,
    plan_source_value,
    plan_source_concept_id,
    contract_source_value,
    contract_source_concept_id,
    sponsor_source_value,
    sponsor_source_concept_id,
    family_source_value,
    stop_reason_source_value,
    stop_reason_source_concept_id
)

SELECT ROW_NUMBER()OVER(ORDER BY pat.id, pt.start_year) payer_plan_period_id,
       per.person_id                                    person_id,
       CAST(NULL AS INTEGER)                            contract_person_id,

       {@synthea_version == "2.7.0"} ? {
       CAST(CONCAT('01-JAN-',CAST(pt.start_year AS VARCHAR)) AS DATE) payer_plan_period_start_date,
       CAST(CONCAT('31-DEC-',CAST(pt.end_year AS VARCHAR)) AS DATE)   payer_plan_period_end_date,
       }

       {@synthea_version == "3.0.0"} ? {
       CAST(pt.start_year AS DATE)                      payer_plan_period_start_date,
       CAST(pt.end_year AS DATE)                        payer_plan_period_end_date,
       }

       0                                                payer_concept_id,
       0                                                plan_concept_id,
       0                                                contract_concept_id,
       0                                                sponsor_concept_id,
       0                                                stop_reason_concept_id,
       pt.payer                                         payer_source_value,
       0                                                payer_source_concept_id,
       pay.name                                         plan_source_value,
       0                                                plan_source_concept_id,
       per.person_source_value                          contract_source_value,
       0                                                contract_source_concept_id,
       CAST(NULL AS VARCHAR)                            sponsor_source_value,
       0                                                sponsor_source_concept_id,
       CAST(NULL AS VARCHAR)                            family_source_value,
       CAST(NULL AS VARCHAR)                            stop_reason_source_value,
       0                                                stop_reason_source_concept_id
FROM @synthea_schema.payers pay 
JOIN @synthea_schema.payer_transitions pt
     ON pay.id = pt.payer
JOIN @synthea_schema.patients pat
     ON pt.patient = pat.id  
JOIN @cdm_schema.person per
     ON pat.id = per.person_source_value
;
