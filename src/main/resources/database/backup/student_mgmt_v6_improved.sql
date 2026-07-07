-- =====================================================
-- STUDENT MANAGEMENT SYSTEM - IMPROVED SCHEMA v6
-- MySQL 8.0+
-- =====================================================
-- Key Changes:
-- 1. PaymentType = FULL_PAYMENT or INSTALLMENT only (student chooses type)
-- 2. Installment rules set by admin per course (count, amount, due_date)
-- 3. Scholarship per course, student applies, admin approves
-- 4. installment_plan tracks each student's payment schedule
-- 5. Announcement with target_type + recipient table for selective visibility
-- 6. Fixed final_grade to be per enrollment (student+course)
-- 7. Fixed attendance tracking structure
-- 8. Added missing constraints and indexes
-- =====================================================

SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- DROP ALL TABLES FIRST (children before parents)
-- Includes legacy names from student_mgmt_v5 so old FKs
-- (e.g. certificate -> final_grade.assignment_id) are removed
-- before the new final_grade structure is created.
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
-- CORE REFERENCE TABLES
-- =====================================================

-- Role table (unchanged)
CREATE TABLE `role` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_role_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payment Type lookup table
-- Only: FULL_PAYMENT or INSTALLMENT (student chooses type only, not count)
CREATE TABLE `payment_type` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_payment_type_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payment Method lookup table (NEW)
-- Cash, Bank Transfer, Mobile Payment (KBZPay, AYA Pay, CB Pay, etc.)
CREATE TABLE `payment_method` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `is_active` TINYINT DEFAULT 1,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_payment_method_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- USER MANAGEMENT
-- =====================================================

CREATE TABLE `user` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `role_id` INT NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `password` VARCHAR(255) NOT NULL COMMENT 'Should be hashed, increased length',
    `phone_no` VARCHAR(20) DEFAULT NULL,
    `address` VARCHAR(255) DEFAULT NULL,
    `dob` DATE DEFAULT NULL,
    `gender` ENUM('Male', 'Female', 'Other') DEFAULT NULL,
    `profile_image` VARCHAR(255) DEFAULT NULL,
    `is_active` TINYINT DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_email` (`email`),
    KEY `idx_user_role` (`role_id`),
    KEY `idx_user_is_active` (`is_active`),
    CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- COURSE STRUCTURE
-- =====================================================

CREATE TABLE `course_category` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `is_active` TINYINT DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_course_category_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `subcategory` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `course_category_id` INT NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `is_active` TINYINT DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_subcategory_name_category` (`course_category_id`, `name`),
    KEY `idx_subcategory_category` (`course_category_id`),
    CONSTRAINT `fk_subcategory_category` FOREIGN KEY (`course_category_id`) 
        REFERENCES `course_category` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `course` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `course_category_id` INT NOT NULL,
    `subcategory_id` INT NOT NULL,
    `teacher_id` INT DEFAULT NULL COMMENT 'Primary teacher for the course',
    `created_by` INT DEFAULT NULL,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `duration_weeks` INT DEFAULT NULL COMMENT 'Changed from varchar to int',
    `fee` DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT 'Base course fee',
    `level` ENUM('Beginner', 'Intermediate', 'Advanced') DEFAULT 'Beginner',
    `status` ENUM('Draft', 'Open', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Draft',
    `seats_total` INT DEFAULT NULL,
    `seats_available` INT DEFAULT NULL,
    `thumbnail_path` VARCHAR(255) DEFAULT NULL,
    `allow_installment` TINYINT DEFAULT 0 COMMENT '0 = no, 1 = yes',
    `allow_scholarship` TINYINT DEFAULT 0 COMMENT '0 = no, 1 = yes',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_course_category` (`course_category_id`),
    KEY `idx_course_subcategory` (`subcategory_id`),
    KEY `idx_course_teacher` (`teacher_id`),
    KEY `idx_course_status` (`status`),
    KEY `idx_course_level` (`level`),
    CONSTRAINT `fk_course_category` FOREIGN KEY (`course_category_id`) 
        REFERENCES `course_category` (`id`),
    CONSTRAINT `fk_course_subcategory` FOREIGN KEY (`subcategory_id`) 
        REFERENCES `subcategory` (`id`),
    CONSTRAINT `fk_course_teacher` FOREIGN KEY (`teacher_id`) 
        REFERENCES `user` (`id`),
    CONSTRAINT `fk_course_created_by` FOREIGN KEY (`created_by`) 
        REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- SCHOLARSHIP SYSTEM (Per Course - Student must apply and be approved)
-- =====================================================

-- Scholarship belongs to a specific course
CREATE TABLE `scholarship` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `course_id` INT NOT NULL COMMENT 'Scholarship is for this course only',
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `discount_type` ENUM('Percentage', 'Fixed Amount') NOT NULL DEFAULT 'Percentage',
    `discount_value` DECIMAL(12,2) NOT NULL COMMENT 'Percentage (0-100) or fixed amount',
    `max_recipients` INT DEFAULT NULL COMMENT 'NULL = unlimited',
    `application_deadline` DATE DEFAULT NULL,
    `is_active` TINYINT DEFAULT 1,
    `created_by` INT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_scholarship_course` (`course_id`),
    KEY `idx_scholarship_active` (`is_active`),
    CONSTRAINT `fk_scholarship_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`),
    CONSTRAINT `fk_scholarship_created_by` FOREIGN KEY (`created_by`) 
        REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Student applies for scholarship, admin approves/rejects
