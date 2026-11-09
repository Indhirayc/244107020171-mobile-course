# 244107020171 — Mobile Course Portfolio

**Nama:** Indhira Yuantika Christy
**NIM:** 244107020171
**Mata Kuliah:** Pemrograman Mobile

---

## 📱 Deskripsi

Repository ini berisi dokumentasi dan hasil praktikum mata kuliah **Pemrograman Mobile** selama satu semester.

Setiap minggu berisi materi pembelajaran, implementasi aplikasi, eksperimen, dokumentasi, serta hasil pembelajaran yang telah dikerjakan.

Portfolio ini digunakan untuk mendokumentasikan proses belajar mulai dari dasar **Flutter & Dart**, pengembangan aplikasi mobile, integrasi API, penyimpanan lokal, keamanan, hingga deployment dan final project.

---

## 📂 Struktur Portfolio

```text
244107020171-mobile-course/
│
├── README.md
│
├── 01-week-1-mobile-development-ecosystem-flutter-refresh/
├── 02-week-2-declarative-ui-responsive-design/
├── 03-week-3-navigation-state-management/
├── 04-week-4-networking-rest-api/
├── 05-week-5-local-storage-offline-first/
├── 06-week-6-authentication-security-fcm/
├── 07-week-7-clean-architecture/
├── 08-week-8-mid-project-review-code-review/
├── 09-week-9-ai-assisted-development/
├── 10-week-10-ai-feature-integration/
├── 11-week-11-performance-optimization/
├── 12-week-12-testing-quality-assurance/
├── 13-week-13-ci-cd-automation/
├── 14-week-14-deployment-monitoring/
├── 15-week-15-secure-mobile-development/
├── 16-week-16-final-project-expo/
│
├── notes/
└── portfolio-summary.md
```

---

## 🛠️ Teknologi

Teknologi dan tools yang digunakan dalam pembelajaran:

* **Flutter** — Framework pengembangan aplikasi mobile
* **Dart** — Bahasa pemrograman utama
* **Riverpod** — State management
* **GoRouter** — Navigasi dan routing
* **Dio** — HTTP client untuk REST API
* **JSONPlaceholder** — Dummy REST API untuk praktikum
* **SharedPreferences** — Penyimpanan key-value untuk preferensi lokal
* **sqflite (SQLite)** — Database lokal untuk penyimpanan data terstruktur dan offline
* **Android Studio** — Android development environment
* **Android SDK** — Tools dan platform Android
* **Visual Studio Code** — Code editor
* **Git** — Version control
* **GitHub** — Repository dan dokumentasi project
* **Firebase Cloud Messaging (FCM)** — Push notification dan topic messaging
* **flutter_local_notifications** — Menampilkan notifikasi lokal
* **flutter_secure_storage** — Penyimpanan token autentikasi secara aman
* **GitHub Copilot** — AI-assisted development dan refactoring
* **Flutter Test** — Unit testing dan widget testing

---

## 📊 Progress Pembelajaran

| Minggu | Materi                                         |   Status  |
| :----: | ---------------------------------------------- | :-------: |
|   01   | Mobile Development Ecosystem & Flutter Refresh | ✅ Selesai |
|   02   | Declarative UI & Responsive Design             | ✅ Selesai |
|   03   | Navigation & State Management                  | ✅ Selesai |
|   04   | Networking & REST API                          | ✅ Selesai |
|   05   | Local Storage & Offline First                  | ✅ Selesai |
|   06   | Authentication, Security & FCM                 | ✅ Selesai |
|   07   | Clean Architecture                             | ✅ Selesai |
|   08   | Mid Project Review & Code Review               | ✅ Selesai |
|   09   | AI-assisted Development / Vibe Coding          | ✅ Selesai |
|   10   | AI Feature Integration                         | ✅ Selesai |
|   11   | Performance Optimization                       |  ⏳ Belum  |
|   12   | Testing & Quality Assurance                    |  ⏳ Belum  |
|   13   | CI/CD & Automation                             |  ⏳ Belum  |
|   14   | Deployment & Monitoring                        |  ⏳ Belum  |
|   15   | Secure Mobile Development                      |  ⏳ Belum  |
|   16   | Final Project Expo                             |  ⏳ Belum  |

---

## 📚 Materi yang Sudah Dipelajari

### Week 01 — Mobile Development Ecosystem & Flutter Refresh

