import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/product/constants/config.dart';
import 'package:spotifyclone_app/product/utils/token_manager.dart';

// Defining the state
class HomeState {
  final List<dynamic> musicList;
  final List<dynamic> playlist;

  HomeState({required this.musicList, required this.playlist});
}

// Creating a StateNotifier for HomeState
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState(musicList: [], playlist: []));

  Future<void> fetchFeaturedPlaylists() async {
    final accessToken = await TokenManager().getAccessToken();
    final playlistResponse = await http.get(
      Uri.parse('$baseUrl/browse/featured-playlists'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (playlistResponse.statusCode == 200) { 
      final playlistData = json.decode(playlistResponse.body);

      final playlist = (playlistData['playlists']['items'] as List)
          .where((item) => item['images'].isNotEmpty)
          .toList();

      state = HomeState(musicList: state.musicList, playlist: playlist);
    } else {
      print('Error fetching playlists: ${playlistResponse.statusCode}');
    }
  }

  Future<void> fetchMusic() async {
    final accessToken = await TokenManager().getAccessToken();
    final tracksResponse = await http.get(
      Uri.parse('$baseUrl/playlists/37i9dQZF1EIVLxV8R74NBi/tracks'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (tracksResponse.statusCode == 200) {
      final tracksData = json.decode(tracksResponse.body);

      final musicList = tracksData['items']
          .where((item) => item['track']['preview_url'] != null)
          .toList();

      state = HomeState(musicList: musicList, playlist: state.playlist);
    } else {
      print('Error fetching tracks: ${tracksResponse.statusCode}');
    }
  }
}

// Creating a provider for HomeNotifier
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
