// controllers/SystemController.php
class SystemController {
    public function getSystemInfo() {
        $info = [
            'cpu_usage' => sys_getloadavg(),
            'memory_usage' => $this->getMemoryUsage(),
            'disk_usage' => disk_free_space('/'),
            'uptime' => $this->getUptime()
        ];
        return $info;
    }
}
