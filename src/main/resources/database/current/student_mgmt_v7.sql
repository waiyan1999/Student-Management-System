-- =====================================================
-- STUDENT MANAGEMENT SYSTEM - SCHEMA v7 (Full Sample Data)
-- MySQL 8.0+ (requires 8.0.13+ for DEFAULT (UUID()))
-- =====================================================
-- All primary keys are CHAR(36) with DEFAULT (UUID())
-- Primary key names are custom: <tableName>ID
-- All foreign key columns reference these custom names
-- Created By Wai Yan Tha Mung based on student_mgmt_v6
-- =====================================================
DROP DATABASE IF EXISTS student_mgmt_v7;

CREATE DATABASE IF NOT EXISTS student_mgmt_v7;
USE student_mgmt_v7;

SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- DROP ALL TABLES (children before parents)
-- =====================================================

DROP TABLE IF EXISTS `usercertificate`;
DROP TABLE IF EXISTS `user_certificate`;
DROP TABLE IF EXISTS `certificate`;
DROP TABLE IF EXISTS `final_grade`;
DROP TABLE IF EXISTS `exam_result`;
DROP TABLE IF EXISTS `submission`;
DROP TABLE IF EXISTS `user_attendance`;
DROP TABLE IF EXISTS `attendance`;
DROP TABLE IF EXISTS `attendence`;
DROP TABLE IF EXISTS `payment_record`;
DROP TABLE IF EXISTS `payment`;
DROP TABLE IF EXISTS `installment_plan`;
DROP TABLE IF EXISTS `installment_rule_item`;
DROP TABLE IF EXISTS `installment_rule`;
DROP TABLE IF EXISTS `feedback`;
DROP TABLE IF EXISTS `announcement_recipient`;
DROP TABLE IF EXISTS `announcement`;
DROP TABLE IF EXISTS `assignment`;
DROP TABLE IF EXISTS `exam`;
DROP TABLE IF EXISTS `schedule`;
DROP TABLE IF EXISTS `enrollment`;
DROP TABLE IF EXISTS `scholarship_application`;
DROP TABLE IF EXISTS `scholarship`;
DROP TABLE IF EXISTS `course`;
DROP TABLE IF EXISTS `subcategory`;
DROP TABLE IF EXISTS `course_category`;
DROP TABLE IF EXISTS `payment_method`;
DROP TABLE IF EXISTS `payment_type`;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS `role`;

-- =====================================================
-- CORE REFERENCE TABLES (custom PK names)
-- =====================================================

