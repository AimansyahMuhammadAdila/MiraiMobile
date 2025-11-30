<?php

namespace App\Models;

use CodeIgniter\Model;

class UserModel extends Model
{
    protected $table = 'users';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $protectFields = true;
    protected $allowedFields = ['name', 'email', 'phone', 'password', 'jwt_token'];

    // Dates
    protected $useTimestamps = true;
    protected $dateFormat = 'datetime';
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    // Validation
    protected $validationRules = [
        'name' => 'required|min_length[3]|max_length[255]',
        'email' => 'required|valid_email|is_unique[users.email,id,{id}]',
        'phone' => 'permit_empty|min_length[10]|max_length[20]',
        'password' => 'required|min_length[6]',
    ];

    protected $validationMessages = [
        'name' => [
            'required' => 'Nama harus diisi',
            'min_length' => 'Nama minimal 3 karakter',
        ],
        'email' => [
            'required' => 'Email harus diisi',
            'valid_email' => 'Format email tidak valid',
            'is_unique' => 'Email sudah terdaftar',
        ],
        'phone' => [
            'min_length' => 'Nomor telepon minimal 10 digit',
        ],
        'password' => [
            'required' => 'Password harus diisi',
            'min_length' => 'Password minimal 6 karakter',
        ],
    ];

    protected $skipValidation = false;

    // Callbacks
    protected $beforeInsert = ['hashPassword'];
    protected $beforeUpdate = ['hashPassword'];

    protected function hashPassword(array $data)
    {
        if (isset($data['data']['password'])) {
            $data['data']['password'] = password_hash($data['data']['password'], PASSWORD_DEFAULT);
        }
        return $data;
    }

    /**
     * Verify user login credentials
     */
    public function verifyLogin(string $email, string $password)
    {
        $user = $this->where('email', $email)->first();

        if (!$user) {
            return false;
        }

        if (!password_verify($password, $user['password'])) {
            return false;
        }

        return $user;
    }

    /**
     * Update user JWT token
     */
    public function updateToken(int $userId, string $token)
    {
        return $this->update($userId, ['jwt_token' => $token]);
    }

    /**
     * Clear user JWT token (logout)
     */
    public function clearToken(int $userId)
    {
        return $this->update($userId, ['jwt_token' => null]);
    }

    /**
     * Get user by token
     */
    public function getUserByToken(string $token)
    {
        return $this->where('jwt_token', $token)->first();
    }
}
