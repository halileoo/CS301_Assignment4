DROP INDEX IF EXISTS idx_rentals_dates;

EXPLAIN ANALYZE
SELECT *
FROM rentals
WHERE start_date <= '2026-08-01'
  AND planned_end_date >= '2026-07-15'
  AND status = 'active';

-- QUERY PLAN
-- Gather  (cost=1000.00..10565.33 rows=235 width=62) (actual time=0.680..43.137 rows=31.00 loops=1)
--   Workers Planned: 2
--   Workers Launched: 2
--   Buffers: shared hit=5896
--   ->  Parallel Seq Scan on rentals  (cost=0.00..9541.83 rows=98 width=62) (actual time=0.535..14.999 rows=10.33 loops=3)
--         Filter: ((start_date <= '2026-08-01'::date) AND (planned_end_date >= '2026-07-15'::date) AND ((status)::text = 'active'::text))
--         Rows Removed by Filter: 166656
--         Buffers: shared hit=5896
-- Planning:
--   Buffers: shared hit=5
-- Planning Time: 0.812 ms
-- Execution Time: 43.175 ms

CREATE INDEX idx_rentals_dates ON rentals (start_date, planned_end_date);

-- QUERY PLAN
-- Bitmap Heap Scan on rentals  (cost=6916.48..9788.19 rows=235 width=62) (actual time=3.217..3.350 rows=31.00 loops=1)
--   Recheck Cond: ((start_date <= '2026-08-01'::date) AND (planned_end_date >= '2026-07-15'::date))
--   Filter: ((status)::text = 'active'::text)
--   Rows Removed by Filter: 141
--   Heap Blocks: exact=170
--   Buffers: shared hit=180 read=475
--   ->  Bitmap Index Scan on idx_rentals_dates  (cost=0.00..6916.42 rows=1141 width=0) (actual time=3.181..3.182 rows=172.00 loops=1)
--         Index Cond: ((start_date <= '2026-08-01'::date) AND (planned_end_date >= '2026-07-15'::date))
--         Index Searches: 5
--         Buffers: shared hit=10 read=475
-- Planning:
--   Buffers: shared hit=19 read=4
-- Planning Time: 1.066 ms
-- Execution Time: 3.365 ms


------------------------------------------------------------------------
------------------------------------------------------------------------


DROP INDEX IF EXISTS idx_rentals_client;

EXPLAIN ANALYZE
SELECT *
FROM rentals
WHERE client_id = (SELECT id FROM clients LIMIT 1);

-- QUERY PLAN
-- Gather  (cost=1000.02..9500.89 rows=7 width=62) (actual time=4.394..43.148 rows=9.00 loops=1)
--   Workers Planned: 2
--   Workers Launched: 2
--   Buffers: shared hit=5896 read=3
--   InitPlan 1
--     ->  Limit  (cost=0.00..0.02 rows=1 width=4) (actual time=1.039..1.040 rows=1.00 loops=1)
--           Buffers: shared read=3
--           ->  Seq Scan on clients  (cost=0.00..1994.00 rows=80000 width=4) (actual time=1.038..1.038 rows=1.00 loops=1)
--                 Buffers: shared read=3
--   ->  Parallel Seq Scan on rentals  (cost=0.00..8500.17 rows=3 width=62) (actual time=0.919..8.492 rows=3.00 loops=3)
--         Filter: (client_id = (InitPlan 1).col1)
--         Rows Removed by Filter: 166664
--         Buffers: shared hit=5896
-- Planning:
--   Buffers: shared hit=59 read=4
-- Planning Time: 12.318 ms
-- Execution Time: 43.187 ms

CREATE INDEX idx_rentals_client ON rentals (client_id);

-- QUERY PLAN
-- Bitmap Heap Scan on rentals  (cost=4.50..31.87 rows=7 width=62) (actual time=0.058..0.066 rows=9.00 loops=1)
--   Recheck Cond: (client_id = (InitPlan 1).col1)
--   Heap Blocks: exact=9
--   Buffers: shared hit=11 read=3
--   InitPlan 1
--     ->  Limit  (cost=0.00..0.02 rows=1 width=4) (actual time=0.012..0.013 rows=1.00 loops=1)
--           Buffers: shared hit=2
--           ->  Seq Scan on clients  (cost=0.00..1994.00 rows=80000 width=4) (actual time=0.012..0.012 rows=1.00 loops=1)
--                 Buffers: shared hit=2
--   ->  Bitmap Index Scan on idx_rentals_client  (cost=0.00..4.48 rows=7 width=0) (actual time=0.051..0.051 rows=9.00 loops=1)
--         Index Cond: (client_id = (InitPlan 1).col1)
--         Index Searches: 1
--         Buffers: shared hit=2 read=3
-- Planning:
--   Buffers: shared hit=15 read=1
-- Planning Time: 1.238 ms
-- Execution Time: 0.082 ms

