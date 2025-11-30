<?php

namespace App\Models;

use CodeIgniter\Model;

class TicketTypeModel extends Model
{
    protected $table = 'ticket_types';
    protected $primaryKey = 'id';
    protected $useAutoIncrement = true;
    protected $returnType = 'array';
    protected $useSoftDeletes = false;
    protected $protectFields = true;
    protected $allowedFields = ['name', 'description', 'price', 'quota', 'remaining_quota'];

    // Dates
    protected $useTimestamps = true;
    protected $dateFormat = 'datetime';
    protected $createdField = 'created_at';
    protected $updatedField = 'updated_at';

    // Validation
    protected $validationRules = [
        'name' => 'required|max_length[100]',
        'price' => 'required|decimal',
        'quota' => 'required|integer',
    ];

    protected $validationMessages = [
        'name' => [
            'required' => 'Nama tiket harus diisi',
        ],
        'price' => [
            'required' => 'Harga tiket harus diisi',
            'decimal' => 'Harga harus berupa angka',
        ],
        'quota' => [
            'required' => 'Kuota tiket harus diisi',
            'integer' => 'Kuota harus berupa angka bulat',
        ],
    ];

    protected $skipValidation = false;

    /**
     * Get all available tickets (with stock)
     */
    public function getAvailableTickets()
    {
        return $this->where('remaining_quota >', 0)->findAll();
    }

    /**
     * Check if ticket has enough stock
     */
    public function checkAvailability(int $ticketTypeId, int $quantity): bool
    {
        $ticket = $this->find($ticketTypeId);

        if (!$ticket) {
            return false;
        }

        return $ticket['remaining_quota'] >= $quantity;
    }

    /**
     * Reduce ticket quota (use in transaction)
     */
    public function reduceQuota(int $ticketTypeId, int $quantity): bool
    {
        $ticket = $this->find($ticketTypeId);

        if (!$ticket) {
            return false;
        }

        $newQuota = $ticket['remaining_quota'] - $quantity;

        if ($newQuota < 0) {
            return false;
        }

        return $this->update($ticketTypeId, ['remaining_quota' => $newQuota]);
    }

    /**
     * Restore ticket quota (for cancelled bookings)
     */
    public function restoreQuota(int $ticketTypeId, int $quantity): bool
    {
        $ticket = $this->find($ticketTypeId);

        if (!$ticket) {
            return false;
        }

        $newQuota = $ticket['remaining_quota'] + $quantity;

        // Don't exceed original quota
        if ($newQuota > $ticket['quota']) {
            $newQuota = $ticket['quota'];
        }

        return $this->update($ticketTypeId, ['remaining_quota' => $newQuota]);
    }
}
