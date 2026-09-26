-- Apply the data integrity checks to databases created before those checks
-- were added to edunest_schema.sql. Safe to run more than once on MySQL 8.0.16+.
USE edunest_db;

DROP PROCEDURE IF EXISTS EduNestAddCheckIfMissing;
DELIMITER $$
CREATE PROCEDURE EduNestAddCheckIfMissing(
    IN p_constraint_name VARCHAR(64),
    IN p_table_name VARCHAR(64),
    IN p_check_expression VARCHAR(500)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE CONSTRAINT_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND CONSTRAINT_NAME = p_constraint_name
    ) THEN
        SET @check_sql = CONCAT(
            'ALTER TABLE `', p_table_name,
            '` ADD CONSTRAINT `', p_constraint_name,
            '` CHECK (', p_check_expression, ')'
        );
        PREPARE check_stmt FROM @check_sql;
        EXECUTE check_stmt;
        DEALLOCATE PREPARE check_stmt;
    END IF;
END$$
DELIMITER ;

CALL EduNestAddCheckIfMissing('chk_topic_sequence', 'LearningPathTopics', 'SequenceOrder >= 1');
CALL EduNestAddCheckIfMissing('chk_question_correct_option', 'QuizQuestions', "CorrectOption IN ('A','B','C','D')");
CALL EduNestAddCheckIfMissing('chk_quiz_attempt_score', 'QuizAttempts', 'Score >= 0 AND TotalQuestions >= 1 AND Score <= TotalQuestions');
CALL EduNestAddCheckIfMissing('chk_peer_review_rating', 'PeerReviews', 'Rating BETWEEN 1 AND 5');

DROP PROCEDURE EduNestAddCheckIfMissing;
