-- Add course catalog metadata and assignment grading fields to an existing
-- EduNest database. This migration preserves all existing records and is
-- safe to run repeatedly. Requires MySQL 8.0.16+.
USE edunest_db;

DROP PROCEDURE IF EXISTS EduNestAddColumnIfMissing;
DROP PROCEDURE IF EXISTS EduNestAddIndexIfMissing;
DELIMITER $$
CREATE PROCEDURE EduNestAddColumnIfMissing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition VARCHAR(500)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND COLUMN_NAME = p_column_name
    ) THEN
        SET @column_sql = CONCAT('ALTER TABLE `', p_table_name,
            '` ADD COLUMN `', p_column_name, '` ', p_column_definition);
        PREPARE column_stmt FROM @column_sql;
        EXECUTE column_stmt;
        DEALLOCATE PREPARE column_stmt;
    END IF;
END$$

CREATE PROCEDURE EduNestAddIndexIfMissing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_index_definition VARCHAR(500)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND INDEX_NAME = p_index_name
    ) THEN
        SET @index_sql = CONCAT('ALTER TABLE `', p_table_name,
            '` ADD INDEX `', p_index_name, '` ', p_index_definition);
        PREPARE index_stmt FROM @index_sql;
        EXECUTE index_stmt;
        DEALLOCATE PREPARE index_stmt;
    END IF;
END$$
DELIMITER ;

CALL EduNestAddColumnIfMissing('Courses', 'Category', "VARCHAR(60) NOT NULL DEFAULT 'Technology' AFTER Description");
CALL EduNestAddColumnIfMissing('Courses', 'Level', "ENUM('Beginner','Intermediate','Advanced') NOT NULL DEFAULT 'Beginner' AFTER Category");
CALL EduNestAddColumnIfMissing('Courses', 'EstimatedHours', 'SMALLINT UNSIGNED NOT NULL DEFAULT 8 AFTER Level');
CALL EduNestAddColumnIfMissing('AssignmentSubmissions', 'Grade', 'DECIMAL(5,2) NULL AFTER SubmissionText');
CALL EduNestAddColumnIfMissing('AssignmentSubmissions', 'Feedback', 'TEXT NULL AFTER Grade');
CALL EduNestAddIndexIfMissing('Courses', 'idx_courses_catalog', '(Category, Level)');

-- Give the two original sample courses appropriate starter metadata without
-- changing values a lecturer has already customized.
UPDATE Courses
SET Category = 'Web Development', Level = 'Intermediate', EstimatedHours = 24
WHERE Title = 'Web Application Development' AND Category = 'Technology';
UPDATE Courses
SET Category = 'Data & Analytics', Level = 'Beginner', EstimatedHours = 16
WHERE Title = 'Database Systems' AND Category = 'Technology';

DROP PROCEDURE EduNestAddColumnIfMissing;
DROP PROCEDURE EduNestAddIndexIfMissing;
