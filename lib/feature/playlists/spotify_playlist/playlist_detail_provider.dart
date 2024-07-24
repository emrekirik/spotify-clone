import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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

    const clientId = 'd9395681539940c4bde56031585fe648';
    const clientSecret = '9220e39b7fe14da8aa7d554506013435';
    const credentials = '$clientId:$clientSecret';
    final encodedCredentials = base64Encode(utf8.encode(credentials));
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $encodedCredentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final accessToken = json.decode(response.body)['access_token'];
      final playlistsResponse = await http.get(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId'),
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
    } else {
      print('Failed to load access token: ${response.body}');
    }
  }

  void clearPlaylist() {
    state = PlaylistDetailState(playlist: {}, tracks: []);
  }
}

// Creating a provider for PlaylistDetailNotifier
final playlistDetailProvider = StateNotifierProvider<PlaylistDetailNotifier, PlaylistDetailState>((ref) {
  return PlaylistDetailNotifier();
});
