<?php
namespace App\Controllers;

use App\Core\Controller;

class SystemController extends Controller {
    public function index() {
        if (!isAuthenticated()) {
            redirect('/login');
        }

        $systemInfo = $this->getDetailedSystemInfo();
        return $this->view('system.index', ['systemInfo' => $systemInfo]);
    }

    public function getDetailedSystemInfo() {
        return [
            'os' => [
                'name' => php_uname('s'),
                'version' => php_uname('r'),
                'machine' => php_uname('m'),
                'hostname' => php_uname('n')
            ],
            'cpu' => $this->getCpuInfo(),
            'memory' => $this->getMemoryInfo(),
            'disk' => $this->getDiskInfo(),
            'network' => $this->getNetworkInfo(),
            'services' => $this->getServicesStatus()
        ];
    }

    private function getCpuInfo() {
        $cpu = shell_exec('cat /proc/cpuinfo');
        $cpu_array = explode("\n", $cpu);
        $cpu_info = [];
        
        foreach($cpu_array as $line) {
            if (strpos($line, 'model name') !== false) {
                $cpu_info['model'] = trim(explode(':', $line)[1]);
            }
            if (strpos($line, 'cpu cores') !== false) {
                $cpu_info['cores'] = trim(explode(':', $line)[1]);
            }
        }
        
        $load = sys_getloadavg();
        $cpu_info['load'] = [
            '1min' => $load[0],
            '5min' => $load[1],
            '15min' => $load[2]
        ];
        
        return $cpu_info;
    }

    private function getMemoryInfo() {
        $meminfo = file_get_contents('/proc/meminfo');
        $lines = explode("\n", $meminfo);
        $memory = [];
        
        foreach($lines as $line) {
            if (preg_match('/^MemTotal:\s+(\d+)/', $line, $matches)) {
                $memory['total'] = $matches[1] * 1024;
            }
            if (preg_match('/^MemFree:\s+(\d+)/', $line, $matches)) {
                $memory['free'] = $matches[1] * 1024;
            }
            if (preg_match('/^MemAvailable:\s+(\d+)/', $line, $matches)) {
                $memory['available'] = $matches[1] * 1024;
            }
        }
        
        $memory['used'] = $memory['total'] - $memory['available'];
        $memory['percentage'] = round(($memory['used'] / $memory['total']) * 100, 2);
        
        return $memory;
    }

    private function getDiskInfo() {
        $disks = [];
        $df = shell_exec('df -P');
        $df_lines = explode("\n", $df);
        array_shift($df_lines); // Remove header line
        
        foreach($df_lines as $line) {
            if (empty($line)) continue;
            $parts = preg_split('/\s+/', $line);
            if (strpos($parts[0], '/dev/') === 0) {
                $disks[] = [
                    'device' => $parts[0],
                    'total' => $parts[1] * 1024,
                    'used' => $parts[2] * 1024,
                    'free' => $parts[3] * 1024,
                    'mount' => $parts[5],
                    'percentage' => str_replace('%', '', $parts[4])
                ];
            }
        }
        
        return $disks;
    }

    private function getNetworkInfo() {
        $interfaces = [];
        $netdev = file_get_contents('/proc/net/dev');
        $lines = explode("\n", $netdev);
        array_shift($lines); // Remove header
        array_shift($lines); // Remove header
        
        foreach($lines as $line) {
            if (empty($line)) continue;
            $parts = preg_split('/\s+/', trim($line));
            $interface = rtrim($parts[0], ':');
            if ($interface != 'lo') { // Skip loopback
                $interfaces[$interface] = [
                    'rx_bytes' => $parts[1],
                    'rx_packets' => $parts[2],
                    'tx_bytes' => $parts[9],
                    'tx_packets' => $parts[10]
                ];
            }
        }
        
        return $interfaces;
    }

    private function getServicesStatus() {
        $services = ['nginx', 'php-fpm', 'mysql', 'ssh'];
        $status = [];
        
        foreach($services as $service) {
            $result = shell_exec("systemctl is-active $service 2>&1");
            $status[$service] = trim($result) === 'active';
        }
        
        return $status;
    }

    public function updateSystem() {
        if (!isAuthenticated()) {
            return $this->json(['success' => false, 'message' => 'Unauthorized']);
        }

        $output = shell_exec('apt-get update && apt-get upgrade -y 2>&1');
        return $this->json([
            'success' => true,
            'message' => 'System updated successfully',
            'output' => $output
        ]);
    }

    public function reboot() {
        if (!isAuthenticated()) {
            return $this->json(['success' => false, 'message' => 'Unauthorized']);
        }

        shell_exec('shutdown -r now');
        return $this->json([
            'success' => true,
            'message' => 'System is rebooting'
        ]);
    }
}
