<?php

namespace App\Controllers\API\V1\Admin;

use App\Controllers\BaseController;
use App\Models\UserModel;

class UserManagement extends BaseController
{
    protected $userModel;

    public function __construct()
    {
        $this->userModel = new UserModel();
        helper('jwt');
    }

    /**
     * Get all users with pagination
     * GET /api/v1/admin/users
     */
    public function index()
    {
        try {
            $page = $this->request->getGet('page') ?? 1;
            $perPage = $this->request->getGet('per_page') ?? 20;
            $search = $this->request->getGet('search') ?? '';

            $builder = $this->userModel->select('id, name, email, phone, role, created_at');

            if (!empty($search)) {
                $builder->like('name', $search)
                    ->orLike('email', $search);
            }

            $total = $builder->countAllResults(false);
            $users = $builder->paginate($perPage, 'default', $page);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Data user berhasil diambil',
                'data' => [
                    'users' => $users,
                    'pagination' => [
                        'current_page' => (int) $page,
                        'per_page' => (int) $perPage,
                        'total' => (int) $total,
                        'total_pages' => (int) ceil($total / $perPage),
                    ],
                ],
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Gagal mengambil data: ' . $e->getMessage(),
                'data' => null,
            ])->setStatusCode(500);
        }
    }

    /**
     * Get user details
     * GET /api/v1/admin/users/{id}
     */
    public function show($id = null)
    {
        if (!$id) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'ID user harus disertakan',
                'data' => null,
            ])->setStatusCode(400);
        }

        try {
            $user = $this->userModel->select('id, name, email, phone, role, created_at, updated_at')->find($id);

            if (!$user) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            // Get user bookings
            $bookingModel = new \App\Models\BookingModel();
            $bookings = $bookingModel->getUserBookings($id);

            $user['bookings'] = $bookings;

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Data user berhasil diambil',
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

    /**
     * Update user information
     * PUT /api/v1/admin/users/{id}
     */
    public function update($id = null)
    {
        if (!$id) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'ID user harus disertakan',
                'data' => null,
            ])->setStatusCode(400);
        }

        $json = $this->request->getJSON();

        try {
            $user = $this->userModel->find($id);

            if (!$user) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            $updateData = [];

            if (isset($json->name))
                $updateData['name'] = $json->name;
            if (isset($json->email))
                $updateData['email'] = $json->email;
            if (isset($json->phone))
                $updateData['phone'] = $json->phone;
            if (isset($json->role))
                $updateData['role'] = $json->role;

            if (empty($updateData)) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Tidak ada data yang diupdate',
                    'data' => null,
                ])->setStatusCode(400);
            }

            $updated = $this->userModel->update($id, $updateData);

            if (!$updated) {
                throw new \Exception('Gagal mengupdate user');
            }

            $updatedUser = $this->userModel->select('id, name, email, phone, role, created_at, updated_at')->find($id);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'User berhasil diupdate',
                'data' => $updatedUser,
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null,
            ])->setStatusCode(500);
        }
    }

    /**
     * Delete user
     * DELETE /api/v1/admin/users/{id}
     */
    public function delete($id = null)
    {
        if (!$id) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'ID user harus disertakan',
                'data' => null,
            ])->setStatusCode(400);
        }

        try {
            // Prevent deleting admin user
            $currentUserId = getCurrentUserId();
            if ($id == $currentUserId) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Tidak dapat menghapus akun sendiri',
                    'data' => null,
                ])->setStatusCode(400);
            }

            $user = $this->userModel->find($id);

            if (!$user) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            $deleted = $this->userModel->delete($id);

            if (!$deleted) {
                throw new \Exception('Gagal menghapus user');
            }

            return $this->response->setJSON([
                'success' => true,
                'message' => 'User berhasil dihapus',
                'data' => ['id' => $id],
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
