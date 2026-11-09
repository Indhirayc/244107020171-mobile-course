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
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
    'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent',
    'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent',
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
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

  Future<String> ask(String question, {String? systemPrompt}) async {
    final trimmedQuestion = question.trim();
    if (trimmedQuestion.isEmpty) {
      throw Exception('Pertanyaan tidak boleh kosong.');
    }

    final apiKey = await getApiKey();
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

    final endpointsToTry = [
      ?_cachedWorkingEndpoint,
      ..._candidateEndpoints.where((ep) => ep != _cachedWorkingEndpoint),
    ];

    http.Response? lastResponse;

    try {
      for (final endpoint in endpointsToTry) {
        final response = await _client.post(
          Uri.parse('$endpoint?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        );

        lastResponse = response;

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
        } else if (response.statusCode == 404) {
          // Model tidak ditemukan pada endpoint ini, lanjut coba kandidat berikutnya
          continue;
        } else if (response.statusCode == 403) {
          throw Exception(
            'API key tidak valid atau akses ditolak (HTTP 403). Periksa kembali Gemini API key Anda.',
          );
        } else if (response.statusCode == 429) {
          throw Exception(
            'Batas kuota request tercapai (HTTP 429). Mohon tunggu beberapa saat sebelum mencoba lagi.',
          );
        } else if (response.statusCode == 400) {
          // Jika 400, kemungkinan konfigurasi parameter pada model tertentu, coba kandidat lain jika ada
          continue;
        } else {
          throw Exception(
            'Gagal memanggil AI API: HTTP ${response.statusCode}. Silakan coba lagi nanti.',
          );
        }
      }

      // Jika seluruh endpoint dicoba dan tetap gagal
      if (lastResponse != null) {
        if (lastResponse.statusCode == 404) {
          throw Exception(
            'Model AI tidak ditemukan (HTTP 404). Pastikan Generative Language API aktif pada Google AI Studio project Anda.',
          );
        } else if (lastResponse.statusCode == 400) {
          throw Exception(
            'Permintaan tidak valid (HTTP 400). Periksa format prompt atau API key Anda.',
          );
        } else {
          throw Exception(
            'Gagal memanggil AI API: HTTP ${lastResponse.statusCode}. Silakan coba lagi nanti.',
          );
        }
      }

      throw Exception('Tidak ada endpoint AI yang dapat dihubungi.');
    } on http.ClientException catch (e) {
      throw Exception('Koneksi internet bermasalah: ${e.message}');
    }
  }
}
