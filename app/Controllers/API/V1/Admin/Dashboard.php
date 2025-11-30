<?php

namespace App\Controllers\API\V1\Admin;

use App\Controllers\BaseController;
use App\Models\BookingModel;
use App\Models\UserModel;
use App\Models\TicketTypeModel;

class Dashboard extends BaseController
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
     * Get dashboard statistics
     * GET /api/v1/admin/dashboard/stats
     */
    public function stats()
    {
        try {
            // Total bookings
            $totalBookings = $this->bookingModel->countAll();

            // Pending payments count
            $pendingPayments = $this->bookingModel->where('payment_status', 'pending')->countAllResults();

            // Total revenue (confirmed bookings only)
            $revenue = $this->bookingModel
                ->selectSum('total_price')
                ->where('payment_status', 'confirmed')
                ->first();
            $totalRevenue = $revenue['total_price'] ?? 0;

            // Total users
            $totalUsers = $this->userModel->where('role', 'user')->countAllResults();

            // Bookings by ticket type
            $bookingsByType = $this->bookingModel
                ->select('ticket_types.name, COUNT(bookings.id) as total_bookings, SUM(bookings.quantity) as total_tickets, SUM(bookings.total_price) as revenue')
                ->join('ticket_types', 'ticket_types.id = bookings.ticket_type_id')
                ->where('bookings.payment_status', 'confirmed')
                ->groupBy('bookings.ticket_type_id')
                ->findAll();

            // Recent bookings (last 5)
            $recentBookings = $this->bookingModel
                ->select('bookings.*, users.name as user_name, ticket_types.name as ticket_name')
                ->join('users', 'users.id = bookings.user_id')
                ->join('ticket_types', 'ticket_types.id = bookings.ticket_type_id')
                ->orderBy('bookings.created_at', 'DESC')
                ->limit(5)
                ->find();

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Statistik dashboard berhasil diambil',
                'data' => [
                    'overview' => [
                        'total_bookings' => $totalBookings,
                        'pending_payments' => $pendingPayments,
                        'total_revenue' => $totalRevenue,
                        'total_users' => $totalUsers,
                    ],
                    'bookings_by_type' => $bookingsByType,
                    'recent_bookings' => $recentBookings,
                ],
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Gagal mengambil statistik: ' . $e->getMessage(),
                'data' => null,
            ])->setStatusCode(500);
        }
    }
}
