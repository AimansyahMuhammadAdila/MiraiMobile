<?php

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

if (!function_exists('generateJWT')) {
    /**
     * Generate JWT token for user
     *
     * @param int $userId
     * @param array $userData Additional user data to include in token
     * @return string
     */
    function generateJWT(int $userId, array $userData = []): string
    {
        $secretKey = getenv('JWT_SECRET_KEY');
        $timeToLive = getenv('JWT_TIME_TO_LIVE') ?: 86400; // Default 24 hours

        $issuedAt = time();
        $expire = $issuedAt + $timeToLive;

        $payload = [
            'iat' => $issuedAt,
            'exp' => $expire,
            'user_id' => $userId,
            'data' => $userData,
        ];

        return JWT::encode($payload, $secretKey, 'HS256');
    }
}

if (!function_exists('validateJWT')) {
    /**
     * Validate and decode JWT token
     *
     * @param string $token
     * @return object|false Returns decoded token or false if invalid
     */
    function validateJWT(string $token)
    {
        try {
            $secretKey = getenv('JWT_SECRET_KEY');
            $decoded = JWT::decode($token, new Key($secretKey, 'HS256'));
            return $decoded;
        } catch (\Exception $e) {
            log_message('error', 'JWT Validation Error: ' . $e->getMessage());
            return false;
        }
    }
}

if (!function_exists('getJWTFromHeader')) {
    /**
     * Extract JWT token from Authorization header
     *
     * @return string|null
     */
    function getJWTFromHeader(): ?string
    {
        $request = \Config\Services::request();
        $authHeader = $request->getHeaderLine('Authorization');

        if (empty($authHeader)) {
            return null;
        }

        // Remove 'Bearer ' prefix if present
        if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            return $matches[1];
        }

        return $authHeader;
    }
}

if (!function_exists('getCurrentUserId')) {
    /**
     * Get current user ID from JWT token
     *
     * @return int|null
     */
    function getCurrentUserId(): ?int
    {
        $token = getJWTFromHeader();

        if (!$token) {
            return null;
        }

        $decoded = validateJWT($token);

        if (!$decoded) {
            return null;
        }

        return $decoded->user_id ?? null;
    }
}

if (!function_exists('getCurrentUserData')) {
    /**
     * Get current user data from JWT token
     *
     * @return array|null
     */
    function getCurrentUserData(): ?array
    {
        $token = getJWTFromHeader();

        if (!$token) {
            return null;
        }

        $decoded = validateJWT($token);

        if (!$decoded) {
            return null;
        }

        return (array) ($decoded->data ?? []);
    }
}
