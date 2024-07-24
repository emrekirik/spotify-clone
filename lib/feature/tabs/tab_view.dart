import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotifyclone_app/feature/tabs/player_provider.dart';
import 'package:spotifyclone_app/product/constants/color.dart';
import 'package:spotifyclone_app/feature/home/home_view.dart';
import 'package:spotifyclone_app/feature/library/library.dart';
import 'package:spotifyclone_app/feature/search/search.dart';
import 'package:spotifyclone_app/feature/playlists/user_playlist/user_playlist_detail.dart';
import 'package:spotifyclone_app/product/widget/mini_player.dart';
import 'package:spotifyclone_app/feature/playlists/spotify_playlist/playlist_detail.dart';




class TabView extends ConsumerStatefulWidget {
  const TabView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TabViewState();
}

class _TabViewState extends ConsumerState<TabView> {
  final player = AudioPlayer();
  int currentTabsIndex = 0;
  String? selectedPlaylistId;
  bool isUserPlaylist = false;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentTabsIndex,
            children: [
              HomeView(onPlaylistSelected: (playlistId, isUser) {
                setState(() {
                  selectedPlaylistId = playlistId;
                  isUserPlaylist = isUser;
                  currentTabsIndex =
                      3; // PlaylistDetail sayfası için yeni bir index
                });
              }),
              const SearchScreen(),
              LibraryScreen(
                onPlaylistSelected: (playlistId, isUser) {
                  setState(() {
                    selectedPlaylistId = playlistId;
                    isUserPlaylist = isUser;
                    currentTabsIndex =
                        3; // PlaylistDetail sayfası için yeni bir index
                  });
                },
              ),
              if (selectedPlaylistId != null)
                isUserPlaylist
                    ? UserPlaylistDetail(
                        key: ValueKey(
                            selectedPlaylistId), // State'i yeniden inşa etmek için key kullanıyoruz
                        playlistId: selectedPlaylistId!,

                        onBack: () {  
                          setState(() {
                            currentTabsIndex = 0;
                          });
                        },
                      )
                    : PlaylistDetail(
                        key: ValueKey(
                            selectedPlaylistId), // State'i yeniden inşa etmek için key kullanıyoruz
                        playlistId: selectedPlaylistId!,

                        onBack: () {
                          setState(() {
                            currentTabsIndex = 0;
                          });
                        },
                      ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: playerState.currentTrack == null
                ? const SizedBox()
                : MiniPlayer(
                    music: playerState.currentTrack,
                    stop: !playerState.isPlaying,
                  ),
          ),
        ],
      ),
      backgroundColor: HexColor(gridColor),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            currentIndex: currentTabsIndex < 3 ? currentTabsIndex : 0,
            onTap: (currentIndex) {
              setState(() {
                currentTabsIndex = currentIndex;
              });
            },
            selectedItemColor: Colors.white,
            backgroundColor: HexColor(backgroundColor),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.my_library_music),
                label: 'library',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
