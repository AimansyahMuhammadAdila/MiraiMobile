<?php

namespace App\Database\Seeds;

use CodeIgniter\Database\Seeder;

class TicketTypeSeeder extends Seeder
{
    public function run()
    {
        $data = [
            [
                'name' => 'General Admission (GA)',
                'description' => 'Akses ke semua area event MiraiFest, termasuk: Main Stage, Vendor Booths, Photo Spots, dan Cosplay Competition sebagai penonton.',
                'price' => 150000.00,
                'quota' => 500,
                'remaining_quota' => 500,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
            [
                'name' => 'VIP Pass',
                'description' => 'Semua benefit GA + Meet & Greet dengan Guest Stars, VIP Seating Area, Exclusive MiraiFest Merchandise (T-Shirt + Tote Bag), Priority Entry.',
                'price' => 350000.00,
                'quota' => 150,
                'remaining_quota' => 150,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
            [
                'name' => 'Cosplayer Pass',
                'description' => 'Semua benefit GA + Akses ke Backstage & Changing Room, Partisipasi Cosplay Competition (jika mendaftar), Professional Photoshoot Corner, Cosplayer Lounge Area.',
                'price' => 250000.00,
                'quota' => 200,
                'remaining_quota' => 200,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
            [
                'name' => 'Tiket Khusus',
                'description' => 'Semua benefit GA + Akses ke Backstage & Changing Room, Partisipasi Cosplay Competition (jika mendaftar), Professional Photoshoot Corner, Cosplayer Lounge Area.',
                'price' => 200000.00,
                'quota' => 10,
                'remaining_quota' => 10,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
            [
                'name' => 'Tiket Cosplayer',
                'description' => 'Tiket yang dikhususkan untuk para cosplayer ',
                'price' => 20000.00,
                'quota' => 80,
                'remaining_quota' => 80,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
            [
                'name' => 'Tiket Khusus Mahasiswa',
                'description' => 'Tiket yang ditujukan untuk para mahasiswa',
                'price' => 30000.00,
                'quota' => 80,
                'remaining_quota' => 80,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
            [
                'name' => 'Tiket Normal',
                'description' => 'Tiket masuk MiraiFest ',
                'price' => 50000.00,
                'quota' => 20,
                'remaining_quota' => 20,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
            [
                'name' => 'Tiket Coswalk',
                'description' => 'Tiket untuk lomba Coswalk, Berhadiah Total Hingga 3 Juta!!',
                'price' => 40000.00,
                'quota' => 70,
                'remaining_quota' => 70,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
            [
                'name' => 'tiket keren',
                'description' => 'tiket terkeren 2025',
                'price' => 10000000.00,
                'quota' => 3,
                'remaining_quota' => 3,
                'created_at' => date('Y-m-d H:i:s'),
                'updated_at' => date('Y-m-d H:i:s'),
            ],
        ];

        $this->db->table('ticket_types')->insertBatch($data);
    }
}
