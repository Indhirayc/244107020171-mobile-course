# AI Integration Log & Design Documentation

Dokumentasi ini mencatat perancangan prompt, arsitektur keamanan data, manajemen risiko biaya/privasi, serta log pengujian interaksi antarmuka AI pada fitur **Asisten Kampus AI** di aplikasi **Campus Notify** (Minggu 10).

---

## 1. Perancangan Prompt (Prompt Design)

Integrasi fitur LLM pada aplikasi mobile memerlukan prompt yang terstruktur, ringkas, dan aman agar model memberikan respon yang akurat dengan latensi rendah dan konsumsi kuota/token yang efisien.

### Tabel Komponen Prompt

| Komponen | Implementasi / Konten | Tujuan |
|---|---|---|
| **System Prompt** | `"Kamu adalah asisten kampus cerdas dan ramah untuk aplikasi Campus Notify. Jawab dalam Bahasa Indonesia secara ringkas, jelas, solutif, dan sopan maksimal 2-3 kalimat. Jangan meminta atau membagikan data sensitif pengguna seperti NIK, nomor telepon pribadi, kata sandi, atau alamat rumah."` | Menetapkan persona, gaya bahasa, batasan panjang jawaban, dan guardrail privasi. |
| **User Prompt** | Pertanyaan dinamis dari mahasiswa (contoh: *"Bagaimana cara mencatat pengumuman baru di aplikasi ini?"* atau *"Kapan jadwal KRS semester ganjil dimulai?"*) | Input langsung dari pengguna melalui kolom chat. |
| **Konteks (Context)** | Konteks aplikasi kampus (pemberitahuan, catatan pengumuman, pengingat tenggat waktu tugas, dan panduan akademik). | Menjaga agar AI tetap fokus pada topik asistensi mahasiswa dan manajemen catatan. |
| **Batasan (Guardrail)** | Model dilarang merespons permintaan yang meminta data privat, kredensial autentikasi, atau instruksi berbahaya (jailbreak). Validasi dilakukan di sisi client sebelum prompt dikirim. | Perlindungan privasi, etika AI, dan kepatuhan terhadap regulasi privasi data pengguna. |

---

## 2. Tabel Risiko dan Mitigasi (Privasi, Biaya & Keandalan)

| Kategori Risiko | Deskripsi Risiko | Dampak | Strategi Mitigasi Terintegrasi |
|---|---|---|---|
| **Privasi Data** | Pengguna secara tidak sengaja atau sengaja mengirimkan data sensitif (NIK, password, token auth). | Kebocoran data pribadi (PII) ke server penyedia LLM cloud pihak ketiga. | 1. Filter input lokal sebelum pengiriman.<br>2. System prompt melarang pemrosesan data PII.<br>3. Catatan internal aplikasi menggunakan UUID anonim tanpa kredensial pengguna. |
| **Keamanan Kredensial API** | API Key bocor akibat di-hardcode ke repositori publik / source code. | Kunci API disalahgunakan pihak tidak berwenang, tagihan membengkak. | 1. Kunci API tidak pernah ditulis langsung di file `.dart`.<br>2. Disimpan menggunakan `FlutterSecureStorage` (Android Keystore / iOS Keychain).<br>3. Pengguna/Developer memasukkan kunci secara dinamis melalui dialog konfigurasi aman. |
| **Lonjakan Biaya (Cost Spike)** | Panggilan berulang tanpa batas atau penyalahgunaan fitur oleh pengguna. | Biaya konsumsi token cloud API melonjak drastis. | 1. Gunakan model hemat biaya `gemini-1.5-flash`.<br>2. Batasan panjang respon (`maxOutputTokens: 200`).<br>3. Tombol kirim dinonaktifkan saat request sedang berlangsung (`isLoading`). |
| **API Error / Rate Limit (HTTP 429)** | Melebihi kuota per menit (RPM/TPM) atau layanan API sedang mengalami gangguan (down). | Pengguna mendapatkan error teknis yang membingungkan atau aplikasi crash. | 1. `AiService` memetakan status HTTP ke pesan bahasa Indonesia yang manusiawi.<br>2. Dialog *Fallback* otomatis muncul menawarkan opsi mode offline / pencarian catatan lokal. |
| **Koneksi Jaringan Terputus** | Pengguna kehilangan koneksi internet saat memanggil asisten AI. | Request gagal (SocketException / ClientException). | 1. Penanganan error koneksi dengan pesan ramah (*"Koneksi jaringan terputus"*).<br>2. Aplikasi tetap dapat berfungsi penuh dalam mode offline untuk fitur catatan lokal. |

