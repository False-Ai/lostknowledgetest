-- ============================================================
-- Migration v3: 16-Feature Expansion
-- Views, Tags, Notifications, Reputation, Revisions, Digests
-- Run in phpMyAdmin or MySQL CLI
-- ============================================================

USE lost_knowledge;

-- 1. Add views counter to knowledge_entries
ALTER TABLE knowledge_entries ADD COLUMN views INT UNSIGNED NOT NULL DEFAULT 0 AFTER image_path;

-- 2. Add avatar_path and bio to users
ALTER TABLE users ADD COLUMN avatar_path VARCHAR(255) DEFAULT NULL AFTER password;
ALTER TABLE users ADD COLUMN bio TEXT DEFAULT NULL AFTER avatar_path;
ALTER TABLE users ADD COLUMN karma INT NOT NULL DEFAULT 0 AFTER bio;

-- 3. Tags system
CREATE TABLE IF NOT EXISTS tags (
    id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(60)  NOT NULL UNIQUE,
    slug VARCHAR(60)  NOT NULL UNIQUE,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS entry_tags (
    entry_id INT UNSIGNED NOT NULL,
    tag_id   INT UNSIGNED NOT NULL,
    PRIMARY KEY (entry_id, tag_id),
    FOREIGN KEY fk_et_entry (entry_id) REFERENCES knowledge_entries(id) ON DELETE CASCADE,
    FOREIGN KEY fk_et_tag   (tag_id)   REFERENCES tags(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Notifications system
CREATE TABLE IF NOT EXISTS notifications (
    id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id    INT UNSIGNED NOT NULL,
    type       VARCHAR(30)  NOT NULL,  -- 'entry_approved','entry_rejected','new_comment','vote_milestone'
    message    VARCHAR(400) NOT NULL,
    link       VARCHAR(255) DEFAULT NULL,
    is_read    TINYINT(1)   NOT NULL DEFAULT 0,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY fk_notif_user (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_created (created_at)
) ENGINE=InnoDB;

-- 5. Entry revision history
CREATE TABLE IF NOT EXISTS entry_revisions (
    id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    entry_id   INT UNSIGNED NOT NULL,
    user_id    INT UNSIGNED NOT NULL,
    title      VARCHAR(200) NOT NULL,
    summary    VARCHAR(400) NOT NULL,
    body       TEXT         NOT NULL,
    region     VARCHAR(100) DEFAULT NULL,
    era        VARCHAR(100) DEFAULT NULL,
    revised_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY fk_rev_entry (entry_id) REFERENCES knowledge_entries(id) ON DELETE CASCADE,
    FOREIGN KEY fk_rev_user  (user_id)  REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_entry_rev (entry_id, revised_at)
) ENGINE=InnoDB;

-- 6. Email digest preferences
CREATE TABLE IF NOT EXISTS email_preferences (
    user_id       INT UNSIGNED NOT NULL,
    digest_freq   ENUM('none','daily','weekly','monthly') NOT NULL DEFAULT 'weekly',
    notify_email  TINYINT(1) NOT NULL DEFAULT 1,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    FOREIGN KEY fk_ep_user (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. Bookmarks table (if not already exists)
CREATE TABLE IF NOT EXISTS bookmarks (
    id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id    INT UNSIGNED NOT NULL,
    entry_id   INT UNSIGNED NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_bm_user_entry (user_id, entry_id),
    FOREIGN KEY fk_bm_user  (user_id)  REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY fk_bm_entry (entry_id) REFERENCES knowledge_entries(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 8. Feedback table (if not already exists)
CREATE TABLE IF NOT EXISTS feedback (
    id         INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    name       VARCHAR(100)    DEFAULT NULL,
    email      VARCHAR(150)    NOT NULL,
    phone      VARCHAR(20)     DEFAULT NULL,
    subject    VARCHAR(200)    DEFAULT NULL,
    message    TEXT             NOT NULL,
    type       VARCHAR(30)     DEFAULT 'feedback',
    status     ENUM('unread','read','resolved') NOT NULL DEFAULT 'unread',
    created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_status (status)
) ENGINE=InnoDB;
