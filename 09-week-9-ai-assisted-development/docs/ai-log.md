# Log AI-Assisted Development – Week 09

Dokumen ini mencatat seluruh siklus *AI-assisted development* (**Prompt → Generate → Verify → Test → Refactor → Explain**) pada penambahan fitur **Pencarian Catatan (*Search Notes by Title*)** dan **Empty State** pada aplikasi Offline Notes.

---

## 1. Prompt Engineering (Formula 5 Slot)

### A. Struktur 5 Slot Prompt

Penyusunan prompt dilakukan dengan mengisi 5 slot spesifik agar AI menghasilkan kode yang presisi, aman, dan mematuhi batasan arsitektur:

| Slot | Parameter | Isi Konteks |
|---|---|---|
| **Peran (*Role*)** | Senior Flutter Developer | Berpengalaman dalam arsitektur Flutter, Riverpod, dan SQLite. |
| **Konteks (*Context*)** | Project Offline Notes | Menggunakan Flutter 3.x, `flutter_riverpod: ^3.4.3`, `sqflite: ^2.4.4`, repository pattern (`NoteRepository`, `Note`, `notesProvider` di `lib/pages/notes_page.dart`). |
| **Tugas (*Task*)** | Fitur Search + Empty State | Tambahkan fitur pencarian catatan berdasarkan judul (`searchNotes(String query)`) dan *empty state* informatif jika hasil pencarian tidak ditemukan. |
| **Batas (*Constraints*)** | Arsitektur & Kerapian | Jangan panggil query SQLite langsung dari widget (harus melalui `NoteRepository`), hindari bug *case-sensitive*, jangan ubah struktur dasar, dan batasi penambahan kode maksimal 80 baris. |
| **Output (*Deliverables*)** | Kode + Test + Uji | Potongan kode repository, provider, integrasi UI search bar + empty state, 3 skenario unit test, dan panduan pengujian manual. |

### B. Prompt Lengkap yang Digunakan

```text
Peran: Senior Flutter Developer
Konteks: Project Flutter Offline Notes menggunakan Riverpod 3.x (flutter_riverpod), SQLite (sqflite), dan repository pattern (NoteRepository, model Note, notesProvider di lib/pages/notes_page.dart).
Tugas: Tambahkan fitur pencarian catatan berdasarkan judul (search notes) beserta penanganan empty state ketika hasil pencarian tidak ditemukan.
Batas:
1. Jangan panggil SQLite langsung dari widget (akses data wajib melalui NoteRepository).
2. Hindari bug case-sensitive pada pencarian judul.
3. Jangan ubah arsitektur dasar dan batasi perubahan kode di bawah 80 baris.
4. Jangan sertakan secret/token atau dependensi eksternal yang tidak diperlukan.
Output:
1. Potongan kode penambahan method di NoteRepository.
2. Provider Riverpod dan integrasi SearchBar + Empty State pada NotesPage.
3. 3 skenario unit test (pencarian cocok, case-insensitive, dan kata kunci tidak ditemukan).
4. Langkah pengujian manual.
```

### C. Perbandingan Prompt Buruk vs Prompt Baik

- **Prompt Buruk:**
  > *"Buatkan search notes yang keren di Flutter."*
  > **Dampak:** AI cenderung menghasilkan kode sembarangan: menaruh query SQL mentah di dalam widget `build()`, menggunakan state management yang berbeda (misal `setState` atau `Bloc`), tidak menangani empty state, serta tidak menyediakan pengujian otomatis.

- **Prompt Baik (5 Slot):**
  > Menetapkan peran, konteks library (`sqflite`, `flutter_riverpod: ^3.4.3`), tugas eksplisit, batasan arsitektur, serta permintaan test case yang terukur. Hasilnya mudah diverifikasi dan tidak merusak kode yang sudah ada.

---

## 2. Output Awal AI (Hasil Generate)

Berikut adalah usulan awal yang dihasilkan oleh AI Assistant:

