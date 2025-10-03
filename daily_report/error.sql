SELECT
    DATE_TRUNC('day', (p.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Shanghai')) AS day_beijing,
    COUNT(1)
FROM
    problems p
        JOIN listings l ON l.id = p.source_id
        JOIN accounts a ON l.user_id = a.user_id AND a.country = 'JP'
WHERE
    p.source_type = 'Listing'
  AND p.context = 'publishing'
  AND p.created_at > '2025-09-01'
GROUP BY
    day_beijing;