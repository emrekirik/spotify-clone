import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/feature/library/library_notifier.dart';
import 'package:spotifyclone_app/product/widget/playlist_create.dart';

class PlaylistAddBottomSheet extends ConsumerStatefulWidget {
  final dynamic music;

  const PlaylistAddBottomSheet({required this.music, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlaylistAddBottomSheetState();
}

class _PlaylistAddBottomSheetState
    extends ConsumerState<PlaylistAddBottomSheet> {
  int? _selectedPlaylistIndex;

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final libraryNotifier = ref.read(libraryProvider.notifier); 

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'İptal',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Çalma listesine ekle',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (_selectedPlaylistIndex != null) {
                          final selectedPlaylist = libraryState
                              .playlists[_selectedPlaylistIndex!];
                          libraryNotifier.addMusicToPlaylist(
                              selectedPlaylist['id'], widget.music);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Müzik başarılı bir şekilde kaydedildi'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Bitti',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0))),
                        builder: (context) =>
                            PlaylistCreateBottomSheet(music: widget.music),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Yeni çalma listesi'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    hintText: 'Çalma listesi bul',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      libraryState.playlists.length, // Çalma listesi sayısı
                  itemBuilder: (context, index) {
                    final playlist = libraryState.playlists[index];
                    return ListTile(
                      leading: playlist['imageUrl'] != null
                          ? Image.network(
                              playlist['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.music_note,
                              color: Colors.white,
                            ),
                      title: Text(
                        playlist['name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${playlist['songs'].length} şarkı',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Radio(
                        value: index,
                        groupValue:
                            _selectedPlaylistIndex, // Seçilen çalma listesi değeri
                        onChanged: (int? value) {
                          setState(() {
                            _selectedPlaylistIndex = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
