-- One row per campaign that has started: actual quantity sold vs forecast.
-- Each fact is aggregated to campaign level first and only then joined (drill-across),
-- so forecasts are never repeated per sale.

WITH actuals AS (

    SELECT
        campaign_id,
        SUM(quantity)                       AS actual_quantity
    FROM {{ ref("fact_sales") }}
    WHERE campaign_id != '-1'
    GROUP BY campaign_id

), all_forecasts AS (

    -- Forecasts of both grains, combined to be summed per campaign
    SELECT campaign_id, forecast_quantity
    FROM {{ ref("fact_campaign_product_forecast") }}
    UNION ALL
    SELECT campaign_id, forecast_quantity
    FROM {{ ref("fact_campaign_product_type_forecast") }}

), forecasts AS (

    SELECT
        campaign_id,
        SUM(forecast_quantity)              AS forecast_quantity
    FROM all_forecasts
    GROUP BY campaign_id

), final AS (

    SELECT
        dc.campaign_id,
        dc.campaign_name,
        dc.campaign_manager_name,
        dc.start_date,
        dc.end_date,
        dc.discount_rate,
        dc.end_date >= CURRENT_DATE('Europe/Amsterdam')                         AS is_running,
        COALESCE(a.actual_quantity, 0)                                          AS actual_quantity,
        COALESCE(f.forecast_quantity, 0)                                        AS forecast_quantity,
        COALESCE(a.actual_quantity, 0) - COALESCE(f.forecast_quantity, 0)       AS quantity_vs_forecast,
        SAFE_DIVIDE(COALESCE(a.actual_quantity, 0), f.forecast_quantity)        AS actual_vs_forecast_ratio
    FROM {{ ref("dim_campaign") }} AS dc
    LEFT JOIN actuals AS a
        ON dc.campaign_id = a.campaign_id
    LEFT JOIN forecasts AS f
        ON dc.campaign_id = f.campaign_id
    WHERE dc.campaign_id != '-1'
      AND dc.start_date <= CURRENT_DATE('Europe/Amsterdam')  -- Future campaigns are not shown on the dashboard

)

SELECT *
FROM final
