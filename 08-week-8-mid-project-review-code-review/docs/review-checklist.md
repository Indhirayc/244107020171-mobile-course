# Review Checklist & Mid-Project Review

Dokumen ini memuat audit commit, checklist code review Pull Request, evaluasi kesiapan mid-project, dan checklist verifikasi mandiri untuk Week 08.

---

## 1. Audit Riwayat Git & Simulasi Perbaikan Commit

### A. Audit Riwayat Git

Perintah audit yang dijalankan:

```bash
git log --oneline -15
git branch -a
git status
```

- **Branch aktif repository:** `master`, `develop`, dan `feat/notes-validation`.
- **Branch pengembangan:** `feat/notes-validation` digunakan untuk mengembangkan fitur validasi judul catatan kosong agar terisolasi dari branch utama.
- **Evaluasi Conventional Commits:** Sebagian besar commit sudah menggunakan prefix konvensional (`feat`, `docs`, `refactor`), namun dapat ditingkatkan dengan penambahan scope yang spesifik.

### B. Simulasi Penulisan Ulang Pesan Commit

| No. | Pesan Sebelum | Pesan Sesudah | Alasan Perbaikan |
|---|---|---|---|
| 1 | `docs: update week 7 README and add practicum screenshots` | `docs(week-7): update README and add practicum screenshots` | Penambahan scope `week-7` memperjelas konteks pembaruan dokumentasi. |
| 2 | `feat: complete week 7 AI challenge, refactoring, and testing` | `feat(week-7): complete AI challenge, refactoring, and tests` | Penambahan scope `week-7` memperjelas bahwa pekerjaan berkaitan dengan modul Week 7. |
| 3 | `feat: complete week 7 practical 2 notes domain and data layers` | `feat(notes): implement domain and data layers` | Penambahan scope `notes` membuat fokus perubahan fitur lebih mudah diidentifikasi. |

*Catatan: Perubahan di atas merupakan simulasi. Riwayat commit lama pada Git tidak diubah menggunakan rebase atau amend.*

---

## 2. Checklist Self-Review Pull Request #1

Informasi Pull Request:
- **PR:** #1
- **Judul:** `feat(notes): validasi judul kosong + test`
- **Base branch:** `develop`
- **Feature branch:** `feat/notes-validation`

### A. Checklist Temuan Review

| Kategori | Temuan Review | Tindak Lanjut / Solusi |
|---|---|---|
| **Kebenaran Input** | Judul kosong atau hanya spasi harus menghasilkan failure | Menambahkan validasi `trim().isEmpty` menghasilkan `LocalFailure` |
| **Kebenaran Hasil** | Hasil operasi (sukses/failure) harus diteruskan ke caller | Use case mengembalikan record `({Note? note, Failure? failure})` |
| **Arsitektur** | Validasi judul berada di Data Layer (melanggar Clean Architecture) | Memindahkan validasi ke Domain Layer melalui Use Case `AddNote` |
| **Testing** | Pengujian hanya menguji fungsi trim, bukan alur use case | Menghapus pengujian lama, membuat unit test `add_note_test.dart` (4 skenario) |
| **Keterbacaan** | Struktur kode dan provider perlu dirapikan | Menambahkan `addNoteProvider` di `notes_providers.dart` dan merapikan pemanggilan di `notes_page.dart` |

- **Keputusan Review Awal:** Request Changes.
- **Keputusan Setelah Refactoring:** Approve dan di-merge ke branch `develop` via Squash and Merge.

---

## 3. Hasil Evaluasi Kesiapan Mid-Project Review

Pemeriksaan kesiapan proyek paruh semester pada direktori `07-week-7-clean-architecture/campus_notify`:

| Aspek Pemeriksaan | Target / Standar | Hasil Pemeriksaan | Status |
|---|---|---|:---:|
| **Arsitektur** | Feature-first Clean Architecture (Domain, Data, Presentation) | Struktur folder `features/notes` dan `features/auth` terpisah layer-nya | Memenuhi |
| **Static Analysis** | `flutter analyze` bersih (0 error, 0 warning, 0 info) | `No issues found!` | Memenuhi |
| **Dart Formatter** | `dart format --set-exit-if-changed lib test` | 33 files formatted, 0 changed pada re-check | Memenuhi |
| **Automated Test** | `flutter test` hijau | 20 tests passed (termasuk 4 pengujian `AddNote`) | Memenuhi |
| **Pull Request** | PR kecil terfokus pada satu fitur dan di-merge ke `develop` | PR #1 di-merge via Squash and Merge | Memenuhi |
| **Automasi CI** | Workflow GitHub Actions `.github/workflows/ci.yml` | Workflow menjalankan format, analyze, dan test | Memenuhi |

### Evaluasi Ukuran Pull Request #1

- **Jumlah file berubah:** 6 file
- **Baris ditambahkan:** +310
- **Baris dihapus:** -6
- **Total perubahan:** 316 baris
- **Catatan Evaluasi:** Ukuran PR melewati ambang batas rekomendasi 300 baris karena mencakup implementasi Use Case, penyesuaian UI & provider, serta penambahan unit test. Karena PR sudah di-merge, perbaikan di masa mendatang dilakukan dengan membagi PR menjadi unit kerja yang lebih granular (< 300 baris).

---

## 4. Checklist Verifikasi Mandiri

| No. | Item Pemeriksaan | Bukti / Catatan | Status |
|---|---|---|:---:|
| 1 | Branch dibuat dari `develop` dan PR berfokus pada satu fitur | Branch `feat/notes-validation` menuju `develop` | Selesai |
| 2 | Issue ditutup melalui PR | Integrasi issue tracking pada PR description | Belum diverifikasi |
| 3 | Minimal 3 komentar review bermakna ditindaklanjuti hingga Approve | Self-review mencatat 5 temuan dan perbaikan mandiri | Belum (peer review) |
| 4 | `flutter analyze` bersih | `No issues found!` | Selesai |
| 5 | `dart format` rapi | 33 files checked, 0 changed | Selesai |
| 6 | `flutter test` berhasil | 20 unit tests passed | Selesai |
| 7 | Tabel usulan AI dan keputusan final terdokumentasi di `docs/` | Terdokumentasi pada `docs/ai-review-vs-keputusan.md` | Selesai |
