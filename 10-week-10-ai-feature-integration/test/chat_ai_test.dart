import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:campus_notify/ai/ai_service.dart';
import 'package:campus_notify/ai/ai_providers.dart';

class FakeStorage extends FlutterSecureStorage {
  FakeStorage({Map<String, String>? initialData})
      : _data = initialData != null ? Map.from(initialData) : {};

  final Map<String, String> _data;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  group('AiService Unit Tests', () {
    test('melempar Exception jika API key belum diatur', () async {
      final storage = FakeStorage();
      final service = AiService(storage: storage);

      expect(
        () => service.ask('Halo apa kabar?'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('API key belum diatur'),
          ),
        ),
      );
    });

    test('melempar Exception jika pertanyaan kosong atau hanya spasi', () async {
      final storage = FakeStorage(initialData: {'ai_api_key': 'test-key'});
      final service = AiService(storage: storage);

      expect(
        () => service.ask('   '),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Pertanyaan tidak boleh kosong'),
          ),
        ),
      );
    });

    test('mengembalikan respon teks yang benar saat HTTP 200', () async {
      final storage = FakeStorage(initialData: {'ai_api_key': 'dummy-key'});

      final mockClient = MockClient((request) async {
        final mockResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text':
                        'Jadwal kuliah hari Senin adalah Pemrograman Mobile di Lab 2.'
                  }
                ]
              }
            }
          ]
        };
        return http.Response(jsonEncode(mockResponse), 200, headers: {
          'content-type': 'application/json',
        });
      });

      final service = AiService(storage: storage, client: mockClient);
      final answer = await service.ask('Jadwal hari Senin apa?');

      expect(
        answer,
        'Jadwal kuliah hari Senin adalah Pemrograman Mobile di Lab 2.',
      );
    });

    test('menangani error kuota HTTP 429 dengan pesan yang ramah', () async {
      final storage = FakeStorage(initialData: {'ai_api_key': 'dummy-key'});

      final mockClient = MockClient((request) async {
        return http.Response('Rate limit exceeded', 429);
      });

      final service = AiService(storage: storage, client: mockClient);

      expect(
        () => service.ask('Halo?'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Batas kuota request tercapai'),
          ),
        ),
      );
    });
  });

  group('ChatNotifier State Tests', () {
    test('inisialisasi awal memuat pesan sambutan', () {
      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWithValue(
            AiService(storage: FakeStorage()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(chatProvider);
      expect(state.messages.length, 1);
      expect(state.messages.first.isUser, isFalse);
      expect(state.messages.first.text, contains('Asisten AI Kampus'));
    });

    test('sendMessage menambahkan pesan user dan respon asisten', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Ini jawaban simulasi asisten AI.'}
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      final storage = FakeStorage(initialData: {'ai_api_key': 'valid-key'});
      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWithValue(
            AiService(storage: storage, client: mockClient),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(chatProvider.notifier).sendMessage('Pertanyaan tes');

      final state = container.read(chatProvider);
      expect(state.messages.length, 3); // welcome + user + assistant
      expect(state.messages[1].text, 'Pertanyaan tes');
      expect(state.messages[1].isUser, isTrue);
      expect(state.messages[2].text, 'Ini jawaban simulasi asisten AI.');
      expect(state.messages[2].isUser, isFalse);
      expect(state.isLoading, isFalse);
    });

    test('saveApiKey dan clearApiKey memperbarui hasApiKey', () async {
      final storage = FakeStorage();
      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWithValue(
            AiService(storage: storage),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(chatProvider.notifier);
      await notifier.saveApiKey('my-secret-key');

      expect(container.read(chatProvider).hasApiKey, isTrue);

      await notifier.clearApiKey();
      expect(container.read(chatProvider).hasApiKey, isFalse);
    });
  });
}
