import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      body: {
        'grant_type': 'client_credentials',
      },
    );
    final accessToken = json.decode(response.body)['access_token'];
    final playlistsResponse = await http.get(
      Uri.parse('https://api.spotify.com/v1/browse/featured-playlists'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final playlistsData = json.decode(playlistsResponse.body);

    final playlist = (playlistsData['playlists']['items'] as List)
        .where((item) => item['images'].isNotEmpty)
        .toList();
    
    state = HomeState(musicList: state.musicList, playlist: playlist);
  }

  Future<void> fetchMusic() async {
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
      body: {
        'grant_type': 'client_credentials',
      },
    );
    final accessToken = json.decode(response.body)['access_token'];
    final tracksResponse = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/37i9dQZF1EIVLxV8R74NBi/tracks'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    final tracksData = json.decode(tracksResponse.body);

    final musicList = tracksData['items']
        .where((item) => item['track']['preview_url'] != null)
        .toList();
    
    state = HomeState(musicList: musicList, playlist: state.playlist);
  }
}

// Creating a provider for HomeNotifier
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
