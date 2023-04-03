
INSERT INTO @cdm_schema.observation_period (
    observation_period_id,
    person_id,
    observation_period_start_date,
    observation_period_end_date,
    period_type_concept_id
)
SELECT ROW_NUMBER() OVER(ORDER BY person_id),
       person_id,
       start_date,
       end_date,
       44814724 period_type_concept_id
FROM (
    SELECT p.person_id,
           MIN(e.start) start_date,
           MAX(e.stop) end_date
    FROM @cdm_schema.person p
    JOIN @synthea_schema.encounters e
         ON p.person_source_value = e.patient
    GROUP BY p.person_id
       ) tmp;
