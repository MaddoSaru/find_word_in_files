WITH client_ins AS (
	SELECT 
		merchant_id,
		insurance_id
	FROM 
		client_insurance
),
order_val AS (
	SELECT 
		item.shipment_id,
		SUM(item.value) AS ORD_VALUE
	FROM
		shipment AS ship
	INNER JOIN
		item
	ON
		ship.id = item.shipment_id
	INNER JOIN 
		client_ins AS cins 
	ON
		ship.merchant_id = cins.merchant_id
	WHERE 
		ship.time_bought >= UNIX_TIMESTAMP(20220101)
	GROUP BY
		shipment_id
)
SELECT
	CONCAT(YEAR(FROM_UNIXTIME(ship.time_bought)),"-Q",QUARTER(FROM_UNIXTIME(ship.time_bought))) AS label_printed_year_quarter,
	merch.company AS brand_name,
	ins.parameters->'$.limit' AS insurance_limit,
	ROUND(AVG(ORD_VALUE),2) AS avg_ord_val
FROM 
	shipment AS ship
INNER JOIN
	merchant AS merch
ON
	ship.merchant_id = merch.id
INNER JOIN 
	client_ins AS cins
ON
	ship.merchant_id = cins.merchant_id
INNER JOIN 
	insurance AS ins
ON
	cins.insurance_id = ins.id
INNER JOIN 
	order_val as oval
ON
	ship.id = oval.shipment_id
WHERE 
	ship.time_bought >= UNIX_TIMESTAMP(20220101)
GROUP BY 
	1, 2, 3