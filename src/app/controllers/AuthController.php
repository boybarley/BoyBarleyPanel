<?php
namespace App\Controllers;

use App\Core\Controller;

class AuthController extends Controller {
    public function login() {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $username = $_POST['username'] ?? '';
            $password = $_POST['password'] ?? '';
            
            $stmt = $this->db->prepare("SELECT * FROM users WHERE username = ?");
            $stmt->execute([$username]);
            $user = $stmt->fetch();
            
            if ($user && password_verify($password, $user['password'])) {
                $_SESSION['user_id'] = $user['id'];
                $_SESSION['username'] = $user['username'];
                redirect('/dashboard');
            }
            
            return $this->view('auth.login', ['error' => 'Invalid credentials']);
        }
        
        return $this->view('auth.login');
    }
    
    public function logout() {
        session_destroy();
        redirect('/login');
    }
}
