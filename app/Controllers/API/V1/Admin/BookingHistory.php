<?php

namespace App\Controllers\API\V1\Admin;

use App\Controllers\BaseController;
use App\Models\BookingModel;
use App\Models\UserModel;
use App\Models\TicketTypeModel;

class BookingHistory extends BaseController
{
    protected $bookingModel;
    protected $userModel;
    protected $ticketModel;

    public function __construct()
    {
        $this->bookingModel = new BookingModel();
        $this->userModel = new UserModel();
        $this->ticketModel = new TicketTypeModel();
    }

    /**
     * Get all bookings with filters
     * GET /api/v1/admin/bookings/history
     */
    public function index()
    {
        try {
            $page = $this->request->getGet('page') ?? 1;
            $perPage = $this->request->getGet('per_page') ?? 20;
            $search = $this->request->getGet('search') ?? '';
            $status = $this->request->getGet('status') ?? '';
            $ticketTypeId = $this->request->getGet('ticket_type_id') ?? '';

            $builder = $this->bookingModel
                ->select('bookings.*, users.name as user_name, users.email as user_email, ticket_types.name as ticket_name, ticket_types.description as ticket_description')
                ->join('users', 'users.id = bookings.user_id')
                ->join('ticket_types', 'ticket_types.id = bookings.ticket_type_id')
                ->orderBy('bookings.created_at', 'DESC');

            // Apply search filter
            if (!empty($search)) {
                $builder->groupStart()
                    ->like('users.name', $search)
                    ->orLike('users.email', $search)
                    ->orLike('bookings.booking_code', $search)
                    ->groupEnd();
            }

            // Apply status filter
            if (!empty($status)) {
                $builder->where('bookings.payment_status', $status);
            }

            // Apply ticket type filter
            if (!empty($ticketTypeId)) {
                $builder->where('bookings.ticket_type_id', $ticketTypeId);
            }

            // Get paginated results
            $bookings = $builder->paginate($perPage, 'default', $page);
            $pager = $this->bookingModel->pager;

            // Format payment proof and QR code URLs
            foreach ($bookings as &$booking) {
                if (!empty($booking['payment_proof'])) {
                    $booking['payment_proof_url'] = base_url($booking['payment_proof']);
                } else {
                    $booking['payment_proof_url'] = null;
                }

                if (!empty($booking['qr_code'])) {
                    $booking['qr_code_url'] = base_url($booking['qr_code']);
                } else {
                    $booking['qr_code_url'] = null;
                }
            }

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Booking history berhasil diambil',
                'data' => [
                    'bookings' => $bookings,
                    'pagination' => [
                        'current_page' => $pager->getCurrentPage(),
                        'total_pages' => $pager->getPageCount(),
                        'per_page' => $pager->getPerPage(),
                        'total' => $pager->getTotal(),
                    ],
                ],
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Gagal mengambil booking history: ' . $e->getMessage(),
                'data' => null,
            ])->setStatusCode(500);
        }
    }
}