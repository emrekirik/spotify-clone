import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/product/models/category.dart';

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
  final TextEditingController searchController = TextEditingController();

  SearchNotifier()
      : super(SearchState(
          categories: [],
          tracks: [],
          isSearching: false,
        ));

  Future<void> fetchCategories() async {
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
    final categoriesResponse = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/browse/categories?country=US&locale=en_US'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final categoriesData = json.decode(categoriesResponse.body);

    final categories = (categoriesData['categories']['items'] as List)
        .map((item) => Category.fromJson(item))
        .toList();

    state = state.copyWith(categories: categories);
  }

  void checkSearchText() {
    if (searchController.text.isEmpty) {
      state = state.copyWith(isSearching: false);
    } else {
      searchMusic();
    }
  }

  Future<void> searchMusic() async {
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

    final searchResponse = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=${searchController.text}&type=track&limit=10'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final searchData = json.decode(searchResponse.body);

    final tracks = searchData['tracks']['items'];
    state = state.copyWith(tracks: tracks, isSearching: true);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
