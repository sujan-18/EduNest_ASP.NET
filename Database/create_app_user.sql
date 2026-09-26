-- Optional least-privilege application account for a new/local installation.
-- Replace the placeholder before running this file, and use the same password
-- in the EduNestDB connection string in Web.ConnectionStrings.config.
-- Run this script as a MySQL administrator after edunest_db exists.

CREATE USER IF NOT EXISTS 'edunest_app'@'localhost'
    IDENTIFIED BY 'REPLACE_WITH_A_LONG_RANDOM_PASSWORD';
GRANT SELECT, INSERT, UPDATE, DELETE ON edunest_db.* TO 'edunest_app'@'localhost';

CREATE USER IF NOT EXISTS 'edunest_app'@'127.0.0.1'
    IDENTIFIED BY 'REPLACE_WITH_A_LONG_RANDOM_PASSWORD';
GRANT SELECT, INSERT, UPDATE, DELETE ON edunest_db.* TO 'edunest_app'@'127.0.0.1';

FLUSH PRIVILEGES;
