
INSERT INTO @cdm_schema.cdm_source (
    cdm_source_name,
    cdm_source_abbreviation,
    cdm_holder,
    source_description,
    source_documentation_reference,
    cdm_etl_reference,
    source_release_date,
    cdm_release_date,
    cdm_version,
    vocabulary_version
)
SELECT '@cdm_source_name',
       '@cdm_source_abbreviation',
       '@cdm_holder',
       '@source_description',
       'https://synthetichealth.github.io/synthea/',
       'https://github.com/OHDSI/ETL-Synthea',
       GETDATE(), -- NB: Set this value to the day the source data was pulled
       GETDATE(),
       '@cdm_version',
       vocabulary_version
FROM @cdm_schema.vocabulary
WHERE vocabulary_id = 'None';
