select * from raw_events where txn_version=7192230165;

-- 删除
delete from raw_events where txn_version in (7204144212);
-- 删除
delete from dex_limit_order_events where txn_version in (7204144212);
-- 删除
delete from raw_transactions where version in (7204144212);
-- 删除
delete from raw_resource_changes where txn_version in (7204144212);

-- 查询
select * from raw_events where txn_version in (7229978895);
-- 查询
select *  from raw_transactions where version in (7229978895);
-- 查询
select *  from raw_resource_changes where txn_version in (7229978895);
-- 查询
select * from dex_limit_order_events where txn_version in (7229978895);

select * from raw_transactions where sender='0xce55bf5206bdd7b081e7951e9781ad21a9ae248f1b077f7e22913362f8aaa9a8' order by version desc limit 10;

select * from tokens where token_address in ('0x8de07899a984265435925655536c522d4306ebf97801ef5b9a04144d6ee49d38', '0x90cae7768a01f9b7e0e76abbd899aafa6540443e54fc1677664badb502d4f707');

select * from raw_events where txn_version in (7200491757,7200586166,7200663386,7200697938,7200742996,7200770880,7200793462,7200807716) order by txn_version asc;

select * from dex_points_events order by txn_version asc;

select * from dex_points_leaderboard;

CALL refresh_continuous_aggregate('public.dex_points_leaderboard', NULL, NULL);

select * from dex_limit_orders;  -- 6   7230361406

select * from dex_limit_order_events;  -- 10  7230361406
                                            --7230384079

select * from raw_events where event_type like '0x8947269278cd0d0ff2a7917045d31d30adfc053290cc7a3f6e5cdedf6ae11d8b%';


select * from dex_limit_order_events where txn_version in ('7229978895');

select * from dex_limit_orders where order_id in ('79228162551157825740963053571','79228162551157825740963053573');


SELECT txn_version, event_index, event_type, is_reverted, data
FROM raw_events
WHERE txn_version = 7213084464
  AND event_type LIKE '%OrderExecutedEvent%'
ORDER BY event_index;

SELECT * FROM raw_events
WHERE data->>'order_id' = '79228162551157825740963053569'
  AND event_type LIKE '%OrderCreatedEvent%';


select distinct raw_events.module_address from raw_events;

select count(1) from raw_transactions where timestamp_utc <'2025-12-18 00:00:00.000000 +00:00';

delete from raw_transactions where timestamp_utc <'2025-12-18 00:00:00.000000 +00:00';