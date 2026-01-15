SELECT
    schemaname AS schema,
    tablename AS table_name,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname || '.' || tablename)) AS table_size,
    pg_size_pretty(pg_indexes_size(schemaname || '.' || tablename)) AS index_size,
    pg_total_relation_size(schemaname || '.' || tablename) AS total_bytes
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY total_bytes DESC;

select * from raw_transactions where version=7359287414;

select * from raw_events where txn_version=7359287414;

select * from raw_resource_changes where txn_version=7359287414;

SELECT * FROM tokens WHERE chain_id = 'aptos';

SELECT * FROM dex_token_stats WHERE chain_id = 'aptos';

SELECT * FROM dex_supported_tokens WHERE chain_id = 'aptos';

select * from pools;

select * from wallet_account_transactions where chain_id='aptos' and account_address in
('0xce55bf5206bdd7b081e7951e9781ad21a9ae248f1b077f7e22913362f8aaa9a8', '0x4c25640a96e3b098dcce10bfec9c0a80d7bd38270803d72d3f27f9e871cb5055')
order by  txn_version;

select * from account_balances where chain_id='aptos' order by  account_address,last_txn_hash;


CALL refresh_continuous_aggregate('dex_points_leaderboard', NULL, NULL);

select * from raw_events e
WHERE
/*
e.chain_id = 'aptos'
AND e.activity_type = 'swap'
AND e.is_reverted = FALSE
AND
*/
e.asset_type_x = '0x1::aptos_coin::AptosCoin' limit 1;

select distinct asset_type_x from raw_events;

select distinct activity_type from raw_events;

select * from raw_events where activity_type='swap';


WITH combined AS (
    (
        -- token 作为输入腿（Sell：用户卖出该 token）
        SELECT
            e.txn_version,
            e.event_index,
            e.txn_time,
            e.txn_hash,
            e.account_address,
            e.sender,
            e.pool_address,
            e.asset_type_x,
            e.amount_x,
            e.asset_type_y,
            e.amount_y,
            e.data ,
            series.price_usd AS series_price_usd
        FROM raw_events e

                 LEFT JOIN LATERAL (
            SELECT s.price_usd
            FROM token_price_series s
            WHERE s.chain_id = 'aptos'
              AND s.token_address = '0x1::aptos_coin::AptosCoin'
              AND s.ts <= e.txn_time
            ORDER BY s.ts DESC
            LIMIT 1
            ) series ON TRUE

        WHERE e.chain_id = 'aptos'
          AND e.activity_type = 'swap'
          AND e.is_reverted = FALSE
          AND e.asset_type_x = '0x90cae7768a01f9b7e0e76abbd899aafa6540443e54fc1677664badb502d4f707'
        ORDER BY e.txn_time DESC, e.txn_version DESC, e.event_index DESC
        LIMIT 3
    )

    UNION ALL

    (
        -- token 作为输出腿（Buy：用户买入该 token）
        SELECT
            e.txn_version,
            e.event_index,
            e.txn_time,
            e.txn_hash,
            e.account_address,
            e.sender,
            e.pool_address,
            e.asset_type_x,
            e.amount_x,
            e.asset_type_y,
            e.amount_y,
            e.data,
            series.price_usd AS series_price_usd
        FROM raw_events e
                 LEFT JOIN LATERAL (
            SELECT s.price_usd
            FROM token_price_series s
            WHERE s.chain_id = 'aptos'
              AND s.token_address = '0x90cae7768a01f9b7e0e76abbd899aafa6540443e54fc1677664badb502d4f707'
              AND s.ts <= e.txn_time
            ORDER BY s.ts DESC
            LIMIT 1
            ) series ON TRUE
        WHERE e.chain_id = 'aptos'
          AND e.activity_type = 'swap'
          AND e.is_reverted = FALSE
          AND e.asset_type_y = '0x90cae7768a01f9b7e0e76abbd899aafa6540443e54fc1677664badb502d4f707'
          AND e.asset_type_x IS DISTINCT FROM '0x90cae7768a01f9b7e0e76abbd899aafa6540443e54fc1677664badb502d4f707'
        ORDER BY e.txn_time DESC, e.txn_version DESC, e.event_index DESC
        LIMIT 3
    )
)
SELECT *
FROM combined
ORDER BY txn_time DESC, txn_version DESC, event_index DESC
LIMIT 3;

select distinct raw_events.txn_version from raw_events;



DELETE FROM raw_transactions rt
WHERE NOT EXISTS (
    SELECT 1 FROM raw_events re
    WHERE re.txn_version = rt.version
);

DELETE FROM wallet_account_transactions rt
WHERE NOT EXISTS (
    SELECT 1 FROM raw_events re
    WHERE re.txn_version = rt.txn_version
);

VACUUM ANALYZE raw_transactions;

select count(1) from wallet_account_transactions;

select count(*) from raw_transactions;  -- 29083825

SELECT COUNT(*) FROM raw_transactions;

SELECT reltuples::bigint AS estimated_rows
FROM pg_class
WHERE relname = 'raw_transactions';

ANALYZE raw_transactions;

-- 先创建临时表存储要保留的版本号
CREATE TEMP TABLE versions_to_keep AS
SELECT DISTINCT txn_version FROM raw_events;

CREATE INDEX ON versions_to_keep(txn_version);

select * from versions_to_keep;

-- 分批删除，每批 10000 条
DO $$
    DECLARE
        deleted_count INTEGER;
        total_deleted INTEGER := 0;
    BEGIN
        LOOP
            DELETE FROM raw_transactions
            WHERE ctid IN (
                SELECT rt.ctid FROM raw_transactions rt
                                        LEFT JOIN versions_to_keep vtk ON rt.version = vtk.txn_version
                WHERE vtk.txn_version IS NULL
                LIMIT 10000
            );

            GET DIAGNOSTICS deleted_count = ROW_COUNT;
            total_deleted := total_deleted + deleted_count;

            RAISE NOTICE '已删除 % 条，累计 % 条', deleted_count, total_deleted;

            -- 每批之间暂停，让其他事务有机会执行
            PERFORM pg_sleep(0.1);

            EXIT WHEN deleted_count = 0;
        END LOOP;

        RAISE NOTICE '删除完成，共删除 % 条记录', total_deleted;
    END $$;

-- 清理临时表
DROP TABLE versions_to_keep;


SELECT extname, extversion
FROM pg_extension
WHERE extname = 'timescaledb_toolkit';