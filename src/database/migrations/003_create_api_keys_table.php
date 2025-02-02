<?php
return [
    'up' => "
        CREATE TABLE api_keys (
            id INT AUTO_INCREMENT PRIMARY KEY,
            key_value VARCHAR(64) UNIQUE NOT NULL,
            description VARCHAR(255),
            active BOOLEAN DEFAULT true,
            last_used DATETIME,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ",
    'down' => "DROP TABLE IF EXISTS api_keys;"
];
