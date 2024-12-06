import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/feature/providers/player_notifier.dart';
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
  Ref ref;
  HomeNotifier(this.ref) : super(HomeState(musicList: [], playlist: []));

  Future<void> fetchMusicFromAudius() async {
    const String url =
        '$audiusBaseUrl/tracks/trending?app_name=$audiusAppName&time=allTime';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Audius'tan gelen şarkı listesini alın
        final musicList = (data['data'] as List)
            .map((track) => {
                  'id': track['id'],
                  'title': track['title'],
                  'artist': track['user']['name'],
                  'artwork': track['artwork']?['1000x1000'] ?? '',
                  'stream_url':
                      '$audiusBaseUrl/tracks/${track['id']}/stream?app_name=$audiusAppName',
                  'is_audius' : true
                })
            .toList();
               ref.read(playerProvider.notifier).setMusicList(musicList);
        state = HomeState(musicList: musicList, playlist: state.playlist);
      } else {
        print('Audius API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Audius API Şarkı Çekme Hatası: $e');
    }
  }

  Future<void> fetchFeaturedPlaylists() async {
    final accessToken = await TokenManager().getAccessToken();
    final playlistResponse = await http.get(
      Uri.parse('$baseUrl/users/jx508sxjnt7msfmfz7ftrktdp/playlists'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (playlistResponse.statusCode == 200) {
      final playlistData = json.decode(playlistResponse.body);

      final playlist = (playlistData['items'] as List)
          .where((item) => item['images'].isNotEmpty)
          .toList();

      state = HomeState(musicList: state.musicList, playlist: playlist);
    } else {
      print('Error fetching playlists: ${playlistResponse.statusCode}');
    }
  }

  // Future<void> fetchMusic() async {
  //   final accessToken = await TokenManager().getAccessToken();
  //   final tracksResponse = await http.get(
  //     Uri.parse('$baseUrl/playlists/3cEYpjA9oz9GiPac4AsH4n/tracks/'),
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //     },
  //   );

  //   if (tracksResponse.statusCode == 200) {
  //     final tracksData = json.decode(tracksResponse.body);

  //     final musicList = tracksData['items']
  //         // .where((item) => item['track']['preview_url'] != null)
  //         .toList();

  //     state = HomeState(musicList: musicList, playlist: state.playlist);
  //   } else {
  //     print('Error fetching tracks: ${tracksResponse.statusCode}');
  //   }
  // }
}

// Creating a provider for HomeNotifier
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});
