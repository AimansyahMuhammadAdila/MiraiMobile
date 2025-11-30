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
        $routes->get('bookings', 'Bookings::index');
        $routes->get('bookings/(:num)', 'Bookings::show/$1');
        $routes->post('bookings', 'Bookings::create');

        // User Profile
        $routes->get('user/profile', 'User::profile');
        $routes->put('user/profile', 'User::update');
        $routes->post('user/profile', 'User::update'); // Alternative for mobile apps
    });
});
