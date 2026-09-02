# Week 1 — Mobile Development Ecosystem & Flutter Refresh

**Nama: Indhira Yuantika Christy**
**NIM: 244107020171**
**Mata Kuliah: Pemrograman Mobile**

---

## Tujuan Pembelajaran

Pada minggu pertama, pembelajaran berfokus pada:

* Memahami evolusi pengembangan aplikasi mobile.
* Menjelaskan perbedaan **native, hybrid, dan cross-platform**.
* Memahami arsitektur Flutter dan peran bahasa Dart.
* Memahami struktur project Flutter dan konsep **widget tree**.
* Mengulang dasar-dasar Dart dan **null safety**.
* Menyiapkan Flutter, Android SDK, Android Studio, dan Android Emulator.
* Menjalankan serta memodifikasi aplikasi Flutter pertama.

---

## Fitur Utama

* Menampilkan AppBar dengan judul `Profil Mahasiswa`.
* Menampilkan ikon pendidikan.
* Menampilkan nama mahasiswa.
* Menampilkan NIM mahasiswa.
* Menampilkan informasi Pemrograman Mobile — Minggu 1.
* Menghilangkan fitur counter bawaan Flutter.

---

## Teknologi yang Digunakan

| Teknologi          | Keterangan                      |
| ------------------ | ------------------------------- |
| Flutter            | Framework pengembangan aplikasi |
| Dart               | Bahasa pemrograman              |
| Android Studio     | IDE dan Android SDK             |
| Android Emulator   | Menjalankan aplikasi Android    |
| Visual Studio Code | Code editor                     |
| Git                | Version control                 |

---

## Cara Menjalankan

Pastikan Flutter dan Android Emulator sudah terpasang dan terkonfigurasi.
Jalankan perintah berikut dari folder project:
```bash
flutter pub get
flutter run
```
Aplikasi kemudian akan dijalankan pada Android Emulator atau perangkat yang tersedia.

---

## Konsep yang Dipelajari

### 1. Flutter
Flutter merupakan framework untuk membangun aplikasi dengan satu codebase yang dapat digunakan pada berbagai platform.

### 2. Dart
Dart merupakan bahasa pemrograman yang digunakan dalam pengembangan aplikasi Flutter.

### 3. Widget
Widget merupakan komponen utama yang digunakan untuk membangun antarmuka aplikasi Flutter.

### 4. Widget Tree
Widget tree merupakan struktur hierarki widget yang membentuk tampilan aplikasi.

---

## Kendala Setup

Kendala yang saya temui adalah perbedaan versi Flutter, Android Studio, dan Android SDK. Ketika melakukan pengecekan menggunakan perintah flutter doctor, muncul keterangan Android license status unknown pada bagian Android toolchain. 

Untuk mengatasi kendala tersebut, saya melakukan konfigurasi dan pengecekan kembali terhadap Android SDK serta lisensi Android. Setelah konfigurasi berhasil, Flutter dapat mendeteksi Android SDK dan Android Emulator dengan baik.

---

## Refleksi

Pada minggu pertama, saya mempelajari dasar ekosistem pengembangan aplikasi mobile dan pengenalan Flutter. Saya juga memahami struktur project Flutter, penggunaan widget, serta cara menjalankan aplikasi menggunakan Android Emulator.

---

## Kesimpulan

Praktikum minggu pertama berhasil dilakukan. Flutter, Android Studio, Android SDK, dan Android Emulator telah dikonfigurasi sehingga aplikasi profil mahasiswa dapat dibuat, dijalankan, dan didokumentasikan.