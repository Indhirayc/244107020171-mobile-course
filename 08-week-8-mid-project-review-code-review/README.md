# 08-week-8-mid-project-review-code-review

## Tujuan

1. Menjelaskan Git Flow dan strategi branching (`main`, `develop`, `feature/*`, `fix/*`);
2. Menulis commit dan Pull Request yang berkualitas dan mudah direview;
3. Melakukan peer code review yang konstruktif dengan checklist terstruktur;
4. Menjalankan static analysis dan formatter (`flutter analyze`, `dart format`) hingga bersih;
5. Menilai kesiapan project tengah semester dan menindaklanjuti hasil review;
6. Memverifikasi saran review dari AI sebelum diterapkan.

---

## Praktikum 1: Hygiene branch dan commit

### A. Audit Riwayat Git

Audit riwayat Git dilakukan pada repository project menggunakan perintah berikut:

```bash
git log --oneline -15
git branch -a
git status
```

Hasil audit menunjukkan bahwa repository menggunakan branch `master`, `develop`, dan `feat/notes-validation`.

Branch `feat/notes-validation` digunakan untuk mengembangkan fitur validasi judul catatan kosong. Pengembangan dilakukan pada feature branch agar perubahan tidak langsung diterapkan pada branch utama (`develop` / `master`).

Berdasarkan riwayat commit, pesan commit yang digunakan sudah memiliki prefix Conventional Commits seperti `feat`, `docs`, dan `refactor`. Namun, beberapa pesan masih dapat diperjelas dengan menambahkan scope yang lebih spesifik.

### B. Simulasi Perbaikan Pesan Commit

Berikut merupakan simulasi penulisan ulang pesan commit lama menjadi format konvensional:

| No. | Pesan Sebelum | Pesan Sesudah |
|---|---|---|
| 1 | `docs: update week 7 README and add practicum screenshots` | `docs(week-7): update README and add practicum screenshots` |
| 2 | `feat: complete week 7 AI challenge, refactoring, and testing` | `feat(week-7): complete AI challenge, refactoring, and tests` |
| 3 | `feat: complete week 7 practical 2 notes domain and data layers` | `feat(notes): implement domain and data layers` |

### C. Alasan Perbaikan

1. **Commit dokumentasi Week 7:** Penambahan scope `week-7` membuat konteks perubahan dokumentasi lebih jelas.
2. **Commit AI Challenge Week 7:** Penambahan scope `week-7` memperjelas bahwa perubahan berkaitan dengan pekerjaan pada Week 7.
3. **Commit Notes Domain dan Data Layer:** Penggunaan scope `notes` membuat fokus perubahan lebih mudah dikenali.

Perubahan tersebut merupakan simulasi penyempurnaan pesan commit. Riwayat commit asli tidak diubah menggunakan `git rebase` atau `git commit --amend`.

### D. Hasil Pengembangan Branch

Fitur validasi judul catatan kosong dikembangkan pada branch `feat/notes-validation`.

Perubahan yang dilakukan:
- Menolak judul catatan yang kosong atau hanya berisi spasi.
- Menghapus spasi di awal dan akhir judul menggunakan `trim()`.
- Menambahkan pengujian untuk validasi judul kosong, judul berisi spasi, dan judul valid.

Pesan commit yang digunakan:

```text
feat(notes): validate empty titles and add tests
```

Branch berhasil dikirim ke remote repository menggunakan:

```bash
git push -u origin feat/notes-validation
```

Hasil push menunjukkan bahwa branch `feat/notes-validation` berhasil dibuat pada remote repository dan telah terhubung dengan `origin/feat/notes-validation`.

---

## Praktikum 2: PR dan peer review

### A. Pembuatan Pull Request

Membuat Pull Request (PR) dari branch `feat/notes-validation` menuju branch `develop`.

- **Nomor PR:** #1
- **Judul:** `feat(notes): validasi judul kosong + test`
- **Base branch:** `develop`
- **Feature branch:** `feat/notes-validation`

PR dibuat untuk mengatasi permasalahan pengguna yang dapat menyimpan catatan dengan judul kosong atau hanya berisi spasi.

### B. Self-Review

Melakukan review secara mandiri terhadap perubahan pada PR #1.

