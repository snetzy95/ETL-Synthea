
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

UNION ALL

SELECT person_id                                             person_id,
       condition_occurrence_id                               cost_event_id,
       4118469                                               cost_event_field_concept_id,   --condition
       0                                                     cost_concept_id,
       32814                                                 cost_type_concept_id,
       44818668                                              currency_concept_id,
       payer_paid + patient_paid                             cost,
       CAST(NULL AS DATE)                                    incurred_date,
       payer_plan_period_start_date                          billed_date,
       CAST(NULL AS DATE)                                    paid_date,
       0                                                     revenue_code_concept_id,
       0                                                     drg_concept_id,
       'UNKNOWN / UNKNOWN'                                   cost_source_value,
       0                                                     cost_source_concept_id,
       'UNKNOWN / UNKNOWN'                                   revenue_code_source_value,
       '000'                                                 drg_source_value,
       payer_plan_period_id                                  payer_plan_period_id
FROM (
    SELECT p.person_id,
           co.condition_occurrence_id,
           ppp.payer_plan_period_id,
           ppp.payer_plan_period_start_date,
           COALESCE(CASE WHEN ct.transfertype = '1' THEN ct.amount END,0) payer_paid,
           COALESCE(CASE WHEN ct.transfertype = 'p' THEN ct.amount END,0) patient_paid
    FROM @synthea_schema.conditions cn
    JOIN @synthea_schema.encounters e
         ON cn.encounter = e.id
         AND cn.patient = e.patient
    JOIN @cdm_schema.person p
         ON cn.patient = p.person_source_value
    JOIN @cdm_schema.visit_occurrence vo
         ON p.person_id = vo.person_id
         AND e.id = vo.visit_source_value
    JOIN @cdm_schema.condition_occurrence co
         ON cn.code = co.condition_source_value
         AND vo.visit_occurrence_id = co.visit_occurrence_id
         AND vo.person_id = co.person_id
    LEFT JOIN @cdm_schema.payer_plan_period ppp
         ON p.person_id = ppp.person_id
         AND ppp.payer_plan_period_start_date <= co.condition_start_date
         AND ppp.payer_plan_period_end_date >= co.condition_start_date
    JOIN @synthea_schema.claims ca
         ON cn.patient = ca.patientid
         AND cn.code = ca.diagnosis1
         AND cn.start = ca.currentillnessdate
         AND e.id = ca.appointmentid
         AND e.provider = ca.providerid
         AND e.payer = ca.primarypatientinsuranceid
         AND e.start = ca.servicedate
    JOIN @synthea_schema.claims_transactions ct
         ON ca.id = ct.claimid
         AND cn.patient = ct.patientid
         AND e.id = ct.appointmentid
         AND e.provider = ct.providerid
    WHERE ct.transfertype IN ('1','p')
    ) AS tmp1
) AS tmp
;