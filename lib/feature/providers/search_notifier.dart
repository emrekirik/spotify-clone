import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/product/constants/config.dart';
import 'package:spotifyclone_app/product/models/category.dart';
import 'package:spotifyclone_app/product/utils/token_manager.dart';

class SearchState {
  final List<Category> categories;
  final List<dynamic> tracks;
  final bool isSearching;

  SearchState({
    required this.categories,
    required this.tracks,
    required this.isSearching,
  });

  SearchState copyWith({
    List<Category>? categories,
    List<dynamic>? tracks,
    bool? isSearching,
  }) {
    return SearchState(
      categories: categories ?? this.categories,
      tracks: tracks ?? this.tracks,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier()
      : super(SearchState(
          categories: [],
          tracks: [],
          isSearching: false,
        ));

  // Şarkıları kontrol eden fonksiyon
  Future<bool> _hasTracks(String categoryId) async {
    final accessToken = await TokenManager().getAccessToken();
    final tracksResponse = await http.get(
      Uri.parse(
          '$baseUrl/browse/categories/$categoryId/playlists?country=US&limit=1'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (tracksResponse.statusCode == 200) {
      final tracksData = json.decode(tracksResponse.body);
      print(tracksData);
      // Kategorinin içeriğinde en az bir playlist ve şarkı var mı diye kontrol ediyoruz
      if (tracksData != null
          //&&
          // tracksData['playlists'] != null &&
          // tracksData['playlists']['items'].isNotEmpty
          ) {
        return true;
      }
    }

    return false;
  }

  Future<void> fetchCategories() async {
    final accessToken = await TokenManager().getAccessToken();
    final categoriesResponse = await http.get(
      Uri.parse('$baseUrl/browse/categories?offset=0&limit=20&locale=tr-TR'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (categoriesResponse.statusCode == 200) {
      final categoriesData = json.decode(categoriesResponse.body);
      if (categoriesData != null && categoriesData['categories'] != null) {
        final allCategories = (categoriesData['categories']['items'] as List)
            .map((item) => Category.fromJson(item))
            .toList();

        // Boş olmayan kategorileri filtreleyip listeye ekliyoruz
        List<Category> filteredCategories = [];
        for (Category category in allCategories) {
          final hasTracks = await _hasTracks(category.id); // İçeriği kontrol et
          if (hasTracks) {
            filteredCategories.add(category);
          }
        }
        state = state.copyWith(categories: allCategories);
      } else {
        print('Failed to load categories: ${categoriesResponse.body}');
      }
    } else {
      print('Failed to fetch categories: ${categoriesResponse.statusCode}');
    }
  }

  void checkSearchText(String text) {
    if (text.isEmpty) {
      state = state.copyWith(isSearching: false);
    } else {
      searchMusic(text);
    }
  }

  Future<void> searchMusic(String searchText) async {
    final encodedSearchText = Uri.encodeQueryComponent(searchText);
    final accessToken = await TokenManager().getAccessToken();
    final searchUrl =
        '$baseUrl/search?q=$encodedSearchText&type=track&limit=10';
    final searchResponse = await http.get(
      Uri.parse(searchUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (searchResponse.statusCode == 200) {
      final searchData = json.decode(searchResponse.body);
      if (searchData != null && searchData['tracks'] != null) {
        final tracks = searchData['tracks']['items'];
        state = state.copyWith(tracks: tracks, isSearching: true);
      } else {
        print('Failed to load search results: ${searchResponse.body}');
      }
    } else {
      print('Failed to search music: ${searchResponse.statusCode}');
    }
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
