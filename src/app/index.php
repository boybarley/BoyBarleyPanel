<?php
require_once 'config/config.php';
require_once 'core/Router.php';

class BoyBarleyPanel {
    private $router;

    public function __construct() {
        $this->router = new Router();
        $this->initializeRoutes();
    }

    private function initializeRoutes() {
        $this->router->add('/', 'DashboardController@index');
        $this->router->add('/system', 'SystemController@index');
        $this->router->add('/services', 'ServicesController@index');
        $this->router->add('/files', 'FileManagerController@index');
        $this->router->add('/database', 'DatabaseController@index');
    }

    public function run() {
        $this->router->dispatch();
    }
}

$app = new BoyBarleyPanel();
$app->run();
