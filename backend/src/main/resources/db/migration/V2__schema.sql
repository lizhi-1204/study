-- Core schema for the integral/check-in/prize system.
-- "不可删除/不可修改" is enforced via MySQL triggers on key immutable records.

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `role` VARCHAR(16) NOT NULL, -- PARENT | CHILD
  `username` VARCHAR(64) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `nickname` VARCHAR(64) NOT NULL DEFAULT '',
  `avatar_url` VARCHAR(512) NOT NULL DEFAULT '',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_users_username` (`username`),
  KEY `idx_users_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `parent_security_question` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `parent_user_id` BIGINT NOT NULL,
  `question_order` TINYINT NOT NULL, -- 1..3
  `question_text` VARCHAR(200) NOT NULL,
  `answer_hash` VARCHAR(255) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_parent_security_question` (`parent_user_id`, `question_order`),
  CONSTRAINT `fk_psq_parent` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `child_profile` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `child_user_id` BIGINT NOT NULL,
  `parent_user_id` BIGINT NOT NULL,
  `real_name` VARCHAR(64) NOT NULL,
  `birthday` DATE NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_child_profile_child_user_id` (`child_user_id`),
  KEY `idx_child_profile_parent` (`parent_user_id`),
  CONSTRAINT `fk_cp_child_user` FOREIGN KEY (`child_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_cp_parent_user` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `credit_project` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `parent_user_id` BIGINT NOT NULL,
  `project_name` VARCHAR(100) NOT NULL,
  `points_value` BIGINT NOT NULL,
  `enabled` TINYINT NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_credit_parent_enabled` (`parent_user_id`, `enabled`),
  CONSTRAINT `fk_cp_credit_parent` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `debit_project` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `parent_user_id` BIGINT NOT NULL,
  `project_name` VARCHAR(100) NOT NULL,
  `points_value` BIGINT NOT NULL,
  `enabled` TINYINT NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_debit_parent_enabled` (`parent_user_id`, `enabled`),
  CONSTRAINT `fk_dp_debit_parent` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `prize` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `parent_user_id` BIGINT NOT NULL,
  `prize_name` VARCHAR(100) NOT NULL,
  `exchange_required_points` BIGINT NULL,
  `lottery_enabled` TINYINT NOT NULL DEFAULT 0,
  `lottery_weight` INT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_prize_parent` (`parent_user_id`),
  KEY `idx_prize_parent_lottery` (`parent_user_id`, `lottery_enabled`),
  CONSTRAINT `fk_prize_parent` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `lottery_config` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `parent_user_id` BIGINT NOT NULL,
  `cost_points` BIGINT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_lottery_config_parent` (`parent_user_id`),
  CONSTRAINT `fk_lottery_config_parent` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `child_check_in_request` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `child_user_id` BIGINT NOT NULL,
  `parent_user_id` BIGINT NOT NULL,
  `credit_project_id` BIGINT NOT NULL,
  `request_date` DATE NOT NULL, -- natural day in Asia/Shanghai
  `status` VARCHAR(16) NOT NULL DEFAULT 'APPLY', -- APPLY | APPROVED | REJECTED
  `submitted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` DATETIME NULL,
  `reviewer_user_id` BIGINT NULL,
  `reviewer_comment` VARCHAR(500) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_check_in_unique_day_project` (`child_user_id`, `credit_project_id`, `request_date`),
  KEY `idx_check_in_parent_status` (`parent_user_id`, `status`),
  KEY `idx_check_in_child_status_date` (`child_user_id`, `status`, `request_date`),
  CONSTRAINT `fk_cir_child_user` FOREIGN KEY (`child_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_cir_parent_user` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_cir_credit_project` FOREIGN KEY (`credit_project_id`) REFERENCES `credit_project` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `points_transaction` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `parent_user_id` BIGINT NOT NULL,
  `child_user_id` BIGINT NOT NULL,
  `txn_type` VARCHAR(16) NOT NULL, -- CREDIT | DEBIT | EXCHANGE | LOTTERY
  `points_delta` BIGINT NOT NULL, -- credit > 0, debit < 0
  `source_type` VARCHAR(32) NULL, -- CHECK_IN | DEBIT_PROJECT | EXCHANGE | LOTTERY
  `source_id` BIGINT NULL,
  `title` VARCHAR(200) NULL,
  `detail` VARCHAR(500) NULL,
  `txn_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_points_child_time` (`child_user_id`, `txn_time`),
  KEY `idx_points_parent_time` (`parent_user_id`, `txn_time`),
  KEY `idx_points_type_time` (`txn_type`, `txn_time`),
  CONSTRAINT `fk_pt_parent_user` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_pt_child_user` FOREIGN KEY (`child_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `exchange_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `parent_user_id` BIGINT NOT NULL,
  `child_user_id` BIGINT NOT NULL,
  `prize_id` BIGINT NOT NULL,
  `prize_name_snapshot` VARCHAR(100) NOT NULL,
  `exchange_required_points` BIGINT NOT NULL,
  `spent_points` BIGINT NOT NULL, -- should be negative when written to points_transaction, but stored as positive here
  `exchanged_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_exchange_child_time` (`child_user_id`, `exchanged_at`),
  CONSTRAINT `fk_er_parent_user` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_er_child_user` FOREIGN KEY (`child_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_er_prize` FOREIGN KEY (`prize_id`) REFERENCES `prize` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `lottery_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `parent_user_id` BIGINT NOT NULL,
  `child_user_id` BIGINT NOT NULL,
  `prize_id` BIGINT NOT NULL,
  `prize_name_snapshot` VARCHAR(100) NOT NULL,
  `lottery_cost_points` BIGINT NOT NULL,
  `awarded_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lottery_child_time` (`child_user_id`, `awarded_at`),
  CONSTRAINT `fk_lr_parent_user` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_lr_child_user` FOREIGN KEY (`child_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_lr_prize` FOREIGN KEY (`prize_id`) REFERENCES `prize` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- Immutability triggers
-- =========================
DELIMITER $$

-- check_in_request immutability:
-- 1) cannot delete
-- 2) only allow status transition APPLY -> APPROVED/REJECTED
-- 3) key fields cannot change
DROP TRIGGER IF EXISTS `trg_cir_before_delete`;
DROP TRIGGER IF EXISTS `trg_cir_before_update`;

