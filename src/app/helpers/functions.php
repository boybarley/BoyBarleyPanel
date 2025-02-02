<?php
function view($template, $data = []) {
    extract($data);
    $template = str_replace('.', '/', $template);
    require BASE_PATH . "/app/views/{$template}.php";
}

function asset($path) {
    return APP_URL . '/public/' . $path;
}

function redirect($path) {
    header("Location: " . APP_URL . $path);
    exit;
}

function formatBytes($bytes, $precision = 2) {
    $units = ['B', 'KB', 'MB', 'GB', 'TB'];
    $bytes = max($bytes, 0);
    $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
    $pow = min($pow, count($units) - 1);
    return round($bytes / pow(1024, $pow), $precision) . ' ' . $units[$pow];
}

function isAuthenticated() {
    return isset($_SESSION['user_id']);
}
