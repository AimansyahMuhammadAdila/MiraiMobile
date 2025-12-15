<?php

namespace App\Controllers\API\V1\Admin;

use App\Controllers\BaseController;
use App\Models\BookingModel;
use App\Models\UserModel;
use Endroid\QrCode\Builder\Builder;
use Endroid\QrCode\Encoding\Encoding;
use Endroid\QrCode\ErrorCorrectionLevel;
use Endroid\QrCode\Writer\PngWriter;
use App\Libraries\GcsService;

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
                    $booking['payment_proof_url'] = $booking['payment_proof'];
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

            if ($booking['payment_status'] === 'confirmed') {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Booking sudah dikonfirmasi',
                ])->setStatusCode(400);
            }

            // Generate QR Code
            $qrCodePath = $this->generateQRCode($booking);

            if (!$qrCodePath) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Gagal mengupload QR Code, coba lagi.',
                ])->setStatusCode(500);
            }

            $this->bookingModel->update($id, [
                'payment_status' => 'confirmed',
                'qr_code' => $qrCodePath,
            ]);

            // Get updated booking data with user and ticket info
            $updatedBooking = $this->bookingModel
                ->select('bookings.*, users.name as user_name, users.email as user_email, ticket_types.name as ticket_name')
                ->join('users', 'users.id = bookings.user_id')
                ->join('ticket_types', 'ticket_types.id = bookings.ticket_type_id')
                ->find($id);

            $updatedBooking['qr_code_url'] = $qrCodePath;

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
        $ticketModel = new \App\Models\TicketTypeModel();
        $userModel = new \App\Models\UserModel();

        $ticket = $ticketModel->find($booking['ticket_type_id']);
        $user = $userModel->find($booking['user_id']);

        $qrData = json_encode([
            'booking_code' => $booking['booking_code'],
            'ticket_type' => $ticket['name'],
            'quantity' => $booking['quantity'],
            'user_name' => $user['name'],
            'user_email' => $user['email'],
            'total_price' => $booking['total_price'],
            'verified_at' => date('Y-m-d H:i:s'),
        ]);
        $tmpDir = sys_get_temp_dir(); // cross-platform
        $tempPath = $tmpDir . DIRECTORY_SEPARATOR . $booking['booking_code'] . '.png';
        if (!is_dir($tmpDir)) {
            mkdir($tmpDir, 0777, true);
        }
        $tempPath = $tmpDir . '/' . $booking['booking_code'] . '.png';

        try {
            $result = new Builder(
                writer: new PngWriter(),
                data: $qrData,
                encoding: new Encoding('UTF-8'),
                errorCorrectionLevel: ErrorCorrectionLevel::High,
                size: 300,
                margin: 10,
            );

            // Build the QR code
            $qrResult = $result->build();

            // Save it to a file
            $qrResult->saveToFile($tempPath);

            $gcs = new GcsService();
            $qrUrl = $gcs->uploadQrCode(
                $tempPath,
                $booking['booking_code'] . '.png'
            );

            unlink($tempPath);

            return $qrUrl;
        } catch (\Exception $e) {
            log_message('error', 'QR Code error: ' . $e->getMessage());
            return null;
        }

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
