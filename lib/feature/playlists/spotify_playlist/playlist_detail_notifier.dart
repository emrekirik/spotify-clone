import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:spotifyclone_app/product/constants/config.dart';
import 'package:spotifyclone_app/product/utils/token_manager.dart';

// Defining the state
class PlaylistDetailState {
  final Map<String, dynamic> playlist;
  final List<dynamic> tracks;

  PlaylistDetailState({required this.playlist, required this.tracks});

  PlaylistDetailState copyWith({
    Map<String, dynamic>? playlist,
    List<dynamic>? tracks,
  }) {
    return PlaylistDetailState(
      playlist: playlist ?? this.playlist,
      tracks: tracks ?? this.tracks,
    );
  }
}

// Creating a StateNotifier for PlaylistDetailState
class PlaylistDetailNotifier extends StateNotifier<PlaylistDetailState> {
  PlaylistDetailNotifier()
      : super(PlaylistDetailState(playlist: {}, tracks: []));

  Future<void> fetchPlaylistDetails(String playlistId) async {
    state = PlaylistDetailState(playlist: {}, tracks: []);

    final accessToken = await TokenManager().getAccessToken();
    final playlistsResponse = await http.get(
      Uri.parse('$baseUrl/playlists/$playlistId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (playlistsResponse.statusCode == 200) {
      final playlistData = json.decode(playlistsResponse.body);

      final playlist = playlistData;
      final tracks = playlistData['tracks']['items']
          .where((item) => item['track']['preview_url'] != null)
          .toList();

      state = PlaylistDetailState(playlist: playlist, tracks: tracks);
    } else {
      print('Failed to load playlist: ${playlistsResponse.body}');
    }
  }

  void clearPlaylist() {
    state = PlaylistDetailState(playlist: {}, tracks: []);
  }
}

// Creating a provider for PlaylistDetailNotifier
final playlistDetailProvider =
    StateNotifierProvider<PlaylistDetailNotifier, PlaylistDetailState>((ref) {
  return PlaylistDetailNotifier();
});
