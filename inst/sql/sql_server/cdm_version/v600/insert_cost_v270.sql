-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-28

-- Code taken from Synthea

INSERT INTO @cdm_schema.cost (
    cost_id,
    person_id,
    cost_event_id,
    cost_event_field_concept_id,
    cost_concept_id,
    cost_type_concept_id,
    currency_concept_id,
    cost,
    incurred_date,
    billed_date,
    paid_date,
    revenue_code_concept_id,
    drg_concept_id,
    cost_source_value,
    cost_source_concept_id,
    revenue_code_source_value,
    drg_source_value,
    payer_plan_period_id
)

SELECT ROW_NUMBER()OVER(ORDER BY tmp.cost_event_id) cost_id,
       tmp.*
FROM (
SELECT DISTINCT
       p.person_id                                           person_id,
       po.procedure_occurrence_id                            cost_event_id,
       4322976                                               cost_event_field_concept_id,   --procedure
       0                                                     cost_concept_id,
       32814                                                 cost_type_concept_id,
       44818668                                              currency_concept_id,
       e.total_claim_cost + pr.base_cost                     cost,
       CAST(NULL AS DATE)                                    incurred_date,
       ppp.payer_plan_period_start_date                      billed_date,
       CAST(NULL AS DATE)                                    paid_date,
       0                                                     revenue_code_concept_id,
       0                                                     drg_concept_id,
       'UNKNOWN / UNKNOWN'                                   cost_source_value,
       0                                                     cost_source_concept_id,
       'UNKNOWN / UNKNOWN'                                   revenue_code_source_value,
       '000'                                                 drg_source_value,
       ppp.payer_plan_period_id                              payer_plan_period_id
FROM @synthea_schema.procedures pr
JOIN @synthea_schema.encounters e
     ON pr.encounter = e.id 
     AND pr.patient = e.patient
JOIN @cdm_schema.person p
     ON pr.patient = p.person_source_value
JOIN @cdm_schema.visit_occurrence VO
     ON p.person_id = vo.person_id
     AND e.id = vo.visit_source_value
JOIN @cdm_schema.procedure_occurrence po
     ON pr.code = po.procedure_source_value
     AND vo.visit_occurrence_id = po.visit_occurrence_id
     AND vo.person_id = po.person_id
LEFT JOIN @cdm_schema.payer_plan_period ppp
     ON p.person_id = ppp.person_id
     AND ppp.payer_plan_period_start_date <= po.procedure_date
     AND ppp.payer_plan_period_end_date >= po.procedure_date

UNION ALL

SELECT DISTINCT
       p.person_id                                           person_id,
       de.drug_exposure_id                                   cost_event_id,
       36310711                                              cost_event_field_concept_id,   --drug
       0                                                     cost_concept_id,
       32814                                                 cost_type_concept_id,
       44818668                                              currency_concept_id,
       e.total_claim_cost + i.base_cost                      cost,
       CAST(NULL AS DATE)                                    incurred_date,
       ppp.payer_plan_period_start_date                      billed_date,
       CAST(NULL AS DATE)                                    paid_date,
       0                                                     revenue_code_concept_id,
       0                                                     drg_concept_id,
       'UNKNOWN / UNKNOWN'                                   cost_source_value,
       0                                                     cost_source_concept_id,
       'UNKNOWN / UNKNOWN'                                   revenue_code_source_value,
       '000'                                                 drg_source_value,
       ppp.payer_plan_period_id                              payer_plan_period_id
FROM @synthea_schema.immunizations i
JOIN @synthea_schema.encounters e
     ON i.encounter = e.id 
     AND i.patient = e.patient
JOIN @cdm_schema.person p 
     ON i.patient = p.person_source_value
JOIN @cdm_schema.visit_occurrence vo
     ON p.person_id = vo.person_id
     AND e.id = vo.visit_source_value
JOIN @cdm_schema.drug_exposure de
     ON i.code = de.drug_source_value
     AND vo.visit_occurrence_id = de.visit_occurrence_id
     AND vo.person_id = de.person_id
LEFT JOIN @cdm_schema.payer_plan_period ppp
     ON p.person_id = ppp.person_id
     AND ppp.payer_plan_period_start_date <= de.drug_exposure_start_date
     AND ppp.payer_plan_period_end_date >= de.drug_exposure_start_date

UNION ALL

SELECT DISTINCT
       p.person_id                                           person_id,
       de.drug_exposure_id                                   cost_event_id,
       36310711                                              cost_event_field_concept_id,   --drug
       0                                                     cost_concept_id,
       32814                                                 cost_type_concept_id,
       44818668                                              currency_concept_id,
       e.total_claim_cost + m.base_cost                      cost,
       CAST(NULL AS DATE)                                    incurred_date,
       ppp.payer_plan_period_start_date                      billed_date,
       CAST(NULL AS DATE)                                    paid_date,
       0                                                     revenue_code_concept_id,
       0                                                     drg_concept_id,
       'UNKNOWN / UNKNOWN'                                   cost_source_value,
       0                                                     cost_source_concept_id,
       'UNKNOWN / UNKNOWN'                                   revenue_code_source_value,
       '000'                                                 drg_source_value,
       ppp.payer_plan_period_id                              payer_plan_period_id
FROM @synthea_schema.medications m

JOIN @synthea_schema.encounters e
     ON m.encounter = e.id
     AND m.patient = e.patient

JOIN @cdm_schema.person p
     ON m.patient = p.person_source_value

JOIN @cdm_schema.visit_occurrence vo
     ON p.person_id = vo.person_id
     AND e.id = vo.visit_source_value

JOIN @cdm_schema.drug_exposure de
     ON m.code = de.drug_source_value
     AND vo.visit_occurrence_id = de.visit_occurrence_id
     AND vo.person_id = de.person_id

LEFT JOIN @cdm_schema.payer_plan_period ppp
     ON p.person_id = ppp.person_id
     AND ppp.payer_plan_period_start_date <= de.drug_exposure_start_date
     AND ppp.payer_plan_period_end_date >= de.drug_exposure_start_date

) AS tmp
;