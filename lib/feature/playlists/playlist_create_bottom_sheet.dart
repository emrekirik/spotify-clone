import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/feature/providers/library_notifier.dart';

class PlaylistCreateBottomSheet extends ConsumerWidget {
  final dynamic music;

  const PlaylistCreateBottomSheet({required this.music, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();
    final libraryNotifier = ref.read(libraryProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Çalma listene bir isim ver',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              decoration: const InputDecoration(
                hintText: 'Çalma listesi adı',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    libraryNotifier.createPlaylist(controller.text, music);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Müzik başarılı bir şekide kaydedildi'),
                      duration: Duration(seconds: 2),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Oluştur'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