CREATE TABLE `scholarship_application` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `scholarship_id` INT NOT NULL,
    `user_id` INT NOT NULL COMMENT 'Student applying',
    `application_date` DATE NOT NULL,
    `reason` TEXT DEFAULT NULL COMMENT 'Why student needs scholarship',
    `supporting_documents` VARCHAR(255) DEFAULT NULL COMMENT 'File path for documents',
    `status` ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    `reviewed_by` INT DEFAULT NULL COMMENT 'Admin who reviewed',
    `reviewed_at` TIMESTAMP DEFAULT NULL,
    `review_notes` TEXT DEFAULT NULL COMMENT 'Reason for approval/rejection',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_scholarship_app_user` (`scholarship_id`, `user_id`) COMMENT 'One application per student per scholarship',
    KEY `idx_scholarship_app_user` (`user_id`),
    KEY `idx_scholarship_app_status` (`status`),
    CONSTRAINT `fk_scholarship_app_scholarship` FOREIGN KEY (`scholarship_id`) 
        REFERENCES `scholarship` (`id`),
    CONSTRAINT `fk_scholarship_app_user` FOREIGN KEY (`user_id`) 
        REFERENCES `user` (`id`),
    CONSTRAINT `fk_scholarship_app_reviewed_by` FOREIGN KEY (`reviewed_by`) 
        REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSTALLMENT RULE SYSTEM (Admin sets rules per course)
-- =====================================================

-- Admin creates installment rule for a course
CREATE TABLE `installment_rule` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `course_id` INT NOT NULL,
    `name` VARCHAR(100) NOT NULL COMMENT 'e.g. "3-month plan"',
    `installment_count` INT NOT NULL COMMENT 'Total number of installments',
    `is_active` TINYINT DEFAULT 1,
    `created_by` INT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_installment_rule_course` (`course_id`),
    KEY `idx_installment_rule_active` (`is_active`),
    CONSTRAINT `fk_installment_rule_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`),
    CONSTRAINT `fk_installment_rule_created_by` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Each installment: admin enters amount + due_date manually
