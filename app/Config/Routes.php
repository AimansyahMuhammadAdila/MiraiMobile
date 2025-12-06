<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');

/*
 * --------------------------------------------------------------------
 * API Routes - Version 1
 * --------------------------------------------------------------------
 */
$routes->group('api/v1', ['namespace' => 'App\Controllers\API\V1'], function ($routes) {

    // Handle all OPTIONS requests for CORS preflight
    $routes->options('(:any)', function () {
        return service('response')
            ->setStatusCode(200)
            ->setHeader('Access-Control-Allow-Origin', '*')
            ->setHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    });

    // Media Route (CORS enabled)
    $routes->get('media/(:segment)/(:segment)', '\App\Controllers\Media::serve/$1/$2');

    // Public Routes - No Authentication Required
    $routes->post('auth/register', 'Auth::register');
    $routes->post('auth/login', 'Auth::login');
    $routes->get('tickets', 'Tickets::index');
    $routes->get('tickets/(:num)', 'Tickets::show/$1');

    // Protected Routes - Requires JWT Authentication
    $routes->group('', ['filter' => 'auth'], function ($routes) {
        // Auth
        $routes->post('auth/logout', 'Auth::logout');

        // Bookings
        $routes->get('bookings', 'Booking::index');
        $routes->post('bookings', 'Booking::create');
        $routes->get('bookings/(:num)', 'Booking::show/$1');
        $routes->post('bookings/(:num)/upload-proof', 'Booking::uploadProof/$1');

        // User profile (protected)
        $routes->get('user/profile', 'User::profile');
        $routes->put('user/profile', 'User::update');
        $routes->post('user/profile', 'User::update'); // Alternative for mobile apps
    });

    // ============================================
    // ADMIN ROUTES (Protected by admin filter)
    // ============================================
    $routes->group('admin', ['filter' => 'admin'], function ($routes) {
        // Dashboard statistics
        $routes->get('dashboard/stats', 'Admin\Dashboard::stats');

        // Payment Verification
        $routes->get('bookings/pending', 'Admin\PaymentVerification::pending');
        $routes->post('bookings/(:num)/approve', 'Admin\PaymentVerification::approve/$1');
        $routes->post('bookings/(:num)/reject', 'Admin\PaymentVerification::reject/$1');

        // Booking History
        $routes->get('bookings/history', 'Admin\BookingHistory::index');

        // User Management
        $routes->get('users', 'Admin\UserManagement::index');
        $routes->get('users/(:num)', 'Admin\UserManagement::show/$1');
        $routes->put('users/(:num)', 'Admin\UserManagement::update/$1');
        $routes->delete('users/(:num)', 'Admin\UserManagement::delete/$1');

        // Ticket Management
        $routes->post('tickets', 'Admin\TicketManagement::create');
        $routes->put('tickets/(:num)', 'Admin\TicketManagement::update/$1');
        $routes->delete('tickets/(:num)', 'Admin\TicketManagement::delete/$1');
    });
});
