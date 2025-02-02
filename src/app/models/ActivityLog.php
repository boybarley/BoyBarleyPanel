<?php
namespace App\Models;

use App\Core\Database;

class ActivityLog {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    public function log($userId, $action, $details = null) {
        $stmt = $this->db->prepare("
            INSERT INTO activity_logs (user_id, action, details, created_at)
            VALUES (?, ?, ?, NOW())
        ");

        return $stmt->execute([$userId, $action, json_encode($details)]);
    }

    public function getRecent($limit = 10) {
        $stmt = $this->db->prepare("
            SELECT al.*, u.username 
            FROM activity_logs al
            LEFT JOIN users u ON al.user_id = u.id
            ORDER BY al.created_at DESC
            LIMIT ?
        ");
        
        $stmt->execute([$limit]);
        return $stmt->fetchAll();
    }

    public function getUserActivity($userId, $limit = 10) {
        $stmt = $this->db->prepare("
            SELECT * FROM activity_logs
            WHERE user_id = ?
            ORDER BY created_at DESC
            LIMIT ?
        ");
        
        $stmt->execute([$userId, $limit]);
        return $stmt->fetchAll();
    }
}