CREATE TABLE `role` (
    `roleID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `name` VARCHAR(45) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`roleID`),
    UNIQUE KEY `uk_role_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payment_type` (
    `paymentTypeID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `name` VARCHAR(45) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`paymentTypeID`),
    UNIQUE KEY `uk_payment_type_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payment_method` (
    `paymentMethodID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `name` VARCHAR(45) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `is_active` TINYINT DEFAULT 1,
    PRIMARY KEY (`paymentMethodID`),
    UNIQUE KEY `uk_payment_method_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- USER MANAGEMENT
-- =====================================================

CREATE TABLE `user` (
    `userID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `roleID` CHAR(36) NOT NULL,                     -- references role(roleID)
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `phone_no` VARCHAR(20) DEFAULT NULL,
    `address` VARCHAR(255) DEFAULT NULL,
    `dob` DATE DEFAULT NULL,
    `gender` ENUM('Male', 'Female', 'Other') DEFAULT NULL,
    `profile_image` VARCHAR(255) DEFAULT NULL,
    `is_active` TINYINT DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`userID`),
    UNIQUE KEY `uk_user_email` (`email`),
    KEY `idx_user_role` (`roleID`),
    KEY `idx_user_is_active` (`is_active`),
    CONSTRAINT `fk_user_role` FOREIGN KEY (`roleID`) REFERENCES `role` (`roleID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- COURSE STRUCTURE
-- =====================================================

CREATE TABLE `course_category` (
    `courseCategoryID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `is_active` TINYINT DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`courseCategoryID`),
    UNIQUE KEY `uk_course_category_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `subcategory` (
    `subcategoryID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `courseCategoryID` CHAR(36) NOT NULL,          -- references course_category(courseCategoryID)
    `name` VARCHAR(100) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `is_active` TINYINT DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`subcategoryID`),
    UNIQUE KEY `uk_subcategory_name_category` (`courseCategoryID`, `name`),
    KEY `idx_subcategory_category` (`courseCategoryID`),
    CONSTRAINT `fk_subcategory_category` FOREIGN KEY (`courseCategoryID`) 
        REFERENCES `course_category` (`courseCategoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `course` (
    `courseID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `courseCategoryID` CHAR(36) NOT NULL,          -- references course_category(courseCategoryID)
    `subcategoryID` CHAR(36) NOT NULL,             -- references subcategory(subcategoryID)
    `teacherID` CHAR(36) DEFAULT NULL,             -- references user(userID)
    `createdByID` CHAR(36) DEFAULT NULL,           -- references user(userID)
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `duration_weeks` INT DEFAULT NULL,
    `fee` DECIMAL(12,2) NOT NULL DEFAULT 0,
    `level` ENUM('Beginner', 'Intermediate', 'Advanced') DEFAULT 'Beginner',
    `status` ENUM('Draft', 'Open', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Draft',
    `seats_total` INT DEFAULT NULL,
    `seats_available` INT DEFAULT NULL,
    `thumbnail_path` VARCHAR(255) DEFAULT NULL,
    `allow_installment` TINYINT DEFAULT 0,
    `allow_scholarship` TINYINT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`courseID`),
    KEY `idx_course_category` (`courseCategoryID`),
    KEY `idx_course_subcategory` (`subcategoryID`),
    KEY `idx_course_teacher` (`teacherID`),
    KEY `idx_course_status` (`status`),
    KEY `idx_course_level` (`level`),
    CONSTRAINT `fk_course_category` FOREIGN KEY (`courseCategoryID`) 
        REFERENCES `course_category` (`courseCategoryID`),
    CONSTRAINT `fk_course_subcategory` FOREIGN KEY (`subcategoryID`) 
        REFERENCES `subcategory` (`subcategoryID`),
    CONSTRAINT `fk_course_teacher` FOREIGN KEY (`teacherID`) 
        REFERENCES `user` (`userID`),
    CONSTRAINT `fk_course_created_by` FOREIGN KEY (`createdByID`) 
        REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- SCHOLARSHIP SYSTEM
-- =====================================================

CREATE TABLE `scholarship` (
    `scholarshipID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `courseID` CHAR(36) NOT NULL,                  -- references course(courseID)
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `discount_type` ENUM('Percentage', 'Fixed Amount') NOT NULL DEFAULT 'Percentage',
    `discount_value` DECIMAL(12,2) NOT NULL,
    `max_recipients` INT DEFAULT NULL,
    `application_deadline` DATE DEFAULT NULL,
    `is_active` TINYINT DEFAULT 1,
    `createdByID` CHAR(36) DEFAULT NULL,           -- references user(userID)
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`scholarshipID`),
    KEY `idx_scholarship_course` (`courseID`),
    KEY `idx_scholarship_active` (`is_active`),
    CONSTRAINT `fk_scholarship_course` FOREIGN KEY (`courseID`) REFERENCES `course` (`courseID`),
    CONSTRAINT `fk_scholarship_created_by` FOREIGN KEY (`createdByID`) 
        REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `scholarship_application` (
    `scholarshipApplicationID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `scholarshipID` CHAR(36) NOT NULL,             -- references scholarship(scholarshipID)
    `userID` CHAR(36) NOT NULL,                    -- references user(userID)
    `application_date` DATE NOT NULL,
    `reason` TEXT DEFAULT NULL,
    `supporting_documents` VARCHAR(255) DEFAULT NULL,
    `status` ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    `reviewedByID` CHAR(36) DEFAULT NULL,          -- references user(userID)
    `reviewed_at` TIMESTAMP DEFAULT NULL,
    `review_notes` TEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`scholarshipApplicationID`),
    UNIQUE KEY `uk_scholarship_app_user` (`scholarshipID`, `userID`),
    KEY `idx_scholarship_app_user` (`userID`),
    KEY `idx_scholarship_app_status` (`status`),
    CONSTRAINT `fk_scholarship_app_scholarship` FOREIGN KEY (`scholarshipID`) 
        REFERENCES `scholarship` (`scholarshipID`),
    CONSTRAINT `fk_scholarship_app_user` FOREIGN KEY (`userID`) 
        REFERENCES `user` (`userID`),
    CONSTRAINT `fk_scholarship_app_reviewed_by` FOREIGN KEY (`reviewedByID`) 
        REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSTALLMENT RULE SYSTEM
-- =====================================================

CREATE TABLE `installment_rule` (
    `installmentRuleID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `courseID` CHAR(36) NOT NULL,                  -- references course(courseID)
    `name` VARCHAR(100) NOT NULL,
    `installment_count` INT NOT NULL,
    `is_active` TINYINT DEFAULT 1,
    `createdByID` CHAR(36) DEFAULT NULL,           -- references user(userID)
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`installmentRuleID`),
    KEY `idx_installment_rule_course` (`courseID`),
    KEY `idx_installment_rule_active` (`is_active`),
    CONSTRAINT `fk_installment_rule_course` FOREIGN KEY (`courseID`) REFERENCES `course` (`courseID`),
    CONSTRAINT `fk_installment_rule_created_by` FOREIGN KEY (`createdByID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `installment_rule_item` (
    `installmentRuleItemID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `installmentRuleID` CHAR(36) NOT NULL,         -- references installment_rule(installmentRuleID)
    `installment_number` INT NOT NULL,
    `amount` DECIMAL(12,2) NOT NULL,
    `due_date` DATE NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`installmentRuleItemID`),
    UNIQUE KEY `uk_rule_item_number` (`installmentRuleID`, `installment_number`),
    CONSTRAINT `fk_rule_item_rule` FOREIGN KEY (`installmentRuleID`) 
        REFERENCES `installment_rule` (`installmentRuleID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ENROLLMENT & PAYMENT
-- =====================================================

CREATE TABLE `enrollment` (
    `enrollmentID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `userID` CHAR(36) NOT NULL,                    -- references user(userID)
    `courseID` CHAR(36) NOT NULL,                  -- references course(courseID)
    `paymentTypeID` CHAR(36) NOT NULL,             -- references payment_type(paymentTypeID)
    `installmentRuleID` CHAR(36) DEFAULT NULL,     -- references installment_rule(installmentRuleID)
    `scholarshipApplicationID` CHAR(36) DEFAULT NULL, -- references scholarship_application(scholarshipApplicationID)
    `enrollment_date` DATE NOT NULL,
    `original_fee` DECIMAL(12,2) NOT NULL,
    `discount_amount` DECIMAL(12,2) DEFAULT 0,
    `final_fee` DECIMAL(12,2) NOT NULL,
    `payment_status` ENUM('Unpaid', 'Partial', 'Fully Paid') DEFAULT 'Unpaid',
    `status` ENUM('Pending', 'Active', 'Completed', 'Dropped', 'Cancelled') DEFAULT 'Pending',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`enrollmentID`),
    UNIQUE KEY `uk_enrollment_user_course` (`userID`, `courseID`),
    KEY `idx_enrollment_user` (`userID`),
    KEY `idx_enrollment_course` (`courseID`),
    KEY `idx_enrollment_status` (`status`),
    KEY `idx_enrollment_payment_status` (`payment_status`),
    KEY `idx_enrollment_date` (`enrollment_date`),
    KEY `idx_enrollment_payment_type` (`paymentTypeID`),
    KEY `idx_enrollment_installment_rule` (`installmentRuleID`),
    KEY `idx_enrollment_scholarship_app` (`scholarshipApplicationID`),
    CONSTRAINT `fk_enrollment_user` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`),
    CONSTRAINT `fk_enrollment_course` FOREIGN KEY (`courseID`) REFERENCES `course` (`courseID`),
    CONSTRAINT `fk_enrollment_payment_type` FOREIGN KEY (`paymentTypeID`) 
        REFERENCES `payment_type` (`paymentTypeID`),
    CONSTRAINT `fk_enrollment_installment_rule` FOREIGN KEY (`installmentRuleID`) 
        REFERENCES `installment_rule` (`installmentRuleID`),
    CONSTRAINT `fk_enrollment_scholarship_app` FOREIGN KEY (`scholarshipApplicationID`) 
        REFERENCES `scholarship_application` (`scholarshipApplicationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `installment_plan` (
    `installmentPlanID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `enrollmentID` CHAR(36) NOT NULL,              -- references enrollment(enrollmentID)
    `installmentRuleItemID` CHAR(36) DEFAULT NULL, -- references installment_rule_item(installmentRuleItemID)
    `installment_number` INT NOT NULL,
    `amount_due` DECIMAL(12,2) NOT NULL,
    `due_date` DATE NOT NULL,
    `paid_amount` DECIMAL(12,2) DEFAULT 0,
    `status` ENUM('Pending', 'Partial', 'Paid', 'Overdue') DEFAULT 'Pending',
    `paid_at` TIMESTAMP DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`installmentPlanID`),
    UNIQUE KEY `uk_installment_plan_enrollment_number` (`enrollmentID`, `installment_number`),
    KEY `idx_installment_plan_status` (`status`),
    KEY `idx_installment_plan_due_date` (`due_date`),
    CONSTRAINT `fk_installment_plan_enrollment` FOREIGN KEY (`enrollmentID`) 
        REFERENCES `enrollment` (`enrollmentID`),
    CONSTRAINT `fk_installment_plan_rule_item` FOREIGN KEY (`installmentRuleItemID`) 
        REFERENCES `installment_rule_item` (`installmentRuleItemID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payment` (
    `paymentID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `enrollmentID` CHAR(36) NOT NULL,              -- references enrollment(enrollmentID)
    `installmentPlanID` CHAR(36) DEFAULT NULL,     -- references installment_plan(installmentPlanID)
    `paymentMethodID` CHAR(36) NOT NULL,           -- references payment_method(paymentMethodID)
    `amount` DECIMAL(12,2) NOT NULL,
    `payment_date` DATE NOT NULL,
    `transaction_reference` VARCHAR(100) DEFAULT NULL,
    `status` ENUM('Pending', 'Success', 'Failed', 'Refunded') DEFAULT 'Pending',
    `notes` TEXT DEFAULT NULL,
    `processedByID` CHAR(36) DEFAULT NULL,         -- references user(userID)
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`paymentID`),
    KEY `idx_payment_enrollment` (`enrollmentID`),
    KEY `idx_payment_installment_plan` (`installmentPlanID`),
    KEY `idx_payment_method` (`paymentMethodID`),
    KEY `idx_payment_date` (`payment_date`),
    KEY `idx_payment_status` (`status`),
    CONSTRAINT `fk_payment_enrollment` FOREIGN KEY (`enrollmentID`) 
        REFERENCES `enrollment` (`enrollmentID`),
    CONSTRAINT `fk_payment_installment_plan` FOREIGN KEY (`installmentPlanID`) 
        REFERENCES `installment_plan` (`installmentPlanID`),
    CONSTRAINT `fk_payment_method` FOREIGN KEY (`paymentMethodID`) 
        REFERENCES `payment_method` (`paymentMethodID`),
    CONSTRAINT `fk_payment_processed_by` FOREIGN KEY (`processedByID`) 
        REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- SCHEDULE & ATTENDANCE
-- =====================================================

CREATE TABLE `schedule` (
    `scheduleID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `courseID` CHAR(36) NOT NULL,                  -- references course(courseID)
    `schedule_date` DATE NOT NULL,
    `start_time` TIME NOT NULL,
    `end_time` TIME NOT NULL,
    `room` VARCHAR(50) DEFAULT NULL,
    `topic` VARCHAR(255) DEFAULT NULL,
    `status` ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`scheduleID`),
    KEY `idx_schedule_course` (`courseID`),
    KEY `idx_schedule_date` (`schedule_date`),
    KEY `idx_schedule_status` (`status`),
    CONSTRAINT `fk_schedule_course` FOREIGN KEY (`courseID`) REFERENCES `course` (`courseID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `attendance` (
    `attendanceID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `scheduleID` CHAR(36) NOT NULL,                -- references schedule(scheduleID)
    `userID` CHAR(36) NOT NULL,                    -- references user(userID)
    `status` ENUM('Present', 'Absent', 'Late', 'Excused') NOT NULL DEFAULT 'Absent',
    `check_in_time` TIME DEFAULT NULL,
    `remarks` VARCHAR(255) DEFAULT NULL,
    `markedByID` CHAR(36) DEFAULT NULL,            -- references user(userID)
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`attendanceID`),
    UNIQUE KEY `uk_attendance_schedule_user` (`scheduleID`, `userID`),
    KEY `idx_attendance_user` (`userID`),
    KEY `idx_attendance_status` (`status`),
    CONSTRAINT `fk_attendance_schedule` FOREIGN KEY (`scheduleID`) REFERENCES `schedule` (`scheduleID`),
    CONSTRAINT `fk_attendance_user` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`),
    CONSTRAINT `fk_attendance_marked_by` FOREIGN KEY (`markedByID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ASSIGNMENTS & SUBMISSIONS
-- =====================================================

CREATE TABLE `assignment` (
    `assignmentID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `courseID` CHAR(36) NOT NULL,                  -- references course(courseID)
    `createdByID` CHAR(36) NOT NULL,               -- references user(userID)
    `title` VARCHAR(100) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `max_score` DECIMAL(5,2) DEFAULT 100.00,
    `weight_percent` DECIMAL(5,2) DEFAULT NULL,
    `due_date` DATETIME DEFAULT NULL,
    `status` ENUM('Draft', 'Published', 'Closed') DEFAULT 'Draft',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`assignmentID`),
    KEY `idx_assignment_course` (`courseID`),
    KEY `idx_assignment_due_date` (`due_date`),
    KEY `idx_assignment_status` (`status`),
    CONSTRAINT `fk_assignment_course` FOREIGN KEY (`courseID`) REFERENCES `course` (`courseID`),
    CONSTRAINT `fk_assignment_created_by` FOREIGN KEY (`createdByID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `submission` (
    `submissionID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `assignmentID` CHAR(36) NOT NULL,              -- references assignment(assignmentID)
    `userID` CHAR(36) NOT NULL,                    -- references user(userID)
    `file_path` VARCHAR(255) DEFAULT NULL,
    `submission_text` TEXT DEFAULT NULL,
    `score` DECIMAL(5,2) DEFAULT NULL,
    `feedback` TEXT DEFAULT NULL,
    `gradedByID` CHAR(36) DEFAULT NULL,            -- references user(userID)
    `graded_at` TIMESTAMP DEFAULT NULL,
    `submitted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`submissionID`),
    UNIQUE KEY `uk_submission_assignment_user` (`assignmentID`, `userID`),
    KEY `idx_submission_user` (`userID`),
    CONSTRAINT `fk_submission_assignment` FOREIGN KEY (`assignmentID`) REFERENCES `assignment` (`assignmentID`),
    CONSTRAINT `fk_submission_user` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`),
    CONSTRAINT `fk_submission_graded_by` FOREIGN KEY (`gradedByID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- EXAMS & RESULTS
-- =====================================================

CREATE TABLE `exam` (
    `examID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `courseID` CHAR(36) NOT NULL,                  -- references course(courseID)
    `createdByID` CHAR(36) NOT NULL,               -- references user(userID)
    `name` VARCHAR(100) NOT NULL,
    `exam_type` ENUM('Quiz', 'Midterm', 'Final', 'Practical') DEFAULT 'Quiz',
    `max_score` DECIMAL(5,2) DEFAULT 100.00,
    `weight_percent` DECIMAL(5,2) DEFAULT NULL,
    `exam_date` DATETIME DEFAULT NULL,
    `duration_minutes` INT DEFAULT NULL,
    `status` ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`examID`),
    KEY `idx_exam_course` (`courseID`),
    KEY `idx_exam_date` (`exam_date`),
    KEY `idx_exam_type` (`exam_type`),
    CONSTRAINT `fk_exam_course` FOREIGN KEY (`courseID`) REFERENCES `course` (`courseID`),
    CONSTRAINT `fk_exam_created_by` FOREIGN KEY (`createdByID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `exam_result` (
    `examResultID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `examID` CHAR(36) NOT NULL,                    -- references exam(examID)
    `userID` CHAR(36) NOT NULL,                    -- references user(userID)
    `score` DECIMAL(5,2) DEFAULT NULL,
    `remarks` TEXT DEFAULT NULL,
    `gradedByID` CHAR(36) DEFAULT NULL,            -- references user(userID)
    `graded_at` TIMESTAMP DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`examResultID`),
    UNIQUE KEY `uk_exam_result_exam_user` (`examID`, `userID`),
    KEY `idx_exam_result_user` (`userID`),
    CONSTRAINT `fk_exam_result_exam` FOREIGN KEY (`examID`) REFERENCES `exam` (`examID`),
    CONSTRAINT `fk_exam_result_user` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`),
    CONSTRAINT `fk_exam_result_graded_by` FOREIGN KEY (`gradedByID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FINAL GRADE
-- =====================================================

CREATE TABLE `final_grade` (
    `finalGradeID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `enrollmentID` CHAR(36) NOT NULL,              -- references enrollment(enrollmentID)
    `assignment_total_score` DECIMAL(5,2) DEFAULT NULL,
    `exam_total_score` DECIMAL(5,2) DEFAULT NULL,
    `attendance_score` DECIMAL(5,2) DEFAULT NULL,
    `final_score` DECIMAL(5,2) DEFAULT NULL,
    `letter_grade` VARCHAR(5) DEFAULT NULL,
    `status` ENUM('In Progress', 'Completed', 'Failed') DEFAULT 'In Progress',
    `remarks` TEXT DEFAULT NULL,
    `finalizedByID` CHAR(36) DEFAULT NULL,         -- references user(userID)
    `finalized_at` TIMESTAMP DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`finalGradeID`),
    UNIQUE KEY `uk_final_grade_enrollment` (`enrollmentID`),
    CONSTRAINT `fk_final_grade_enrollment` FOREIGN KEY (`enrollmentID`) 
        REFERENCES `enrollment` (`enrollmentID`),
    CONSTRAINT `fk_final_grade_finalized_by` FOREIGN KEY (`finalizedByID`) 
        REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- CERTIFICATE
-- =====================================================

CREATE TABLE `certificate` (
    `certificateID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `enrollmentID` CHAR(36) NOT NULL,              -- references enrollment(enrollmentID)
    `certificate_number` VARCHAR(50) NOT NULL,
    `issue_date` DATE NOT NULL,
    `expiry_date` DATE DEFAULT NULL,
    `finalGradeID` CHAR(36) NOT NULL,              -- references final_grade(finalGradeID)
    `issuedByID` CHAR(36) DEFAULT NULL,            -- references user(userID)
    `template_path` VARCHAR(255) DEFAULT NULL,
    `pdf_path` VARCHAR(255) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`certificateID`),
    UNIQUE KEY `uk_certificate_number` (`certificate_number`),
    UNIQUE KEY `uk_certificate_enrollment` (`enrollmentID`),
    KEY `idx_certificate_issue_date` (`issue_date`),
    CONSTRAINT `fk_certificate_enrollment` FOREIGN KEY (`enrollmentID`) 
        REFERENCES `enrollment` (`enrollmentID`),
    CONSTRAINT `fk_certificate_final_grade` FOREIGN KEY (`finalGradeID`) 
        REFERENCES `final_grade` (`finalGradeID`),
    CONSTRAINT `fk_certificate_issued_by` FOREIGN KEY (`issuedByID`) 
        REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FEEDBACK & ANNOUNCEMENTS
-- =====================================================

CREATE TABLE `feedback` (
    `feedbackID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `userID` CHAR(36) NOT NULL,                    -- references user(userID)
    `courseID` CHAR(36) NOT NULL,                  -- references course(courseID)
    `rating` TINYINT NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
    `comment` TEXT DEFAULT NULL,
    `is_anonymous` TINYINT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`feedbackID`),
    UNIQUE KEY `uk_feedback_user_course` (`userID`, `courseID`),
    KEY `idx_feedback_course` (`courseID`),
    KEY `idx_feedback_rating` (`rating`),
    CONSTRAINT `fk_feedback_user` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`),
    CONSTRAINT `fk_feedback_course` FOREIGN KEY (`courseID`) REFERENCES `course` (`courseID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `announcement` (
    `announcementID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `createdByID` CHAR(36) NOT NULL,               -- references user(userID)
    `courseID` CHAR(36) DEFAULT NULL,              -- references course(courseID) – optional
    `title` VARCHAR(200) NOT NULL,
    `content` TEXT NOT NULL,
    `target_type` ENUM('ALL', 'ALL_STUDENTS', 'ALL_TEACHERS', 'SELECTED') DEFAULT 'ALL',
    `priority` ENUM('Low', 'Normal', 'High', 'Urgent') DEFAULT 'Normal',
    `is_published` TINYINT DEFAULT 1,
    `publish_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `expiry_date` DATETIME DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`announcementID`),
    KEY `idx_announcement_created_by` (`createdByID`),
    KEY `idx_announcement_course` (`courseID`),
    KEY `idx_announcement_target_type` (`target_type`),
    KEY `idx_announcement_publish_date` (`publish_date`),
    CONSTRAINT `fk_announcement_created_by` FOREIGN KEY (`createdByID`) REFERENCES `user` (`userID`),
    CONSTRAINT `fk_announcement_course` FOREIGN KEY (`courseID`) REFERENCES `course` (`courseID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `announcement_recipient` (
    `announcementRecipientID` CHAR(36) NOT NULL DEFAULT (UUID()),
    `announcementID` CHAR(36) NOT NULL,            -- references announcement(announcementID)
    `userID` CHAR(36) NOT NULL,                    -- references user(userID)
    `is_read` TINYINT DEFAULT 0,
    `read_at` TIMESTAMP DEFAULT NULL,
    `is_acknowledged` TINYINT DEFAULT 0,
    `acknowledged_at` TIMESTAMP DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`announcementRecipientID`),
    UNIQUE KEY `uk_announcement_recipient` (`announcementID`, `userID`),
    KEY `idx_recipient_user` (`userID`),
    KEY `idx_recipient_is_read` (`is_read`),
    CONSTRAINT `fk_recipient_announcement` FOREIGN KEY (`announcementID`) 
        REFERENCES `announcement` (`announcementID`) ON DELETE CASCADE,
    CONSTRAINT `fk_recipient_user` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- SAMPLE DATA (using subqueries with custom column names)
-- =====================================================

-- Insert roles
INSERT INTO `role` (`name`, `description`) VALUES
('Admin', 'System administrator with full access'),
('Teacher', 'Course instructor'),
('Student', 'Enrolled learner');

-- Insert payment types
INSERT INTO `payment_type` (`name`, `description`) VALUES
('FULL_PAYMENT', 'Single full payment'),
('INSTALLMENT', 'Payment in multiple installments (admin sets count per course)');

-- Insert payment methods
INSERT INTO `payment_method` (`name`, `description`) VALUES
('CASH', 'Cash payment at office'),
('BANK_TRANSFER', 'Bank wire transfer'),
('KBZPAY', 'KBZ Pay mobile payment'),
('AYA_PAY', 'AYA Pay mobile payment'),
('CB_PAY', 'CB Pay mobile payment'),
('WAVE_PAY', 'Wave Money mobile payment');

-- Insert users
INSERT INTO `user` (`roleID`, `name`, `email`, `password`, `phone_no`, `address`, `dob`, `gender`, `is_active`)
SELECT 
    (SELECT roleID FROM role WHERE name = 'Admin'),
    'Admin User', 'admin@school.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    '0912345678', 'Admin Office, Yangon', '1980-01-01', 'Male', 1
UNION ALL
SELECT 
    (SELECT roleID FROM role WHERE name = 'Teacher'),
    'John Teacher', 'john.teacher@school.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    '0923456789', 'Teacher Room, Yangon', '1985-05-15', 'Male', 1
UNION ALL
SELECT 
    (SELECT roleID FROM role WHERE name = 'Teacher'),
    'Jane Teacher', 'jane.teacher@school.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    '0934567890', 'Teacher Room, Mandalay', '1988-07-20', 'Female', 1
UNION ALL
SELECT 
    (SELECT roleID FROM role WHERE name = 'Student'),
    'Alice Student', 'alice@student.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    '0945678901', '123 Main St, Yangon', '2000-03-10', 'Female', 1
UNION ALL
SELECT 
    (SELECT roleID FROM role WHERE name = 'Student'),
    'Bob Student', 'bob@student.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    '0956789012', '456 Oak Ave, Mandalay', '1999-11-22', 'Male', 1
UNION ALL
SELECT 
    (SELECT roleID FROM role WHERE name = 'Student'),
    'Carol Student', 'carol@student.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    '0967890123', '789 Pine Rd, Naypyidaw', '2001-07-05', 'Female', 1;

-- Course Categories
INSERT INTO `course_category` (`name`, `description`) VALUES
('Programming', 'Courses related to software development'),
('Design', 'Graphic and UI/UX design courses'),
('Business', 'Business management and entrepreneurship');

-- Subcategories
INSERT INTO `subcategory` (`courseCategoryID`, `name`, `description`)
SELECT 
    (SELECT courseCategoryID FROM course_category WHERE name = 'Programming'),
    'Web Development', 'Frontend and backend web technologies'
UNION ALL
SELECT 
    (SELECT courseCategoryID FROM course_category WHERE name = 'Programming'),
    'Data Science', 'Data analysis, machine learning'
UNION ALL
SELECT 
    (SELECT courseCategoryID FROM course_category WHERE name = 'Design'),
    'Graphic Design', 'Visual design with tools like Photoshop'
UNION ALL
SELECT 
    (SELECT courseCategoryID FROM course_category WHERE name = 'Design'),
    'UX/UI Design', 'User experience and interface design'
UNION ALL
SELECT 
    (SELECT courseCategoryID FROM course_category WHERE name = 'Business'),
    'Marketing', 'Digital marketing and branding';

-- Courses
INSERT INTO `course` (
    `courseCategoryID`, `subcategoryID`, `teacherID`, `createdByID`,
    `name`, `description`, `duration_weeks`, `fee`, `level`, `status`,
    `seats_total`, `seats_available`, `allow_installment`, `allow_scholarship`
)
SELECT
    (SELECT courseCategoryID FROM course_category WHERE name = 'Programming'),
    (SELECT subcategoryID FROM subcategory WHERE name = 'Web Development'),
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    (SELECT userID FROM user WHERE name = 'Admin User'),
    'Full-Stack Web Development', 'Learn HTML, CSS, JavaScript, Node.js, and React',
    12, 1500.00, 'Beginner', 'Open', 30, 28, 1, 1
UNION ALL
SELECT
    (SELECT courseCategoryID FROM course_category WHERE name = 'Programming'),
    (SELECT subcategoryID FROM subcategory WHERE name = 'Web Development'),
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    (SELECT userID FROM user WHERE name = 'Admin User'),
    'Advanced React & Next.js', 'Deep dive into React hooks, context, and Next.js',
    8, 1200.00, 'Intermediate', 'Open', 20, 18, 1, 1
UNION ALL
SELECT
    (SELECT courseCategoryID FROM course_category WHERE name = 'Programming'),
    (SELECT subcategoryID FROM subcategory WHERE name = 'Data Science'),
    (SELECT userID FROM user WHERE name = 'Jane Teacher'),
    (SELECT userID FROM user WHERE name = 'Admin User'),
    'Python for Data Science', 'NumPy, Pandas, Matplotlib, and introduction to ML',
    10, 1300.00, 'Beginner', 'In Progress', 25, 20, 1, 1
UNION ALL
SELECT
    (SELECT courseCategoryID FROM course_category WHERE name = 'Design'),
    (SELECT subcategoryID FROM subcategory WHERE name = 'Graphic Design'),
    (SELECT userID FROM user WHERE name = 'Jane Teacher'),
    (SELECT userID FROM user WHERE name = 'Admin User'),
    'Graphic Design Masterclass', 'Adobe Photoshop, Illustrator, and InDesign',
    8, 900.00, 'Beginner', 'Open', 15, 15, 0, 0
UNION ALL
SELECT
    (SELECT courseCategoryID FROM course_category WHERE name = 'Business'),
    (SELECT subcategoryID FROM subcategory WHERE name = 'Marketing'),
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    (SELECT userID FROM user WHERE name = 'Admin User'),
    'Digital Marketing Strategy', 'SEO, social media, and content marketing',
    6, 800.00, 'Intermediate', 'Draft', 20, 20, 1, 1;

-- Scholarships
INSERT INTO `scholarship` (`courseID`, `name`, `description`, `discount_type`, `discount_value`, `max_recipients`, `application_deadline`, `createdByID`)
SELECT
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    'Merit Scholarship', 'Full scholarship for top performers',
    'Percentage', 100.00, 2, '2026-08-01',
    (SELECT userID FROM user WHERE name = 'Admin User')
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Python for Data Science'),
    'Partial Scholarship', '50% discount for students with financial need',
    'Percentage', 50.00, 3, '2026-07-15',
    (SELECT userID FROM user WHERE name = 'Admin User');

-- Scholarship Applications
INSERT INTO `scholarship_application` (
    `scholarshipID`, `userID`, `application_date`, `reason`, `status`, `reviewedByID`, `reviewed_at`, `review_notes`
)
SELECT
    (SELECT scholarshipID FROM scholarship WHERE name = 'Merit Scholarship'),
    (SELECT userID FROM user WHERE name = 'Alice Student'),
    '2026-06-01',
    'I have excellent grades and want to pursue full-stack development.',
    'Approved',
    (SELECT userID FROM user WHERE name = 'Admin User'),
    '2026-06-10',
    'Approved based on academic performance.'
UNION ALL
SELECT
    (SELECT scholarshipID FROM scholarship WHERE name = 'Partial Scholarship'),
    (SELECT userID FROM user WHERE name = 'Bob Student'),
    '2026-06-05',
    'I need financial assistance to continue my data science studies.',
    'Pending',
    NULL,
    NULL,
    NULL
UNION ALL
SELECT
    (SELECT scholarshipID FROM scholarship WHERE name = 'Merit Scholarship'),
    (SELECT userID FROM user WHERE name = 'Carol Student'),
    '2026-06-08',
    'I want to attend the full-stack course but need funding support.',
    'Rejected',
    (SELECT userID FROM user WHERE name = 'Admin User'),
    '2026-06-15',
    'Application did not meet the required criteria.';

-- Installment Rules
INSERT INTO `installment_rule` (`courseID`, `name`, `installment_count`, `createdByID`)
SELECT
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    '3-Month Plan', 3,
    (SELECT userID FROM user WHERE name = 'Admin User')
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Advanced React & Next.js'),
    '2-Month Plan', 2,
    (SELECT userID FROM user WHERE name = 'Admin User')
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Python for Data Science'),
    '4-Month Plan', 4,
    (SELECT userID FROM user WHERE name = 'Admin User');

-- Installment Rule Items
INSERT INTO `installment_rule_item` (`installmentRuleID`, `installment_number`, `amount`, `due_date`)
SELECT
    (SELECT installmentRuleID FROM installment_rule WHERE name = '3-Month Plan'),
    1, 500.00, '2026-07-01'
UNION ALL
SELECT
    (SELECT installmentRuleID FROM installment_rule WHERE name = '3-Month Plan'),
    2, 500.00, '2026-08-01'
UNION ALL
SELECT
    (SELECT installmentRuleID FROM installment_rule WHERE name = '3-Month Plan'),
    3, 500.00, '2026-09-01'
UNION ALL
SELECT
    (SELECT installmentRuleID FROM installment_rule WHERE name = '2-Month Plan'),
    1, 600.00, '2026-07-15'
UNION ALL
SELECT
    (SELECT installmentRuleID FROM installment_rule WHERE name = '2-Month Plan'),
    2, 600.00, '2026-08-15'
UNION ALL
SELECT
    (SELECT installmentRuleID FROM installment_rule WHERE name = '4-Month Plan'),
    1, 325.00, '2026-06-01'
UNION ALL
SELECT
    (SELECT installmentRuleID FROM installment_rule WHERE name = '4-Month Plan'),
    2, 325.00, '2026-07-01'
UNION ALL
SELECT
    (SELECT installmentRuleID FROM installment_rule WHERE name = '4-Month Plan'),
    3, 325.00, '2026-08-01'
UNION ALL
SELECT
    (SELECT installmentRuleID FROM installment_rule WHERE name = '4-Month Plan'),
    4, 325.00, '2026-09-01';

-- Enrollments
INSERT INTO `enrollment` (
    `userID`, `courseID`, `paymentTypeID`, `installmentRuleID`,
    `scholarshipApplicationID`,
    `enrollment_date`, `original_fee`, `discount_amount`, `final_fee`, `status`
)
SELECT
    (SELECT userID FROM user WHERE name = 'Alice Student'),
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    (SELECT paymentTypeID FROM payment_type WHERE name = 'FULL_PAYMENT'),
    NULL,
    (SELECT scholarshipApplicationID FROM scholarship_application WHERE userID = (SELECT userID FROM user WHERE name = 'Alice Student') AND scholarshipID = (SELECT scholarshipID FROM scholarship WHERE name = 'Merit Scholarship')),
    '2026-01-10',
    (SELECT fee FROM course WHERE name = 'Full-Stack Web Development'),
    0,
    (SELECT fee FROM course WHERE name = 'Full-Stack Web Development'),
    'Active';

INSERT INTO `enrollment` (
    `userID`, `courseID`, `paymentTypeID`, `installmentRuleID`,
    `scholarshipApplicationID`,
    `enrollment_date`, `original_fee`, `discount_amount`, `final_fee`, `status`
)
SELECT
    (SELECT userID FROM user WHERE name = 'Bob Student'),
    (SELECT courseID FROM course WHERE name = 'Python for Data Science'),
    (SELECT paymentTypeID FROM payment_type WHERE name = 'INSTALLMENT'),
    (SELECT installmentRuleID FROM installment_rule WHERE name = '4-Month Plan'),
    NULL,
    '2026-02-01',
    (SELECT fee FROM course WHERE name = 'Python for Data Science'),
    0,
    (SELECT fee FROM course WHERE name = 'Python for Data Science'),
    'Active';

INSERT INTO `enrollment` (
    `userID`, `courseID`, `paymentTypeID`, `installmentRuleID`,
    `scholarshipApplicationID`,
    `enrollment_date`, `original_fee`, `discount_amount`, `final_fee`, `status`
)
SELECT
    (SELECT userID FROM user WHERE name = 'Carol Student'),
    (SELECT courseID FROM course WHERE name = 'Advanced React & Next.js'),
    (SELECT paymentTypeID FROM payment_type WHERE name = 'FULL_PAYMENT'),
    NULL,
    NULL,
    '2026-03-15',
    (SELECT fee FROM course WHERE name = 'Advanced React & Next.js'),
    0,
    (SELECT fee FROM course WHERE name = 'Advanced React & Next.js'),
    'Active';

-- Installment Plans for Bob
INSERT INTO `installment_plan` (
    `enrollmentID`, `installmentRuleItemID`, `installment_number`, `amount_due`, `due_date`, `status`
)
SELECT
    e.enrollmentID,
    iri.installmentRuleItemID,
    iri.installment_number,
    iri.amount,
    iri.due_date,
    'Pending'
FROM enrollment e
JOIN installment_rule ir ON e.installmentRuleID = ir.installmentRuleID
JOIN installment_rule_item iri ON iri.installmentRuleID = ir.installmentRuleID
WHERE e.userID = (SELECT userID FROM user WHERE name = 'Bob Student');

-- Payments
INSERT INTO `payment` (
    `enrollmentID`, `paymentMethodID`, `amount`, `payment_date`, `status`, `processedByID`
)
SELECT
    e.enrollmentID,
    (SELECT paymentMethodID FROM payment_method WHERE name = 'CASH'),
    e.final_fee,
    CURDATE(),
    'Success',
    (SELECT userID FROM user WHERE name = 'Admin User')
FROM enrollment e
WHERE e.userID = (SELECT userID FROM user WHERE name = 'Alice Student');

INSERT INTO `payment` (
    `enrollmentID`, `installmentPlanID`, `paymentMethodID`, `amount`, `payment_date`, `status`, `processedByID`
)
SELECT
    e.enrollmentID,
    ip.installmentPlanID,
    (SELECT paymentMethodID FROM payment_method WHERE name = 'CASH'),
    ip.amount_due,
    '2026-02-10',
    'Success',
    (SELECT userID FROM user WHERE name = 'Admin User')
FROM enrollment e
JOIN installment_plan ip ON ip.enrollmentID = e.enrollmentID
WHERE e.userID = (SELECT userID FROM user WHERE name = 'Bob Student') AND ip.installment_number = 1;

-- Mark Bob's first installment as paid
UPDATE installment_plan ip
JOIN enrollment e ON ip.enrollmentID = e.enrollmentID
SET ip.status = 'Paid', ip.paid_amount = ip.amount_due, ip.paid_at = '2026-02-10'
WHERE e.userID = (SELECT userID FROM user WHERE name = 'Bob Student') AND ip.installment_number = 1;

-- Schedule
INSERT INTO `schedule` (`courseID`, `schedule_date`, `start_time`, `end_time`, `room`, `topic`)
SELECT
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    '2026-07-05', '09:00:00', '11:00:00', 'Room 101', 'Introduction to HTML & CSS'
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    '2026-07-12', '09:00:00', '11:00:00', 'Room 101', 'JavaScript Basics'
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    '2026-07-19', '09:00:00', '11:00:00', 'Room 101', 'Node.js Backend'
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Python for Data Science'),
    '2026-08-01', '14:00:00', '16:00:00', 'Room 202', 'Intro to NumPy'
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Python for Data Science'),
    '2026-08-08', '14:00:00', '16:00:00', 'Room 202', 'Data Visualization with Matplotlib';

-- Attendance
INSERT INTO `attendance` (`scheduleID`, `userID`, `status`, `markedByID`)
SELECT
    s.scheduleID,
    (SELECT userID FROM user WHERE name = 'Alice Student'),
    'Present',
    (SELECT userID FROM user WHERE name = 'John Teacher')
FROM schedule s
JOIN course c ON s.courseID = c.courseID
WHERE c.name = 'Full-Stack Web Development' AND s.topic = 'Introduction to HTML & CSS'
UNION ALL
SELECT
    s.scheduleID,
    (SELECT userID FROM user WHERE name = 'Alice Student'),
    'Absent',
    (SELECT userID FROM user WHERE name = 'John Teacher')
FROM schedule s
JOIN course c ON s.courseID = c.courseID
WHERE c.name = 'Full-Stack Web Development' AND s.topic = 'JavaScript Basics'
UNION ALL
SELECT
    s.scheduleID,
    (SELECT userID FROM user WHERE name = 'Alice Student'),
    'Late',
    (SELECT userID FROM user WHERE name = 'John Teacher')
FROM schedule s
JOIN course c ON s.courseID = c.courseID
WHERE c.name = 'Full-Stack Web Development' AND s.topic = 'Node.js Backend'
UNION ALL
SELECT
    s.scheduleID,
    (SELECT userID FROM user WHERE name = 'Bob Student'),
    'Present',
    (SELECT userID FROM user WHERE name = 'Jane Teacher')
FROM schedule s
JOIN course c ON s.courseID = c.courseID
WHERE c.name = 'Python for Data Science' AND s.topic = 'Intro to NumPy';

-- Assignments
INSERT INTO `assignment` (`courseID`, `createdByID`, `title`, `description`, `max_score`, `weight_percent`, `due_date`, `status`)
SELECT
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    'HTML/CSS Project', 'Build a personal portfolio page using HTML and CSS.',
    100.00, 20.00, '2026-07-20 23:59:59', 'Published'
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    'JavaScript Game', 'Create a simple browser game using vanilla JS.',
    100.00, 30.00, '2026-08-10 23:59:59', 'Published'
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Python for Data Science'),
    (SELECT userID FROM user WHERE name = 'Jane Teacher'),
    'Data Analysis Report', 'Use Pandas to analyze a given dataset.',
    100.00, 25.00, '2026-08-15 23:59:59', 'Published'
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Advanced React & Next.js'),
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    'React Component Library', 'Build reusable components for a design system.',
    100.00, 20.00, '2026-08-30 23:59:59', 'Draft';

-- Submissions
INSERT INTO `submission` (
    `assignmentID`, `userID`, `file_path`, `submission_text`, `score`, `feedback`, `gradedByID`, `graded_at`
)
SELECT
    (SELECT assignmentID FROM assignment WHERE title = 'HTML/CSS Project'),
    (SELECT userID FROM user WHERE name = 'Alice Student'),
    '/uploads/alice_html_project.zip',
    NULL,
    85.00,
    'Good structure, but improve responsiveness.',
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    '2026-07-25 10:00:00'
UNION ALL
SELECT
    (SELECT assignmentID FROM assignment WHERE title = 'JavaScript Game'),
    (SELECT userID FROM user WHERE name = 'Alice Student'),
    '/uploads/alice_js_game.zip',
    NULL,
    92.00,
    'Excellent logic and creativity!',
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    '2026-08-15 14:30:00'
UNION ALL
SELECT
    (SELECT assignmentID FROM assignment WHERE title = 'Data Analysis Report'),
    (SELECT userID FROM user WHERE name = 'Bob Student'),
    NULL,
    'Submitted text report with analysis.',
    78.00,
    'Good analysis but missing visualizations.',
    (SELECT userID FROM user WHERE name = 'Jane Teacher'),
    '2026-08-20 09:15:00';

-- Exams
INSERT INTO `exam` (`courseID`, `createdByID`, `name`, `exam_type`, `max_score`, `weight_percent`, `exam_date`, `duration_minutes`, `status`)
SELECT
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    'Midterm Exam', 'Midterm', 100.00, 30.00, '2026-07-30 10:00:00', 120, 'Completed'
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    'Final Exam', 'Final', 100.00, 40.00, '2026-09-05 10:00:00', 180, 'Scheduled'
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Python for Data Science'),
    (SELECT userID FROM user WHERE name = 'Jane Teacher'),
    'Quiz 1', 'Quiz', 50.00, 10.00, '2026-08-05 14:00:00', 30, 'Completed'
UNION ALL
SELECT
    (SELECT courseID FROM course WHERE name = 'Python for Data Science'),
    (SELECT userID FROM user WHERE name = 'Jane Teacher'),
    'Final Exam', 'Final', 100.00, 40.00, '2026-09-20 10:00:00', 180, 'Scheduled';

-- Exam Results
INSERT INTO `exam_result` (`examID`, `userID`, `score`, `remarks`, `gradedByID`, `graded_at`)
SELECT
    (SELECT examID FROM exam WHERE name = 'Midterm Exam' AND courseID = (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development')),
    (SELECT userID FROM user WHERE name = 'Alice Student'),
    88.00,
    'Good understanding of concepts.',
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    '2026-08-01 12:00:00'
UNION ALL
SELECT
    (SELECT examID FROM exam WHERE name = 'Quiz 1' AND courseID = (SELECT courseID FROM course WHERE name = 'Python for Data Science')),
    (SELECT userID FROM user WHERE name = 'Bob Student'),
    70.00,
    'Needs improvement on NumPy.',
    (SELECT userID FROM user WHERE name = 'Jane Teacher'),
    '2026-08-06 16:00:00';

-- Final Grades (only for completed or in-progress enrollments)
INSERT INTO `final_grade` (
    `enrollmentID`, `assignment_total_score`, `exam_total_score`, `attendance_score`, 
    `final_score`, `letter_grade`, `status`, `remarks`, `finalizedByID`, `finalized_at`
)
SELECT
    e.enrollmentID,
    (SELECT COALESCE(SUM(score * weight_percent/100), 0) FROM submission s 
     JOIN assignment a ON s.assignmentID = a.assignmentID 
     WHERE s.userID = e.userID AND a.courseID = e.courseID) AS assignment_score,
    (SELECT COALESCE(SUM(er.score * e2.weight_percent/100), 0) FROM exam_result er 
     JOIN exam e2 ON er.examID = e2.examID 
     WHERE er.userID = e.userID AND e2.courseID = e.courseID) AS exam_score,
    (SELECT COALESCE(SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) / COUNT(*) * 100, 0) 
     FROM attendance a JOIN schedule s ON a.scheduleID = s.scheduleID 
     WHERE a.userID = e.userID AND s.courseID = e.courseID) AS attendance_score,
    NULL, NULL, 'In Progress', NULL, NULL, NULL
FROM enrollment e
WHERE e.userID IN ((SELECT userID FROM user WHERE name = 'Alice Student'), 
                   (SELECT userID FROM user WHERE name = 'Bob Student'),
                   (SELECT userID FROM user WHERE name = 'Carol Student'))
  AND e.status = 'Active';

-- Update final scores and letter grades for those with results (simplified)
UPDATE final_grade fg
JOIN enrollment e ON fg.enrollmentID = e.enrollmentID
SET 
    fg.final_score = COALESCE(fg.assignment_total_score, 0) + COALESCE(fg.exam_total_score, 0) + COALESCE(fg.attendance_score * 0.1, 0),
    fg.letter_grade = CASE 
        WHEN COALESCE(fg.assignment_total_score, 0) + COALESCE(fg.exam_total_score, 0) + COALESCE(fg.attendance_score * 0.1, 0) >= 90 THEN 'A'
        WHEN COALESCE(fg.assignment_total_score, 0) + COALESCE(fg.exam_total_score, 0) + COALESCE(fg.attendance_score * 0.1, 0) >= 80 THEN 'B'
        WHEN COALESCE(fg.assignment_total_score, 0) + COALESCE(fg.exam_total_score, 0) + COALESCE(fg.attendance_score * 0.1, 0) >= 70 THEN 'C'
        WHEN COALESCE(fg.assignment_total_score, 0) + COALESCE(fg.exam_total_score, 0) + COALESCE(fg.attendance_score * 0.1, 0) >= 60 THEN 'D'
        ELSE 'F'
    END,
    fg.status = 'Completed',
    fg.finalizedByID = (SELECT userID FROM user WHERE name = 'Admin User'),
    fg.finalized_at = NOW()
WHERE e.userID = (SELECT userID FROM user WHERE name = 'Alice Student')
   OR e.userID = (SELECT userID FROM user WHERE name = 'Bob Student');

-- Certificates (only for completed enrollments)
INSERT INTO `certificate` (
    `enrollmentID`, `certificate_number`, `issue_date`, `finalGradeID`, `issuedByID`, `pdf_path`
)
SELECT
    e.enrollmentID,
    CONCAT('CERT-', UPPER(SUBSTRING(UUID(), 1, 8))),
    CURDATE(),
    fg.finalGradeID,
    (SELECT userID FROM user WHERE name = 'Admin User'),
    CONCAT('/certificates/', e.enrollmentID, '.pdf')
FROM enrollment e
JOIN final_grade fg ON fg.enrollmentID = e.enrollmentID
WHERE e.userID = (SELECT userID FROM user WHERE name = 'Alice Student')
   OR e.userID = (SELECT userID FROM user WHERE name = 'Bob Student');

-- Feedback
INSERT INTO `feedback` (`userID`, `courseID`, `rating`, `comment`, `is_anonymous`)
SELECT
    (SELECT userID FROM user WHERE name = 'Alice Student'),
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    5,
    'Excellent course! John is a great teacher.',
    0
UNION ALL
SELECT
    (SELECT userID FROM user WHERE name = 'Bob Student'),
    (SELECT courseID FROM course WHERE name = 'Python for Data Science'),
    4,
    'Very informative, but pace is a bit fast.',
    0
UNION ALL
SELECT
    (SELECT userID FROM user WHERE name = 'Carol Student'),
    (SELECT courseID FROM course WHERE name = 'Advanced React & Next.js'),
    3,
    'Good content, but needs more examples.',
    1;

-- Announcements
INSERT INTO `announcement` (
    `createdByID`, `courseID`, `title`, `content`, `target_type`, `priority`, `is_published`, `publish_date`
)
SELECT
    (SELECT userID FROM user WHERE name = 'Admin User'),
    NULL,
    'Welcome to the New Semester!',
    'All courses are now open for enrollment. Check the schedule for details.',
    'ALL',
    'Normal',
    1,
    '2026-01-01 08:00:00'
UNION ALL
SELECT
    (SELECT userID FROM user WHERE name = 'John Teacher'),
    (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development'),
    'First Assignment Posted',
    'The HTML/CSS project is now available. Due date: July 20.',
    'ALL_STUDENTS',
    'High',
    1,
    '2026-07-01 10:00:00'
UNION ALL
SELECT
    (SELECT userID FROM user WHERE name = 'Jane Teacher'),
    (SELECT courseID FROM course WHERE name = 'Python for Data Science'),
    'Quiz 1 Reminder',
    'Quiz 1 will be held on August 5. Please review NumPy.',
    'ALL_STUDENTS',
    'Normal',
    1,
    '2026-07-30 09:00:00';

-- Announcement Recipients (for demonstration, we'll add for all active users for the first announcement)
INSERT INTO `announcement_recipient` (`announcementID`, `userID`, `is_read`, `read_at`)
SELECT
    (SELECT announcementID FROM announcement WHERE title = 'Welcome to the New Semester!'),
    u.userID,
    IF(u.name IN ('Alice Student', 'Bob Student'), 1, 0),
    IF(u.name IN ('Alice Student', 'Bob Student'), NOW(), NULL)
FROM user u
WHERE u.is_active = 1;

-- For the second announcement, only students enrolled in the course
INSERT INTO `announcement_recipient` (`announcementID`, `userID`, `is_read`, `read_at`)
SELECT
    (SELECT announcementID FROM announcement WHERE title = 'First Assignment Posted'),
    u.userID,
    0,
    NULL
FROM user u
WHERE u.roleID = (SELECT roleID FROM role WHERE name = 'Student')
  AND EXISTS (
    SELECT 1 FROM enrollment e 
    WHERE e.userID = u.userID 
      AND e.courseID = (SELECT courseID FROM course WHERE name = 'Full-Stack Web Development')
  );

-- =====================================================
-- VIEWS (updated with custom column names)
-- =====================================================

CREATE OR REPLACE VIEW `v_student_payment_summary` AS
SELECT 
    e.enrollmentID,
    u.name AS student_name,
    c.name AS course_name,
    pt.name AS payment_type,
    ir.name AS installment_rule_name,
    ir.installment_count,
    s.name AS scholarship_name,
    sa.status AS scholarship_status,
    e.original_fee,
    e.discount_amount,
    e.final_fee,
    COALESCE(SUM(p.amount), 0) AS total_paid,
    e.final_fee - COALESCE(SUM(p.amount), 0) AS balance_due,
    e.payment_status,
    e.status AS enrollment_status
FROM enrollment e
JOIN user u ON e.userID = u.userID
JOIN course c ON e.courseID = c.courseID
JOIN payment_type pt ON e.paymentTypeID = pt.paymentTypeID
LEFT JOIN installment_rule ir ON e.installmentRuleID = ir.installmentRuleID
LEFT JOIN scholarship_application sa ON e.scholarshipApplicationID = sa.scholarshipApplicationID
LEFT JOIN scholarship s ON sa.scholarshipID = s.scholarshipID
LEFT JOIN payment p ON p.enrollmentID = e.enrollmentID AND p.status = 'Success'
GROUP BY e.enrollmentID;

CREATE OR REPLACE VIEW `v_installment_status` AS
SELECT 
    ip.installmentPlanID AS plan_id,
    e.enrollmentID,
    u.name AS student_name,
    c.name AS course_name,
    ip.installment_number,
    ip.amount_due,
    ip.due_date,
    ip.paid_amount,
    ip.status AS installment_status,
    CASE 
        WHEN ip.status = 'Pending' AND ip.due_date < CURDATE() THEN 'OVERDUE'
        WHEN ip.status = 'Pending' AND ip.due_date <= DATE_ADD(CURDATE(), INTERVAL 3 DAY) THEN 'DUE SOON'
        ELSE ip.status
    END AS alert_status
FROM installment_plan ip
JOIN enrollment e ON ip.enrollmentID = e.enrollmentID
JOIN user u ON e.userID = u.userID
JOIN course c ON e.courseID = c.courseID
ORDER BY ip.due_date;

CREATE OR REPLACE VIEW `v_course_statistics` AS
SELECT 
    c.courseID,
    c.name AS course_name,
    cat.name AS category,
    sub.name AS subcategory,
    c.fee,
    c.seats_total,
    c.seats_available,
    c.seats_total - c.seats_available AS enrolled_count,
    c.status
FROM course c
JOIN course_category cat ON c.courseCategoryID = cat.courseCategoryID
JOIN subcategory sub ON c.subcategoryID = sub.subcategoryID;