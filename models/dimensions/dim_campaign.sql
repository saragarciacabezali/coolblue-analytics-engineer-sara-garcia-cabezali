WITH campaigns AS (

    SELECT
        cm.campaign_id,
        cm.employee_id,
        ce.employee_name,
        cm.campaign_name,
        cm.start_date,
        cm.end_date,
        cm.discount_rate
    FROM {{ ref("src_campaign") }} AS cm
    INNER JOIN {{ ref("src_campaign_employee") }} AS ce
        ON cm.employee_id = ce.employee_id

), no_campaign AS (

    SELECT
        '-1'                    AS campaign_id,
        CAST(NULL AS STRING)    AS employee_id,
        'No manager'            AS employee_name,
        'No campaign'           AS campaign_name,
        CAST(NULL AS DATE)      AS start_date,
        CAST(NULL AS DATE)      AS end_date,
        CAST(NULL AS NUMERIC)   AS discount_rate

), final AS (

    SELECT * FROM no_campaign
    UNION ALL 
    SELECT * FROM campaigns

)

SELECT *
FROM final