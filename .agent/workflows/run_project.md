---
description: How to run the MiraiMobile project
---

# How to Run MiraiMobile

Follow these steps to run the backend and frontend of the MiraiMobile application.

## 1. Backend (CodeIgniter 4)

The backend is located in the root directory `c:\laragon\www\MiraiMobile`.

### Prerequisites
- Ensure Laragon is running (Apache/Nginx & MySQL).
- Database `mirai_mobile` should exist.

### Setup & Run
1.  **Open Terminal** in the root directory:
    ```powershell
    cd c:\laragon\www\MiraiMobile
    ```

2.  **Run Migrations** (Important for new features):
    ```powershell
    php spark migrate
    ```

3.  **Start Server** (If not using Laragon's auto-host):
    ```powershell
    php spark serve --host 0.0.0.0 --port 8080
    ```
    *Note: If using Laragon, you might access it via `http://miraimobile.test` or similar. Adjust `base_url` in `.env` accordingly.*

## 2. Frontend (Flutter)

The frontend is located in the `mirai_mobile` subdirectory.

### Setup
1.  **Navigate to Frontend Directory**:
    ```powershell
    cd c:\laragon\www\MiraiMobile\mirai_mobile
    ```

2.  **Install Dependencies**:
    ```powershell
    flutter pub get
    ```

### Run
1.  **Run on Emulator/Device**:
    ```powershell
    flutter run
    ```

## 3. Verification

1.  Open the app.
2.  Login/Register.
3.  Create a booking.
4.  Go to **History** -> **Upload Bukti**.
5.  Check backend `public/uploads` folder for the file.
