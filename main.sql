-- QuanXk5 Storage System Database Schema

-- Storage Locations Table
CREATE TABLE IF NOT EXISTS `storage_locations` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `coords` TEXT NOT NULL,
    `heading` FLOAT NOT NULL DEFAULT 0.0,
    `label` VARCHAR(100) NOT NULL,
    `blip` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Player Storages Table
CREATE TABLE IF NOT EXISTS `player_storages` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(50) NOT NULL,
    `location_id` INT(11) NOT NULL,
    `tier` INT(11) NOT NULL DEFAULT 1,
    `password` VARCHAR(100) NOT NULL,
    `purchased_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_accessed` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`),
    KEY `location_id` (`location_id`),
    CONSTRAINT `fk_storage_location` FOREIGN KEY (`location_id`) REFERENCES `storage_locations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Indexes for performance
CREATE INDEX `idx_player_storages_identifier` ON `player_storages` (`identifier`);
CREATE INDEX `idx_player_storages_location` ON `player_storages` (`location_id`);
