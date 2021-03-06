-- version 1
SET client_min_messages = warning;
DROP EXTENSION IF EXISTS unit CASCADE;
CREATE TABLE IF NOT EXISTS pg_depend_save (LIKE pg_depend);
RESET client_min_messages;

\set pg_depend_save 'BEGIN; DELETE FROM pg_depend_save; WITH ext AS (DELETE FROM pg_depend WHERE refobjid = (SELECT oid FROM pg_extension WHERE extname = $$unit$$) RETURNING *) INSERT INTO pg_depend_save SELECT * FROM ext; COMMIT;'
\set pg_depend_restore 'INSERT INTO pg_depend SELECT * FROM pg_depend_save;'

CREATE EXTENSION unit VERSION "1";
:pg_depend_save
\! pg_dump -f unit-1.dump -T pg_depend_save
:pg_depend_restore

-- upgrade to version 2
ALTER EXTENSION unit UPDATE TO "2";
:pg_depend_save
\! pg_dump -f unit-1-2.dump -T pg_depend_save
:pg_depend_restore

-- upgrade to version 3
ALTER EXTENSION unit UPDATE TO "3";
:pg_depend_save
\! pg_dump -f unit-2-3.dump -T pg_depend_save
:pg_depend_restore

-- upgrade to version 4
ALTER EXTENSION unit UPDATE TO "4";
:pg_depend_save
\! pg_dump -f unit-3-4.dump -T pg_depend_save
:pg_depend_restore

-- upgrade to version 5
ALTER EXTENSION unit UPDATE TO "5";
:pg_depend_save
\! pg_dump -f unit-4-5.dump -T pg_depend_save
:pg_depend_restore

-- upgrade to version 6
ALTER EXTENSION unit UPDATE TO "6";
:pg_depend_save
\! pg_dump -f unit-5-6.dump -T pg_depend_save
:pg_depend_restore

-- upgrade to version 7
ALTER EXTENSION unit UPDATE TO "7";
:pg_depend_save
\! pg_dump -f unit-6-7.dump -T pg_depend_save
:pg_depend_restore

-- reinstall latest version
DROP EXTENSION unit CASCADE;
CREATE EXTENSION unit;
:pg_depend_save
\! pg_dump -f unit-create.dump -T pg_depend_save
:pg_depend_restore

-- different ordering in unit_accum_t expected:
\! diff -u --label unit-update.dump unit-6-7.dump --label unit-create.dump unit-create.dump | sed -e 's/@@.*@@/@@/'
