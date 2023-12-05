WITH `exclude` AS
	(
	SELECT
		s.id,
		DATE(FROM_UNIXTIME(s.time_bought)),
		s.insurance_external_cost,
		s.insurance_internal_cost,
		SUM(i.value) AS total_value
	FROM
		shipment s FORCE INDEX (shipment_time_bought_IDX)
	JOIN item i ON
		i.shipment_id = s.id
	WHERE 1 = 1
		AND s.time_bought BETWEEN 1637816400 AND 1641013200
		AND s.insurance_external_cost IS NOT NULL
		AND s.insurance_external_cost > 0
	HAVING total_value <= 100
	)
SELECT 
	m.company 'Customer', 
	cl.company '3PL',
	CASE 
		WHEN ci.archived = 0 THEN "Insured"
		ELSE "Not Insured Currently"
	END AS "Current Insurance Status",
	DATE(FROM_UNIXTIME(MIN(s.time_bought))) 'Start date',
	DATE(FROM_UNIXTIME(MAX(s.time_bought))) 'Last insured shipment',
	COUNT(s.id) 'Shipments',
	CEILING(AVG(COALESCE(s.insurance_external_cost, 0) / 1.2)) * 100 'Avg insured amount',
	SUM(COALESCE(s.insurance_external_cost, 0)) AS 'Total Insurance Paid All Time'
FROM
	(
	SELECT
		merchant_id,
		client_id,
		time_bought,
		s.id,
		insurance_external_cost
	FROM
		shipment s
	JOIN invoice_shipment inv ON
		inv.shipment_id = s.id
	WHERE
		1 = 1
		AND s.archived = 0
		AND s.is_voided = 0
		AND s.insurance_external_cost IS NOT NULL
		AND s.insurance_external_cost != 0
		AND s.id NOT IN (
		SELECT
			id
		FROM
			`exclude`)
      ) s
LEFT JOIN merchant m ON
	m.id = s.merchant_id
LEFT JOIN client cl ON
	cl.id = s.client_id
LEFT JOIN client_insurance ci 
	ON ci.merchant_id = m.id AND ci.client_id = cl.id
WHERE
	cl.is_test = 0
	AND m.archived = 0
	AND m.company NOT IN ("Passport", "ShipTest", "company2", "aboltest")
GROUP BY
	m.company,
	cl.company
ORDER BY
	`Start date` ASC;