import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/product/utils/token_manager.dart';

// Defining the state
class CategoryDetailState {
  final List<dynamic> playlist;
  final String? errorMessage;
  final String? message;
  final List<dynamic> musicList;

  CategoryDetailState(
      {required this.musicList,
      required this.message,
      required this.playlist,
      this.errorMessage});

  // Copy method for safe state updates
  CategoryDetailState copyWith({
    List<dynamic>? playlist,
    String? errorMessage,
    String? message,
    List<dynamic>? musicList,
  }) {
    return CategoryDetailState(
      playlist: playlist ?? this.playlist,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      musicList: musicList ?? this.musicList,
    );
  }
}

// Creating a StateNotifier for CategoryDetailState
class CategoryDetailNotifier extends StateNotifier<CategoryDetailState> {
  CategoryDetailNotifier()
      : super(CategoryDetailState(playlist: [], message: '', musicList: []));

  Future<void> getCategoryPlaylists(String categoryId) async {
    try {
      // TokenManager'dan token almak için await kullanıyoruz
      final accessToken = await TokenManager().getAccessToken();
      final response = await http.get(
        Uri.parse(
            'https://api.spotify.com/v1/browse/categories/$categoryId/playlists'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        final playlist = data['playlists']['items'];
        final message = data['message'];
        state = state.copyWith(playlist: playlist, message: message);
      } else {
        state = state.copyWith(
            errorMessage:
                'Playlistleri alırken bir hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Bir hata oluştu: $e');
    }
  }
}

// Creating a provider for CategoryDetailNotifier
final categoryDetailProvider =
    StateNotifierProvider<CategoryDetailNotifier, CategoryDetailState>((ref) {
  return CategoryDetailNotifier();
});
