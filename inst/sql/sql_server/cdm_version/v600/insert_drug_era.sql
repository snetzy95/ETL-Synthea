-- Code version update from OMOP CDM v5.4 to OMOP CDM v6.0
-- Developed by Bence Nagy (E-Group)
-- Last modification: 2023-03-28

-- Code taken from Synthea

-- Code taken from:
-- https://github.com/OHDSI/ETL-CMS/blob/master/SQL/create_CDMv5_drug_era_non_stockpile.sql


IF OBJECT_ID('tempdb..#tmp_de', 'U') IS NOT NULL DROP TABLE #tmp_de;

WITH
ctePreDrugTarget(drug_exposure_id, person_id, ingredient_concept_id, drug_exposure_start_datetime, days_supply, drug_exposure_end_datetime) AS
(-- Normalize DRUG_EXPOSURE_END_DATETIME to either the existing drug exposure end datetime, or add days supply, or add 1 day to the start datetime
    SELECT
          d.drug_exposure_id
        , d.person_id
        , c.concept_id AS ingredient_concept_id
        , d.drug_exposure_start_datetime AS drug_exposure_start_datetime
        , d.days_supply AS days_supply
        , COALESCE(
              ---NULLIF returns NULL if both values are the same, otherwise it returns the first parameter
              NULLIF(drug_exposure_end_datetime, NULL),
              ---If drug_exposure_end_datetime != NULL, return drug_exposure_end_datetime, otherwise go to next case
              NULLIF(DATEADD(day,days_supply,drug_exposure_start_datetime), drug_exposure_start_datetime),
              ---If days_supply != NULL or 0, return drug_exposure_start_datetime + days_supply, otherwise go to next case
              DATEADD(day,1,drug_exposure_start_datetime)
              ---Add 1 day to the drug_exposure_start_datetime since there is no end_datetime or INTERVAL for the days_supply
          ) AS drug_exposure_end_datetime
    FROM @cdm_schema.drug_exposure d
        JOIN @cdm_schema.concept_ancestor ca
             ON ca.descendant_concept_id = d.drug_concept_id
        JOIN @cdm_schema.concept c
             ON ca.ancestor_concept_id = c.concept_id
        WHERE c.vocabulary_id = 'RxNorm' ---8 selects RxNorm from the vocabulary_id
             AND c.concept_class_id = 'Ingredient'
             AND d.drug_concept_id != 0 ---Our unmapped drug_concept_id's are set to 0, so we don't want different drugs wrapped up in the same era
             AND COALESCE(d.days_supply,0) >= 0 ---We have cases where days_supply is negative, and this can set the end_datetime before the start_datetime, which we don't want. So we're just looking over those rows. This is a data-quality issue.
)

, cteSubExposureEndDates (person_id, ingredient_concept_id, end_datetime) AS --- A preliminary sorting that groups all of the overlapping exposures into one exposure so that we don't double-count non-gap-days
(
    SELECT person_id, ingredient_concept_id, event_datetime AS end_datetime
    FROM
    (
        SELECT person_id, ingredient_concept_id, event_datetime, event_type,
               MAX(start_ordinal) OVER (PARTITION BY person_id, ingredient_concept_id
                                            ORDER BY event_datetime, event_type ROWS unbounded preceding) AS start_ordinal,
               -- this pulls the current START down from the prior rows so that the NULLs
               -- from the END DATES will contain a value we can compare with
               ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id
                                      ORDER BY event_datetime, event_type) AS overall_ord
            -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
        FROM (
            -- select the start dates, assigning a row number to each
            SELECT person_id, ingredient_concept_id, drug_exposure_start_datetime AS event_datetime,
                   -1 AS event_type,
                   ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id
                                          ORDER BY drug_exposure_start_datetime) AS start_ordinal
            FROM ctePreDrugTarget

            UNION ALL

            SELECT person_id, ingredient_concept_id, drug_exposure_end_datetime, 1 AS event_type, NULL
            FROM ctePreDrugTarget
        ) RAWDATA
    ) e
    WHERE (2 * e.start_ordinal) - e.overall_ord = 0
)

