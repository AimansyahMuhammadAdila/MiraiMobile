<?php

// Load CodeIgniter
require 'app/Config/Paths.php';
$paths = new Config\Paths();
require rtrim($paths->systemDirectory, '\\/ ') . DIRECTORY_SEPARATOR . 'bootstrap.php';

use App\Models\BookingModel;

$model = new BookingModel();
$booking = $model->orderBy('id', 'DESC')->first();

if ($booking) {
    echo "Booking ID: " . $booking['id'] . "\n";
    echo "Payment Proof Path: " . $booking['payment_proof'] . "\n";
    echo "Full URL: " . base_url($booking['payment_proof']) . "\n";
} else {
    echo "No bookings found.\n";
}
