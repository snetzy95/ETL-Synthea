
SELECT DISTINCT condition_concept_id AS concept_id FROM @cdm_schema.condition_occurrence
UNION
SELECT DISTINCT procedure_concept_id               FROM @cdm_schema.procedure_occurrence
UNION
SELECT DISTINCT drug_concept_id                    FROM @cdm_schema.drug_exposure
UNION
SELECT DISTINCT measurement_concept_id             FROM @cdm_schema.measurement
UNION
SELECT DISTINCT observation_concept_id             FROM @cdm_schema.observation
UNION
SELECT DISTINCT visit_concept_id                   FROM @cdm_schema.visit_occurrence
UNION
SELECT DISTINCT drug_concept_id                    FROM @cdm_schema.drug_era
UNION
SELECT DISTINCT condition_concept_id               FROM @cdm_schema.condition_era;


