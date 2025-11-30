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
        ];

        $this->db->table('ticket_types')->insertBatch($data);
    }
}
