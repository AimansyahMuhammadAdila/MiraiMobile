<?php

namespace App\Controllers\API\V1\Admin;

use App\Controllers\BaseController;
use App\Models\BookingModel;
use App\Models\UserModel;

class PaymentVerification extends BaseController
{
    protected $bookingModel;
    protected $userModel;

    public function __construct()
    {
        $this->bookingModel = new BookingModel();
        $this->userModel = new UserModel();
        helper('jwt');
    }

    /**
     * Get all pending bookings for payment verification
     * GET /api/v1/admin/bookings/pending
     */
    public function pending()
    {
        try {
            // Get all bookings with pending payment status
            $pendingBookings = $this->bookingModel
                ->select('bookings.*, users.name as user_name, users.email as user_email, ticket_types.name as ticket_name')
                ->join('users', 'users.id = bookings.user_id')
                ->join('ticket_types', 'ticket_types.id = bookings.ticket_type_id')
                ->where('bookings.payment_status', 'pending')
                ->orderBy('bookings.created_at', 'DESC')
                ->findAll();

            // Add full URLs for payment proofs
            foreach ($pendingBookings as &$booking) {
                if (!empty($booking['payment_proof'])) {
                    // Use Media controller to serve image with CORS headers
                    $booking['payment_proof_url'] = base_url('api/v1/media/payment_proofs/' . basename($booking['payment_proof']));
                }
            }

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Data booking pending berhasil diambil',
                'data' => $pendingBookings,
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
     * Approve a booking payment
     * POST /api/v1/admin/bookings/{id}/approve
     */
    public function approve($id = null)
    {
        if (!$id) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'ID booking harus disertakan',
                'data' => null,
            ])->setStatusCode(400);
        }

        try {
            $booking = $this->bookingModel->find($id);

            if (!$booking) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            // Generate QR Code
            $qrCodePath = $this->generateQRCode($booking);

            // Update payment status to confirmed and add QR code
            $updated = $this->bookingModel->update($id, [
                'payment_status' => 'confirmed',
                'qr_code' => $qrCodePath,
            ]);

            if (!$updated) {
                throw new \Exception('Gagal meng-approve booking');
            }

            // Get updated booking data with user and ticket info
            $updatedBooking = $this->bookingModel
                ->select('bookings.*, users.name as user_name, users.email as user_email, ticket_types.name as ticket_name')
                ->join('users', 'users.id = bookings.user_id')
                ->join('ticket_types', 'ticket_types.id = bookings.ticket_type_id')
                ->find($id);

            $updatedBooking['qr_code_url'] = base_url($qrCodePath);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Pembayaran berhasil di-approve dan QR code telah dibuat',
                'data' => $updatedBooking,
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
     * Generate QR Code for booking
     */
    private function generateQRCode($booking)
    {
        // Get ticket and user info
        $ticketModel = new \App\Models\TicketTypeModel();
        $userModel = new \App\Models\UserModel();

        $ticket = $ticketModel->find($booking['ticket_type_id']);
        $user = $userModel->find($booking['user_id']);

        // Prepare QR code data
        $qrData = json_encode([
            'booking_code' => $booking['booking_code'],
            'ticket_type' => $ticket['name'],
            'quantity' => $booking['quantity'],
            'user_name' => $user['name'],
            'user_email' => $user['email'],
            'total_price' => $booking['total_price'],
            'verified_at' => date('Y-m-d H:i:s'),
        ]);

        // Generate QR Code using endroid/qr-code
        $qrCode = (new \Endroid\QrCode\Builder\Builder(
            data: $qrData,
            size: 300,
            margin: 10
        ))->build();

        // Save QR code to file
        $qrCodeDir = FCPATH . 'uploads/qr_codes';
        if (!is_dir($qrCodeDir)) {
            mkdir($qrCodeDir, 0777, true);
        }

        $fileName = $booking['booking_code'] . '.png';
        $filePath = $qrCodeDir . '/' . $fileName;

        $qrCode->saveToFile($filePath);

        return 'uploads/qr_codes/' . $fileName;
    }

    /**
     * Reject a booking payment
     * POST /api/v1/admin/bookings/{id}/reject
     */
    public function reject($id = null)
    {
        if (!$id) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'ID booking harus disertakan',
                'data' => null,
            ])->setStatusCode(400);
        }

        // Get JSON input for rejection reason
        $json = $this->request->getJSON();
        $reason = $json->reason ?? 'Tidak ada alasan';

        try {
            $booking = $this->bookingModel->find($id);

            if (!$booking) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Booking tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            $db = \Config\Database::connect();
            $db->transStart();

            // Update payment status to cancelled
            $updated = $this->bookingModel->update($id, [
                'payment_status' => 'cancelled'
            ]);

            if (!$updated) {
                $db->transRollback();
                throw new \Exception('Gagal mereject booking');
            }

            // Restore ticket quota
            $ticketModel = new \App\Models\TicketTypeModel();
            $ticketModel->set('remaining_quota', 'remaining_quota + ' . $booking['quantity'], false)
                ->where('id', $booking['ticket_type_id'])
                ->update();

            $db->transComplete();

            if ($db->transStatus() === false) {
                throw new \Exception('Transaksi gagal');
            }

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Pembayaran berhasil di-reject dan kuota dikembalikan',
                'data' => [
                    'booking_id' => $id,
                    'reason' => $reason,
                    'quota_restored' => $booking['quantity'],
                ],
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
