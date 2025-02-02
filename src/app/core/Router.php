<?php
namespace App\Core;

class Router {
    private $routes = [];
    
    public function add($path, $handler) {
        $this->routes[$path] = $handler;
    }
    
    public function dispatch() {
        $uri = $_SERVER['REQUEST_URI'];
        $uri = parse_url($uri, PHP_URL_PATH);
        
        if (isset($this->routes[$uri])) {
            list($controller, $method) = explode('@', $this->routes[$uri]);
            $controllerClass = "App\\Controllers\\{$controller}";
            
            if (class_exists($controllerClass)) {
                $controller = new $controllerClass();
                if (method_exists($controller, $method)) {
                    return $controller->$method();
                }
            }
        }
        
        header("HTTP/1.0 404 Not Found");
        return view('errors/404');
    }
}
