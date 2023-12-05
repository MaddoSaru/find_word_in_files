-- updated to replace all and added signup date and week
SELECT 
	ci.merchant_id,
	m.company,
	FROM_UNIXTIME(ci.created, '%Y-%m-%d') as insurance_signup_date,
	FROM_UNIXTIME(ci.created, '%Y-W%u') as insurance_signup_year_week
FROM client_insurance ci 
LEFT JOIN merchant m ON ci.merchant_id = m.id
WHERE ci.insurance_id BETWEEN 10 AND 14
AND ci.archived = 0
AND m.archived = 0
