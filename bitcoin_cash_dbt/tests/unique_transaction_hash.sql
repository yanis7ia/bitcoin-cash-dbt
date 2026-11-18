
SELECT
    `hash`
FROM
    {{ ref('stg_transactions') }}
WHERE
    `hash` IS NOT NULL
GROUP BY
    `hash`
HAVING
    COUNT(*) > 1