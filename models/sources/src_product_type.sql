WITH final AS (

    SELECT
        CAST(product_type_id AS INT64)      AS product_type_id,
        CAST(product_type_name AS STRING)   AS product_type_name,
        CAST(team_id AS INT64)              AS team_id
    FROM {{ ref("product_type") }}

)

SELECT *
FROM final