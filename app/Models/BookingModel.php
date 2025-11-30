<?php

namespace App\Models;

use CodeIgniter\Model;

class BookingModel extends Model
{
    protected $table = 'bookings';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $protectFields = true;
    protected $allowedFields = [
        'user_id',
        'ticket_type_id',
        'quantity',
        'total_price',
        'qr_code',
        'booking_code',
        'payment_status'
    ];

    // Dates
    protected $useTimestamps = true;
    protected $dateFormat = 'datetime';
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    // Validation
    protected $validationRules = [
        'user_id' => 'required|integer',
        'ticket_type_id' => 'required|integer',
        'quantity' => 'required|integer|greater_than[0]',
        'total_price' => 'required|decimal',
        'payment_status' => 'in_list[pending,confirmed,cancelled]',
    ];

    protected $validationMessages = [
        'quantity' => [
            'required' => 'Jumlah tiket harus diisi',
            'integer' => 'Jumlah tiket harus berupa angka',
            'greater_than' => 'Jumlah tiket minimal 1',
        ],
        'total_price' => [
            'required' => 'Total harga harus diisi',
            'decimal' => 'Total harga harus berupa angka',
        ],
    ];

    protected $skipValidation = false;

    /**
     * Get user bookings with ticket type details
     */
    public function getUserBookings(int $userId)
    {
        return $this->select('bookings.*, ticket_types.name as ticket_name, ticket_types.description as ticket_description')
            ->join('ticket_types', 'ticket_types.id = bookings.ticket_type_id')
            ->where('bookings.user_id', $userId)
            ->orderBy('bookings.created_at', 'DESC')
            ->findAll();
    }

    /**
     * Get booking detail with full information
     */
    public function getBookingDetail(int $bookingId, int $userId = null)
    {
        $builder = $this->select('bookings.*, ticket_types.name as ticket_name, ticket_types.description as ticket_description, users.name as user_name, users.email as user_email')
            ->join('ticket_types', 'ticket_types.id = bookings.ticket_type_id')
            ->join('users', 'users.id = bookings.user_id')
            ->where('bookings.id', $bookingId);

        if ($userId !== null) {
            $builder->where('bookings.user_id', $userId);
        }

        return $builder->first();
    }

    /**
     * Generate unique QR code
     */
    public function generateQRCode(): string
    {
        do {
            $qrCode = 'MF-' . strtoupper(bin2hex(random_bytes(16)));
        } while ($this->where('qr_code', $qrCode)->first());

        return $qrCode;
    }

    /**
     * Generate unique booking code
     */
    public function generateBookingCode(): string
    {
        do {
            $bookingCode = 'MIRAI' . date('Ymd') . strtoupper(substr(bin2hex(random_bytes(3)), 0, 4));
        } while ($this->where('booking_code', $bookingCode)->first());

        return $bookingCode;
    }

    /**
     * Create booking with QR code
     */
    public function createBooking(array $data): array
    {
        $data['qr_code'] = $this->generateQRCode();
        $data['booking_code'] = $this->generateBookingCode();
        $data['payment_status'] = 'pending';

        $inserted = $this->insert($data);

        if ($inserted) {
            return [
                'success' => true,
                'booking_id' => $inserted,
                'qr_code' => $data['qr_code'],
                'booking_code' => $data['booking_code'],
            ];
        }

        return ['success' => false];
    }

    /**
     * Update payment status
     */
    public function updatePaymentStatus(int $bookingId, string $status): bool
    {
        if (!in_array($status, ['pending', 'confirmed', 'cancelled'])) {
            return false;
        }

        return $this->update($bookingId, ['payment_status' => $status]);
    }
}
