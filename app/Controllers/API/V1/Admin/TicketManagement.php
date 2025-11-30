<?php

namespace App\Controllers\API\V1\Admin;

use App\Controllers\BaseController;
use App\Models\TicketTypeModel;

class TicketManagement extends BaseController
{
    protected $ticketModel;

    public function __construct()
    {
        $this->ticketModel = new TicketTypeModel();
        helper('jwt');
    }

    /**
     * Create new ticket type
     * POST /api/v1/admin/tickets
     */
    public function create()
    {
        $json = $this->request->getJSON();

        $rules = [
            'name' => 'required|min_length[3]|max_length[255]',
            'description' => 'permit_empty',
            'price' => 'required|numeric',
            'quota' => 'required|integer|greater_than[0]',
        ];

        if (!$this->validate($rules)) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'Validasi gagal',
                'data' => $this->validator->getErrors(),
            ])->setStatusCode(400);
        }

        try {
            $data = [
                'name' => $json->name,
                'description' => $json->description ?? null,
                'price' => $json->price,
                'quota' => $json->quota,
                'remaining_quota' => $json->quota,
            ];

            $ticketId = $this->ticketModel->insert($data);

            if (!$ticketId) {
                throw new \Exception('Gagal membuat tiket');
            }

            $ticket = $this->ticketModel->find($ticketId);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Tiket berhasil dibuat',
                'data' => $ticket,
            ])->setStatusCode(201);

        } catch (\Exception $e) {
            return $this->response->setJSON([
                'success' => false,
                'message' => $e->getMessage(),
                'data' => null,
            ])->setStatusCode(500);
        }
    }

    /**
     * Update ticket type
     * PUT /api/v1/admin/tickets/{id}
     */
    public function update($id = null)
    {
        if (!$id) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'ID tiket harus disertakan',
                'data' => null,
            ])->setStatusCode(400);
        }

        $json = $this->request->getJSON();

        try {
            $ticket = $this->ticketModel->find($id);

            if (!$ticket) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Tiket tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            $updateData = [];

            if (isset($json->name))
                $updateData['name'] = $json->name;
            if (isset($json->description))
                $updateData['description'] = $json->description;
            if (isset($json->price))
                $updateData['price'] = $json->price;

            // If quota is updated, adjust remaining_quota proportionally
            if (isset($json->quota)) {
                $quotaDiff = $json->quota - $ticket['quota'];
                $updateData['quota'] = $json->quota;
                $updateData['remaining_quota'] = $ticket['remaining_quota'] + $quotaDiff;

                // Ensure remaining_quota doesn't go negative
                if ($updateData['remaining_quota'] < 0) {
                    $updateData['remaining_quota'] = 0;
                }
            }

            if (empty($updateData)) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Tidak ada data yang diupdate',
                    'data' => null,
                ])->setStatusCode(400);
            }

            $updated = $this->ticketModel->update($id, $updateData);

            if (!$updated) {
                throw new \Exception('Gagal mengupdate tiket');
            }

            $updatedTicket = $this->ticketModel->find($id);

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Tiket berhasil diupdate',
                'data' => $updatedTicket,
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
     * Delete ticket type
     * DELETE /api/v1/admin/tickets/{id}
     */
    public function delete($id = null)
    {
        if (!$id) {
            return $this->response->setJSON([
                'success' => false,
                'message' => 'ID tiket harus disertakan',
                'data' => null,
            ])->setStatusCode(400);
        }

        try {
            $ticket = $this->ticketModel->find($id);

            if (!$ticket) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Tiket tidak ditemukan',
                    'data' => null,
                ])->setStatusCode(404);
            }

            // Check if ticket has existing bookings
            $bookingModel = new \App\Models\BookingModel();
            $hasBookings = $bookingModel->where('ticket_type_id', $id)->countAllResults() > 0;

            if ($hasBookings) {
                return $this->response->setJSON([
                    'success' => false,
                    'message' => 'Tidak dapat menghapus tiket yang sudah memiliki booking',
                    'data' => null,
                ])->setStatusCode(400);
            }

            $deleted = $this->ticketModel->delete($id);

            if (!$deleted) {
                throw new \Exception('Gagal menghapus tiket');
            }

            return $this->response->setJSON([
                'success' => true,
                'message' => 'Tiket berhasil dihapus',
                'data' => ['id' => $id],
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