, cteDrugExposureEnds (person_id, drug_concept_id, drug_exposure_start_datetime, drug_sub_exposure_end_datetime) AS
(
SELECT
      dt.person_id
    , dt.ingredient_concept_id
    , dt.drug_exposure_start_datetime
    , MIN(e.end_datetime) AS drug_sub_exposure_end_datetime
FROM ctePreDrugTarget dt
JOIN cteSubExposureEndDates e
     ON dt.person_id = e.person_id
     AND dt.ingredient_concept_id = e.ingredient_concept_id
     AND e.end_datetime >= dt.drug_exposure_start_datetime
GROUP BY
      dt.drug_exposure_id
    , dt.person_id
    , dt.ingredient_concept_id
    , dt.drug_exposure_start_datetime
)
--------------------------------------------------------------------------------------------------------------
, cteSubExposures(ROW_NUMBER, person_id, drug_concept_id, drug_sub_exposure_start_datetime, drug_sub_exposure_end_datetime, drug_exposure_count) AS
(
    SELECT ROW_NUMBER() OVER (PARTITION BY person_id, drug_concept_id, drug_sub_exposure_end_datetime ORDER BY person_id)
         , person_id, drug_concept_id, MIN(drug_exposure_start_datetime) AS drug_sub_exposure_start_datetime, drug_sub_exposure_end_datetime, COUNT(*) AS drug_exposure_count
    FROM cteDrugExposureEnds
    GROUP BY person_id, drug_concept_id, drug_sub_exposure_end_datetime
    --ORDER BY person_id, drug_concept_id
)
--------------------------------------------------------------------------------------------------------------
/*Everything above grouped exposures into sub_exposures if there was overlap between exposures.
 *So there was no persistence window. Now we can add the persistence window to calculate eras.
 */
--------------------------------------------------------------------------------------------------------------
, cteFinalTarget(ROW_NUMBER, person_id, ingredient_concept_id, drug_sub_exposure_start_datetime, drug_sub_exposure_end_datetime, drug_exposure_count, days_exposed) AS
(
    SELECT ROW_NUMBER, person_id, drug_concept_id, drug_sub_exposure_start_datetime, drug_sub_exposure_end_datetime, drug_exposure_count
         , DATEDIFF(day,drug_sub_exposure_start_datetime,drug_sub_exposure_end_datetime) AS days_exposed
    FROM cteSubExposures
)
--------------------------------------------------------------------------------------------------------------
, cteEndDates (person_id, ingredient_concept_id, end_datetime) AS -- the magic
(
    SELECT person_id, ingredient_concept_id, DATEADD(day,-30,event_datetime) AS end_datetime -- unpad the end date
    FROM
    (
        SELECT person_id, ingredient_concept_id, event_datetime, event_type,
               MAX(start_ordinal) OVER (PARTITION BY person_id, ingredient_concept_id
                                            ORDER BY event_datetime, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal,
                -- this pulls the current START down from the prior rows so that the NULLs
                -- from the END DATES will contain a value we can compare with
               ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id
                                      ORDER BY event_datetime, event_type) AS overall_ord
        -- this re-numbers the inner UNION so all rows are numbered ordered by the event datetime
        FROM (
            -- select the start dates, assigning a row number to each
            SELECT person_id, ingredient_concept_id, drug_sub_exposure_start_datetime AS event_datetime,
                   -1 AS event_type,
                   ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id
                                          ORDER BY drug_sub_exposure_start_datetime) AS start_ordinal
            FROM cteFinalTarget

            UNION ALL

            -- pad the end dates by 30 to allow a grace period for overlapping ranges.
            SELECT person_id, ingredient_concept_id, DATEADD(day,30,drug_sub_exposure_end_datetime), 1 AS event_type, NULL
            FROM cteFinalTarget
        ) RAWDATA
    ) e
    WHERE (2 * e.start_ordinal) - e.overall_ord = 0

)
, cteDrugEraEnds (person_id, drug_concept_id, drug_sub_exposure_start_datetime, drug_era_end_datetime, drug_exposure_count, days_exposed) AS
(
SELECT
      ft.person_id
    , ft.ingredient_concept_id
    , ft.drug_sub_exposure_start_datetime
    , MIN(e.end_datetime) AS era_end_datetime
    , drug_exposure_count
    , days_exposed
FROM cteFinalTarget ft
JOIN cteEndDates e
     ON ft.person_id = e.person_id
     AND ft.ingredient_concept_id = e.ingredient_concept_id
     AND e.end_datetime >= ft.drug_sub_exposure_start_datetime
GROUP BY
      ft.person_id
    , ft.ingredient_concept_id
    , ft.drug_sub_exposure_start_datetime
    , drug_exposure_count
    , days_exposed
)
SELECT
      ROW_NUMBER()OVER(ORDER BY person_id) drug_era_id
    , person_id
    , drug_concept_id
    , MIN(drug_sub_exposure_start_datetime) AS drug_era_start_datetime
    , drug_era_end_datetime
    , SUM(drug_exposure_count) AS drug_exposure_count
    , DATEDIFF(day,MIN(drug_sub_exposure_start_datetime),drug_era_end_datetime)-SUM(days_exposed) AS gap_days
INTO #tmp_de
FROM cteDrugEraEnds dee
GROUP BY person_id, drug_concept_id, drug_era_end_datetime;

INSERT INTO @cdm_schema.drug_era(drug_era_id,person_id, drug_concept_id, drug_era_start_datetime, drug_era_end_datetime, drug_exposure_count, gap_days)
SELECT * FROM #tmp_de;