Temuan review meliputi:
1. **Kebenaran input:** Judul kosong dan hanya berisi spasi harus menghasilkan `LocalFailure`.
2. **Kebenaran hasil:** Hasil sukses maupun failure dari repository harus diteruskan kepada pemanggil.
3. **Arsitektur:** Validasi judul perlu ditempatkan pada Domain Layer, bukan Data Layer.
4. **Test:** Pengujian perlu memeriksa perilaku Use Case secara langsung.
5. **Keterbacaan:** Struktur kode perlu dirapikan agar konsisten.

Keputusan self-review awal: **Request Changes**.

### C. Perbaikan Hasil Review

Melakukan perbaikan berdasarkan temuan self-review:

- Membuat Use Case `AddNote` pada Domain Layer.
- Memindahkan validasi judul kosong ke Use Case `AddNote`.
- Memperbarui `notes_providers.dart` dengan `addNoteProvider`.
- Memperbarui `notes_page.dart` agar menggunakan Use Case `AddNote`.
- Menghapus validasi judul dari `NoteRepositoryImpl`.
- Membuat unit test `add_note_test.dart` untuk menguji validasi dan hasil operasi.
- Menghapus `note_validation_test.dart` yang hanya menguji ekspresi `trim()`.

### D. Pengujian

Hasil pengujian setelah perbaikan:

| Pengujian | Hasil |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test test/add_note_test.dart` | 4 tests passed |
| `flutter test` | 20 tests passed |

### E. Merge dan Sinkronisasi Branch

- Melakukan push perubahan ke `feat/notes-validation`.
- Memperbarui PR #1 dengan hasil perbaikan.
- Melakukan Squash and Merge menuju `develop`.
- Menghapus branch remote dan lokal `feat/notes-validation`.
- Melakukan `git pull origin develop`.
- Memastikan branch lokal sudah sinkron dengan `origin/develop`.
- Memastikan working tree bersih.

**Status akhir:** PR #1 berhasil di-merge dan perubahan sudah tersedia pada branch `develop`.

---

## Praktikum 3: Static analysis dan mid review

### A. Static Analysis

Melakukan pemeriksaan kualitas kode Flutter menggunakan tiga perintah berikut:

```bash
flutter analyze
dart format --set-exit-if-changed lib test
flutter test
```

Hasil pemeriksaan:

| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze` | No issues found! |
| `dart format --set-exit-if-changed lib test` | 33 files formatted, 0 changed pada pemeriksaan ulang |
| `flutter test` | 20 tests passed |

Pada pemeriksaan format pertama, ditemukan 23 file yang perlu diformat dari total 33 file. Setelah proses formatting, pemeriksaan ulang menunjukkan seluruh file sudah sesuai format.

### B. Konfigurasi Continuous Integration (CI)

Membuat workflow GitHub Actions pada file:

```text
.github/workflows/ci.yml
```

Workflow dikonfigurasi untuk berjalan ketika terdapat Pull Request dengan tahapan:
1. Mengambil kode repository menggunakan `actions/checkout@v4`.
2. Menyiapkan Flutter menggunakan `subosito/flutter-action@v2`.
3. Menjalankan `dart format --set-exit-if-changed lib test`.
4. Menjalankan `flutter analyze`.
5. Menjalankan `flutter test`.

Workflow menggunakan working directory:

```text
07-week-7-clean-architecture/campus_notify
```

Konfigurasi CI berhasil di-commit dan di-push ke branch `develop`.

Pesan commit:

```text
ci: add Flutter analyze and test workflow
ci: enforce Dart formatting in workflow
```

**Catatan:** Workflow sudah dibuat dan dikirim ke GitHub, tetapi belum diverifikasi melalui Pull Request sehingga status eksekusi GitHub Actions belum dapat dinyatakan berhasil.

### C. Hasil Mid Project Review

Berdasarkan pemeriksaan proyek, beberapa aspek yang telah dicapai adalah:

- Struktur proyek menggunakan pendekatan Feature-First dan Clean Architecture.
- Static analysis berhasil tanpa masalah (`No issues found!`).
- Seluruh 20 unit test berhasil dijalankan.
- Format kode Dart sudah diperiksa dan diperbaiki.
- Pull Request #1 berhasil di-merge melalui Squash and Merge.
- Konfigurasi GitHub Actions sudah tersedia pada repository.

Aspek dokumentasi README, screenshot praktikum, dan peta issue/PR perlu diperiksa kembali untuk memastikan seluruh kebutuhan mid-project review terpenuhi.

### D. Riwayat Commit Week 08

| Commit | Pesan |
|---|---|
| `01bf722` | `style(week-7): format Dart source and tests` |
| `eb4f8ee` | `ci: add Flutter analyze and test workflow` |