```dart
// 1. Usulan penambahan di NoteRepository
Future<List<Note>> searchNotes(String query) async {
  final db = await _openDb();
  final rows = await db.query(
    'notes',
    where: 'title LIKE ?',
    whereArgs: ['%$query%'],
    orderBy: 'updated_at DESC',
  );
  return rows.map(Note.fromMap).toList();
}

// 2. Usulan provider di notes_page.dart (Menggunakan Riverpod StateProvider lama)
final searchQueryProvider = StateProvider<String>((ref) => '');

final notesProvider = FutureProvider<List<Note>>((ref) {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(noteRepositoryProvider).searchNotes(query);
});

// 3. Usulan widget UI
class NotesPage extends ConsumerStatefulWidget { ... }
class _NotesPageState extends ConsumerState<NotesPage> {
  // AI mengusulkan method build dengan signature:
  @override
  Widget build(BuildContext context, WidgetRef ref) { ... }
}
```

---

## 3. Evaluasi & Deteksi Halusinasi (Verify)

Setiap baris kode usulan AI ditelaah secara kritis dengan acuan kode sumber dan package versi terkini:

| No. | Aspek Evaluasi | Temuan & Analisis Halusinasi | Tindakan / Keputusan |
|---|---|---|---|
| 1 | **Package Kadaluarsa (*Riverpod 3.x API*)** | AI mengusulkan `StateProvider<String>((ref) => '')`. Pada `flutter_riverpod: ^3.4.3`, `StateProvider` telah ditinggalkan/dihapus demi konsistensi arsitektur. | **Ditolak & Direfactor:** Diganti dengan `NotifierProvider<SearchQueryNotifier, String>` menggunakan kelas `Notifier` resmi. |
| 2 | **Signature Lifecycle Flutter Salah** | AI menulis `@override Widget build(BuildContext context, WidgetRef ref)` di dalam kelas yang mewarisi `ConsumerState<NotesPage>`. Padahal pada `ConsumerState`, `ref` adalah properti bawaan (*class property*) dan `build` hanya menerima satu argumen `(BuildContext context)`. | **Ditolak & Diperbaiki:** Signature diubah menjadi `Widget build(BuildContext context)`. |
| 3 | **Penanganan Input String Kosong/Spasi** | AI mengoper `query` langsung ke SQL `%$query%`. Jika pengguna hanya mengetikkan spasi atau menghapus input, query menjadi `%%` dan memicu filter SQL yang kurang efisien. | **Diterima dengan Perbaikan:** Menambahkan `final trimmed = query.trim(); if (trimmed.isEmpty) return fetchNotes();` agar langsung mengembalikan seluruh catatan tanpa filter LIKE. |
| 4 | **Pembedaan UX Empty State** | AI awalnya hanya mengusulkan satu teks *"Belum ada catatan"* baik saat database kosong maupun saat kata kunci pencarian tidak ditemukan. | **Ditingkatkan (*Refactor*):** Membedakan tampilan: jika sedang mencari dan hasil nihil, tampilkan pesan informatif `Catatan dengan judul "$query" tidak ditemukan.` beserta icon `Icons.search_off`. |
| 5 | **Tombol Reset Search (*Clear Button*)** | AI tidak menyertakan tombol pembersih input search pada suffix TextField. | **Ditambahkan:** Menambahkan icon button `Icons.clear` yang membersihkan controller dan memanggil `clear()` pada notifier. |

---

## 4. Refactoring & Integrasi Kode Final

### A. Penambahan Method Repository (`lib/data/repositories/note_repository.dart`)

```dart
  Future<List<Note>> searchNotes(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return fetchNotes();
    }
    final db = await _openDb();
    final rows = await db.query(
      'notes',
      where: 'title LIKE ?',
      whereArgs: ['%$trimmed%'],
      orderBy: 'updated_at DESC',
    );
    return rows.map(Note.fromMap).toList();
  }
```

