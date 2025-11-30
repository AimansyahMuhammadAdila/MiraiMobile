# MiraiMobile - Ticket Booking Application

**MiraiMobile** adalah aplikasi mobile untuk pemesanan tiket event **MiraiFest 2025**, festival cosplay tahunan terbesar di Indonesia. Aplikasi ini dibangun menggunakan **Flutter** (frontend) dan **CodeIgniter 4** (backend) dengan arsitektur REST API dan JWT authentication.

---

## 📱 Fitur Utama

### Frontend (Flutter Mobile App)
- **Authentication**: Login & Register dengan JWT token
- **Dashboard**: Event countdown, informasi MiraiFest, quick actions
- **Tiket**: Browse dan beli 3 jenis tiket (GA, VIP, Cosplayer Pass)
- **E-Ticket**: Display QR code untuk scanning di venue
- **Booking History**: Riwayat pembelian tiket dengan status
- **Profile Management**: Kelola akun dan logout

### Backend (CodeIgniter 4 REST API)
- **JWT Authentication**: Secure token-based authentication
- **Ticket Management**: CRUD operations untuk tiket
- **Booking System**: Transaction-safe booking dengan QR code generation
- **Stock Management**: Automatic quota reduction dan overbooking prevention
- **Database**: MySQL dengan 3 tabel utama (users, ticket_types, bookings)

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.9.2+
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences
- **QR Code**: qr_flutter
- **UI**: Google Fonts, Material Design 3

### Backend
- **Framework**: CodeIgniter 4.6.3
- **Database**: MySQL
- **Authentication**: Firebase PHP-JWT
- **Language**: PHP 7.4+

---

## 🚀 Getting Started

### Prerequisites
- **Backend**: PHP 7.4+, Composer, MySQL, Laragon/XAMPP
- **Frontend**: Flutter SDK 3.9+, Android Studio/VS Code
- **Tools**: Git

### Backend Setup

1. **Install Dependencies**
   ```bash
   composer install
   ```

2. **Configure Environment**
   - Edit `.env` file (sudah dikonfigurasi):
   ```env
   database.default.database = mirai_fest_db
   JWT_SECRET_KEY = MiraiFest2025SecretKey!@#$%
   ```

3. **Database sudah dibuat dan seeded** dengan 3 jenis tiket

4. **Start Server**
   ```bash
   php spark serve
   ```
   API: `http://localhost/MiraiMobile/api/v1`

### Frontend Setup

1. **Navigate to Flutter Project**
   ```bash
   cd mirai_mobile
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run Application**
   ```bash
   flutter run
   ```

---

## 📡 API Endpoints

### Public
- `POST /api/v1/auth/register` - Register
- `POST /api/v1/auth/login` - Login (returns JWT)
- `GET /api/v1/tickets` - Get tickets

### Protected (Require JWT)
- `POST /api/v1/bookings` - Create booking
- `GET /api/v1/bookings` - Get user bookings
- `GET /api/v1/user/profile` - Get profile

---

## 💾 Database Schema

**users** - Authentication & profile  
**ticket_types** - Ticket categories (GA, VIP, Cosplayer Pass)  
**bookings** - Transactions with QR codes

---

**Developed for MiraiFest 2025** 🎭✨
