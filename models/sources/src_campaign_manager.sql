WITH final AS (

    SELECT
        CAST(employee_id AS STRING)     AS campaign_manager_id,
        CAST(employee_name AS STRING)   AS campaign_manager_name
    FROM {{ ref("campaign_manager") }}

)

SELECT *
FROM final
