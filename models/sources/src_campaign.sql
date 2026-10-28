WITH final AS (

    SELECT
        CAST(campaign_id AS STRING)     AS campaign_id,
        CAST(campaign_name AS STRING)   AS campaign_name,
        CAST(employee_id AS STRING)     AS campaign_manager_id,
        CAST(start_date AS DATE)        AS start_date,
        CAST(end_date AS DATE)          AS end_date,
        CAST(discount_perc AS NUMERIC) / 100   AS discount_rate  -- 0.25 = 25%

    FROM {{ ref("campaign") }}

)

SELECT *
FROM final