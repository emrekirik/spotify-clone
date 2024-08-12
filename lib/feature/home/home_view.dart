import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/feature/home/home_notifier.dart';
import 'package:spotifyclone_app/feature/library/library_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/feature/tabs/player_notifier.dart';
import 'package:spotifyclone_app/product/widget/custom_appbar.dart';

class HomeView extends ConsumerStatefulWidget {
  final Function(String, bool) onPlaylistSelected;
  const HomeView({required this.onPlaylistSelected, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final player = AudioPlayer();
  final String _title = 'Anasayfa';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeNotifier = ref.read(homeProvider.notifier);
      final libraryNotifier = ref.read(libraryProvider.notifier);
      homeNotifier.fetchFeaturedPlaylists();
      homeNotifier.fetchMusic();
      libraryNotifier.fetchPlaylists();
    });
  }

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
                    CustomAppbar(
                      message: _title,
                    ),
                    createGrid(libraryState.playlists),
                    createMusicList('Senin İçin', homeState.musicList),
                    createPlaylist('Popüler Çalma Listeleri', homeState.playlist),
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
              child: playlist.containsKey('images') && playlist['images'].isNotEmpty
                  ? Image.network(
                      playlist['images'][0]['url'],
                      fit: BoxFit.cover,
                    )
                  : playlist.containsKey('imageUrl') && playlist['imageUrl'].isNotEmpty
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
              SizedBox(
                height: 60,
                width: 60,
                child: playlist.containsKey('imageUrl') && playlist['imageUrl'].isNotEmpty
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  playlist['name'] ?? 'Unnamed Playlist',
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
    return userPlaylist.map((playlist) => createUserPlaylistItem(playlist)).toList();
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
                ref.read(playerProvider.notifier).playMusic(music['track']);
              },
              child: Image.network(
                music['track']['album']['images'][0]['url'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            music['track']['name'],
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            music['track']['artists'][0]['name'],
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget createMusicList(String label, List<dynamic> musicList) {
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
      height: 250,
      child: GridView.count(
        childAspectRatio: 7 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: limitedPlaylist
            .map((userPlaylist) => createUserPlaylistItem(userPlaylist))
            .toList(),
      ),
    );
  }
}