CREATE TRIGGER `trg_cir_before_delete`
BEFORE DELETE ON `child_check_in_request`
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'child_check_in_request cannot be deleted';
END$$

CREATE TRIGGER `trg_cir_before_update`
BEFORE UPDATE ON `child_check_in_request`
FOR EACH ROW
BEGIN
  -- after review, record becomes immutable
  IF OLD.status <> 'APPLY' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'child_check_in_request is immutable after review';
  END IF;

  -- key fields cannot be changed at any time
  IF OLD.child_user_id <> NEW.child_user_id
     OR OLD.parent_user_id <> NEW.parent_user_id
     OR OLD.credit_project_id <> NEW.credit_project_id
     OR OLD.request_date <> NEW.request_date
     OR OLD.submitted_at <> NEW.submitted_at THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'child_check_in_request key fields are immutable';
  END IF;

  -- disallow updates without status transition
  IF OLD.status = NEW.status THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'status must transition for update';
  END IF;

  -- only allow to APPROVED / REJECTED
  IF NEW.status NOT IN ('APPROVED','REJECTED') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'invalid status transition';
  END IF;

  -- reviewer fields should be set when reviewed
  IF NEW.reviewer_user_id IS NULL OR NEW.reviewed_at IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'reviewer_user_id and reviewed_at are required';
  END IF;
END$$

-- points_transaction immutability:
DROP TRIGGER IF EXISTS `trg_pt_before_delete`;
DROP TRIGGER IF EXISTS `trg_pt_before_update`;

CREATE TRIGGER `trg_pt_before_delete`
BEFORE DELETE ON `points_transaction`
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'points_transaction cannot be deleted';
END$$

CREATE TRIGGER `trg_pt_before_update`
BEFORE UPDATE ON `points_transaction`
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'points_transaction cannot be updated';
END$$

-- exchange_record immutability:
DROP TRIGGER IF EXISTS `trg_er_before_delete`;
DROP TRIGGER IF EXISTS `trg_er_before_update`;

CREATE TRIGGER `trg_er_before_delete`
BEFORE DELETE ON `exchange_record`
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'exchange_record cannot be deleted';
END$$

CREATE TRIGGER `trg_er_before_update`
BEFORE UPDATE ON `exchange_record`
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'exchange_record cannot be updated';
END$$

-- lottery_record immutability:
DROP TRIGGER IF EXISTS `trg_lr_before_delete`;
DROP TRIGGER IF EXISTS `trg_lr_before_update`;

CREATE TRIGGER `trg_lr_before_delete`
BEFORE DELETE ON `lottery_record`
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'lottery_record cannot be deleted';
END$$

CREATE TRIGGER `trg_lr_before_update`
BEFORE UPDATE ON `lottery_record`
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'lottery_record cannot be updated';
END$$

DELIMITER ;

