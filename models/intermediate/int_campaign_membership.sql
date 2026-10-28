-- One row per product and period in which it was part of a campaign,
-- either individually or through its product type. valid_to is exclusive.

WITH product_snapshot AS (

    SELECT * FROM {{ ref("snapshot_src_campaign_product") }}

), product_type_snapshot AS (

    SELECT * FROM {{ ref("snapshot_src_campaign_product_type") }}

), product_memberships AS (

    -- Merge all versions of a membership (e.g. forecast revisions) into one period.
    -- Memberships that already existed at the first snapshot run start early, so past campaigns keep their sales.
    SELECT
        campaign_id,
        product_id,
        CASE
            WHEN MIN(dbt_valid_from) = (SELECT MIN(dbt_valid_from) FROM product_snapshot)
                THEN DATE '2020-01-01'
            ELSE DATE(MIN(dbt_valid_from))
        END                                         AS valid_from,
        IF(
            COUNTIF(dbt_valid_to IS NULL) > 0,
            DATE '9999-12-31',
            DATE(MAX(dbt_valid_to))
        )                                           AS valid_to
    FROM product_snapshot
    GROUP BY campaign_product_id, campaign_id, product_id

), product_type_memberships AS (

    -- Same logic for campaigns that include a whole product type
    SELECT
        campaign_id,
        product_type_id,
        CASE
            WHEN MIN(dbt_valid_from) = (SELECT MIN(dbt_valid_from) FROM product_type_snapshot)
                THEN DATE '2020-01-01'
            ELSE DATE(MIN(dbt_valid_from))
        END                                         AS valid_from,
        IF(
            COUNTIF(dbt_valid_to IS NULL) > 0,
            DATE '9999-12-31',
            DATE(MAX(dbt_valid_to))
        )                                           AS valid_to
    FROM product_type_snapshot
    GROUP BY campaign_product_type_id, campaign_id, product_type_id

), product_type_memberships_expanded AS (

    -- Expand product types into products, using the product type each product had at the time (Type 2 in dim_product)
    SELECT
        ptm.campaign_id,
        dp.product_id,
        GREATEST(ptm.valid_from, dp.valid_from)                                 AS valid_from,
        LEAST(ptm.valid_to, COALESCE(dp.valid_to, DATE '9999-12-31'))           AS valid_to
    FROM product_type_memberships AS ptm
    INNER JOIN {{ ref("dim_product") }} AS dp
        ON ptm.product_type_id = dp.product_type_id

), all_memberships AS (

    SELECT campaign_id, product_id, 'product' AS inclusion_type, valid_from, valid_to
    FROM product_memberships
    UNION ALL
    SELECT campaign_id, product_id, 'product_type' AS inclusion_type, valid_from, valid_to
    FROM product_type_memberships_expanded

), final AS (

    -- Limit each membership to the days the campaign was running (end_date is inclusive)
    SELECT
        am.campaign_id,
        am.product_id,
        am.inclusion_type,
        GREATEST(am.valid_from, dc.start_date)                                  AS valid_from,
        LEAST(am.valid_to, DATE_ADD(dc.end_date, INTERVAL 1 DAY))               AS valid_to
    FROM all_memberships AS am
    INNER JOIN {{ ref("dim_campaign") }} AS dc
        ON am.campaign_id = dc.campaign_id

)

SELECT *
FROM final
WHERE valid_from < valid_to
