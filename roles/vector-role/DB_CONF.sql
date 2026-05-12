-- Создать базу и таблицу в ClickHouse
CREATE DATABASE IF NOT EXISTS logs;

CREATE TABLE IF NOT EXISTS logs.events (
    timestamp DateTime64(3) DEFAULT now64(3),
    host String,
    level String,
    message String,
    INDEX idx_level level TYPE set(10) GRANULARITY 4
) ENGINE = MergeTree
PARTITION BY toYYYYMM(timestamp)
ORDER BY (timestamp, host)
TTL timestamp + INTERVAL 30 DAY;