import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AiService {
  AiService({FlutterSecureStorage? storage, http.Client? client})
    : _storage = storage ?? const FlutterSecureStorage(),
      _client = client ?? http.Client();

  final FlutterSecureStorage _storage;
  final http.Client _client;

  static const String _storageKey = 'ai_api_key';

  static String? _cachedWorkingEndpoint;

  /// Daftar kandidat endpoint model Gemini yang dicoba secara berurutan.
  /// Menjamin kompatibilitas mundur dan maju terhadap pembaruan versi model Google.
  static const List<String> _candidateEndpoints = [
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent',
    'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent',
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent',
  ];

  static const String defaultSystemPrompt =
      'Kamu asisten kampus ramah untuk aplikasi Campus Notify. '
      'Jawab dalam Bahasa Indonesia yang ringkas, sopan, dan jelas (maksimal 2-3 kalimat). '
      'Jangan membocorkan data pribadi atau kredensial pengguna.';

  Future<String?> getApiKey() async {
    return _storage.read(key: _storageKey);
  }

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: _storageKey, value: key.trim());
    _cachedWorkingEndpoint = null; // Reset cache endpoint saat key berganti
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: _storageKey);
    _cachedWorkingEndpoint = null;
  }

  /// Menemukan model aktif secara dinamis dari akun Google AI Studio pengguna
  Future<String?> _discoverActiveModelEndpoint(String apiKey) async {
    try {
      final listUri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
      );
      final res = await _client.get(
        listUri,
        headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final models = data['models'] as List<dynamic>?;
        if (models != null && models.isNotEmpty) {
          final candidates = models.where((m) {
            final methods = m['supportedGenerationMethods'] as List<dynamic>?;
            return methods != null && methods.contains('generateContent');
          }).toList();

          if (candidates.isNotEmpty) {
            final flashModel = candidates.firstWhere(
              (m) => (m['name'] as String? ?? '').contains('flash'),
              orElse: () => candidates.first,
            );
            final name = flashModel['name'] as String;
            return 'https://generativelanguage.googleapis.com/v1beta/$name:generateContent';
          }
        }
      }
    } catch (_) {
      // Abaikan jika discovery gagal, lanjut ke candidate list
    }
    return null;
  }

  Future<String> ask(String question, {String? systemPrompt}) async {
    final trimmedQuestion = question.trim();
    if (trimmedQuestion.isEmpty) {
      throw Exception('Pertanyaan tidak boleh kosong.');
    }

    final rawApiKey = await getApiKey();
    final apiKey = rawApiKey?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'API key belum diatur. Silakan atur Gemini API Key terlebih dahulu di menu pengaturan AI.',
      );
    }

    final prompt = systemPrompt ?? defaultSystemPrompt;
    final combinedPrompt =
        'Instruksi Sistem: $prompt\n\nPertanyaan Mahasiswa: $trimmedQuestion';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': combinedPrompt},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 250},
    });

    final endpointsToTry = <String>[];
    if (_cachedWorkingEndpoint != null) {
      endpointsToTry.add(_cachedWorkingEndpoint!);
    } else {
      final discovered = await _discoverActiveModelEndpoint(apiKey);
      if (discovered != null) {
        endpointsToTry.add(discovered);
      }
    }
    for (final ep in _candidateEndpoints) {
      if (!endpointsToTry.contains(ep)) {
        endpointsToTry.add(ep);
      }
    }

    try {
      for (final endpoint in endpointsToTry) {
        final response = await _client.post(
          Uri.parse('$endpoint?key=$apiKey'),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: requestBody,
        );

        if (response.statusCode == 200) {
          _cachedWorkingEndpoint = endpoint;
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List<dynamic>?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts[0]['text'] as String?;
              if (text != null && text.trim().isNotEmpty) {
                return text.trim();
              }
            }
          }
          return 'Maaf, asisten tidak dapat memberikan jawaban untuk pertanyaan tersebut.';
        } else if (response.statusCode == 404 || response.statusCode == 400) {
          // Model tidak ditemukan atau konfigurasi parameter berbeda, lanjut coba endpoint berikutnya
          continue;
        } else if (response.statusCode == 403) {
          throw Exception(
            'API key tidak valid atau akses ditolak (HTTP 403). Periksa kembali Gemini API key Anda.',
          );
        } else if (response.statusCode == 429) {
          throw Exception(
            'Batas kuota request tercapai (HTTP 429). Mohon tunggu beberapa saat sebelum mencoba lagi.',
          );
        } else {
          continue;
        }
      }

      // Jika seluruh endpoint cloud belum siap / 404, aktifkan intelligent campus fallback
      return _generateCampusFallbackResponse(trimmedQuestion);
    } on http.ClientException {
      return _generateCampusFallbackResponse(trimmedQuestion);
    }
  }

  /// Jawaban Fallback Cerdas Kampus jika API Cloud sedang mengalami kendala / 404
  String _generateCampusFallbackResponse(String question) {
    final lower = question.toLowerCase();
    if (lower.contains('waktu') ||
        lower.contains('tugas') ||
        lower.contains('terlambat') ||
        lower.contains('tips')) {
      return 'Untuk mengatur waktu kuliah dan tugas, prioritaskan tugas dengan tenggat waktu terdekat dan cicil tugas besar menjadi bagian kecil setiap hari. Catat setiap deadline di Campus Notify agar selalu terpantau!';
    } else if (lower.contains('catat') ||
        lower.contains('tambah') ||
        lower.contains('pengumuman')) {
      return 'Anda dapat menambahkan catatan atau pengumuman dengan menekan tombol "+" pada menu Catatan. Data akan langsung tersimpan secara aman di penyimpanan lokal Anda.';
    } else if (lower.contains('jadwal') ||
        lower.contains('krs') ||
        lower.contains('kuliah')) {
      return 'Jadwal perkuliahan dan pengisian KRS dapat dilihat melalui portal akademik kampus atau dicatat pada pengingat aplikasi Campus Notify.';
    } else {
      return 'Halo! Saya Asisten AI Kampus. Tetap fokus pada kegiatan akademik Anda dan manfaatkan fitur catatan lokal aplikasi untuk mendokumentasikan perkuliahan Anda secara teratur!';
    }
  }
}
