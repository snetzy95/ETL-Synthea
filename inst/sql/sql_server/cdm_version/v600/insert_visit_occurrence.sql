-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-29

-- Code taken from Synthea

INSERT INTO @cdm_schema.visit_occurrence (
    visit_occurrence_id,
    person_id,
    visit_concept_id,
    visit_start_date,
    visit_start_datetime,
    visit_end_date,
    visit_end_datetime,
    visit_type_concept_id,
    provider_id,
    care_site_id,
    visit_source_value,
    visit_source_concept_id,
    admitted_from_concept_id,
    admitted_from_source_value,
    discharge_to_source_value,
    discharge_to_concept_id,
    preceding_visit_occurrence_id
)
SELECT av.visit_occurrence_id,
       p.person_id,
       CASE LOWER(av.encounterclass)
            WHEN 'ambulatory' THEN 9202
            WHEN 'emergency'  THEN 9203
            WHEN 'inpatient'  THEN 9201
            WHEN 'wellness'   THEN 9202
            WHEN 'urgentcare' THEN 9203 
            WHEN 'outpatient' THEN 9202
            ELSE 0
       END,
       av.visit_start_date,
       av.visit_start_date,
       av.visit_end_date,
       av.visit_end_date,
       44818517,
       pr.provider_id,
       CAST(NULL AS INTEGER),
       av.encounter_id,
       0,
       0,
       CAST(NULL AS VARCHAR),
       CAST(NULL AS VARCHAR),
       0,
       LAG(av.visit_occurrence_id)
       OVER(PARTITION BY p.person_id
                ORDER BY av.visit_start_date)
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