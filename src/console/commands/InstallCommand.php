<?php
namespace App\Console\Commands;

use App\Console\Command;
use App\Core\Database;
use App\Core\Migration;

class InstallCommand extends Command {
    protected $name = 'install';
    protected $description = 'Install BoyBarleyPanel';

    public function execute($args = []) {
        $this->output("Starting BoyBarleyPanel installation...");

        // Check requirements
        $this->checkRequirements();
        
        // Create database
        $this->createDatabase();
        
        // Run migrations
        $this->runMigrations();
        
        // Create admin user
        $this->createAdminUser();
        
        // Set up configuration
        $this->setupConfiguration();
        
        $this->success("Installation completed successfully!");
    }

    private function checkRequirements() {
        $this->output("Checking requirements...");
        
        $requirements = [
            'php' => '7.4',
            'extensions' => ['pdo', 'json', 'mbstring', 'openssl']
        ];

        if (version_compare(PHP_VERSION, $requirements['php'], '<')) {
            $this->error("PHP version {$requirements['php']} or higher is required.");
            exit(1);
        }

        foreach ($requirements['extensions'] as $ext) {
            if (!extension_loaded($ext)) {
                $this->error("PHP extension {$ext} is required.");
                exit(1);
            }
        }

        $this->success("All requirements met!");
    }

    private function createDatabase() {
        $this->output("Creating database...");
        
        try {
            $pdo = new \PDO("mysql:host=".DB_HOST, DB_USER, DB_PASS);
            $pdo->exec("CREATE DATABASE IF NOT EXISTS ".DB_NAME);
            $this->success("Database created successfully!");
        } catch (\PDOException $e) {
            $this->error("Database creation failed: " . $e->getMessage());
            exit(1);
        }
    }

    private function runMigrations() {
        $this->output("Running migrations...");
        
        try {
            $migration = new Migration();
            $migration->migrate();
            $this->success("Migrations completed successfully!");
        } catch (\Exception $e) {
            $this->error("Migration failed: " . $e->getMessage());
            exit(1);
        }
    }

    private function createAdminUser() {
        $this->output("Creating admin user...");
        
        try {
            $db = Database::getInstance()->getConnection();
            $password = password_hash('admin', PASSWORD_DEFAULT);
            
            $stmt = $db->prepare("
                INSERT INTO users (username, password, email, role)
                VALUES (?, ?, ?, 'admin')
            ");
            
            $stmt->execute(['admin', $password, 'admin@example.com']);
            $this->success("Admin user created successfully!");
        } catch (\Exception $e) {
            $this->error("Failed to create admin user: " . $e->getMessage());
            exit(1);
        }
    }

    private function setupConfiguration() {
        $this->output("Setting up configuration...");
        
        // Create configuration files from templates
        $configs = [
            'config.php' => [
                'APP_URL' => 'http://localhost',
                'APP_ENV' => 'production',
                'APP_DEBUG' => false
            ]
        ];

        foreach ($configs as $file => $values) {
            $this->createConfigFile($file, $values);
        }

        $this->success("Configuration completed!");
    }
}
