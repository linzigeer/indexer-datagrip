SELECT table_name FROM information_schema.tables WHERE table_name IN (
                                                                      'token_price_series',
                                                                      'token_holder_stats',
                                                                      'token_audit',
                                                                      'dex_token_stats'
    );


select * from raw_resource_changes order by tx_time desc limit 10;

select * from raw_transactions order by timestamp_utc desc limit 10;