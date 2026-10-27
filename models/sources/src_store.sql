WITH final AS (

    SELECT
        CAST(store_id AS STRING)        AS store_id,
        CAST(store_name AS STRING)      AS store_name,
        CAST(store_address AS STRING)   AS store_address,
        CAST(store_type_id AS STRING)   AS store_type_id
    FROM {{ ref("store") }}

)

SELECT *
FROM final