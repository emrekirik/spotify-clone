import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/providers/category_detail_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';

class CategoryDetailView extends ConsumerStatefulWidget {
  final String categoryId;
  final VoidCallback onBack;
  final Function(String, bool) onPlaylistSelected;

  const CategoryDetailView(
      {required this.onBack,
      required this.onPlaylistSelected,
      required this.categoryId,
      super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CategoryDetailViewState();
}

class _CategoryDetailViewState extends ConsumerState<CategoryDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(categoryDetailProvider.notifier)
          .getCategoryPlaylists(widget.categoryId);
    });
  }

  // dispose yerine onBack fonksiyonunu kullanıyoruz
  void _handleBack() {
    ref.invalidate(categoryDetailProvider);
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final categoryDetailState = ref.watch(categoryDetailProvider);
    final sizeHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: sizeHeight * 0.1,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                icon: const Icon(Icons.arrow_back_ios), onPressed: _handleBack),
            Text(
              categoryDetailState.message!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 125, 23, 23),
                HexColor(backgroundColor),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                if (categoryDetailState.errorMessage != null)
                  Text(
                    categoryDetailState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  )
                else if (categoryDetailState.playlist.isNotEmpty)
                  createPlaylist(categoryDetailState.playlist)
                else
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget createPlaylistItem(dynamic playlist) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: 180,
            child: InkWell(
              onTap: () {
                if (playlist['id'] != null) {
                  widget.onPlaylistSelected(playlist['id'], false);
                }
              },
              child: playlist.containsKey('images') &&
                      playlist['images'].isNotEmpty
                  ? Image.network(
                      playlist['images'][0]['url'],
                      fit: BoxFit.cover,
                    )
                  : playlist.containsKey('imageUrl') &&
                          playlist['imageUrl'].isNotEmpty
                      ? Image.network(
                          playlist['imageUrl'],
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.music_note,
                          size: 30,
                          color: Colors.white,
                        ),
            ),
          ),
          Text(
            playlist['name'] ?? 'Unnamed Playlist',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget createPlaylist(List<dynamic> playlist) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return createPlaylistItem(playlist[index]);
              },
              itemCount: playlist.length < 10 ? playlist.length : 10,
            ),
          ),
        ],
      ),
    );
  }
}
