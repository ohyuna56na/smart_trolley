<div align="center">

<h1>Smart Trolley System</h1>

<img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&style=for-the-badge">
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&style=for-the-badge">
<img src="https://img.shields.io/badge/Midtrans-Payment_Gateway-004B87?style=for-the-badge">
<img src="https://img.shields.io/badge/REST_API-HTTP-green?style=for-the-badge">
<img src="https://img.shields.io/badge/Status-Completed-success?style=for-the-badge">

</div>

<br>

## 📌 Gambaran Umum Proyek

**Smart Trolley (Ummi Mart)** adalah aplikasi mobile pintar berbasis Flutter yang berfungsi sebagai *Smart Shopping Assistant*. Aplikasi ini dirancang untuk mempermudah proses berbelanja di lingkungan kampus maupun minimarket dengan menghubungkan aplikasi seluler pengguna ke keranjang/troli belanja fisik berbasis IoT secara *real-time*.

Sistem ini menghilangkan kebutuhan antrean kasir konvensional dengan memungkinkan pengguna memindai QR Code troli, memantau daftar barang belanjaan secara otomatis via *IoT Polling*, melakukan pembayaran digital (QRIS/E-Wallet), dan menerima struk bukti transaksi digital secara otomatis.

---

## 🛠️ Tools & Dependensi yang Digunakan

Proyek ini dibangun menggunakan *library*, *package*, dan alat pengembangan berikut:

