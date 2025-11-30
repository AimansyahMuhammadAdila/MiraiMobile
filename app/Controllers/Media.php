<?php

namespace App\Controllers;

use CodeIgniter\Controller;

class Media extends Controller
{
    public function serve($folder, $filename)
    {
        $path = FCPATH . 'uploads/' . $folder . '/' . $filename;

        if (!file_exists($path)) {
            throw \CodeIgniter\Exceptions\PageNotFoundException::forPageNotFound();
        }

        $mime = mime_content_type($path);
        header('Content-Type: ' . $mime);
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization');

        readfile($path);
        exit;
    }
}