### E. Evaluasi Ukuran Pull Request

PR #1 (`feat(notes): validate note titles and add tests`) memiliki statistik perubahan:

- 6 file berubah.
- 310 baris ditambahkan.
- 6 baris dihapus.
- Total perubahan: 316 baris.

PR tersebut melewati batas 300 baris yang direkomendasikan dalam Refactoring Challenge. Namun, perubahan masih berfokus pada satu fitur, yaitu validasi judul catatan.

**Keputusan:** PR tidak dipecah karena sudah di-merge. Untuk pengembangan berikutnya, perubahan fitur, pengujian, dan dokumentasi akan direncanakan menjadi PR yang lebih kecil agar proses review lebih mudah.

---

## AI Challenge

Dokumentasi lengkap hasil pengujian dan verifikasi AI Challenge tersimpan secara terpisah pada file [docs/ai-review-vs-keputusan.md](docs/ai-review-vs-keputusan.md).

### 1. Agent yang Dipakai

GitHub Copilot

### 2. Prompt yang Digunakan

**Prompt 1 – Review PR**

```text
Review perubahan pada PR ini sebagai senior Flutter developer.
Fokus pada correctness, Clean Architecture, dan testing.
Abaikan masalah style.
Berikan maksimal 5 temuan beserta alasan teknis dan saran perbaikan.
Jangan mengarang bug.
```

**Prompt 2 – Review Lanjutan**

```text
Lakukan review ulang terhadap PR #1.
Cari maksimal 3 potensi masalah tambahan pada correctness,
Clean Architecture, atau testing.
Periksa juga apakah ada temuan yang sebenarnya bukan bug.
Jangan mengulang dua temuan sebelumnya.
Jangan mengarang masalah yang tidak didukung kode.
```

### 3. Ringkasan Temuan GitHub Copilot

1. **P2 – Tap berulang pada tombol Simpan dapat membuat catatan duplikat.** Tombol masih aktif ketika proses penyimpanan berlangsung.
2. **P3 – Menutup dialog saat submit berjalan dapat membuat daftar tidak diperbarui.** Pemeriksaan `dialogContext.mounted` dapat menghentikan callback sebelum `notesProvider` di-invalidate.
3. **P3 – Feedback validasi kemungkinan tertutup dialog.** Pesan validasi ditampilkan melalui `ScaffoldMessenger` dari halaman di belakang dialog.

### 4. Verifikasi dan Keputusan Developer

| No. | Temuan AI | Bukti Verifikasi | Keputusan |
|---|---|---|---|
| 1 | Tap berulang menyebabkan duplikat | Tombol Simpan belum memiliki status `isSaving` dan tidak dinonaktifkan selama operasi async. | Diterima |
| 2 | Dialog ditutup saat submit menyebabkan daftar tidak diperbarui | Pemeriksaan `dialogContext.mounted` menghentikan callback sebelum invalidasi provider jika dialog sudah ditutup. | Diterima |
| 3 | Feedback validasi kemungkinan tertutup dialog | Pengujian manual dengan judul kosong menunjukkan notifikasi "Judul catatan tidak boleh kosong" tetap terlihat. | Ditolak |

### 5. Bukti Pengujian

| Pengujian | Hasil |
|---|---|
| `flutter test test/add_note_test.dart` | 4 tes berhasil |
| `flutter analyze` | No issues found |
| Pengujian manual judul kosong | Notifikasi validasi terlihat |

Catatan: Pengujian otomatis yang tersedia belum mencakup skenario tap berulang maupun penutupan dialog saat operasi penyimpanan berlangsung.

---

## Refactoring, testing, dan error umum

### A. Refactoring Challenge

#### 1. Review dan Perbaikan Pull Request

PR yang digunakan sebagai objek evaluasi:
- **PR:** #1
- **Judul:** `feat(notes): validasi judul kosong + test`
- **Base branch:** `develop`
- **Feature branch:** `feat/notes-validation`
- **Status:** Merged

Perbaikan yang dilakukan berdasarkan proses review:
1. Memindahkan validasi judul kosong ke Domain Layer melalui Use Case `AddNote`.
2. Memperbarui `notes_providers.dart` dengan `addNoteProvider`.
3. Memperbarui `notes_page.dart` agar menggunakan Use Case.
4. Menambahkan unit test pada `add_note_test.dart`.

Catatan: Review yang dilakukan merupakan self-review, belum peer review dengan minimal tiga komentar bermakna hingga status Approve.

