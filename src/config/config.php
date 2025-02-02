<?php
define('APP_NAME', 'BoyBarleyPanel');
define('APP_VERSION', '1.0.0');
define('BASE_PATH', dirname(__DIR__));
define('APP_URL', 'http://localhost'); // Change this according to your setup

// Database configuration
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'boybarleypanel');

// Session configuration
ini_set('session.gc_maxlifetime', 3600);
session_start();

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Timezone
date_default_timezone_set('UTC');
