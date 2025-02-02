<?php
namespace App\Controllers;

use App\Core\Controller;

class ApiController extends Controller {
    public function __construct() {
        parent::__construct();
        header('Content-Type: application/json');
        
        if (!$this->isValidApiRequest()) {
            echo json_encode(['error' => 'Unauthorized']);
            exit;
        }
    }

    private function isValidApiRequest() {
        return isAuthenticated() || $this->isValidApiKey();
    }

    private function isValidApiKey() {
        $headers = getallheaders();
        $apiKey = $headers['X-API-Key'] ?? null;
        
        if (!$apiKey) return false;
        
        // Verify API key from database
        $stmt = $this->db->prepare("SELECT * FROM api_keys WHERE key_value = ? AND active = 1");
        $stmt->execute([$apiKey]);
        return $stmt->fetch() ? true : false;
    }

    public function getSystemStats() {
        $stats = [
            'cpu' => sys_getloadavg(),
            'memory' => $this->getMemoryUsage(),
            'disk' => $this->getDiskUsage(),
            'network' => $this->getNetworkStats(),
            'timestamp' => time()
        ];
        
        echo json_encode($stats);
    }

    public function getServiceStatus($serviceName) {
        $allowedServices = ['nginx', 'php-fpm', 'mysql', 'ssh'];
        
        if (!in_array($serviceName, $allowedServices)) {
            echo json_encode(['error' => 'Invalid service']);
            return;
        }
        
        $status = shell_exec("systemctl is-active $serviceName");
        echo json_encode([
            'service' => $serviceName,
            'status' => trim($status),
            'timestamp' => time()
        ]);
    }

    public function getLogs() {
        $type = $_GET['type'] ?? 'system';
        $limit = min((int)($_GET['limit'] ?? 100), 1000);
        
        switch($type) {
            case 'system':
                $logs = $this->getSystemLogs($limit);
                break;
            case 'access':
                $logs = $this->getAccessLogs($limit);
                break;
            case 'error':
                $logs = $this->getErrorLogs($limit);
                break;
            default:
                $logs = [];
        }
        
        echo json_encode(['logs' => $logs]);
    }

    private function getSystemLogs($limit) {
        return array_slice(explode("\n", shell_exec("journalctl -n $limit")), 0, $limit);
    }

    private function getAccessLogs($limit) {
        return array_slice(explode("\n", shell_exec("tail -n $limit /var/log/nginx/access.log")), 0, $limit);
    }

    private function getErrorLogs($limit) {
        return array_slice(explode("\n", shell_exec("tail -n $limit /var/log/nginx/error.log")), 0, $limit);
    }
}
