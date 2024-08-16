import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/search/search_notifier.dart';
import 'package:spotifyclone_app/feature/tabs/player_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/product/models/category.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(() {
      final text = searchController.text;
      ref.read(searchProvider.notifier).checkSearchText(text);
    });
    ref.read(searchProvider.notifier).fetchCategories();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: _SearchBar(searchController: searchController, ref: ref),
      ),
      body: Stack(
        children: [
          searchState.isSearching
              ? buildList(searchState)
              : buildGrid(searchState),
        ],
      ),
    );
  }

  Widget buildGrid(SearchState searchState) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: createListOfCategories(searchState),
      ),
    );
  }

  Widget buildList(SearchState searchState) {
    return ListView.builder(
      itemCount: searchState.tracks.length,
      itemBuilder: (context, index) {
        final track = searchState.tracks[index];
        return buildListTile(track);
      },
    );
  }

  Widget buildListTile(dynamic track) {
    final playerNotifier = ref.read(playerProvider.notifier);
    return ListTile(
      leading: Image.network(track['album']['images'][0]['url']),
      title: Text(
        track['name'],
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        track['artists'][0]['name'],
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: () {
        playerNotifier.playMusic(track);
      },
    );
  }

  List<Widget> createListOfCategories(SearchState searchState) {
    return searchState.categories
        .map((Category category) => buildGridTile(category))
        .toList();
  }

  Widget buildGridTile(Category category) {
    return GridTile(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: NetworkImage(category.imageURL),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.searchController,
    required this.ref,
  });

  final TextEditingController searchController;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: HexColor(backgroundColor),
      flexibleSpace: Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Ne dinlemek istiyorsun',
            hintStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.grey[200],
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            ref
                .read(searchProvider.notifier)
                .searchMusic(searchController.text);
          },
          icon: const Icon(Icons.search),
          color: Colors.black,
        ),
      ],
    );
  }
}
