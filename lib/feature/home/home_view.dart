import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/feature/providers/home_notifier.dart';
import 'package:spotifyclone_app/feature/providers/library_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/feature/providers/player_notifier.dart';

class HomeView extends ConsumerStatefulWidget {
  final Function(String, bool) onPlaylistSelected;
  const HomeView({required this.onPlaylistSelected, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  // Ekran genişliği ve yüksekliğini al



  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final libraryState = ref.watch(libraryProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: HexColor(backgroundColor),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    createGrid(libraryState.playlists),
                    createMusicList('Audius Trendleri', homeState.musicList),
                    createPlaylist(
                        'Popüler Çalma Listeleri', homeState.playlist),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                widget.onPlaylistSelected(playlist['id'], false);
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

  Widget createUserPlaylistItem(dynamic playlist) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: InkWell(
        onTap: () {
          if (playlist['id'] != null) {
            widget.onPlaylistSelected(playlist['id'], true);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Container(
                width: 50, // Resmin genişliği
                height: 50, // Resmin yüksekliği
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[700], // Varsayılan arka plan rengi
                ),
                child: playlist != null &&
                        playlist.containsKey('imageUrl') &&
                        playlist['imageUrl'] != null &&
                        playlist['imageUrl'].isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          playlist['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note,
                              size: 30,
                              color: Colors.white,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.music_note,
                        size: 30,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  playlist != null && playlist.containsKey('name')
                      ? playlist['name']
                      : 'Unnamed Playlist',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> createListOfPlaylists(List<dynamic> playlist) {
    return playlist.map((playlist) => createPlaylistItem(playlist)).toList();
  }

  List<Widget> createUserListOfPlaylists(List<dynamic> userPlaylist) {
    return userPlaylist
        .map((playlist) => createUserPlaylistItem(playlist))
        .toList();
  }

  Widget createMusic(dynamic music) {
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
                ref.read(playerProvider.notifier).playMusic(music);
              },
              child: Image.network(
                music['artwork'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    size: 50,
                    color: Colors.red,
                  );
                },
              ),
            ),
          ),
          Text(
            music['title'].length > 20
                ? '${music['title'].substring(0, 20)}...'
                : music['title'],
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            music['artist'],
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget createMusicList(String label, List<dynamic> musicList) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 255,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return createMusic(musicList[index]);
              },
              itemCount: musicList.length < 10 ? musicList.length : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget createPlaylist(String label, List<dynamic> playlist) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
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

  Widget createGrid(List<dynamic> userPlaylist) {
    int maxItems = 6; // Gösterilecek maksimum öğe sayısı
    List limitedPlaylist = userPlaylist.reversed.toList();

    // Eğer listedeki öğe sayısı maxItems'dan büyükse, maxItems kadar öğe al
    if (limitedPlaylist.length > maxItems) {
      limitedPlaylist = limitedPlaylist.sublist(0, maxItems);
    }
    return Container(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: limitedPlaylist.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 7 / 2,
        ),
        itemBuilder: (context, index) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return createUserPlaylistItem(limitedPlaylist[index]);
            },
          );
        },
      ),
    );
  }
}
