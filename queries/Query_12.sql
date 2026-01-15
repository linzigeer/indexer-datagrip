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

-- truncate table raw_transactions;

select * from raw_transactions;

-- 外链域名白名单
UPDATE system_config
SET value = '["onekey.so", "example.com"]'::jsonb
WHERE key = 'wallet_banner_external_domains_allowlist';

-- 图片资源域名白名单
UPDATE system_config
SET value = '["cdn.onekey.so", "img.example.com"]'::jsonb
WHERE key = 'wallet_banner_image_domains_allowlist';

-- 内部跳转 scheme 白名单
UPDATE system_config
SET value = '["onekey"]'::jsonb
WHERE key = 'wallet_banner_internal_schemes_allowlist';

-- 内部跳转路径前缀白名单
UPDATE system_config
SET value = '["/wallet", "/swap", "/home"]'::jsonb
WHERE key = 'wallet_banner_internal_path_prefixes_allowlist';


-- 2. 插入测试 Banner
INSERT INTO wallet_banners (
    id, title, description, button,
    src_light, src_dark,
    href_type, href,
    position, rank, enabled
) VALUES (
             'test-banner-001',
             'Welcome to OneKey',
             'Your secure crypto wallet',
             'Learn More',
             'https://cdn.onekey.so/banner/test-light.png',
             'https://cdn.onekey.so/banner/test-dark.png',
             'external',
             'https://onekey.so',
             'home',
             100,
             true
         );


-- 3. 插入 allow 规则（必须！否则默认不可见）
INSERT INTO wallet_banner_rules (banner_id, rule_type, platforms, locales)
VALUES ('test-banner-001', 'allow', ARRAY['android', 'ios', 'desktop'], ARRAY['en-us', 'zh-cn']);



-- Aptos 网络收款页 Banner
INSERT INTO wallet_banners (
    id, title, description, button,
    src_light, href_type, href,
    position, network_id, rank, enabled
) VALUES (
             'receive-aptos-001',
             'Receive APT Easily',
             'Share your address to receive APT tokens',
             'Copy Address',
             'https://cdn.onekey.so/banner/receive-aptos.png',
             'internal',
             '/wallet/receive',
             'receive',
             'aptos--1',
             100,
             true
         );

INSERT INTO wallet_banner_rules (banner_id, rule_type)
VALUES ('receive-aptos-001', 'allow');

-- Ethereum 网络收款页 Banner
INSERT INTO wallet_banners (
    id, title, description, button,
    src_light, href_type, href,
    position, network_id, rank, enabled
) VALUES (
             'receive-eth-001',
             'Receive ETH',
             'Get your Ethereum address',
             'Show QR',
             'https://cdn.onekey.so/banner/receive-eth.png',
             'internal',
             '/wallet/receive/qr',
             'receive',
             'evm--1',
             100,
             true
         );

INSERT INTO wallet_banner_rules (banner_id, rule_type)
VALUES ('receive-eth-001', 'allow');

-- Bitcoin 网络收款页 Banner
INSERT INTO wallet_banners (
    id, title, description, button,
    src_light, href_type, href,
    position, network_id, rank, enabled
) VALUES (
             'receive-btc-001',
             'Receive BTC',
             'Bitcoin address ready',
             'View Address',
             'https://cdn.onekey.so/banner/receive-btc.png',
             'internal',
             '/wallet/receive',
             'receive',
             'btc--0',
             100,
             true
         );

INSERT INTO wallet_banner_rules (banner_id, rule_type)
VALUES ('receive-btc-001', 'allow');

-- =====================================================
-- 更多首页 Banner（不同场景）
-- =====================================================

-- 首页 Banner - 仅 iOS 用户可见
INSERT INTO wallet_banners (
    id, title, description, button,
    src_light, src_dark, href_type, href,
    position, rank, enabled
) VALUES (
             'home-ios-promo',
             'iOS Exclusive',
             'Special offer for iOS users',
             'Get Now',
             'https://cdn.onekey.so/banner/ios-promo-light.png',
             'https://cdn.onekey.so/banner/ios-promo-dark.png',
             'external',
             'https://onekey.so/ios-promo',
             'home',
             200,
             true
         );

INSERT INTO wallet_banner_rules (banner_id, rule_type, platforms)
VALUES ('home-ios-promo', 'allow', ARRAY['ios']);

-- 首页 Banner - 仅中文用户可见
INSERT INTO wallet_banners (
    id, title, description, button,
    src_light, href_type, href,
    title_i18n, description_i18n, button_i18n,
    position, rank, enabled
) VALUES (
             'home-cn-users',
             '新春特惠',
             '限时优惠活动',
             '立即参与',
             'https://cdn.onekey.so/banner/cn-promo.png',
             'external',
             'https://onekey.so/cn-promo',
             '{"zh-cn": "新春特惠", "zh-tw": "新春特惠"}'::jsonb,
             '{"zh-cn": "限时优惠活动", "zh-tw": "限時優惠活動"}'::jsonb,
             '{"zh-cn": "立即参与", "zh-tw": "立即參與"}'::jsonb,
             'home',
             150,
             true
         );

