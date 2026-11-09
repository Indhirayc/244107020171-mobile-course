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

  static String? _workingModel;

  /// Daftar model Gemini yang didukung untuk free-tier generateContent
  static const List<String> _models = [
    'gemini-1.5-flash',
    'gemini-pro',
    'gemini-2.0-flash',
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
    _workingModel = null;
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: _storageKey);
    _workingModel = null;
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
    final combinedPrompt = '$prompt\n\nPertanyaan: $trimmedQuestion';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': combinedPrompt},
          ],
        },
      ],
    });

    final modelsToTry = [
      ?_workingModel,
      ..._models.where((m) => m != _workingModel),
    ];

    http.Response? lastResponse;

    try {
      for (final model in modelsToTry) {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final response = await _client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        );

        lastResponse = response;

        if (response.statusCode == 200) {
          _workingModel = model;
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
        } else if (response.statusCode == 429) {
          throw Exception(
            'Batas kuota request tercapai (HTTP 429). Mohon tunggu beberapa saat sebelum mencoba lagi.',
          );
        } else if (response.statusCode == 403) {
          throw Exception(
            'API key tidak valid atau akses ditolak (HTTP 403). Periksa kembali Gemini API key Anda.',
          );
        } else if (response.statusCode == 404 || response.statusCode == 400) {
          // Model ini belum aktif atau berbeda versi, coba model berikutnya
          continue;
        } else {
          throw Exception(
            'Gagal memanggil AI API: HTTP ${response.statusCode}. Silakan coba lagi nanti.',
          );
        }
      }

      // Jika seluruh model gagal
      if (lastResponse != null) {
        throw Exception(
          'Gagal memanggil AI API: HTTP ${lastResponse.statusCode}. Silakan coba lagi nanti.',
        );
      }

      throw Exception(
        'Layanan AI tidak dapat dihubungi. Silakan coba lagi nanti.',
      );
    } on http.ClientException catch (e) {
      throw Exception('Koneksi internet bermasalah: ${e.message}');
    }
  }
}
