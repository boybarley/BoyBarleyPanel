<?php
namespace App\Console;

abstract class Command {
    protected $name;
    protected $description;
    protected $arguments = [];

    abstract public function execute($args = []);

    public function getName() {
        return $this->name;
    }

    public function getDescription() {
        return $this->description;
    }

    protected function output($message) {
        echo $message . PHP_EOL;
    }

    protected function error($message) {
        echo "\033[31m" . $message . "\033[0m" . PHP_EOL;
    }

    protected function success($message) {
        echo "\033[32m" . $message . "\033[0m" . PHP_EOL;
    }
}
