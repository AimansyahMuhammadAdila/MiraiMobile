-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 14, 2025 at 04:57 AM
-- Server version: 9.4.0
-- PHP Version: 8.4.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mirai_fest_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `ticket_type_id` int UNSIGNED NOT NULL,
  `quantity` int UNSIGNED NOT NULL,
  `total_price` decimal(15,2) NOT NULL,
  `qr_code` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `booking_code` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `payment_proof` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `payment_status` enum('pending','confirmed','cancelled') COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'pending',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `user_id`, `ticket_type_id`, `quantity`, `total_price`, `qr_code`, `booking_code`, `payment_proof`, `payment_status`, `created_at`, `updated_at`) VALUES
(8, 3, 2, 1, 350000.00, 'uploads/qr_codes/MIRAI202511308285.png', 'MIRAI202511308285', 'uploads/payment_proofs/8_1764518598.png', 'confirmed', '2025-11-30 16:03:09', '2025-11-30 16:03:49'),
(9, 3, 4, 1, 200000.00, 'uploads/qr_codes/MIRAI20251130FA1F.png', 'MIRAI20251130FA1F', 'uploads/payment_proofs/9_1764519197.png', 'confirmed', '2025-11-30 16:13:00', '2025-11-30 16:13:42'),
(10, 4, 6, 2, 60000.00, 'uploads/qr_codes/MIRAI202512010014.png', 'MIRAI202512010014', 'uploads/payment_proofs/10_1764552116.png', 'confirmed', '2025-12-01 01:21:12', '2025-12-01 01:22:34'),
(11, 4, 8, 1, 40000.00, 'MF-BBAD958F836571C637AD909A97B25F97', 'MIRAI202512015E54', 'uploads/payment_proofs/11_1764552107.png', 'cancelled', '2025-12-01 01:21:17', '2025-12-01 01:22:41'),
(12, 4, 1, 1, 150000.00, 'uploads/qr_codes/MIRAI20251201CF79.png', 'MIRAI20251201CF79', 'uploads/payment_proofs/12_1764552655.jpg', 'confirmed', '2025-12-01 01:30:33', '2025-12-01 01:35:06'),
(13, 4, 2, 1, 350000.00, 'uploads/qr_codes/MIRAI20251201CC6F.png', 'MIRAI20251201CC6F', 'uploads/payment_proofs/13_1764552648.png', 'confirmed', '2025-12-01 01:30:35', '2025-12-01 01:31:20'),
(14, 5, 9, 1, 10000000.00, 'uploads/qr_codes/MIRAI20251201A212.png', 'MIRAI20251201A212', 'uploads/payment_proofs/14_1764593454.png', 'confirmed', '2025-12-01 12:50:06', '2025-12-01 12:51:41');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` bigint UNSIGNED NOT NULL,
  `version` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `class` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `group` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `namespace` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `time` int NOT NULL,
  `batch` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `version`, `class`, `group`, `namespace`, `time`, `batch`) VALUES
(7, '2025_11_30_000001', 'App\\Database\\Migrations\\CreateUsersTable', 'default', 'App', 1764513360, 1),
(8, '2025_11_30_000002', 'App\\Database\\Migrations\\CreateTicketTypesTable', 'default', 'App', 1764513360, 1),
(9, '2025_11_30_000003', 'App\\Database\\Migrations\\CreateBookingsTable', 'default', 'App', 1764513360, 1);

-- --------------------------------------------------------

--
-- Table structure for table `ticket_types`
--

CREATE TABLE `ticket_types` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `price` decimal(10,2) NOT NULL,
  `quota` int UNSIGNED NOT NULL,
  `remaining_quota` int UNSIGNED NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ticket_types`
--

