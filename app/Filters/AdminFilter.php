<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

class AdminFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        helper('jwt');

        // Get token from header
        $authHeader = $request->getHeaderLine('Authorization');

        if (empty($authHeader)) {
            return service('response')
                ->setJSON([
                    'success' => false,
                    'message' => 'Token tidak ditemukan',
                    'data' => null,
                ])
                ->setStatusCode(401);
        }

        try {
            // Extract token
            $token = str_replace('Bearer ', '', $authHeader);

            // Validate token
            $payload = validateJWT($token);

            if (!$payload) {
                throw new \Exception('Token tidak valid');
            }

            // Get user ID from payload
            $userId = $payload->user_id ?? null;

            if (!$userId) {
                throw new \Exception('User ID tidak ditemukan dalam token');
            }

            // Check if user is admin
            $userModel = new \App\Models\UserModel();
            if (!$userModel->isAdmin($userId)) {
                return service('response')
                    ->setJSON([
                        'success' => false,
                        'message' => 'Akses ditolak. Hanya admin yang dapat mengakses resource ini.',
                        'data' => null,
                    ])
                    ->setStatusCode(403);
            }

            // Store user ID in request for later use
            $request->user_id = $userId;

        } catch (\Exception $e) {
            return service('response')
                ->setJSON([
                    'success' => false,
                    'message' => $e->getMessage(),
                    'data' => null,
                ])
                ->setStatusCode(401);
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        return $response;
    }
}
