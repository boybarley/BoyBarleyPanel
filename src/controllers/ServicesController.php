<?php
namespace App\Controllers;

use App\Core\Controller;

class ServicesController extends Controller {
    private $allowedServices = [
        'nginx' => 'Web Server',
        'php-fpm' => 'PHP-FPM',
        'mysql' => 'MySQL Database',
        'ssh' => 'SSH Server',
        'postfix' => 'Mail Server',
        'redis' => 'Redis Cache'
    ];

    public function index() {
        if (!isAuthenticated()) {
            redirect('/login');
        }

        $services = $this->getServicesStatus();
        return $this->view('services.index', ['services' => $services]);
    }

    public function getServicesStatus() {
        $status = [];
        foreach ($this->allowedServices as $service => $description) {
            $running = $this->isServiceRunning($service);
            $status[$service] = [
                'name' => $service,
                'description' => $description,
                'running' => $running,
                'pid' => $running ? $this->getServicePid($service) : null,
                'memory' => $running ? $this->getServiceMemoryUsage($service) : 0,
                'uptime' => $running ? $this->getServiceUptime($service) : null
            ];
        }
        return $status;
    }

    public function control() {
        if (!isAuthenticated()) {
            return $this->json(['success' => false, 'message' => 'Unauthorized']);
        }

        $service = $_POST['service'] ?? '';
        $action = $_POST['action'] ?? '';

        if (!array_key_exists($service, $this->allowedServices)) {
            return $this->json(['success' => false, 'message' => 'Invalid service']);
        }

        switch ($action) {
            case 'start':
                exec("systemctl start $service 2>&1", $output, $return);
                break;
            case 'stop':
                exec("systemctl stop $service 2>&1", $output, $return);
                break;
            case 'restart':
                exec("systemctl restart $service 2>&1", $output, $return);
                break;
            default:
                return $this->json(['success' => false, 'message' => 'Invalid action']);
        }

        return $this->json([
            'success' => $return === 0,
            'message' => $return === 0 ? 
                "Service $service {$action}ed successfully" : 
                "Failed to $action $service"
        ]);
    }

    private function isServiceRunning($service) {
        exec("systemctl is-active $service 2>&1", $output, $return);
        return $return === 0;
    }

    private function getServicePid($service) {
        exec("systemctl show --property MainPID $service", $output);
        $pid = explode('=', $output[0])[1];
        return $pid != '0' ? $pid : null;
    }

    private function getServiceMemoryUsage($service) {
        $pid = $this->getServicePid($service);
        if (!$pid) return 0;
        
        exec("ps -o rss= -p $pid", $output);
        return isset($output[0]) ? intval($output[0]) * 1024 : 0;
    }

    private function getServiceUptime($service) {
        $pid = $this->getServicePid($service);
        if (!$pid) return null;
        
        exec("ps -o etimes= -p $pid", $output);
        return isset($output[0]) ? intval($output[0]) : null;
    }
}

