# Week 08 – Mid Project Review & Code Review

## Praktikum 1 – Hygiene Branch dan Commit

### A. Audit Riwayat Git

Audit dilakukan menggunakan perintah:

```bash
git log --oneline -15
git branch -a
git status
```

Hasil audit menunjukkan bahwa repository menggunakan branch `master`, `develop`, dan `feat/notes-validation`.

Branch `feat/notes-validation` digunakan untuk mengembangkan fitur validasi judul catatan kosong. Pengembangan dilakukan pada feature branch agar perubahan tidak langsung diterapkan pada branch utama.

Berdasarkan riwayat commit, pesan commit yang digunakan sudah memiliki prefix Conventional Commits seperti `feat`, `docs`, dan `refactor`. Namun, beberapa pesan masih dapat diperjelas dengan menambahkan scope yang lebih spesifik.

### B. Simulasi Perbaikan Pesan Commit

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

## Praktikum 2 – Pull Request dan Code Review

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