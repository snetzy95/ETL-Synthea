-- Code version update from OMOP CDM v5.4 TO OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-28

-- Code taken from Synthea

IF OBJECT_ID('@cdm_schema.concept_orig', 'U') IS NOT NULL DROP TABLE @cdm_schema.concept_orig;
IF OBJECT_ID('@cdm_schema.concept', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept TO concept_orig;

IF OBJECT_ID('@cdm_schema.concept_ancestor_orig', 'U') IS NOT NULL DROP TABLE @cdm_schema.concept_ancestor_orig;
IF OBJECT_ID('@cdm_schema.concept_ancestor', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_ancestor TO concept_ancestor_orig;

IF OBJECT_ID('@cdm_schema.concept_class_orig', 'U') IS NOT NULL DROP TABLE @cdm_schema.concept_class_orig;
IF OBJECT_ID('@cdm_schema.concept_class', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_class TO concept_class_orig;

IF OBJECT_ID('@cdm_schema.concept_relationship_orig', 'U') IS NOT NULL DROP TABLE @cdm_schema.concept_relationship_orig;
IF OBJECT_ID('@cdm_schema.concept_relationship', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_relationship TO concept_relationship_orig;

IF OBJECT_ID('@cdm_schema.concept_synonym_orig', 'U') IS NOT NULL DROP TABLE @cdm_schema.concept_synonym_orig;
IF OBJECT_ID('@cdm_schema.concept_synonym', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_synonym TO concept_synonym_orig;

IF OBJECT_ID('@cdm_schema.source_to_concept_map_orig', 'U') IS NOT NULL DROP TABLE @cdm_schema.source_to_concept_map_orig;
IF OBJECT_ID('@cdm_schema.source_to_concept_map', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.source_to_concept_map TO source_to_concept_map_orig;

