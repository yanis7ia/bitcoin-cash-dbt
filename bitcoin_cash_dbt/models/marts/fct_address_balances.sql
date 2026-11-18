
{{
    config(materialized = 'table')
}}

WITH source_transactions AS (
    SELECT
        t.hash,
        t.is_coinbase,
        t.inputs,
        t.outputs
    FROM `bigquery-public-data.crypto_bitcoin_cash.transactions` AS t
),

received AS (
    SELECT
        address,
        SUM(output.value) AS total_received
    FROM source_transactions AS transactions,
    UNNEST(transactions.outputs) AS output,
    UNNEST(output.addresses) AS address
    WHERE output.value IS NOT NULL
    GROUP BY address
),

spent AS (
    SELECT
        address,
        SUM(input.value) AS total_spent
    FROM source_transactions AS transactions,
    UNNEST(transactions.inputs) AS input,
    UNNEST(input.addresses) AS address
    WHERE input.value IS NOT NULL
    GROUP BY address
),

coinbase_addresses AS (
    SELECT DISTINCT address
    FROM source_transactions AS transactions,
    UNNEST(transactions.outputs) AS output,
    UNNEST(output.addresses) AS address
    WHERE transactions.is_coinbase = TRUE
),

all_addresses AS (
    SELECT address FROM received
    UNION DISTINCT
    SELECT address FROM spent
)

SELECT
    addresses.address,
    COALESCE(received.total_received, 0) AS total_received,
    COALESCE(spent.total_spent, 0) AS total_spent,
    COALESCE(received.total_received, 0) - COALESCE(spent.total_spent, 0) AS current_balance
FROM all_addresses AS addresses
LEFT JOIN received ON addresses.address = received.address
LEFT JOIN spent ON addresses.address = spent.address
WHERE NOT EXISTS (
    SELECT 1
    FROM coinbase_addresses AS coinbase
    WHERE coinbase.address = addresses.address
)
