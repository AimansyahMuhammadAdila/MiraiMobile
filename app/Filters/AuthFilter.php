<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;

class AuthFilter implements FilterInterface
{
    /**
     * Do whatever processing this filter needs to do.
     * By default it should not return anything during
     * normal execution. However, when an abnormal state
     * is found, it should return an instance of
     * CodeIgniter\HTTP\Response. If it does, script
     * execution will end and that Response will be
     * sent back to the client, allowing for error pages,
     * redirects, etc.
     *
     * @param RequestInterface $request
     * @param array|null       $arguments
     *
     * @return mixed
     */
    public function before(RequestInterface $request, $arguments = null)
    {
        helper('jwt');

        $token = getJWTFromHeader();

        if (!$token) {
            return $this->unauthorizedResponse('Token tidak ditemukan');
        }

        $decoded = validateJWT($token);

        if (!$decoded) {
            return $this->unauthorizedResponse('Token tidak valid atau sudah kadaluarsa');
        }

        // Token is valid, request can proceed
        return $request;
    }

    /**
     * Allows After filters to inspect and modify the response
     * object as needed. This method does not allow any way
     * to stop execution of other after filters, short of
     * throwing an Exception or Error.
     *
     * @param RequestInterface  $request
     * @param ResponseInterface $response
     * @param array|null        $arguments
     *
     * @return mixed
     */
    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        // Do nothing
    }

    /**
     * Return unauthorized response
     *
     * @param string $message
     * @return ResponseInterface
     */
    private function unauthorizedResponse(string $message): ResponseInterface
    {
        $response = service('response');
        $response->setStatusCode(401);
        $response->setJSON([
            'success' => false,
            'message' => $message,
            'data' => null,
        ]);
        return $response;
    }
}
