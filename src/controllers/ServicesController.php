// controllers/ServicesController.php
class ServicesController {
    public function manageService($service, $action) {
        switch($action) {
            case 'start':
                exec("systemctl start $service");
                break;
            case 'stop':
                exec("systemctl stop $service");
                break;
            case 'restart':
                exec("systemctl restart $service");
                break;
        }
    }
}
