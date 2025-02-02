<?php
namespace App\Core;

class Controller {
    protected $db;
    
    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }
    
    protected function view($template, $data = []) {
        extract($data);
        $template = str_replace('.', '/', $template);
        require BASE_PATH . "/app/views/{$template}.php";
    }
    
    protected function json($data) {
        header('Content-Type: application/json');
        echo json_encode($data);
    }
}
