-- UP START
CREATE TABLE foo.bar(
  id integer,
  baz text
);
-- UP END


-- ROLLBACK START
DROP TABLE foo.bar;
-- ROLLBACK END
