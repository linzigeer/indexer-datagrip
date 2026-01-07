select * from wallet_account_transactions where account_address='0xce55bf5206bdd7b081e7951e9781ad21a9ae248f1b077f7e22913362f8aaa9a8';

select * from raw_transactions where sender='0xce55bf5206bdd7b081e7951e9781ad21a9ae248f1b077f7e22913362f8aaa9a8';

select * from wallet_transaction_legs where account_address='0xce55bf5206bdd7b081e7951e9781ad21a9ae248f1b077f7e22913362f8aaa9a8';

select count(1) from wallet_account_transactions;

select count(1) from raw_transactions;


INSERT INTO wallet_transaction_legs (
    chain_id,
    txn_version,
    txn_hash,
    leg_index,
    direction,
    token_address,
    asset_standard,
    token_symbol,
    token_decimals,
    raw_amount,
    usd_value,
    account_address,
    peer_address,
    source,
    is_own,
    finality_state,
    data_source,
    created_at
) VALUES (
             'aptos',
             7053617774,
             '0x2dcdcd31704f04b681f2c59fd907af22711e180a39ff5c0d38d9a77406624423',
             1,  -- leg_index
             'send',  -- 或 'receive'
             '0x1::aptos_coin::AptosCoin',  -- 代币地址
             'coin',
             'APT',
             8,  -- 小数位数
             '1000000',  -- 原始数量
             1.5,  -- USD 价值（可选）
             '0xce55bf5206bdd7b081e7951e9781ad21a9ae248f1b077f7e22913362f8aaa9a8',
             '0xPEER_ADDRESS',  -- 对手方地址
             'manual',
             true,
             'finalized',
             'manual',
             NOW()
         );


-- 查询需要补全 USD 但缺少价格数据的 token
WITH tokens_in_swaps AS (
    SELECT DISTINCT
        chain_id,
        asset_type_x as token_address
    FROM raw_events
    WHERE activity_type = 'swap'
      AND (data->>'volume_usd' IS NULL OR data->>'volume_usd' = '0')

    UNION

    SELECT DISTINCT
        chain_id,
        asset_type_y as token_address
    FROM raw_events
    WHERE activity_type = 'swap'
      AND (data->>'volume_usd' IS NULL OR data->>'volume_usd' = '0')
)
SELECT
    t.chain_id,
    t.token_address,
    tk.symbol,
    tk.name,
    tp.price_usd,
    tp.updated_at,
    CASE
        WHEN tp.price_usd IS NULL THEN '价格缺失'
        WHEN tp.updated_at < NOW() - INTERVAL '1 hour' THEN '价格过期'
        ELSE '价格有效'
        END as status,
    COUNT(DISTINCT re.txn_version) as affected_swap_count
FROM tokens_in_swaps t
         LEFT JOIN tokens tk ON t.chain_id = tk.chain_id AND t.token_address = tk.token_address
         LEFT JOIN token_prices tp ON t.chain_id = tp.chain_id AND t.token_address = tp.token_address
         LEFT JOIN raw_events re ON t.chain_id = re.chain_id
    AND (re.asset_type_x = t.token_address OR re.asset_type_y = t.token_address)
    AND re.activity_type = 'swap'
    AND (re.data->>'volume_usd' IS NULL OR re.data->>'volume_usd' = '0')
GROUP BY t.chain_id, t.token_address, tk.symbol, tk.name, tp.price_usd, tp.updated_at
ORDER BY affected_swap_count DESC
LIMIT 50;

select count(1) from raw_transactions;

select count(1) from wallet_account_transactions ;

select * from wallet_account_transactions where account_address='0xce55bf5206bdd7b081e7951e9781ad21a9ae248f1b077f7e22913362f8aaa9a8' order by created_at desc;

select * from raw_transactions where sender='0xce55bf5206bdd7b081e7951e9781ad21a9ae248f1b077f7e22913362f8aaa9a8';

select * from raw_transactions where entry_function_id_str='0xd4bd2f3d42030b935f347d97466fade8ab27283fe8d624cc361e536f18d2b097::clmm_router::swap';

select * from raw_transactions where vm_status is not null;

INSERT INTO chain_fee_rate_config (chain_id, divisor, validated_at, validator_notes)
VALUES ('aptos', 10000, NOW(), 'validated from chain');