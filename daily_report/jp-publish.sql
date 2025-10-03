-- publish
WITH filtered_listings AS (
SELECT user_id, start_time
FROM listings
WHERE  managed = TRUE
AND start_time >= '2025-09-20 16:00:00'
)
SELECT  DATE_TRUNC('day', (l.start_time AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Shanghai')) AS day_beijing, COUNT(1) AS listingnum
FROM filtered_listings l JOIN accounts a ON l.user_id = a.user_id and a.country='JP'

GROUP BY  day_beijing ORDER BY day_beijing desc;