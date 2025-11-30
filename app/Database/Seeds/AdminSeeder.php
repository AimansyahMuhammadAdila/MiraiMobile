<?php

namespace App\Database\Seeds;

use CodeIgniter\Database\Seeder;
use App\Models\UserModel;

class AdminSeeder extends Seeder
{
    public function run()
    {
        $userModel = new UserModel();

        $adminEmail = 'admin@miraimobile.com';

        // Check if admin already exists
        $existingAdmin = $userModel->where('email', $adminEmail)->first();

        if ($existingAdmin) {
            echo "Admin user already exists.\n";
            return;
        }

        $data = [
            'name' => 'Super Admin',
            'email' => $adminEmail,
            'password' => 'admin123', // Will be hashed by UserModel callback
            'phone' => '081234567890',
            'role' => 'admin',
        ];

        $userModel->insert($data);

        echo "Admin user created successfully.\n";
        echo "Email: " . $adminEmail . "\n";
        echo "Password: admin123\n";
    }
}
