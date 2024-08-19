import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/feature/providers/library_notifier.dart';


class LibraryScreen extends ConsumerStatefulWidget {
  final Function(String, bool) onPlaylistSelected;
  const LibraryScreen({required this.onPlaylistSelected, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(libraryProvider.notifier).fetchPlaylists());
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: libraryState.playlists.length,
        itemBuilder: (context, index) {
          final playlist = libraryState.playlists[index];
          return buildPlaylistItem(playlist);
        },
      ),
    );
  }

  Widget buildPlaylistItem(Map<String, dynamic> playlist) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Image.network(
          playlist['songs'][0]['album']['images'][0]['url'],
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.music_note, size: 100, color: Colors.grey);
          },
        ),
        title: Text(
          playlist['name'],
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () {
          if (playlist['id'] != null) {
            widget.onPlaylistSelected(playlist['id'], true);
          }
        },
      ),
    );
  }
}