Mempelajari dasar ekosistem pengembangan aplikasi mobile dan melakukan refresh terhadap Flutter, termasuk struktur project, widget dasar, serta penggunaan Flutter untuk membangun aplikasi mobile.

**Status:** ✅ Selesai

### Week 02 — Declarative UI & Responsive Design

Mempelajari konsep **declarative UI** pada Flutter serta penerapan layout yang responsif menggunakan berbagai widget dan teknik layout.

**Status:** ✅ Selesai

### Week 03 — Navigation & State Management

Mempelajari navigasi antar halaman menggunakan **GoRouter** serta pengelolaan state menggunakan **Riverpod**. Praktikum mencakup navigasi multi-page, aplikasi ToDo, penggunaan Provider dan AsyncNotifier, serta penanganan state loading, error, dan success menggunakan AsyncValue.

**Status:** ✅ Selesai

### Week 04 — Networking & REST API

Mempelajari integrasi aplikasi Flutter dengan **REST API** menggunakan Dio, penerapan repository pattern, model JSON yang aman terhadap null, serta state management menggunakan Riverpod.

Praktikum juga mencakup error handling, pagination dan infinite scroll, penggunaan GoRouter untuk halaman detail post, refactoring komponen, serta unit testing menggunakan fake repository tanpa melakukan HTTP request secara langsung.

**Status:** ✅ Selesai

### Week 05 — Local Storage & Offline First

Mempelajari penyimpanan data lokal pada Flutter menggunakan **SharedPreferences** untuk preferensi sederhana dan **SQLite (sqflite)** untuk penyimpanan data terstruktur secara persisten.

Praktikum mencakup penerapan repository pattern, Riverpod, cache-first untuk data API, dirty flag dan proses sinkronisasi catatan, simulasi kondisi offline, serta penyimpanan cache agar data tetap dapat diakses tanpa koneksi internet.

Selain itu, dilakukan refactoring dengan memisahkan widget `NoteTile` dan logika sinkronisasi, menambahkan halaman detail catatan menggunakan **GoRouter**, serta melakukan unit testing menggunakan fake repository tanpa bergantung pada database SQLite sungguhan.

**Status:** ✅ Selesai

### Week 06 — Authentication, Security & FCM

Mempelajari implementasi **autentikasi dan keamanan aplikasi Flutter**, meliputi login, penyimpanan token menggunakan **flutter_secure_storage**, pengelolaan sesi pengguna, refresh token otomatis menggunakan **Dio Interceptor**, serta proteksi halaman menggunakan **GoRouter** dan **Riverpod**.

Praktikum juga mencakup integrasi **Firebase Cloud Messaging (FCM)** untuk mengelola izin notifikasi, token lifecycle (`getToken` dan `onTokenRefresh`), penerimaan notifikasi pada kondisi **foreground, background, dan terminated**, navigasi melalui deep link, serta pengelolaan topic messaging menggunakan `subscribeToTopic()` dan `unsubscribeFromTopic()`.

Selain itu, dilakukan **AI Challenge menggunakan GitHub Copilot**, refactoring struktur kode, pemisahan konstanta route dan penanganan error API, serta unit testing dan widget testing. Pengujian terakhir menunjukkan **11 test berhasil dijalankan**, termasuk smoke test yang mengisolasi inisialisasi Firebase Messaging.

Integrasi backend untuk registrasi token perangkat masih menggunakan konfigurasi contoh dan belum diverifikasi dengan server produksi.

**Status:** ✅ Selesai

### Week 07 — Clean Architecture

Mempelajari penerapan **Clean Architecture** pada Flutter menggunakan pendekatan **feature-first**, pemisahan **Presentation, Domain, dan Data Layer**, serta prinsip SOLID dan dependency rule.

Praktikum mencakup audit arsitektur, implementasi repository pattern, use case, dependency injection menggunakan Riverpod, serta refactoring fitur **Notes dan Auth**.

Selain itu, dilakukan **AI Challenge menggunakan ChatGPT** untuk mengevaluasi rancangan arsitektur dan menghindari over-engineering, serta unit testing menggunakan fake repository.

Hasil pengujian menunjukkan **`flutter analyze` tanpa masalah** dan **16 test berhasil dijalankan**.

**Status:** ✅ Selesai

---

### Week 08 — Mid Project Review & Code Review

