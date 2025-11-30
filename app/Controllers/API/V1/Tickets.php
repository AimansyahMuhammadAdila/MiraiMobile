<?php

namespace App\Controllers\API\V1;

use App\Controllers\BaseController;
use App\Models\TicketTypeModel;

class Tickets extends BaseController
{
    protected $ticketTypeModel;

    public function __construct()
    {
        $this->ticketTypeModel = new TicketTypeModel();
    }

    /**
     * Get all ticket types
     * GET /api/v1/tickets
     */
    public function index()
    {
        try {
            $tickets = $this->ticketTypeModel->findAll();

            // Add availability status
            foreach ($tickets as &$ticket) {
                $ticket['is_available'] = $ticket['remaining_quota'] > 0;
                $ticket['sold'] = $ticket['quota'] - $ticket['remaining_quota'];
            }

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Data tiket berhasil diambil',
                'data' => $tickets,
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Gagal mengambil data tiket',
                'data' => null,
            ])->setStatusCode(500);
        }
    }

    /**
     * Get specific ticket type
     * GET /api/v1/tickets/{id}
     */
    public function show($id = null)
    {
        if (!$id) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'ID tiket harus disertakan',
                'data' => null,
            ])->setStatusCode(400);
        }

        try {
            $ticket = $this->ticketTypeModel->find($id);

            if (!$ticket) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Tiket tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            // Add availability status
            $ticket['is_available'] = $ticket['remaining_quota'] > 0;
            $ticket['sold'] = $ticket['quota'] - $ticket['remaining_quota'];

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Data tiket berhasil diambil',
                'data' => $ticket,
            ])->setStatusCode(200);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Gagal mengambil data tiket',
                'data' => null,
            ])->setStatusCode(500);
        }
    }
}