CREATE TABLE `installment_rule_item` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `installment_rule_id` INT NOT NULL,
    `installment_number` INT NOT NULL COMMENT '1, 2, 3...',
    `amount` DECIMAL(12,2) NOT NULL COMMENT 'Amount for this installment',
    `due_date` DATE NOT NULL COMMENT 'Admin enters due date manually',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_rule_item_number` (`installment_rule_id`, `installment_number`),
    CONSTRAINT `fk_rule_item_rule` FOREIGN KEY (`installment_rule_id`) 
        REFERENCES `installment_rule` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ENROLLMENT & PAYMENT SYSTEM (RESTRUCTURED)
-- =====================================================

-- Enrollment: Links student to course (1 student can enroll in 1 course only once)
CREATE TABLE `enrollment` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL COMMENT 'Student',
    `course_id` INT NOT NULL,
    `payment_type_id` INT NOT NULL COMMENT 'Full Payment or Installment',
    `installment_rule_id` INT DEFAULT NULL COMMENT 'If INSTALLMENT, which rule to use',
    `scholarship_application_id` INT DEFAULT NULL COMMENT 'Only if student was approved for scholarship',
    `enrollment_date` DATE NOT NULL,
    `original_fee` DECIMAL(12,2) NOT NULL COMMENT 'Course fee at enrollment time',
    `discount_amount` DECIMAL(12,2) DEFAULT 0 COMMENT 'Scholarship discount amount',
    `final_fee` DECIMAL(12,2) NOT NULL COMMENT 'Fee after discount',
    `payment_status` ENUM('Unpaid', 'Partial', 'Fully Paid') DEFAULT 'Unpaid',
    `status` ENUM('Pending', 'Active', 'Completed', 'Dropped', 'Cancelled') DEFAULT 'Pending',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_enrollment_user_course` (`user_id`, `course_id`) COMMENT 'Prevent duplicate enrollment',
    KEY `idx_enrollment_user` (`user_id`),
    KEY `idx_enrollment_course` (`course_id`),
    KEY `idx_enrollment_status` (`status`),
    KEY `idx_enrollment_payment_status` (`payment_status`),
    KEY `idx_enrollment_date` (`enrollment_date`),
    KEY `idx_enrollment_payment_type` (`payment_type_id`),
    KEY `idx_enrollment_installment_rule` (`installment_rule_id`),
    KEY `idx_enrollment_scholarship_app` (`scholarship_application_id`),
    CONSTRAINT `fk_enrollment_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    CONSTRAINT `fk_enrollment_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`),
    CONSTRAINT `fk_enrollment_payment_type` FOREIGN KEY (`payment_type_id`) 
        REFERENCES `payment_type` (`id`),
    CONSTRAINT `fk_enrollment_installment_rule` FOREIGN KEY (`installment_rule_id`) 
        REFERENCES `installment_rule` (`id`),
    CONSTRAINT `fk_enrollment_scholarship_app` FOREIGN KEY (`scholarship_application_id`) 
        REFERENCES `scholarship_application` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Student's actual installment schedule (copied from rule when enrolling)
CREATE TABLE `installment_plan` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `enrollment_id` INT NOT NULL,
    `installment_rule_item_id` INT DEFAULT NULL COMMENT 'Link to original rule item',
    `installment_number` INT NOT NULL COMMENT '1, 2, 3...',
    `amount_due` DECIMAL(12,2) NOT NULL,
    `due_date` DATE NOT NULL COMMENT 'From admin rule',
    `paid_amount` DECIMAL(12,2) DEFAULT 0,
    `status` ENUM('Pending', 'Partial', 'Paid', 'Overdue') DEFAULT 'Pending',
    `paid_at` TIMESTAMP DEFAULT NULL COMMENT 'When fully paid',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_installment_plan_enrollment_number` (`enrollment_id`, `installment_number`),
    KEY `idx_installment_plan_status` (`status`),
    KEY `idx_installment_plan_due_date` (`due_date`),
    CONSTRAINT `fk_installment_plan_enrollment` FOREIGN KEY (`enrollment_id`) 
        REFERENCES `enrollment` (`id`),
    CONSTRAINT `fk_installment_plan_rule_item` FOREIGN KEY (`installment_rule_item_id`) 
        REFERENCES `installment_rule_item` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payment: Individual payment transactions
