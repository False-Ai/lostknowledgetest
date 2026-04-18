-- ============================================================
-- Migration v2: Phone number, Google OAuth, Password Resets
-- Run this in phpMyAdmin or MySQL CLI after the initial schema
-- Execute each statement ONE AT A TIME if you get errors
-- ============================================================

USE lost_knowledge;

-- 1. Add phone column to users
ALTER TABLE users ADD COLUMN phone VARCHAR(15) DEFAULT NULL AFTER email;

-- 2. Add unique index on phone (separate statement)
ALTER TABLE users ADD UNIQUE INDEX idx_phone (phone);

-- 3. Add google_id column to users (for Google OAuth)
ALTER TABLE users ADD COLUMN google_id VARCHAR(255) DEFAULT NULL AFTER phone;

-- 4. Add index on google_id
ALTER TABLE users ADD INDEX idx_google_id (google_id);

-- 5. Make password nullable (Google OAuth users won't have one)
ALTER TABLE users MODIFY COLUMN password VARCHAR(255) DEFAULT NULL;

-- 6. Create password_resets table
CREATE TABLE IF NOT EXISTS password_resets (
    id          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    user_id     INT UNSIGNED    NOT NULL,
    token       VARCHAR(64)     NOT NULL UNIQUE,
    expires_at  DATETIME        NOT NULL,
    used        TINYINT(1)      NOT NULL DEFAULT 0,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY fk_reset_user (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_user_expires (user_id, expires_at)
) ENGINE=InnoDB;
