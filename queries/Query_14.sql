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
--             PERFORM pg_sleep(0.1);

            EXIT WHEN deleted_count = 0;
        END LOOP;

        RAISE NOTICE '删除完成，共删除 % 条记录', total_deleted;
    END $$;

-- 清理临时表
DROP TABLE versions_to_keep;