-- For FULL_PAYMENT: 1 payment per enrollment (installment_plan_id = NULL)
-- For INSTALLMENT: Each payment links to an installment_plan row
CREATE TABLE `payment` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `enrollment_id` INT NOT NULL,
    `installment_plan_id` INT DEFAULT NULL COMMENT 'NULL for full payment; links to installment for partial',
    `payment_method_id` INT NOT NULL COMMENT 'How they paid (Cash, KBZPay, etc.)',
    `amount` DECIMAL(12,2) NOT NULL,
    `payment_date` DATE NOT NULL,
    `transaction_reference` VARCHAR(100) DEFAULT NULL COMMENT 'External transaction ID',
    `status` ENUM('Pending', 'Success', 'Failed', 'Refunded') DEFAULT 'Pending',
    `notes` TEXT DEFAULT NULL,
    `processed_by` INT DEFAULT NULL COMMENT 'Admin/Staff who processed',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_payment_enrollment` (`enrollment_id`),
    KEY `idx_payment_installment_plan` (`installment_plan_id`),
    KEY `idx_payment_method` (`payment_method_id`),
    KEY `idx_payment_date` (`payment_date`),
    KEY `idx_payment_status` (`status`),
    CONSTRAINT `fk_payment_enrollment` FOREIGN KEY (`enrollment_id`) 
        REFERENCES `enrollment` (`id`),
    CONSTRAINT `fk_payment_installment_plan` FOREIGN KEY (`installment_plan_id`) 
        REFERENCES `installment_plan` (`id`),
    CONSTRAINT `fk_payment_method` FOREIGN KEY (`payment_method_id`) 
        REFERENCES `payment_method` (`id`),
    CONSTRAINT `fk_payment_processed_by` FOREIGN KEY (`processed_by`) 
        REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- SCHEDULE & ATTENDANCE (RESTRUCTURED)
-- =====================================================

CREATE TABLE `schedule` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `course_id` INT NOT NULL,
    `schedule_date` DATE NOT NULL,
    `start_time` TIME NOT NULL,
    `end_time` TIME NOT NULL,
    `room` VARCHAR(50) DEFAULT NULL,
    `topic` VARCHAR(255) DEFAULT NULL COMMENT 'What will be covered',
    `status` ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_schedule_course` (`course_id`),
    KEY `idx_schedule_date` (`schedule_date`),
    KEY `idx_schedule_status` (`status`),
    CONSTRAINT `fk_schedule_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Attendance: One record per student per schedule session
CREATE TABLE `attendance` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `schedule_id` INT NOT NULL,
    `user_id` INT NOT NULL COMMENT 'Student',
    `status` ENUM('Present', 'Absent', 'Late', 'Excused') NOT NULL DEFAULT 'Absent',
    `check_in_time` TIME DEFAULT NULL,
    `remarks` VARCHAR(255) DEFAULT NULL,
    `marked_by` INT DEFAULT NULL COMMENT 'Teacher/Admin who marked',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_attendance_schedule_user` (`schedule_id`, `user_id`) COMMENT 'One record per student per session',
    KEY `idx_attendance_user` (`user_id`),
    KEY `idx_attendance_status` (`status`),
    CONSTRAINT `fk_attendance_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`id`),
    CONSTRAINT `fk_attendance_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    CONSTRAINT `fk_attendance_marked_by` FOREIGN KEY (`marked_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ASSIGNMENTS & SUBMISSIONS
-- =====================================================

CREATE TABLE `assignment` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `course_id` INT NOT NULL,
    `created_by` INT NOT NULL COMMENT 'Teacher who created',
    `title` VARCHAR(100) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `max_score` DECIMAL(5,2) DEFAULT 100.00,
    `weight_percent` DECIMAL(5,2) DEFAULT NULL COMMENT 'Weight in final grade calculation',
    `due_date` DATETIME DEFAULT NULL,
    `status` ENUM('Draft', 'Published', 'Closed') DEFAULT 'Draft',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_assignment_course` (`course_id`),
    KEY `idx_assignment_due_date` (`due_date`),
    KEY `idx_assignment_status` (`status`),
    CONSTRAINT `fk_assignment_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`),
    CONSTRAINT `fk_assignment_created_by` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `submission` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `assignment_id` INT NOT NULL,
    `user_id` INT NOT NULL COMMENT 'Student',
    `file_path` VARCHAR(255) DEFAULT NULL,
    `submission_text` TEXT DEFAULT NULL COMMENT 'For text-based submissions',
    `score` DECIMAL(5,2) DEFAULT NULL COMMENT 'Grade given',
    `feedback` TEXT DEFAULT NULL COMMENT 'Teacher feedback',
    `graded_by` INT DEFAULT NULL,
    `graded_at` TIMESTAMP DEFAULT NULL,
    `submitted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_submission_assignment_user` (`assignment_id`, `user_id`) COMMENT 'One submission per student per assignment',
    KEY `idx_submission_user` (`user_id`),
    CONSTRAINT `fk_submission_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignment` (`id`),
    CONSTRAINT `fk_submission_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    CONSTRAINT `fk_submission_graded_by` FOREIGN KEY (`graded_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- EXAMS & RESULTS (RESTRUCTURED)
-- =====================================================

