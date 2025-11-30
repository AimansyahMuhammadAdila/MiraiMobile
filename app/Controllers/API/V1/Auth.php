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
        // Get JSON input
        $json = $this->request->getJSON();

        $rules = [
            'name' => 'required|min_length[3]|max_length[255]',
            'email' => 'required|valid_email|is_unique[users.email]',
            'phone' => 'permit_empty|min_length[10]|max_length[20]',
            'password' => 'required|min_length[6]',
        ];

        $inputData = [
            'name' => $json->name ?? null,
            'email' => $json->email ?? null,
            'phone' => $json->phone ?? null,
            'password' => $json->password ?? null,
        ];

        if (!$this->validate($rules)) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Validasi gagal',
                'data' => $this->validator->getErrors(),
            ])->setStatusCode(400);
        }

        $data = [
            'name' => $json->name,
            'email' => $json->email,
            'phone' => $json->phone ?? null,
            'password' => $json->password,
            'role' => 'user', // Default role for new users
        ];

        try {
            $userId = $this->userModel->insert($data);

            if (!$userId) {
                throw new \Exception('Gagal membuat akun');
            }

            // Get user data without password
            $user = $this->userModel->find($userId);
            unset($user['password']);
            unset($user['jwt_token']);

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
        // Get JSON input
        $json = $this->request->getJSON();

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

        $email = $json->email;
        $password = $json->password;

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

        // Prepare clean user response
        return $this->response->setJSON([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => [
                    'id' => $user['id'],
                    'name' => $user['name'],
                    'email' => $user['email'],
                    'phone' => $user['phone'],
                    'role' => $user['role'] ?? 'user',
                ],
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
