-- Initial placeholder migration.
-- Full schema will be added in subsequent migrations once the project tables are finalized.
CREATE TABLE IF NOT EXISTS `app_placeholder` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