CREATE TABLE `exam` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `course_id` INT NOT NULL,
    `created_by` INT NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `exam_type` ENUM('Quiz', 'Midterm', 'Final', 'Practical') DEFAULT 'Quiz',
    `max_score` DECIMAL(5,2) DEFAULT 100.00,
    `weight_percent` DECIMAL(5,2) DEFAULT NULL COMMENT 'Weight in final grade calculation',
    `exam_date` DATETIME DEFAULT NULL,
    `duration_minutes` INT DEFAULT NULL,
    `status` ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_exam_course` (`course_id`),
    KEY `idx_exam_date` (`exam_date`),
    KEY `idx_exam_type` (`exam_type`),
    CONSTRAINT `fk_exam_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`),
    CONSTRAINT `fk_exam_created_by` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Exam Results: Score per student per exam
CREATE TABLE `exam_result` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `exam_id` INT NOT NULL,
    `user_id` INT NOT NULL COMMENT 'Student',
    `score` DECIMAL(5,2) DEFAULT NULL,
    `remarks` TEXT DEFAULT NULL,
    `graded_by` INT DEFAULT NULL,
    `graded_at` TIMESTAMP DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_exam_result_exam_user` (`exam_id`, `user_id`),
    KEY `idx_exam_result_user` (`user_id`),
    CONSTRAINT `fk_exam_result_exam` FOREIGN KEY (`exam_id`) REFERENCES `exam` (`id`),
    CONSTRAINT `fk_exam_result_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    CONSTRAINT `fk_exam_result_graded_by` FOREIGN KEY (`graded_by`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FINAL GRADE (RESTRUCTURED - Per Enrollment)
-- =====================================================

-- Final grade is calculated per enrollment (student + course)
CREATE TABLE `final_grade` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `enrollment_id` INT NOT NULL,
    `assignment_total_score` DECIMAL(5,2) DEFAULT NULL COMMENT 'Weighted assignment score',
    `exam_total_score` DECIMAL(5,2) DEFAULT NULL COMMENT 'Weighted exam score',
    `attendance_score` DECIMAL(5,2) DEFAULT NULL COMMENT 'Optional attendance component',
    `final_score` DECIMAL(5,2) DEFAULT NULL COMMENT 'Combined final score',
    `letter_grade` VARCHAR(5) DEFAULT NULL COMMENT 'A, B+, B, C+, C, D, F',
    `status` ENUM('In Progress', 'Completed', 'Failed') DEFAULT 'In Progress',
    `remarks` TEXT DEFAULT NULL,
    `finalized_by` INT DEFAULT NULL,
    `finalized_at` TIMESTAMP DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_final_grade_enrollment` (`enrollment_id`) COMMENT '1:1 with enrollment',
    CONSTRAINT `fk_final_grade_enrollment` FOREIGN KEY (`enrollment_id`) 
        REFERENCES `enrollment` (`id`),
    CONSTRAINT `fk_final_grade_finalized_by` FOREIGN KEY (`finalized_by`) 
        REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- CERTIFICATE (RESTRUCTURED)
-- =====================================================

CREATE TABLE `certificate` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `enrollment_id` INT NOT NULL,
    `certificate_number` VARCHAR(50) NOT NULL,
    `issue_date` DATE NOT NULL,
    `expiry_date` DATE DEFAULT NULL COMMENT 'For certifications that expire',
    `final_grade_id` INT NOT NULL,
    `issued_by` INT DEFAULT NULL,
    `template_path` VARCHAR(255) DEFAULT NULL,
    `pdf_path` VARCHAR(255) DEFAULT NULL COMMENT 'Generated certificate PDF',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_certificate_number` (`certificate_number`),
    UNIQUE KEY `uk_certificate_enrollment` (`enrollment_id`) COMMENT '1:1 with enrollment',
    KEY `idx_certificate_issue_date` (`issue_date`),
    CONSTRAINT `fk_certificate_enrollment` FOREIGN KEY (`enrollment_id`) 
        REFERENCES `enrollment` (`id`),
    CONSTRAINT `fk_certificate_final_grade` FOREIGN KEY (`final_grade_id`) 
        REFERENCES `final_grade` (`id`),
    CONSTRAINT `fk_certificate_issued_by` FOREIGN KEY (`issued_by`) 
        REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FEEDBACK & ANNOUNCEMENTS
-- =====================================================

CREATE TABLE `feedback` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL COMMENT 'Student giving feedback',
    `course_id` INT NOT NULL,
    `rating` TINYINT NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
    `comment` TEXT DEFAULT NULL,
    `is_anonymous` TINYINT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_feedback_user_course` (`user_id`, `course_id`) COMMENT 'One feedback per user per course',
    KEY `idx_feedback_course` (`course_id`),
    KEY `idx_feedback_rating` (`rating`),
    CONSTRAINT `fk_feedback_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    CONSTRAINT `fk_feedback_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Announcement with target type for selective visibility
