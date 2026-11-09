import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/ai_providers.dart';

class ApiKeyDialog extends ConsumerStatefulWidget {
  const ApiKeyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ApiKeyDialog(),
    );
  }

  @override
  ConsumerState<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends ConsumerState<ApiKeyDialog> {
  late final TextEditingController _keyController;
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController();
    _loadExistingKey();
  }

  Future<void> _loadExistingKey() async {
    final aiService = ref.read(aiServiceProvider);
    final key = await aiService.getApiKey();
    if (mounted && key != null) {
      _keyController.text = key;
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.key, color: Colors.indigo),
          SizedBox(width: 8),
          Text('Pengaturan API Key'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masukkan Google Gemini API Key Anda. Kunci ini akan disimpan '
            'secara aman pada enkripsi lokal (FlutterSecureStorage).',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              hintText: 'AIzaSy...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '💡 Kunci gratis bisa didapatkan di Google AI Studio (aistudio.google.com).',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        if (_keyController.text.isNotEmpty)
          TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    await ref.read(chatProvider.notifier).clearApiKey();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('API Key telah dihapus.')),
                      );
                    }
                  },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isLoading
              ? null
              : () async {
                  final key = _keyController.text.trim();
                  if (key.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('API Key tidak boleh kosong.'),
                      ),
                    );
                    return;
                  }
                  setState(() => _isLoading = true);
                  await ref.read(chatProvider.notifier).saveApiKey(key);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('API Key berhasil disimpan dengan aman!'),
                      ),
                    );
                  }
                },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
