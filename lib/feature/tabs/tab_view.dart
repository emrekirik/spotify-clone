import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotifyclone_app/feature/playlists/spotify_playlist/playlist_detail.dart';
import 'package:spotifyclone_app/feature/playlists/user_playlist/user_playlist_detail.dart';
import 'package:spotifyclone_app/feature/profile/profile_view.dart';
import 'package:spotifyclone_app/feature/tabs/player_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/feature/home/home_view.dart';
import 'package:spotifyclone_app/feature/library/library.dart';
import 'package:spotifyclone_app/feature/search/search.dart';
import 'package:spotifyclone_app/product/models/tab_item_enum.dart';
import 'package:spotifyclone_app/product/widget/mini_player.dart';
import 'package:spotifyclone_app/feature/auth/login/sign_in_view.dart'; // SignInView import edin
import 'package:spotifyclone_app/feature/auth/login/sign_in_notifier.dart'; // SignInNotifier import edin

class TabView extends ConsumerStatefulWidget {
  const TabView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TabViewState();
}

class _TabViewState extends ConsumerState<TabView> {
  final player = AudioPlayer();
  TabItem currentTab = TabItem.home;
  TabItem? previousTab;
  String? selectedPlaylistId;
  bool isUserPlaylist = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  String _getAppBarTitle() {
    switch (currentTab) {
      case TabItem.home:
        return 'Ana sayfa';
      case TabItem.search:
        return 'Ara';
      case TabItem.library:
        return 'Kitaplığın';
      case TabItem.playlistDetail:
        return 'Playlist Details';
      case TabItem.profile: // Yeni tab ekleyin
        return 'Profil';
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final signInNotifier = ref.read(signInProvider.notifier);

    // Oturum kontrolü
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Kullanıcı oturum açmamışsa SignInView sayfasına yönlendirin
      WidgetsBinding.instance.addPostFrameCallback((_) {
        player.stop(); // Oturumu kapatırken player'ı durdur
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignInView(),
          ),
        );
      });
      return const SizedBox();
    }

    return Scaffold(
      appBar:
          currentTab != TabItem.playlistDetail && currentTab != TabItem.profile
              ? AppBar(
                  centerTitle: false,
                  title: Text(_getAppBarTitle()),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          previousTab = currentTab;
                          currentTab = TabItem
                              .profile; // ProfileView'e gitmek için tab'ı değiştir
                        });
                      },
                      child: CircleAvatar(
                        backgroundImage: currentUser?.photoURL != null
                            ? NetworkImage(
                                currentUser!.photoURL!) // Profil fotoğrafı
                            : null,
                        child: currentUser?.photoURL == null
                            ? const Icon(Icons.person) // Varsayılan simge
                            : null,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await signInNotifier.signOut();
                        ref.read(playerProvider.notifier).stopMusic();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => SignInView(),
                          ),
                        );
                      },
                    ),
                  ],
                )
              : null,
      body: Stack(
        children: [
          IndexedStack(
            index: currentTab.index,
            children: [
              HomeView(onPlaylistSelected: (playlistId, isUser) {
                setState(() {
                  selectedPlaylistId = playlistId;
                  isUserPlaylist = isUser;
                  previousTab = currentTab;
                  currentTab = TabItem
                      .playlistDetail; // PlaylistDetail sayfası için yeni bir index
                });
              }),
              const SearchScreen(),
              LibraryScreen(
                onPlaylistSelected: (playlistId, isUser) {
                  setState(() {
                    selectedPlaylistId = playlistId;
                    isUserPlaylist = isUser;
                    previousTab = currentTab;
                    currentTab = TabItem
                        .playlistDetail; // PlaylistDetail sayfası için yeni bir index
                  });
                },
              ),
              ProfileView(
                onPlaylistSelected: (playlistId, isUser) {
                  setState(() {
                    selectedPlaylistId = playlistId;
                    isUserPlaylist = isUser;
                    previousTab = currentTab;
                    currentTab = TabItem
                        .playlistDetail; // PlaylistDetail sayfası için yeni bir index
                  });
                },
                onBack: () {
                  setState(() {
                    currentTab = TabItem.home;
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
                            currentTab = previousTab ?? TabItem.home;
                          });
                        },
                      )
                    : PlaylistDetail(
                        key: ValueKey(
                            selectedPlaylistId), // State'i yeniden inşa etmek için key kullanıyoruz
                        playlistId: selectedPlaylistId!,
                        onBack: () {
                          setState(() {
                            currentTab = previousTab ?? TabItem.home;
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
            currentIndex: currentTab.index < 3 ? currentTab.index : 0,
            onTap: (currentIndex) {
              setState(() {
                currentTab = TabItem.values[currentIndex];
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
