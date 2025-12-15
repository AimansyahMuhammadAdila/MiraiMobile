<?php

namespace App\Libraries;

use Google\Cloud\Storage\StorageClient;

class GcsService
{
    protected $storage;
    protected $bucket;

    public function __construct()
    {
        $this->storage = new StorageClient([
            'keyFilePath' => APPPATH . 'Config/gcs-key.json',
        ]);

        $this->bucket = $this->storage->bucket($_ENV['GCS_BUCKET']);
    }

    /**
     * Upload bukti pembayaran
     */
    public function uploadPaymentProof(string $localPath, string $fileName): string
    {
        return $this->uploadToFolder(
            $_ENV['GCS_PAYMENT_FOLDER'],
            $localPath,
            $fileName
        );
    }

    /**
     * Upload QR Code
     */
    public function uploadQrCode(string $localPath, string $fileName): string
    {
        return $this->uploadToFolder(
            $_ENV['GCS_QR_FOLDER'],
            $localPath,
            $fileName
        );
    }

    /**
     * Core uploader
     */
    private function uploadToFolder(string $folder, string $localPath, string $fileName): string
    {
        $objectName = trim($folder, '/') . '/' . $fileName;

        $this->bucket->upload(
            fopen($localPath, 'r'),
            [
                'name' => $objectName,
            ]
        );

        return sprintf(
            'https://storage.googleapis.com/%s/%s',
            $_ENV['GCS_BUCKET'],
            $objectName
        );
    }

}
