import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryState {
  final List<Map<String, dynamic>> playlists;

  LibraryState({required this.playlists});
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  LibraryNotifier() : super(LibraryState(playlists: []));

  Future<void> createPlaylist(String name, dynamic music) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newPlaylist = {
      'name': name,
      'songs': [music],
      'imageUrl': music['album']['images'][0]['url'],
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .add(newPlaylist);

      await fetchPlaylists(); // Playlists'i güncellemek için beklenir.
    } catch (e) {
      print('Failed to create playlist: $e');
      // Gerekirse hata işleme ekleyin (örn. UI'a bildirim gönderme).
    }
  }

  Future<void> fetchPlaylists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .get();

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
    } catch (e) {
      print('Failed to fetch playlists: $e');
      // Gerekirse hata işleme ekleyin.
    }
  }

  Future<void> addMusicToPlaylist(String playlistId, dynamic music) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final playlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('playlists')
        .doc(playlistId);

    try {
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

      await fetchPlaylists(); // Playlists'i güncellemek için beklenir.
    } catch (e) {
      print('Failed to add music to playlist: $e');
      // Gerekirse hata işleme ekleyin.
    }
  }
}

final libraryProvider =
    StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier();
});