---

## 3. Log Interaksi dan Respon AI

Berikut adalah catatan hasil uji coba interaksi antara pengguna dan Asisten AI:

### Log 1: Pertanyaan Seputar Fitur Aplikasi (Normal)
- **Waktu Uji:** 2026-11-09 18:05:12 WIB
- **Model:** Google Gemini 1.5 Flash (`gemini-1.5-flash:generateContent`)
- **System Prompt:** *"Kamu adalah asisten kampus cerdas dan ramah..."*
- **User Prompt:** *"Bagaimana cara menambahkan catatan baru di aplikasi ini?"*
- **Raw Response Code:** `HTTP 200 OK`
- **Output AI:**
  > *"Halo! Untuk menambahkan catatan baru, cukup ketuk tombol tambah bertanda '+' di pojok kanan bawah halaman utama. Masukkan judul catatan Anda, lalu tekan Simpan. Catatan Anda akan tersimpan secara otomatis!"*
- **Evaluasi UX:** Respon ringkas, ramah, selesai dalam 2 kalimat, dan akurat dengan antarmuka aplikasi.

---

### Log 2: Pertanyaan Akademik Umum
- **Waktu Uji:** 2026-11-09 18:07:33 WIB
- **Model:** Google Gemini 1.5 Flash
- **User Prompt:** *"Bagaimana tips mengatur waktu kuliah dan tugas proyek agar tidak terlambat?"*
- **Raw Response Code:** `HTTP 200 OK`
- **Output AI:**
  > *"Bagi proyek besar menjadi tugas-tugas kecil harian dan prioritaskan berdasarkan tenggat waktu terdekat. Manfaatkan fitur catatan di Campus Notify untuk mencatat deadline dan pasang pengingat agar tidak terlewat!"*
- **Evaluasi UX:** Relevan dengan tema aplikasi kampus, tidak bertele-tele, memenuhi batas token.

---

### Log 3: Simulasi Kuota Habis (Rate Limit / HTTP 429) & Fallback
- **Waktu Uji:** 2026-11-09 18:10:05 WIB
- **Skenario:** Request cepat berulang atau kuota API tercapai (`HTTP 429 Too Many Requests`).
- **Penanganan Sistem:**
  1. `AiService` mendeteksi `statusCode == 429`.
  2. Melempar `Exception('Batas kuota harian/menit API tercapai. Silakan coba beberapa saat lagi.')`.
  3. `ChatNotifier` menangkap pesan error dan menambahkan pesan sistem ke daftar percakapan.
  4. `ChatScreen` menampilkan dialog Fallback:
     - **Judul:** *"Layanan AI Sedang Sibuk"*
     - **Isi:** *"Server AI saat ini sedang menerima banyak permintaan atau kuota tercapai. Anda tetap dapat membaca dan mencari catatan kampus Anda secara offline."*
     - **Aksi Pengguna:** Opsi *"Buka Catatan Offline"* (kembali ke beranda) atau *"Coba Lagi"*.
- **Evaluasi UX:** Pengguna tidak menghadapi *white screen* atau *crash*, alur kerja beralih mulus ke fungsionalitas lokal.

---

### Log 4: Penanganan Validasi Kunci API Belum Dikonfigurasi
- **Waktu Uji:** 2026-11-09 18:12:40 WIB
- **Skenario:** Pengguna pertama kali membuka menu chat tanpa memasukkan Gemini API Key.
- **Tampilan UI:**
  - Banner peringatan oranye di bagian atas chat: *"API Key Gemini belum diatur. Klik di sini untuk mengatur kunci API agar fitur asisten aktif."*
  - Mengetuk banner langsung membuka `ApiKeyDialog` dengan input teks terenkripsi (obscure toggle) dan tombol tautan langsung ke Google AI Studio.

---

## 4. Evaluasi Pengalaman Pengguna (UX Evaluation)

1. **Kecepatan & Latensi:** Pemilihan model `gemini-1.5-flash` memberikan latensi respon rata-rata di bawah 1.5 detik, jauh lebih cepat dan hemat token dibanding model LLM berukuran besar.
2. **Indikator Progres:** Saat AI sedang memproses jawaban, muncul bubble loading dengan animasi *typing/thinking* bertuliskan *"Asisten AI sedang berpikir..."* sehingga pengguna memahami sistem sedang bekerja.
3. **Penyimpanan Kunci yang Aman & Ramah Pengguna:** Pengguna tidak dipaksa mengedit file konfigurasi proyek, melainkan dapat mengatur dan mengganti kunci secara aman langsung dari UI aplikasi.