#### 2. Otomatisasi Pemeriksaan Kualitas Kode

Menerapkan Dart Formatter dan GitHub Actions untuk mengotomatisasi pemeriksaan kualitas kode.

File konfigurasi: `.github/workflows/ci.yml`

```yaml
name: ci

on: [pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: 07-week-7-clean-architecture/campus_notify

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - run: dart format --set-exit-if-changed lib test

      - run: flutter analyze

      - run: flutter test
```

Pemeriksaan yang diterapkan:
- `dart format --set-exit-if-changed lib test`
- `flutter analyze`
- `flutter test`

Commit terkait:

| Commit | Pesan |
|---|---|
| `eb4f8ee` | `ci: add Flutter analyze and test workflow` |
| `61b7ec7` | `ci: enforce Dart formatting in workflow` |

Catatan: Konfigurasi sudah di-push ke `develop`, tetapi eksekusi GitHub Actions melalui Pull Request belum diverifikasi.

#### 3. Evaluasi Ukuran Pull Request

Pemeriksaan ukuran PR #1 menggunakan perintah:

```bash
git --no-pager show --stat --oneline f4a3fa0
```

Hasil pemeriksaan:

| Keterangan | Jumlah |
|---|---:|
| File berubah | 6 |
| Baris ditambahkan | 310 |
| Baris dihapus | 6 |
| Total perubahan | 316 |

PR #1 melewati batas 300 baris yang direkomendasikan dalam Refactoring Challenge. Perubahan mencakup Data Layer, Domain Layer, Presentation Layer, unit test, dan dokumentasi.

Keputusan: PR tidak dipecah karena sudah di-merge. Pada pengembangan berikutnya, perubahan akan direncanakan menjadi PR yang lebih kecil dan berurutan agar lebih mudah direview.

### B. Testing dan Verifikasi

Pengujian dilakukan pada direktori aplikasi: `07-week-7-clean-architecture/campus_notify`

#### 1. Static Analysis

Perintah:

```bash
flutter analyze
```

Hasil:

```text
No issues found!
```

#### 2. Dart Formatter

Perintah:

```bash
dart format --set-exit-if-changed lib test
```

Hasil pemeriksaan ulang:

```text
Formatted 33 files (0 changed).
```

#### 3. Automated Testing

Perintah:

```bash
flutter test
```

Hasil:

```text
00:04 +20: All tests passed!
```

#### 4. Manual Testing

Pengujian dilakukan dengan mencoba menyimpan catatan tanpa mengisi judul.

Hasil:
- Aplikasi menolak penyimpanan catatan dengan judul kosong.
- Notifikasi `Judul catatan tidak boleh kosong` ditampilkan.
- Dialog tetap terbuka sehingga pengguna dapat memperbaiki input.

Catatan: Pengujian manual terhadap skenario tap berulang dan penutupan dialog ketika proses penyimpanan berlangsung belum dilakukan.

### C. Error Umum dan Solusi

| Permasalahan | Solusi |
|---|---|
| `flutter run` menghasilkan error `No pubspec.yaml file found` | Masuk ke direktori `07-week-7-clean-architecture/campus_notify` sebelum menjalankan perintah Flutter. |
| `dart format --set-exit-if-changed .` mengalami error pada folder build | Batasi pemeriksaan pada direktori `lib` dan `test`. |
| CI belum memeriksa format kode | Tambahkan perintah `dart format --set-exit-if-changed lib test` pada workflow. |
| PR memiliki lebih dari 300 baris perubahan | Evaluasi pemisahan perubahan menjadi beberapa PR kecil pada pengembangan berikutnya. |

### D. Checklist Verifikasi Mandiri

| No. | Checklist | Status |
|---|---|---|
| 1 | Branch dibuat dari `develop` dan PR berfokus pada satu fitur | Selesai |
| 2 | Issue ditutup melalui PR | Belum diverifikasi |
| 3 | Minimal 3 komentar review bermakna ditindaklanjuti hingga Approve | Belum |
| 4 | `flutter analyze` bersih | Selesai |
| 5 | `dart format` rapi | Selesai |
| 6 | `flutter test` berhasil | Selesai |
| 7 | Tabel usulan AI dan keputusan final terdokumentasi di `docs/` | Selesai |

---

## Mini project / Industry Challenge

