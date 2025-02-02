<?php
namespace App\Controllers;

use App\Core\Controller;

class DashboardController extends Controller {
    public function index() {
        if (!isAuthenticated()) {
            redirect('/login');
        }
        
        $systemInfo = [
            'cpu' => sys_getloadavg(),
            'memory' => $this->getMemoryUsage(),
            'disk' => disk_free_space('/'),
            'uptime' => $this->getUptime()
        ];
        
        return $this->view('dashboard.index', ['systemInfo' => $systemInfo]);
    }
    
    private function getMemoryUsage() {
        $free = shell_exec('free');
        $free = (string)trim($free);
        $free_arr = explode("\n", $free);
        $mem = explode(" ", $free_arr[1]);
        $mem = array_filter($mem);
        $mem = array_merge($mem);
        
        return [
            'total' => $mem[1],
            'used' => $mem[2],
            'free' => $mem[3]
        ];
    }
    
    private function getUptime() {
        $uptime = shell_exec('uptime -p');
        return trim($uptime);
    }
}
