# AI Review vs Keputusan Developer

## 1. Tujuan

Melakukan review kode menggunakan GitHub Copilot sebagai alat bantu untuk menemukan potensi masalah pada PR #1. Seluruh temuan AI diverifikasi kembali oleh developer sebelum diterima atau ditolak.

## 2. Prompt yang Digunakan

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

## 3. Hasil Review GitHub Copilot

Copilot menemukan tiga potensi masalah:

1. **P2 – Tap berulang pada tombol Simpan dapat membuat catatan duplikat.** Tombol masih aktif ketika proses penyimpanan berlangsung.
2. **P3 – Menutup dialog saat submit berjalan dapat membuat daftar tidak diperbarui.** Pemeriksaan `dialogContext.mounted` dapat menghentikan callback sebelum `notesProvider` di-invalidate.
3. **P3 – Feedback validasi kemungkinan tertutup dialog.** Pesan validasi ditampilkan melalui `ScaffoldMessenger` dari halaman di belakang dialog.

## 4. Verifikasi dan Keputusan Developer

| No. | Temuan AI | Bukti Verifikasi | Keputusan |
|---|---|---|---|
| 1 | Tap berulang menyebabkan duplikat | Tombol Simpan belum memiliki status `isSaving` dan tidak dinonaktifkan selama operasi async. | Diterima |
| 2 | Dialog ditutup saat submit menyebabkan daftar tidak diperbarui | Pemeriksaan `dialogContext.mounted` menghentikan callback sebelum invalidasi provider jika dialog sudah ditutup. | Diterima |
| 3 | Feedback validasi kemungkinan tertutup dialog | Pengujian manual dengan judul kosong menunjukkan notifikasi "Judul catatan tidak boleh kosong" tetap terlihat. | Ditolak |

## 5. Bukti Pengujian

Pengujian yang telah dilakukan:

| Pengujian | Hasil |
|---|---|
| `flutter test test/add_note_test.dart` | 4 tes berhasil |
| `flutter analyze` | No issues found |
| Pengujian manual judul kosong | Notifikasi validasi terlihat |

Catatan: Pengujian otomatis yang tersedia belum mencakup skenario tap berulang maupun penutupan dialog saat operasi penyimpanan berlangsung.