1. Buat minimal 1 issue + 1 PR kecil yang di-merge via review sejawat (branch feature/* → develop).
2. Sertakan template PR lengkap: masalah, solusi, cara uji, dan screenshot.
3. Bukti mesin hijau: hasil flutter analyze + flutter test di README.
4. Dokumentasikan prompt AI, tabel usulan-vs-keputusan-final, dan bukti penolakan/penerimaan di docs/.
5. Push ke folder portfolio 08-week-8-mid-project-review/ dengan struktur docs/, README.md, dan screenshots/. README menjelaskan status paruh semester, peta issue/PR, fitur utama, stack teknologi, cara menjalankan, dan hasil yang dicapai.

---

## Refleksi

1. **Apa beda LGTM buta dengan approve yang bertanggung jawab? Apa risikonya bagi tim?**

   **Jawaban:** LGTM (*Looks Good To Me*) buta adalah memberikan persetujuan terhadap kode tanpa memeriksa perubahan, menjalankan aplikasi, atau melakukan pengujian. Sementara itu, *approve* yang bertanggung jawab dilakukan setelah reviewer memahami perubahan kode, memeriksa kesesuaian arsitektur, dan memastikan fitur berjalan sesuai kebutuhan.

   Risiko LGTM buta bagi tim adalah bug dapat masuk ke branch utama, kualitas kode menurun, dan masalah yang seharusnya ditemukan saat review justru muncul ketika aplikasi digunakan.

2. **Kapan komentar wajib berstatus Request Changes, dan kapan cukup saran?**

   **Jawaban:** Komentar wajib berstatus Request Changes apabila ditemukan masalah serius yang memengaruhi kebenaran fungsi, keamanan, arsitektur, atau menyebabkan fitur tidak berjalan sesuai kebutuhan.

   Sementara itu, komentar cukup berupa saran apabila masalahnya tidak menghambat fungsi utama, seperti alternatif penulisan kode, peningkatan keterbacaan, atau optimasi kecil yang tidak mendesak.

3. **Bagian mana dari review AI yang ditolak atau disederhanakan, dan mengapa?**

   **Jawaban:** Pada review menggunakan GitHub Copilot terhadap PR #1, terdapat tiga temuan. Dua temuan diterima, yaitu kemungkinan penyimpanan catatan duplikat akibat tombol Simpan ditekan berulang kali dan kemungkinan daftar catatan tidak diperbarui ketika dialog ditutup saat proses penyimpanan berlangsung.

   Satu temuan ditolak, yaitu kemungkinan pesan validasi tertutup oleh dialog. Setelah dilakukan pengujian manual dengan memasukkan judul kosong, notifikasi "Judul catatan tidak boleh kosong" ternyata tetap terlihat. Oleh karena itu, temuan tersebut tidak terbukti sebagai masalah pada aplikasi.

4. **Satu hal konkret yang diperbaiki setelah review — apa dampaknya?**

   **Jawaban:** Salah satu perbaikan konkret pada PR #1 adalah memindahkan validasi judul catatan kosong dari Data Layer ke Domain Layer melalui Use Case AddNote.

   Perubahan tersebut membuat tanggung jawab validasi berada pada lapisan yang tepat sesuai prinsip Clean Architecture. Selain itu, pengujian menjadi lebih terarah karena perilaku validasi dapat diuji langsung melalui Use Case menggunakan Fake Repository.

---

## Kesimpulan

Berdasarkan kegiatan Week 08 – Mid Project Review & Code Review, dapat disimpulkan bahwa proses pengembangan aplikasi Flutter tidak hanya berfokus pada implementasi fitur, tetapi juga memperhatikan kualitas kode, struktur arsitektur, pengujian, dan pengelolaan kolaborasi menggunakan Git dan GitHub.

Melalui kegiatan ini, saya mempelajari penerapan Conventional Commits, pengelolaan branch, serta proses Pull Request dan code review. Saya juga melakukan evaluasi terhadap penerapan Clean Architecture dengan memindahkan validasi judul catatan ke Domain Layer melalui Use Case AddNote.

Selain itu, penggunaan GitHub Copilot membantu menemukan potensi masalah pada kode, tetapi setiap rekomendasi AI tetap perlu diverifikasi melalui pemeriksaan kode dan pengujian manual. Pemeriksaan menggunakan `flutter analyze`, Dart Formatter, dan `flutter test` juga membantu memastikan kualitas serta konsistensi kode.

Secara keseluruhan, kegiatan ini memberikan pemahaman bahwa pengembangan aplikasi yang baik membutuhkan kode yang terstruktur, pengujian yang memadai, dokumentasi yang jelas, serta proses review yang bertanggung jawab.

