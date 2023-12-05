WITH insured_brands_by_year_month AS (
	SELECT
		FROM_UNIXTIME(ci.created, '%Y-%M') AS insurance_created_year_month,
		COUNT(ci.merchant_id) AS insured_brand_count
	FROM client_insurance ci 
	WHERE ci.merchant_id IS NOT NULL
	GROUP BY 1
),
total_brands_by_year_month AS (
	SELECT
		FROM_UNIXTIME(m.created, '%Y-%M') AS brand_created_year_month,
		COUNT(m.id) AS brand_count
	FROM merchant_clean m 
	GROUP BY 1
),
latest_label_print_date_by_brand AS ( 
  SELECT 
  	s.merchant_id, 
  	MAX(s.time_bought) latest_label_print_date 
  FROM shipment s 
  JOIN merchant_clean mc ON s.merchant_id = mc.id
  WHERE s.time_bought >= 1641013200 GROUP BY 1
 ),
total_active_brands_by_year_month AS ( 
  SELECT 
  	COUNT(merchant_id) AS active_brand_count 
  FROM latest_label_print_date_by_brand 
  WHERE latest_label_print_date >= UNIX_TIMESTAMP(NOW() - INTERVAL 90 DAY)
)
SELECT 
	t1.brand_created_year_month AS 'year_month',
	t1.brand_count,
	t2.insured_brand_count,
	t3.active_brand_count
FROM total_brands_by_year_month t1
LEFT JOIN insured_brands_by_year_month t2 ON t1.brand_created_year_month = t2.insurance_created_year_month
LEFT JOIN total_active_brands_by_year_month t3 ON t1.brand_created_year_month = FROM_UNIXTIME(UNIX_TIMESTAMP(NOW()), '%Y-%M')