UPDATE word_definitions wd
SET
    min_bt_level = (
        SELECT MIN(b.bt_level)
        FROM word_lists wl
        JOIN books b ON wl.isbn = b.isbn
        WHERE LOWER(wl.word) = LOWER(wd.word)
        AND b.bt_level IS NOT NULL
    ),
    min_lexile = (
        SELECT MIN(CAST(NULLIF(REGEXP_REPLACE(b.lexile, '[^0-9]', '', 'g'), '') AS INTEGER))
        FROM word_lists wl
        JOIN books b ON wl.isbn = b.isbn
        WHERE LOWER(wl.word) = LOWER(wd.word)
        AND b.lexile IS NOT NULL
        AND REGEXP_REPLACE(b.lexile, '[^0-9]', '', 'g') <> ''
    );