INSERT INTO wallet_banner_rules (banner_id, rule_type, locales)
VALUES ('home-cn-users', 'allow', ARRAY['zh-cn', 'zh-tw']);

-- 首页 Banner - 硬件钱包用户专属
INSERT INTO wallet_banners (
    id, title, description, button,
    src_light, href_type, href,
    position, rank, enabled
) VALUES (
             'home-hw-users',
             'Hardware Wallet Tips',
             'Learn how to use your OneKey hardware wallet',
             'Watch Tutorial',
             'https://cdn.onekey.so/banner/hw-tips.png',
             'external',
             'https://onekey.so/tutorials/hardware',
             'home',
             80,
             true
         );

INSERT INTO wallet_banner_rules (banner_id, rule_type, wallet_types)
VALUES ('home-hw-users', 'allow', ARRAY['hw', 'hw-qrcode']);

-- 首页 Banner - 版本 >= 2.0.0 可见
INSERT INTO wallet_banners (
    id, title, description, button,
    src_light, href_type, href,
    position, rank, enabled
) VALUES (
             'home-new-feature',
             'New Feature Available',
             'Try our latest swap feature',
             'Try Now',
             'https://cdn.onekey.so/banner/new-feature.png',
             'internal',
             '/swap',
             'home',
             90,
             true
         );

INSERT INTO wallet_banner_rules (banner_id, rule_type, min_version)
VALUES ('home-new-feature', 'allow', '2.0.0');

-- 首页 Banner - 带时间窗口（限时活动）
INSERT INTO wallet_banners (
    id, title, description, button,
    src_light, href_type, href,
    position, rank, enabled,
    start_at, end_at
) VALUES (
             'home-limited-time',
             'Limited Time Event',
             'Event ends soon!',
             'Join Now',
             'https://cdn.onekey.so/banner/limited.png',
             'external',
             'https://onekey.so/event',
             'home',
             300,
             true,
             '2026-01-01 00:00:00+00',
             '2026-12-31 23:59:59+00'
         );

INSERT INTO wallet_banner_rules (banner_id, rule_type)
VALUES ('home-limited-time', 'allow');

-- 首页 Banner - 全平台可见（通用）
INSERT INTO wallet_banners (
    id, title, description, button,
    src_light, src_dark, href_type, href,
    position, rank, closeable, close_forever, enabled
) VALUES (
             'home-global-notice',
             'Important Notice',
             'Please update your app for security',
             'Update Now',
             'https://cdn.onekey.so/banner/notice-light.png',
             'https://cdn.onekey.so/banner/notice-dark.png',
             'external',
             'https://onekey.so/download',
             'home',
             500,
             true,
             true,
             true
         );

INSERT INTO wallet_banner_rules (banner_id, rule_type)
VALUES ('home-global-notice', 'allow');


SELECT * FROM nft_collections
WHERE chain_id = 'aptos'
  AND image_uri IS NULL    -- 没有图片
  AND uri IS NOT NULL      -- 但有元数据 URI
  AND is_spam IS NOT TRUE  -- 非垃圾
ORDER BY created_at DESC
LIMIT 50;

SELECT * FROM nft_tokens
WHERE chain_id = 'aptos'
  AND image_uri IS NULL    -- 没有图片
  AND uri IS NOT NULL      -- 但有元数据 URI
ORDER BY updated_at DESC
LIMIT 100;


select distinct asset_type_x from raw_events;



CALL refresh_continuous_aggregate('token_price_kline_1m', NULL, NULL);
CALL refresh_continuous_aggregate('kline_1h', NULL, NULL);
CALL refresh_continuous_aggregate('kline_1d', NULL, NULL);

CALL refresh_continuous_aggregate('token_price_kline_1m', NULL, NULL);
CALL refresh_continuous_aggregate('token_trade_x_1m_cagg', NULL, NULL);
CALL refresh_continuous_aggregate('token_trade_y_1m_cagg', NULL, NULL);


SELECT extname, extversion
FROM pg_extension
WHERE extname = 'timescaledb_toolkit';

SELECT name, default_version, installed_version FROM pg_available_extensions WHERE name LIKE 'timescale%';

-- token market data刷新

CALL refresh_continuous_aggregate('token_sell_stats_30m_market_cagg', NULL, NULL);

CALL refresh_continuous_aggregate('token_buy_stats_30m_market_cagg', NULL, NULL);

CALL refresh_continuous_aggregate('token_buy_stats_30m_cagg', NULL, NULL);
CALL refresh_continuous_aggregate('token_sell_stats_30m_cagg', NULL, NULL);
