{{
    config(
        materialized = 'table',
        partition_by = {
            "field": "block_timestamp_month",
            "data_type": "date",
            "granularity": "month"
        }
    )
}}

SELECT t.* FROM `bigquery-public-data.crypto_bitcoin_cash.transactions` as t
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(),INTERVAL 90 DAY)