INSERT INTO `ticket_types` (`id`, `name`, `description`, `price`, `quota`, `remaining_quota`, `created_at`, `updated_at`) VALUES
(1, 'General Admission (GA)', 'Akses ke semua area event MiraiFest, termasuk: Main Stage, Vendor Booths, Photo Spots, dan Cosplay Competition sebagai penonton.', 150000.00, 500, 499, '2025-11-30 14:59:12', '2025-12-01 01:30:33'),
(2, 'VIP Pass', 'Semua benefit GA + Meet & Greet dengan Guest Stars, VIP Seating Area, Exclusive MiraiFest Merchandise (T-Shirt + Tote Bag), Priority Entry.', 350000.00, 150, 148, '2025-11-30 14:59:12', '2025-12-01 01:30:35'),
(3, 'Cosplayer Pass', 'Semua benefit GA + Akses ke Backstage & Changing Room, Partisipasi Cosplay Competition (jika mendaftar), Professional Photoshoot Corner, Cosplayer Lounge Area.', 250000.00, 200, 200, '2025-11-30 14:59:12', '2025-11-30 15:22:47'),
(4, 'Tiket Khusus', 'Semua benefit GA + Akses ke Backstage & Changing Room, Partisipasi Cosplay Competition (jika mendaftar), Professional Photoshoot Corner, Cosplayer Lounge Area.', 200000.00, 10, 9, '2025-11-30 15:36:54', '2025-11-30 16:13:00'),
(5, 'Tiket Cosplayer', 'Tiket yang dikhususkan untuk para cosplayer ', 20000.00, 80, 80, '2025-12-01 01:11:11', '2025-12-01 01:11:11'),
(6, 'Tiket Khusus Mahasiswa', 'Tiket yang ditujukan untuk para mahasiswa', 30000.00, 80, 78, '2025-12-01 01:12:19', '2025-12-01 01:21:12'),
(7, 'Tiket Normal', 'Tiket masuk MiraiFest ', 50000.00, 20, 20, '2025-12-01 01:12:52', '2025-12-01 01:12:52'),
(8, 'Tiket Coswalk', 'Tiket untuk lomba Coswalk, Berhadiah Total Hingga 3 Juta!!', 40000.00, 70, 70, '2025-12-01 01:14:07', '2025-12-01 01:22:41'),
(9, 'tiket keren', 'tiket terkeren 2025', 10000000.00, 3, 2, '2025-12-01 01:23:08', '2025-12-01 12:50:06');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `role` enum('user','admin') COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'user',
  `phone` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `jwt_token` text COLLATE utf8mb4_general_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `role`, `phone`, `password`, `jwt_token`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', 'admin@miraimobile.com', 'admin', '081234567890', '$2y$12$SKXRfhbH5zo1GF7raGH4feqXiq/6mu8zHAu51TG1FOVotzU1gTnse', 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NjUwMzIwMzEsImV4cCI6MTc2NTExODQzMSwidXNlcl9pZCI6MSwiZGF0YSI6eyJlbWFpbCI6ImFkbWluQG1pcmFpbW9iaWxlLmNvbSIsIm5hbWUiOiJTdXBlciBBZG1pbiJ9fQ.oexHwLqH2RmeWe4llhNypiaShoAwyy3knEKPcAJCXEM', '2025-11-30 14:57:31', '2025-12-06 14:40:31'),
(3, 'aiman', 'aiman@gmail.com', 'user', '0808080808', '$2y$12$b8jM.quLZ6A7yRIl9QlTguw0lN1h5EY1mRgVe5Flhhd0D9rRXAiny', NULL, '2025-11-30 16:02:48', '2025-12-06 14:01:39'),
(4, 'aimang', 'aimang@gmail.com', 'user', '08080808080808', '$2y$12$0XlAUhFdohw93NzcuynylucbxFiT.B3fVfLvYA6BVV5hzUMQwSzKW', NULL, '2025-12-01 01:20:43', '2025-12-06 13:50:33'),
(5, 'tomi', 'tomi@gmail.com', 'user', '08080808080808', '$2y$12$yvJgSKuv0pPpEb4LsMRBLehz28GByKAiSXx0b/sDkFIF1gWokENNK', NULL, '2025-12-01 12:49:46', '2025-12-01 12:50:58');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `qr_code` (`qr_code`),
  ADD UNIQUE KEY `booking_code` (`booking_code`),
  ADD KEY `bookings_user_id_foreign` (`user_id`),
  ADD KEY `bookings_ticket_type_id_foreign` (`ticket_type_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ticket_types`
--
ALTER TABLE `ticket_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `ticket_types`
--
ALTER TABLE `ticket_types`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ticket_type_id_foreign` FOREIGN KEY (`ticket_type_id`) REFERENCES `ticket_types` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `bookings_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