Mempelajari proses code review dan evaluasi kualitas pengembangan aplikasi Flutter melalui penerapan Conventional Commits, pengelolaan branch, Pull Request, serta prinsip review kode yang bertanggung jawab.

Praktikum mencakup audit riwayat Git, pengembangan fitur validasi judul catatan, penerapan Clean Architecture melalui Use Case AddNote, self-review terhadap PR #1, serta evaluasi ukuran Pull Request. Selain itu, dilakukan konfigurasi GitHub Actions untuk mengotomatisasi pemeriksaan Dart Formatter, flutter analyze, dan flutter test.

Selanjutnya, dilakukan AI Challenge menggunakan GitHub Copilot untuk mengidentifikasi potensi masalah kode, memverifikasi rekomendasi AI, serta mendokumentasikan keputusan penerimaan dan penolakan temuan. Kegiatan juga mencakup refactoring, pengujian otomatis, pengujian manual, dan dokumentasi refleksi code review.

Hasil pengujian menunjukkan flutter analyze tanpa masalah, 33 file telah sesuai format Dart, dan 20 test berhasil dijalankan.

Status: ✅ Selesai

---

### Week 09 — AI-assisted Development / Vibe Coding

Mempelajari workflow *AI-assisted development* (`prompt`, `generate`, `verify`, `test`, `refactor`, `explain`) untuk meningkatkan produktivitas pengembangan aplikasi Flutter secara bertanggung jawab dan terukur.

Praktikum mencakup penerapan Formula 5 Slot dalam prompt engineering untuk menambahkan fitur pencarian judul catatan (*Search Notes*) dan penanganan *Empty State* pada basis aplikasi Offline Notes. Selain itu, dilakukan evaluasi kritis dan deteksi halusinasi kode AI (koreksi package usang Riverpod `StateProvider` ke `NotifierProvider`, perbaikan lifecycle `ConsumerState.build`), refactoring arsitektur, serta pencatatan log lengkap pada `docs/ai-log.md`.

Hasil pengujian menunjukkan `flutter analyze` bersih tanpa issue, formatting Dart rapi, dan 8 unit test berhasil dijalankan (100% passed).

Status: ✅ Selesai

---

### Week 10 — AI Feature Integration

Mempelajari integrasi model kecerdasan buatan (*Large Language Model / LLM API*) ke dalam aplikasi mobile Flutter secara aman, terstruktur, dan efisien.

Praktikum mencakup perancangan antarmuka obrolan (*Chat Interface*) asisten kampus interaktif dengan *streaming/loading indicator*, implementasi *AI Service Layer* terisolasi yang mengonsumsi Google Gemini 1.5 Flash REST API, manajemen kredensial aman menggunakan `flutter_secure_storage` (Android Keystore / iOS Keychain) tanpa pernah meng-hardcode API key pada repositori, serta manajemen state percakapan menggunakan Riverpod `Notifier`.

Selain itu, dilakukan perancangan prompt sistem dan batasan privasi (*guardrails*), mitigasi risiko kebocoran data sensitif dan lonjakan biaya, penanganan error kuota (`HTTP 429`) dengan dialog *fallback* yang anggun (*graceful degradation*) menuju catatan offline lokal, serta dokumentasi log interaksi lengkap pada `docs/ai-log.md`.

Hasil pengujian menunjukkan `flutter analyze` bersih tanpa issue (0 warnings) dan 27 unit test berhasil dijalankan dengan predikat hijau (100% passed).

Status: ✅ Selesai

---

## 📝 Dokumentasi

Setiap folder minggu berisi dokumentasi sesuai materi yang dipelajari, seperti:

* Source code
* Praktikum
* Eksperimen
* Screenshot hasil aplikasi
* Catatan pembelajaran
* README masing-masing minggu

---

## 🎯 Tujuan Portfolio

Portfolio ini dibuat untuk:

1. Mendokumentasikan proses pembelajaran Pemrograman Mobile.
2. Menyimpan hasil praktikum dan eksperimen selama satu semester.
3. Menunjukkan perkembangan kemampuan dalam menggunakan Flutter dan Dart.
4. Menjadi dokumentasi project yang dapat digunakan sebagai referensi di kemudian hari.

---

## 👤 Author

**Indhira Yuantika Christy**
**244107020171**

**D4 Teknik Informatika — Politeknik Negeri Malang**

---

> *Learning by building, experimenting, and improving.*
