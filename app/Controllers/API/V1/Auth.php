<?php

namespace App\Controllers\API\V1;

use App\Controllers\BaseController;
use App\Models\UserModel;

class Auth extends BaseController
{
    protected $userModel;

    public function __construct()
    {
        $this->userModel = new UserModel();
        helper('jwt');
    }

    /**
     * User Registration
     * POST /api/v1/auth/register
     */
    public function register()
    {
        $rules = [
            'name' => 'required|min_length[3]|max_length[255]',
            'email' => 'required|valid_email|is_unique[users.email]',
            'phone' => 'permit_empty|min_length[10]|max_length[20]',
            'password' => 'required|min_length[6]',
        ];

        if (!$this->validate($rules)) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Validasi gagal',
                'data' => $this->validator->getErrors(),
            ])->setStatusCode(400);
        }

        $data = [
            'name' => $this->request->getPost('name'),
            'email' => $this->request->getPost('email'),
            'phone' => $this->request->getPost('phone'),
            'password' => $this->request->getPost('password'),
        ];

        try {
            $userId = $this->userModel->insert($data);

            if (!$userId) {
                throw new \Exception('Gagal membuat akun');
            }

            // Get user data without password
            $user = $this->userModel->find($userId);
            unset($user['password']);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Registrasi berhasil! Silakan login.',
                'data' => $user,
            ])->setStatusCode(201);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null,
            ])->setStatusCode(500);
        }
    }

    /**
     * User Login
     * POST /api/v1/auth/login
     */
    public function login()
    {
        $rules = [
            'email' => 'required|valid_email',
            'password' => 'required',
        ];

        if (!$this->validate($rules)) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Validasi gagal',
                'data' => $this->validator->getErrors(),
            ])->setStatusCode(400);
        }

        $email = $this->request->getPost('email');
        $password = $this->request->getPost('password');

        // Verify credentials
        $user = $this->userModel->verifyLogin($email, $password);

        if (!$user) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Email atau password salah',
                'data' => null,
            ])->setStatusCode(401);
        }

        // Generate JWT token
        $userData = [
            'email' => $user['email'],
            'name' => $user['name'],
        ];

        $token = generateJWT($user['id'], $userData);

        // Save token to database
        $this->userModel->updateToken($user['id'], $token);

        // Remove password from response
        unset($user['password']);
        unset($user['jwt_token']);

        return $this->response->setJSON([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => $user,
                'token' => $token,
            ],
        ])->setStatusCode(200);
    }

    /**
     * User Logout
     * POST /api/v1/auth/logout
     * Requires Authentication
     */
    public function logout()
    {
        $userId = getCurrentUserId();

        if (!$userId) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Unauthorized',
                'data' => null,
            ])->setStatusCode(401);
        }

        // Clear token from database
        $this->userModel->clearToken($userId);

        return $this->response->setJSON([
            'success' => true,
            'message' => 'Logout berhasil',
            'data' => null,
        ])->setStatusCode(200);
    }
}
