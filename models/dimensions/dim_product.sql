WITH final AS (

    SELECT
        sp.dbt_scd_id AS product_key,
        sp.product_id,
        sp.product_type_id,
        pt.product_type_name,
        pt.team_id,
        FIRST_VALUE(sp.product_name) OVER (
            PARTITION BY sp.product_id ORDER BY sp.dbt_valid_to DESC NULLS FIRST ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
            ) AS product_name, -- Type 1: latest product name on all versions
        CASE
            WHEN sp.dbt_valid_from = MIN(sp.dbt_valid_from) OVER (PARTITION BY sp.product_id)
            THEN DATE '2020-01-01'
            ELSE CAST(sp.dbt_valid_from AS DATE)
            END
                                    AS valid_from,
        CAST(sp.dbt_valid_to AS DATE) AS valid_to,
        sp.dbt_valid_to IS NULL AS is_current

    FROM {{ ref("snapshot_src_product") }} AS sp
    LEFT JOIN {{ ref("src_product_type") }} AS pt -- Edge case: Eventhough we test relationsips between product and product_type in the source, what if a product type is deleted
        ON sp.product_type_id = pt.product_type_id

)

SELECT *
FROM final