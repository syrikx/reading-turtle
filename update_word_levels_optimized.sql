-- Optimized version using CTEs to avoid correlated subqueries
-- This should be much faster (seconds instead of minutes)

-- First, create a CTE with minimum levels per word
WITH word_min_levels AS (
    SELECT
        wl.word,
        MIN(b.bt_level) as min_bt_level,
        MIN(CAST(NULLIF(REGEXP_REPLACE(b.lexile, '[^0-9]', '', 'g'), '') AS INTEGER)) as min_lexile
    FROM word_lists wl
    JOIN books b ON wl.isbn = b.isbn
    WHERE
        b.bt_level IS NOT NULL
        OR (b.lexile IS NOT NULL AND REGEXP_REPLACE(b.lexile, '[^0-9]', '', 'g') <> '')
    GROUP BY wl.word
)
-- Now update word_definitions using the CTE
UPDATE word_definitions wd
SET
    min_bt_level = wml.min_bt_level,
    min_lexile = wml.min_lexile
FROM word_min_levels wml
WHERE wd.word = wml.word;
