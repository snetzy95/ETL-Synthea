
-- For testing purposes, create populate VISIT_DETAIL
-- such that it's basically a copy of VISIT_OCCURRENCE

INSERT INTO @cdm_schema.visit_detail (
    visit_detail_id,
    person_id,
    visit_detail_concept_id,
    visit_detail_start_date,
    visit_detail_start_datetime,
    visit_detail_end_date,
    visit_detail_end_datetime,
    visit_detail_type_concept_id,
    provider_id,
    care_site_id,
    discharge_to_concept_id,
    admitted_from_concept_id,
    admitted_from_source_value,
    visit_detail_source_value,
    visit_detail_source_concept_id,
    discharge_to_source_value,
    preceding_visit_detail_id,
    visit_detail_parent_id,
    visit_occurrence_id
)

SELECT av.visit_occurrence_id + 1000000                     visit_detail_id,
       p.person_id                                          person_id,
       CASE LOWER(av.encounterclass)
           WHEN 'ambulatory' THEN 9202
           WHEN 'emergency'  THEN 9203
           WHEN 'inpatient'  THEN 9201
           WHEN 'wellness'   THEN 9202
           WHEN 'urgentcare' THEN 9203
           WHEN 'outpatient' THEN 9202
           ELSE 0
       END                                                  visit_detail_concept_id,
       av.visit_start_date                                  visit_detail_start_date,
       av.visit_start_date                                  visit_detail_start_datetime,
       av.visit_end_date                                    visit_detail_end_date,
       av.visit_end_date                                    visit_detail_end_datetime,
       44818517                                             visit_detail_type_concept_id,
       pr.provider_id                                       provider_id,
       CAST(NULL AS INTEGER)                                care_site_id,
       0                                                    discharge_to_concept_id,
       0                                                    admitted_from_concept_id,
       0                                                    admitted_from_source_value,
       av.encounter_id                                      visit_detail_source_value,
       0                                                    visit_detail_source_concept_id,
       CAST(NULL AS VARCHAR)                                discharge_to_source_value,
       LAG(av.visit_occurrence_id)
       OVER(PARTITION BY p.person_id
                ORDER BY av.visit_start_date) + 1000000     preceding_visit_detail_id,
       CAST(NULL AS INTEGER)                                visit_detail_parent_id,
       av.visit_occurrence_id                               visit_occurrence_id
FROM @cdm_schema.all_visits av
JOIN @cdm_schema.person p
     ON av.patient = p.person_source_value
JOIN @synthea_schema.encounters e
     ON av.encounter_id = e.id
     AND av.patient = e.patient
JOIN @cdm_schema.provider pr 
     ON e.provider = pr.provider_source_value
WHERE av.visit_occurrence_id IN (SELECT DISTINCT visit_occurrence_id_new
                                   FROM @cdm_schema.final_visit_ids);