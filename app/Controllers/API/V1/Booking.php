<?php

namespace App\Controllers\API\V1;

use App\Controllers\BaseController;
use App\Models\BookingModel;
use App\Models\TicketTypeModel;
use CodeIgniter\HTTP\ResponseInterface;

class Booking extends BaseController
{
    protected $bookingModel;
    protected $ticketTypeModel;

    public function __construct()
    {
        $this->bookingModel = new BookingModel();
        $this->ticketTypeModel = new TicketTypeModel();
        helper('jwt');
    }

    /**
     * Get user's booking history
     * GET /api/v1/bookings
     * Requires Authentication
     */
    public function index()
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
            $bookings = $this->bookingModel->getUserBookings($userId);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Data booking berhasil diambil',
                'data' => $bookings,
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Gagal mengambil data booking',
                'data' => null,
            ])->setStatusCode(500);
        }
    }

    /**
     * Get specific booking detail
     * GET /api/v1/bookings/{id}
     * Requires Authentication
     */
    public function show($id = null)
    {
        $userId = getCurrentUserId();

        if (!$userId) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Unauthorized',
                'data' => null,
            ])->setStatusCode(401);
        }

        if (!$id) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'ID booking harus disertakan',
                'data' => null,
            ])->setStatusCode(400);
        }

        try {
            $booking = $this->bookingModel->getBookingDetail($id, $userId);

            if (!$booking) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Data booking berhasil diambil',
                'data' => $booking,
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Gagal mengambil data booking',
                'data' => null,
            ])->setStatusCode(500);
        }
    }

    /**
     * Create new booking
     * POST /api/v1/bookings
     * Requires Authentication
     */
    public function create()
    {
        $userId = getCurrentUserId();

        if (!$userId) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Unauthorized',
                'data' => null,
            ])->setStatusCode(401);
        }

        // Get JSON input
        $json = $this->request->getJSON();

        $rules = [
            'ticket_type_id' => 'required|integer',
            'quantity' => 'required|integer|greater_than[0]',
        ];

        if (!$this->validate($rules)) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Validasi gagal',
                'data' => $this->validator->getErrors(),
            ])->setStatusCode(400);
        }

        $ticketTypeId = $json->ticket_type_id;
        $quantity = $json->quantity;

        // Start transaction
        $db = \Config\Database::connect();
        $db->transStart();

        try {
            // Check ticket availability
            $ticket = $this->ticketTypeModel->find($ticketTypeId);

            if (!$ticket) {
                $db->transRollback();
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Tiket tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            // Check stock availability
            if (!$this->ticketTypeModel->checkAvailability($ticketTypeId, $quantity)) {
                $db->transRollback();
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Stok tiket tidak mencukupi. Sisa: ' . $ticket['remaining_quota'],
                    'data' => [
                        'available_quota' => $ticket['remaining_quota']
                    ],
                ])->setStatusCode(400);
            }

            // Calculate total price
            $totalPrice = $ticket['price'] * $quantity;

            // Create booking
            $bookingData = [
                'user_id' => $userId,
                'ticket_type_id' => $ticketTypeId,
                'quantity' => $quantity,
                'total_price' => $totalPrice,
            ];

            $result = $this->bookingModel->createBooking($bookingData);

            if (!$result['success']) {
                $db->transRollback();
                throw new \Exception('Gagal membuat booking');
            }

            // Reduce ticket quota
            if (!$this->ticketTypeModel->reduceQuota($ticketTypeId, $quantity)) {
                $db->transRollback();
                throw new \Exception('Gagal mengurangi kuota tiket');
            }

            // Commit transaction
            $db->transComplete();

            if ($db->transStatus() === false) {
                throw new \Exception('Transaksi gagal');
            }

            // Get complete booking data
            $booking = $this->bookingModel->getBookingDetail($result['booking_id'], $userId);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Booking berhasil dibuat! Silakan upload bukti pembayaran.',
                'data' => $booking,
            ])->setStatusCode(201);

        } catch (\Exception $e) {
            $db->transRollback();
            return $this->response->setJSON([
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null,
            ])->setStatusCode(500);
        }
    }

    /**
     * Upload payment proof for a booking
     * POST /api/v1/bookings/:id/upload-proof
     */
    public function uploadProof($id = null)
    {
        try {
            // Get authenticated user
            $userId = getCurrentUserId();
            if (!$userId) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Unauthorized',
                ])->setStatusCode(401);
            }

            // Validate booking exists and belongs to user
            $booking = $this->bookingModel->find($id);
            if (!$booking) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan',
                ])->setStatusCode(404);
            }

            if ($booking['user_id'] != $userId) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Anda tidak memiliki akses ke booking ini',
                ])->setStatusCode(403);
            }

            // Validate file upload
            $file = $this->request->getFile('payment_proof');
            if (!$file) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'File bukti pembayaran harus diupload',
                ])->setStatusCode(400);
            }

            // Validate file type and size
            $validTypes = ['image/jpeg', 'image/jpg', 'image/png'];
            if (!in_array($file->getMimeType(), $validTypes)) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'File harus berupa gambar (JPG, JPEG, atau PNG)',
                ])->setStatusCode(400);
            }

            // Max 5MB
            if ($file->getSize() > 5 * 1024 * 1024) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Ukuran file maksimal 5MB',
                ])->setStatusCode(400);
            }

            if (!$file->isValid()) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'File tidak valid: ' . $file->getErrorString(),
                ])->setStatusCode(400);
            }

            // Generate unique filename
            $newName = $id . '_' . time() . '.' . $file->getExtension();

            // Move file to uploads directory
            $uploadPath = FCPATH . 'uploads/payment_proofs';
            if (!is_dir($uploadPath)) {
                mkdir($uploadPath, 0777, true);
            }

            $file->move($uploadPath, $newName);

            // Update booking with payment proof path
            $proofPath = 'uploads/payment_proofs/' . $newName;
            $this->bookingModel->update($id, [
                'payment_proof' => $proofPath,
            ]);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Bukti pembayaran berhasil diupload',
                'data' => [
                    'booking_id' => $id,
                    'payment_proof' => base_url($proofPath),
                ],
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            log_message('error', 'Upload proof error: ' . $e->getMessage());
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Terjadi kesalahan saat upload: ' . $e->getMessage(),
            ])->setStatusCode(500);
        }
    }
}
