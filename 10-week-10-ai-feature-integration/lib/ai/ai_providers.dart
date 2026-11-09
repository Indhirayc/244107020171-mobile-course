import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_service.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
}

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasApiKey = false,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final bool hasApiKey;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool? hasApiKey,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasApiKey: hasApiKey ?? this.hasApiKey,
    );
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    _init();
    return ChatState(
      messages: [
        ChatMessage(
          id: 'welcome',
          text:
              'Halo! Saya Asisten AI Kampus. Tanyakan apa saja seputar jadwal kuliah, '
              'kegiatan akademik, atau catatan kampus!',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> _init() async {
    final aiService = ref.read(aiServiceProvider);
    final key = await aiService.getApiKey();
    state = state.copyWith(hasApiKey: key != null && key.isNotEmpty);
  }

  Future<void> refreshApiKeyStatus() async {
    final aiService = ref.read(aiServiceProvider);
    final key = await aiService.getApiKey();
    state = state.copyWith(hasApiKey: key != null && key.isNotEmpty);
  }

  Future<void> saveApiKey(String key) async {
    final aiService = ref.read(aiServiceProvider);
    await aiService.saveApiKey(key);
    state = state.copyWith(hasApiKey: key.trim().isNotEmpty);
  }

  Future<void> clearApiKey() async {
    final aiService = ref.read(aiServiceProvider);
    await aiService.clearApiKey();
    state = state.copyWith(hasApiKey: false);
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) {
      return;
    }

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );

    try {
      final aiService = ref.read(aiServiceProvider);
      final responseText = await aiService.ask(trimmed);

      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorClean = e.toString().replaceFirst('Exception: ', '');
      final errorMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: '⚠️ $errorClean',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        errorMessage: errorClean,
      );
    }
  }

  void clearHistory() {
    state = ChatState(
      hasApiKey: state.hasApiKey,
      messages: [
        ChatMessage(
          id: 'welcome',
          text:
              'Riwayat telah dibersihkan. Ada yang bisa saya bantu seputar kampus?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
