WITH final AS (

    SELECT
        dbt_scd_id                                      AS store_key,
        store_id,
        store_type_id,
        FIRST_VALUE(store_name) OVER (
            PARTITION BY store_id 
            ORDER BY dbt_valid_to DESC NULLS FIRST ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
            )                                           AS store_name, -- Type 1: latest name on all versions
        store_address,
        CASE 
          WHEN dbt_valid_from = MIN(dbt_valid_from) OVER (
            PARTITION BY store_id
            )
          THEN DATE '2020-01-01'
          ELSE CAST(dbt_valid_from AS DATE)
          END                                           AS valid_from, -- First valid_from to cover all sales, to delete dependency on the first snapshot date
        CAST(dbt_valid_to AS DATE)                      AS valid_to,
        dbt_valid_to IS NULL                            AS is_current
    FROM {{ ref("snapshot_src_store") }}

)

SELECT *
FROM final