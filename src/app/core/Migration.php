<?php
namespace App\Core;

class Migration {
    private $db;
    private $migrations_path;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
        $this->migrations_path = BASE_PATH . '/database/migrations';
        $this->createMigrationsTable();
    }

    private function createMigrationsTable() {
        $this->db->exec("
            CREATE TABLE IF NOT EXISTS migrations (
                id INT AUTO_INCREMENT PRIMARY KEY,
                migration VARCHAR(255),
                executed_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");
    }

    public function migrate() {
        $executed_migrations = $this->getExecutedMigrations();
        $available_migrations = $this->getAvailableMigrations();
        
        $new_migrations = array_diff($available_migrations, $executed_migrations);
        
        foreach ($new_migrations as $migration) {
            $this->executeMigration($migration);
        }
    }

    public function rollback() {
        $executed_migrations = $this->getExecutedMigrations();
        
        if (empty($executed_migrations)) {
            echo "No migrations to rollback.\n";
            return;
        }
        
        $last_migration = end($executed_migrations);
        $this->rollbackMigration($last_migration);
    }

    private function getExecutedMigrations() {
        $stmt = $this->db->query("SELECT migration FROM migrations ORDER BY id");
        return $stmt->fetchAll(\PDO::FETCH_COLUMN);
    }

    private function getAvailableMigrations() {
        return array_map(function($file) {
            return pathinfo($file, PATHINFO_FILENAME);
        }, glob($this->migrations_path . '/*.php'));
    }

    private function executeMigration($migration) {
        $file = $this->migrations_path . "/{$migration}.php";
        $migration_data = require $file;
        
        try {
            $this->db->beginTransaction();
            $this->db->exec($migration_data['up']);
            $this->db->prepare("INSERT INTO migrations (migration) VALUES (?)")
                     ->execute([$migration]);
            $this->db->commit();
            
            echo "Migrated: $migration\n";
        } catch (\Exception $e) {
            $this->db->rollBack();
            echo "Error migrating $migration: " . $e->getMessage() . "\n";
        }
    }

    private function rollbackMigration($migration) {
        $file = $this->migrations_path . "/{$migration}.php";
        $migration_data = require $file;
        
        try {
            $this->db->beginTransaction();
            $this->db->exec($migration_data['down']);
            $this->db->prepare("DELETE FROM migrations WHERE migration = ?")
                     ->execute([$migration]);
            $this->db->commit();
            
            echo "Rolled back: $migration\n";
        } catch (\Exception $e) {
            $this->db->rollBack();
            echo "Error rolling back $migration: " . $e->getMessage() . "\n";
        }
    }
}
