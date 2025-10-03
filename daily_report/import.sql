WITH DailyImports AS (
  SELECT
     (p.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Shanghai')::date AS day_beijing,
    COUNT(1) AS DailyImportNum
  FROM
    products p
  WHERE
    p.data_source IN ('EBAY', 'EBAY_AUTO_IMPORT')
    AND p.created_at >= '2025-09-10 16:00:00'
  GROUP BY
    day_beijing
),
ManualImports AS (
  SELECT
    (t.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Shanghai')::date AS day_beijing,
    COUNT(1) AS ImportNum
  FROM
    product_import_tasks t
  INNER JOIN
    product_import_items i ON t.id = i.task_id
  WHERE
    t.created_at >= '2025-06-28 16:00:00'
  GROUP BY
    day_beijing
),
AutomaticImports AS (
  SELECT
     (original_time AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Shanghai')::date AS day_beijing,
    COUNT(*) AS CountOfExceptions
  FROM (
      SELECT em.uuid, em.original_time
      FROM event_store_messages em
      WHERE em.kind = 'itemListed'
        AND em.original_time > '2025-09-12 16:00:00'
  ) filtered_em
  LEFT JOIN event_store_completions ec ON filtered_em.uuid = ec.message_uuid
  WHERE ec.message_uuid IS NULL
  GROUP BY
    day_beijing
)
select t1.*,t2.impSpeed,t2.totalnum from 
(SELECT
  COALESCE(di.day_beijing, mi.day_beijing, ai.day_beijing) AS day_beijing,
  COALESCE(ai.CountOfExceptions, 0) AS AutomaticImportNum,
  COALESCE(mi.ImportNum, 0) AS ManualImportNum,
  COALESCE(di.DailyImportNum, 0) AS DailyImportNum
FROM
  DailyImports di
 left JOIN
  ManualImports mi ON di.day_beijing = mi.day_beijing
 left JOIN
  AutomaticImports ai ON di.day_beijing = ai.day_beijing OR mi.day_beijing = ai.day_beijing
ORDER BY
  day_beijing desc) as t1

left join 


 (SELECT
    ROUND(CAST(SUM(CAST(data->>'time_cost' AS double precision)) / SUM(CAST(data->>'total_items' AS INTEGER)) AS numeric), 2) AS impSpeed,
  TO_CHAR(DATE_TRUNC('day', (created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Shanghai')), 'YYYY-MM-DD')::date AS day_beijing,
    SUM(CAST(data->>'total_items' AS INTEGER)) AS totalnum
FROM
    action_logs
WHERE
    action = 'item_import'
    AND created_at > '2025-09-12 16:00:00'
GROUP BY
    day_beijing
ORDER BY
    day_beijing desc) as t2

on t1.day_beijing=t2.day_beijing