CREATE TABLE `announcement` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `created_by` INT NOT NULL COMMENT 'Author (admin/teacher)',
    `course_id` INT DEFAULT NULL COMMENT 'NULL = not course-specific',
    `title` VARCHAR(200) NOT NULL,
    `content` TEXT NOT NULL,
    `target_type` ENUM('ALL', 'ALL_STUDENTS', 'ALL_TEACHERS', 'SELECTED') DEFAULT 'ALL',
    `priority` ENUM('Low', 'Normal', 'High', 'Urgent') DEFAULT 'Normal',
    `is_published` TINYINT DEFAULT 1,
    `publish_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `expiry_date` DATETIME DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_announcement_created_by` (`created_by`),
    KEY `idx_announcement_course` (`course_id`),
    KEY `idx_announcement_target_type` (`target_type`),
    KEY `idx_announcement_publish_date` (`publish_date`),
    CONSTRAINT `fk_announcement_created_by` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`),
    CONSTRAINT `fk_announcement_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Recipients: who can see each announcement (inserted based on target_type)
-- For ALL: insert all active users
-- For ALL_STUDENTS: insert all students
-- For ALL_TEACHERS: insert all teachers  
-- For SELECTED: insert only selected users
CREATE TABLE `announcement_recipient` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `announcement_id` INT NOT NULL,
    `user_id` INT NOT NULL COMMENT 'Who can see this announcement',
    `is_read` TINYINT DEFAULT 0,
    `read_at` TIMESTAMP DEFAULT NULL,
    `is_acknowledged` TINYINT DEFAULT 0 COMMENT 'Optional: user confirmed/ok',
    `acknowledged_at` TIMESTAMP DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_announcement_recipient` (`announcement_id`, `user_id`),
    KEY `idx_recipient_user` (`user_id`),
    KEY `idx_recipient_is_read` (`is_read`),
    CONSTRAINT `fk_recipient_announcement` FOREIGN KEY (`announcement_id`) 
        REFERENCES `announcement` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_recipient_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- INITIAL REFERENCE DATA
-- =====================================================

-- Roles
INSERT INTO `role` (`id`, `name`, `description`) VALUES
(1, 'Admin', 'System administrator with full access'),
(2, 'Teacher', 'Course instructor'),
(3, 'Student', 'Enrolled learner');

-- Payment Types (ONLY these two - per business rules)
-- Student only chooses type; admin sets installment count via installment_rule
INSERT INTO `payment_type` (`id`, `name`, `description`) VALUES
(1, 'FULL_PAYMENT', 'Single full payment'),
(2, 'INSTALLMENT', 'Payment in multiple installments (admin sets count per course)');

-- Payment Methods (How they pay)
INSERT INTO `payment_method` (`id`, `name`, `description`) VALUES
(1, 'CASH', 'Cash payment at office'),
(2, 'BANK_TRANSFER', 'Bank wire transfer'),
(3, 'KBZPAY', 'KBZ Pay mobile payment'),
(4, 'AYA_PAY', 'AYA Pay mobile payment'),
(5, 'CB_PAY', 'CB Pay mobile payment'),
(6, 'WAVE_PAY', 'Wave Money mobile payment');

-- Note: Scholarships are created per course, so no sample data here
-- Example: To create a scholarship for course_id=1:
-- INSERT INTO `scholarship` (`course_id`, `name`, `discount_type`, `discount_value`) 
-- VALUES (1, 'Java Basic Full Scholarship', 'Percentage', 100.00);

-- =====================================================
-- DATA MIGRATION HELPERS (Run these to migrate existing data)
-- =====================================================

/*
-- Migration Example: Move existing course_category data
INSERT INTO course_category (id, name) 
SELECT id, name FROM old_database.course_category;

-- Migration Example: Move users
INSERT INTO user (id, role_id, name, email, password, phone_no, address, dob, gender, profile_image, is_active, created_at)
SELECT id, role_id, name, email, password, phone_no, address, dob, gender, file_path, is_active, created_at
FROM old_database.user;

-- Migration Example: Convert existing enrollments
-- Note: You'll need to map old payment_type values to new payment_type_id
-- Old SCHOLARSHIP -> payment_type_id=1 (FULL_PAYMENT) + scholarship_id
-- Old FULL_PAYMENT -> payment_type_id=1 (FULL_PAYMENT)

INSERT INTO enrollment (user_id, course_id, payment_type_id, scholarship_id, enrollment_date, original_fee, discount_amount, final_fee, status)
SELECT 
    e.user_id,
    e.course_id,
    CASE WHEN pr.payment_type = 'SCHOLARSHIP' THEN 1 ELSE 1 END as payment_type_id,
    CASE WHEN pr.payment_type = 'SCHOLARSHIP' THEN 1 ELSE NULL END as scholarship_id,
    e.enrollment_date,
    c.fee as original_fee,
    CASE WHEN pr.payment_type = 'SCHOLARSHIP' THEN c.fee ELSE 0 END as discount_amount,
    CASE WHEN pr.payment_type = 'SCHOLARSHIP' THEN 0 ELSE c.fee END as final_fee,
    CASE e.status WHEN 1 THEN 'Active' ELSE 'Cancelled' END as status
FROM old_database.enrollment e
JOIN old_database.course c ON e.course_id = c.id
LEFT JOIN old_database.payment p ON p.enrollment_id = e.id
LEFT JOIN old_database.payment_record pr ON pr.payment_id = p.id
GROUP BY e.id;
*/

-- =====================================================
-- USEFUL VIEWS
-- =====================================================

-- View: Student payment summary
CREATE OR REPLACE VIEW `v_student_payment_summary` AS
SELECT 
    e.id as enrollment_id,
    u.name as student_name,
    c.name as course_name,
    pt.name as payment_type,
    ir.name as installment_rule_name,
    ir.installment_count,
    s.name as scholarship_name,
    sa.status as scholarship_status,
    e.original_fee,
    e.discount_amount,
    e.final_fee,
    COALESCE(SUM(p.amount), 0) as total_paid,
    e.final_fee - COALESCE(SUM(p.amount), 0) as balance_due,
    e.payment_status,
    e.status as enrollment_status
FROM enrollment e
JOIN user u ON e.user_id = u.id
JOIN course c ON e.course_id = c.id
JOIN payment_type pt ON e.payment_type_id = pt.id
LEFT JOIN installment_rule ir ON e.installment_rule_id = ir.id
LEFT JOIN scholarship_application sa ON e.scholarship_application_id = sa.id
LEFT JOIN scholarship s ON sa.scholarship_id = s.id
LEFT JOIN payment p ON p.enrollment_id = e.id AND p.status = 'Success'
GROUP BY e.id;

-- View: Installment plan status per student
CREATE OR REPLACE VIEW `v_installment_status` AS
SELECT 
    ip.id as plan_id,
    e.id as enrollment_id,
    u.name as student_name,
    c.name as course_name,
    ip.installment_number,
    ip.amount_due,
    ip.due_date,
    ip.paid_amount,
    ip.status as installment_status,
    CASE 
        WHEN ip.status = 'Pending' AND ip.due_date < CURDATE() THEN 'OVERDUE'
        WHEN ip.status = 'Pending' AND ip.due_date <= DATE_ADD(CURDATE(), INTERVAL 3 DAY) THEN 'DUE SOON'
        ELSE ip.status
    END as alert_status
FROM installment_plan ip
JOIN enrollment e ON ip.enrollment_id = e.id
JOIN user u ON e.user_id = u.id
JOIN course c ON e.course_id = c.id
ORDER BY ip.due_date;

-- View: Course statistics
CREATE OR REPLACE VIEW `v_course_statistics` AS
SELECT 
    c.id as course_id,
    c.name as course_name,
    cat.name as category,
    sub.name as subcategory,
    c.fee,
    c.seats_total,
    c.seats_available,
    c.seats_total - c.seats_available as enrolled_count,
    c.status
FROM course c
JOIN course_category cat ON c.course_category_id = cat.id
JOIN subcategory sub ON c.subcategory_id = sub.id;
