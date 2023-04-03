
IF OBJECT_ID('@cdm_schema.concept', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept TO concept_old;
IF OBJECT_ID('@cdm_schema.concept_ancesTOr', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_ancesTOr TO concept_ancesTOr_old;
IF OBJECT_ID('@cdm_schema.concept_class', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_class TO concept_class_old;
IF OBJECT_ID('@cdm_schema.concept_relationship', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_relationship TO concept_relationship_old;
IF OBJECT_ID('@cdm_schema.concept_synonym', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_synonym TO concept_synonym_old;
IF OBJECT_ID('@cdm_schema.source_TO_concept_map', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.source_TO_concept_map TO source_TO_concept_map_old;

IF OBJECT_ID('@cdm_schema.concept_orig', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_orig TO concept;
IF OBJECT_ID('@cdm_schema.concept_ancesTOr_orig', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_ancesTOr_orig TO concept_ancesTOr;
IF OBJECT_ID('@cdm_schema.concept_class_orig', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_class_orig TO concept_class;
IF OBJECT_ID('@cdm_schema.concept_relationship_orig', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_relationship_orig TO concept_relationship;
IF OBJECT_ID('@cdm_schema.concept_synonym_orig', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.concept_synonym_orig TO concept_synonym;
IF OBJECT_ID('@cdm_schema.source_TO_concept_map_orig', 'U') IS NOT NULL RENAME OBJECT @cdm_schema.source_TO_concept_map_orig TO source_TO_concept_map;

IF OBJECT_ID('@cdm_schema.concept_old', 'U') IS NOT NULL DROP TABLE @cdm_schema.concept_old;
IF OBJECT_ID('@cdm_schema.concept_ancesTOr_old', 'U') IS NOT NULL DROP TABLE @cdm_schema.concept_ancesTOr_old;
IF OBJECT_ID('@cdm_schema.concept_class_old', 'U') IS NOT NULL DROP TABLE @cdm_schema.concept_class_old;
IF OBJECT_ID('@cdm_schema.concept_relationship_old', 'U') IS NOT NULL DROP TABLE @cdm_schema.concept_relationship_old;
IF OBJECT_ID('@cdm_schema.concept_synonym_old', 'U') IS NOT NULL DROP TABLE @cdm_schema.concept_synonym_old;
IF OBJECT_ID('@cdm_schema.source_TO_concept_map_old', 'U') IS NOT NULL DROP TABLE @cdm_schema.source_TO_concept_map_old;


