<?php

namespace App\Controllers\API\V1;

use App\Controllers\BaseController;
use App\Models\UserModel;

class User extends BaseController
{
    protected $userModel;

    public function __construct()
    {
        $this->userModel = new UserModel();
        helper('jwt');
    }

    /**
     * Get user profile
     * GET /api/v1/user/profile
     * Requires Authentication
     */
    public function profile()
    {
        $userId = getCurrentUserId();

        if (!$userId) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Unauthorized',
                'data' => null,
            ])->setStatusCode(401);
        }

        try {
            $user = $this->userModel->find($userId);

            if (!$user) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            // Remove sensitive data
            unset($user['password']);
            unset($user['jwt_token']);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Data profil berhasil diambil',
                'data' => $user,
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Gagal mengambil data profil',
                'data' => null,
            ])->setStatusCode(500);
        }
    }

    /**
     * Update user profile
     * PUT /api/v1/user/profile
     * Requires Authentication
     */
    public function update()
    {
        $userId = getCurrentUserId();

        if (!$userId) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Unauthorized',
                'data' => null,
            ])->setStatusCode(401);
        }

        $rules = [
            'name' => 'permit_empty|min_length[3]|max_length[255]',
            'phone' => 'permit_empty|min_length[10]|max_length[20]',
        ];

        if (!$this->validate($rules)) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Validasi gagal',
                'data' => $this->validator->getErrors(),
            ])->setStatusCode(400);
        }

        try {
            $data = [];

            if ($this->request->getVar('name')) {
                $data['name'] = $this->request->getVar('name');
            }

            if ($this->request->getVar('phone')) {
                $data['phone'] = $this->request->getVar('phone');
            }

            if (empty($data)) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Tidak ada data yang diupdate',
                    'data' => null,
                ])->setStatusCode(400);
            }

            $updated = $this->userModel->update($userId, $data);

            if (!$updated) {
                throw new \Exception('Gagal mengupdate profil');
            }

            // Get updated user data
            $user = $this->userModel->find($userId);
            unset($user['password']);
            unset($user['jwt_token']);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Profil berhasil diupdate',
                'data' => $user,
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null,
            ])->setStatusCode(500);
        }
    }
}