| Kategori | Tool / Package | Kegunaan |
| :--- | :--- | :--- |
| **Framework** | [Flutter (Dart)](https://flutter.dev/) | Framework utama pengembangan aplikasi lintas platform. |
| **Design System** | [Google Fonts (Poppins)](https://fonts.google.com/specimen/Poppins) | Font standar antarmuka aplikasi. |
| **QR / Barcode Scanner** | [`ai_barcode_scanner`](https://pub.dev/packages/ai_barcode_scanner) | Pemindaian QR Code pada troli untuk mengambil `deviceId`. |
| **HTTP Client** | [`http`](https://pub.dev/packages/http) | Komunikasi asynchronous dengan backend REST API. |
| **Session & Storage** | [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Penyimpanan data sesi lokal (`apiUrl`, `deviceId`, draft struk, status pembayaran). |
| **In-App WebView** | [`webview_flutter`](https://pub.dev/packages/webview_flutter) | Menampilkan antarmuka pembayaran digital Midtrans di dalam aplikasi. |
| **External Launcher** | [`url_launcher`](https://pub.dev/packages/url_launcher) | Membuka tautan pembayaran eksternal untuk dukungan web. |
| **Payment Gateway** | [Midtrans](https://midtrans.com/) | Gateway pembayaran terintegrasi backend untuk transaksi QRIS/E-Wallet. |

---

## ✨ Fitur-Fitur Utama

1. **Scan QR Troli (`HomeScreen`)**
   * Memindai QR Code pada keranjang/troli fisik untuk mendapatkan `deviceId` dan menginisialisasi sesi belanja.
2. **Sinkronisasi IoT Otomatis (*Real-time Polling*)**
   * Menjalankan *timer periodic* setiap 3 detik untuk mengambil (*fetch*) daftar barang yang dimasukkan ke dalam troli fisik.
3. **Manajemen Produk & Keranjang**
   * Menambah/mengurangi kuantitas barang secara otomatis memperbarui database backend (`/api/cart/update-quantity`).
   * Fitur pengosongan keranjang (`/api/cart/clear`).
4. **Ringkasan Pesanan & Kalkulasi Otomatis (`OrderSummaryScreen`)**
   * Menghitung total biaya belanja secara *real-time* dan memformat nilai mata uang ke Rupiah (`formatRupiah`).
5. **Form Identitas Pembeli (`PaymentScreen`)**
   * Input dan validasi nama, email, dan nomor telepon pembeli sebelum memproses pembayaran.
6. **Pembayaran Digital via Midtrans (`QrisWebViewScreen`)**
   * Membuka antarmuka pembayaran QRIS/E-Wallet dan mengecek status transaksi (*pending*, *completed*, *failed*, *expired*) secara berkala setiap 3 detik.
7. **Struk Pembelian Digital (`ReceiptScreen`)**
   * Menampilkan bukti pembayaran lengkap berisi nomor *invoice*, rincian produk, total bayar, dan informasi pelanggan.
   * Menghapus seluruh sesi belanja (`AppSession.clearAll()`) setelah transaksi selesai.

---

## 📂 Struktur Arsitektur Repositori (`/lib`)

Struktur folder dan berkas pada repositori `smart_trolley`:

```text
lib/
├── constants/
│   └── api_constants.dart       # Konfigurasi Endpoint Base URL REST API Backend
├── models/
│   └── product.dart             # Model data produk (id, name, price, qty, image)
├── screen/
│   ├── splash_screen.dart       # Tampilan splash awal logo "Ummi Mart"
│   ├── onboarding_screen.dart   # Halaman selamat datang & pengenalan
│   ├── home_screen.dart         # Layar scan QR keranjang & daftar produk IoT
│   ├── order_summary_screen.dart# Layar ringkasan total dan item belanjaan
│   ├── payment_screen.dart      # Form pengisian identitas pelanggan
│   ├── qris_webview_screen.dart # WebView penampil transaksi pembayaran QRIS
│   └── receipt_screen.dart      # Layar struk digital bukti pembayaran
├── services/
│   ├── app_session.dart         # Helper SharedPreferences untuk persistensi sesi
│   ├── checkout_service.dart    # Service API checkout, status pembayaran, & struk
│   └── product_service.dart     # Service API produk, update kuantitas, & reset keranjang
├── theme/
│   └── app_colors.dart          # Sentralisasi variabel warna tema aplikasi
├── utils/
│   └── currency.dart            # Helper format mata uang (Rupiah)
└── main.dart                    # Entry point aplikasi & konfigurasi rute navigasi
```


## 🎨 Skema Warna Aplikasi (`AppColors`)

Definisi tema warna yang digunakan pada seluruh komponen antarmuka aplikasi:

* **Primary Blue:** `#1E88E5` (Warna utama AppBar, tombol, & identitas)
* **Background Light:** `#F8FBFF` (Latar belakang halaman)
* **Onboarding Background:** `#EAF4FF` (Latar belakang layar pengenalan)
* **Price / Highlight:** `#D32F2F` (Warna penjelas harga & total belanja)
* **Text Primary:** `#263238` (Warna teks utama)

---

## 🔄 Alur Integrasi Sistem

```mermaid
sequenceDiagram
    autonumber
    actor User as Pengguna
    participant App as Aplikasi Mobile
    participant IoT as Troli Fisik / IoT
    participant API as Backend REST API
    participant PG as Midtrans Gateway

    User->>App: Scan QR Code pada Troli
    App->>App: Simpan Session (apiUrl & deviceId)
    loop Setiap 3 Detik (Polling)
        App->>API: GET Request daftar produk
        API-->>App: Return JSON items dalam troli
    end
    User->>App: Tekan Tombol Checkout & Isi Data Diri
    App->>API: POST /api/cart/checkout (device_id, name, email, phone)
    API->>PG: Inisialisasi Transaksi Midtrans
    PG-->>API: Return payment_url & invoice
    API-->>App: Return payment_url & invoice
    App->>User: Buka WebView Pembayaran QRIS
    loop Cek Status Transaksi (Setiap 3 Detik)
        App->>API: GET /api/payment/status/{invoice}
        API-->>App: Return status ("completed" / "pending")
    end
    App->>User: Tampilkan Struk Pembelian (ReceiptScreen)
    App->>App: Clear Session (Reset Troli)
