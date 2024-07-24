import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Defining the state
class LibraryState {
  final List<Map<String, dynamic>> playlists;

  LibraryState({required this.playlists});
}

// Creating a StateNotifier for LibraryState
class LibraryNotifier extends StateNotifier<LibraryState> {
  LibraryNotifier() : super(LibraryState(playlists: []));

  Future<void> createPlaylist(String name, dynamic music) async {
    final newPlaylist = {
      'name': name,
      'songs': [music],
      'imageUrl': music['album']['images'][0]['url'],
    };

    await FirebaseFirestore.instance.collection('playlists').add(newPlaylist);

    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('playlists').get();

    final playlists = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'],
        'songs': List<Map<String, dynamic>>.from(data['songs']),
        'imageUrl': data['imageUrl'] ?? '',
      };
    }).toList();

    state = LibraryState(playlists: playlists);
  }

  Future<void> addMusicToPlaylist(String playlistId, dynamic music) async {
    final playlistRef =
        FirebaseFirestore.instance.collection('playlists').doc(playlistId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(playlistRef);
      if (!snapshot.exists) {
        throw Exception("Playlist does not exist!");
      }
      final data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> songs = data['songs'] ?? [];
      songs.add(music);

      transaction.update(playlistRef, {'songs': songs});
    });

    fetchPlaylists();
  }
}

// Creating a provider for LibraryNotifier
final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier();
});
