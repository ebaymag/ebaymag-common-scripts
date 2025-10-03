-- pending all
SELECT a.country, COUNT(1) AS total_listings
FROM listings l
JOIN accounts a ON l.user_id = a.user_id
LEFT JOIN products p ON l.user_id = p.user_id AND l.source_id = p.id
LEFT JOIN showcases s ON l.user_id = s.user_id AND l.showcase_id = s.id
LEFT JOIN problems ON problems.source_id = l.id AND problems.source_type = 'Listing'
WHERE l.selected_at IS NOT NULL
  AND l.item_id IS NULL
  AND (p.archived IS NULL OR p.archived = FALSE)
  AND p.deleted_at IS NULL
  AND s.free_limit_reached_at IS NULL
  AND (problems.severity = 'warning' OR problems.id IS NULL)
  and a.refresh_token_expires_at > NOW()
GROUP BY a.country;