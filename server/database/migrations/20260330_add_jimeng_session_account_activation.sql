ALTER TABLE jimeng_session_accounts ADD COLUMN is_enabled INTEGER DEFAULT 1;
ALTER TABLE jimeng_session_accounts ADD COLUMN priority INTEGER DEFAULT 0;

UPDATE jimeng_session_accounts
SET is_enabled = 1
WHERE is_enabled IS NULL;

WITH ranked_accounts AS (
  SELECT
    id,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY is_default DESC, id ASC
    ) - 1 AS next_priority
  FROM jimeng_session_accounts
)
UPDATE jimeng_session_accounts
SET priority = (
  SELECT ranked_accounts.next_priority
  FROM ranked_accounts
  WHERE ranked_accounts.id = jimeng_session_accounts.id
)
WHERE id IN (SELECT id FROM ranked_accounts);
