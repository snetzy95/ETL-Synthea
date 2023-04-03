-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-28

-- Code taken from Synthea

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


