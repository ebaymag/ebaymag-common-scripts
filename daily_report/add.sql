-- -- add
SELECT a.country,DATE_TRUNC('day', (l.selected_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Shanghai')) AS day_beijing,
       COUNT(1) AS listingnum
FROM listings l
         INNER JOIN accounts a ON l.user_id = a.user_id
WHERE l.managed = TRUE
  AND a.refresh_token_expires_at > NOW()
  AND l.selected_at >= '2025-09-12 16:00:00'
GROUP BY a.country,day_beijing
ORDER BY day_beijing;