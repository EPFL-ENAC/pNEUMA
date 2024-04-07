DO $$
DECLARE
  batch_limit INT := 1000; -- Number of rows to process in each batch
  updated_rows INT;
BEGIN
  LOOP
    WITH sub AS (
      SELECT p.id
      FROM points p
      LEFT JOIN hexagons h ON ST_Intersects(h.geom, p.geom)
      WHERE p.hex_id IS NULL
      LIMIT batch_limit
    )
    UPDATE points p
    SET hex_id = h.hex_id
    FROM hexagons h, sub
    WHERE ST_Intersects(h.geom, p.geom) AND p.id = sub.id;

    GET DIAGNOSTICS updated_rows = ROW_COUNT;
    EXIT WHEN updated_rows = 0;
  END LOOP;
END;
$$;
