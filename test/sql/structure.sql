CREATE TABLE structure (a bigint, "b b" date, d text, sys_period tstzrange);

CREATE TABLE structure_history (like structure);

CREATE TRIGGER versioning_trigger
BEFORE INSERT OR UPDATE OR DELETE ON structure
FOR EACH ROW EXECUTE PROCEDURE versioning('sys_period', 'structure_history', false);

-- Insert.
BEGIN;

INSERT INTO structure (a, "b b", d) VALUES (1, '2000-01-01', 'test');

SELECT a, "b b", d FROM structure ORDER BY a, sys_period;

SELECT * FROM structure_history ORDER BY a, sys_period;

COMMIT;

-- Make sure that the next transaction's CURRENT_TIMESTAMP is different.
SELECT pg_sleep(0.1);

-- Update.
BEGIN;

UPDATE structure SET d = 'blah' WHERE a = 1;

SELECT a, "b b", d FROM structure ORDER BY a, sys_period;

SELECT a, "b b", d FROM structure_history ORDER BY a, sys_period;

COMMIT;

-- Make sure that the next transaction's CURRENT_TIMESTAMP is different.
SELECT pg_sleep(0.1);

-- Drop column in the versioned table.
ALTER TABLE structure DROP COLUMN d;

-- Update.
BEGIN;

UPDATE structure SET "b b" = '2001-01-01' WHERE a = 1;

SELECT a, "b b" FROM structure ORDER BY a, sys_period;

SELECT a, "b b", d FROM structure_history ORDER BY a, sys_period;

COMMIT;

-- Make sure that the next transaction's CURRENT_TIMESTAMP is different.
SELECT pg_sleep(0.1);

-- Add column to the versioned table.
ALTER TABLE structure ADD COLUMN e text;

-- Update.
BEGIN;

UPDATE structure SET e = 'test' WHERE a = 1;

SELECT a, "b b", e FROM structure ORDER BY a, sys_period;

SELECT a, "b b", d FROM structure_history ORDER BY a, sys_period;

COMMIT;

-- Make sure that the next transaction's CURRENT_TIMESTAMP is different.
SELECT pg_sleep(0.1);

-- Add column in the history table.
ALTER TABLE structure_history ADD COLUMN e text;

-- Update.
BEGIN;

UPDATE structure SET e = 'test2' WHERE a = 1;

SELECT a, "b b", e FROM structure ORDER BY a, sys_period;

SELECT a, "b b", d, e FROM structure_history ORDER BY a, sys_period;

COMMIT;

-- Make sure that the next transaction's CURRENT_TIMESTAMP is different.
SELECT pg_sleep(0.1);

-- Drop column in the history table.
ALTER TABLE structure_history DROP COLUMN "b b";

-- Update.
BEGIN;

UPDATE structure SET "b b" = '2012-01-01' WHERE a = 1;

SELECT a, "b b", e FROM structure ORDER BY a, sys_period;

SELECT a, d, e FROM structure_history ORDER BY a, sys_period;

COMMIT;