### B. Notifier & State Provider (`lib/pages/notes_page.dart`)

```dart
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final notesProvider = FutureProvider<List<Note>>(
  (ref) {
    final query = ref.watch(searchQueryProvider);
    return ref.watch(noteRepositoryProvider).searchNotes(query);
  },
);
```

### C. Komponen Search Bar & Empty State UI

```dart
// TextField Pencarian
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: TextField(
    controller: _searchController,
    decoration: InputDecoration(
      hintText: 'Cari judul catatan...',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).clear();
              },
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    onChanged: (value) {
      ref.read(searchQueryProvider.notifier).setQuery(value);
    },
  ),
),

// Penanganan Empty State
notes.isEmpty
    ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              query.isNotEmpty
                  ? Icons.search_off
                  : Icons.note_alt_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              query.isNotEmpty
                  ? 'Catatan dengan judul "$query" tidak ditemukan.'
                  : 'Belum ada catatan.',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
    : ListView.builder(...);
```

---

## 5. Bukti Pengujian & Verifikasi Mesin (Test)

### A. Unit Testing (`test/note_test.dart`)

Empat skenario pengujian spesifik untuk fitur search dan empty state ditambahkan ke unit test:
1. `searchNotes menemukan catatan yang cocok berdasarkan judul (partial match)`
2. `searchNotes bersifat case-insensitive`
3. `searchNotes mengembalikan list kosong (empty state) jika query tidak cocok`
4. `provider notesProvider reaktif terhadap perubahan searchQueryProvider`

Eksekusi perintah:
```bash
flutter test
```

Output:
```text
00:00 +0: fromMap aman terhadap field yang hilang
00:00 +1: flag dirty bertahan pada serialisasi
00:00 +2: provider sukses dengan repository palsu
00:00 +3: provider error dengan repository palsu
00:00 +4: searchNotes menemukan catatan yang cocok berdasarkan judul (partial match)
00:00 +5: searchNotes bersifat case-insensitive
00:00 +6: searchNotes mengembalikan list kosong (empty state) jika query tidak cocok
00:00 +7: provider notesProvider reaktif terhadap perubahan searchQueryProvider
00:00 +8: All tests passed!
```
**Status: 8 tests passed (100% lulus)**.

### B. Static Analysis

Eksekusi perintah:
```bash
flutter analyze
```

Output:
```text
Analyzing 09-week-9-ai-assisted-development...                  
No issues found! (ran in 3.7s)
```
**Status: Bersih (0 error, 0 warning, 0 info)**.

### C. Dart Formatter

Eksekusi perintah:
```bash
dart format --set-exit-if-changed lib test
```

Output:
```text
Formatted 19 files (0 changed) in 0.04 seconds.
```
**Status: Konsisten dan rapi**.

---

## 6. Penjelasan Mandiri (Explain)

1. **Mengapa `Notifier` lebih tepat dibanding `StateProvider`?**
   Pada ekosistem Riverpod modern (versi 3.x), `Notifier` dan `NotifierProvider` menyediakan enkapsulasi logika mutasi state yang lebih bersih (melalui method `setQuery` dan `clear`), sehingga widget tidak mengubah state secara langsung dari luar (`state = ...`).
2. **Bagaimana integritas repository terjaga?**
   Widget UI tidak pernah menjalankan query SQL mentah. UI hanya berinteraksi melalui `notesProvider` dan `searchQueryProvider`. Lapisan data (`NoteRepository`) bertanggung jawab penuh terhadap query database SQLite dengan filter `WHERE title LIKE ?` yang aman dari SQL injection.
3. **Mengapa pengujian otomatis penting setelah generate kode AI?**
   AI dapat menghasilkan kode yang tampak benar secara sintaksis (*vibe coding*), namun rentan mengalami regresi dependensi (package usang) atau kesalahan penanganan kasus batas (*edge case*). Unit test memberikan bukti objektif bahwa logika pencarian dan empty state berfungsi secara nyata.
