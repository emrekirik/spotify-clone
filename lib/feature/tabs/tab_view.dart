import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotifyclone_app/feature/playlists/playlist_detail_view.dart';
import 'package:spotifyclone_app/feature/playlists/user_playlist_detail_view.dart';
import 'package:spotifyclone_app/feature/profile/profile_view.dart';
import 'package:spotifyclone_app/feature/search/category_detail_view.dart';
import 'package:spotifyclone_app/feature/providers/player_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/feature/home/home_view.dart';
import 'package:spotifyclone_app/feature/library/library.dart';
import 'package:spotifyclone_app/feature/search/search.dart';
import 'package:spotifyclone_app/product/models/tab_item_enum.dart';
import 'package:spotifyclone_app/product/widget/mini_player.dart';
import 'package:spotifyclone_app/feature/auth/sign_in_view.dart';
import 'package:spotifyclone_app/feature/providers/sign_in_notifier.dart';

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
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _loadUser() {
    currentUser = FirebaseAuth.instance.currentUser;
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
      case TabItem.profile:
        return 'Profil';
      case TabItem.categoryDetail:
        return 'Kategori Detay';
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final signInNotifier = ref.read(signInProvider.notifier);

    // Oturum kontrolü
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        player.stop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignInView(),
          ),
        );
      });
      return const SizedBox();
    }

    return Scaffold(
      appBar: currentTab != TabItem.playlistDetail &&
              currentTab != TabItem.profile &&
              currentTab != TabItem.categoryDetail
          ? AppBar(
              backgroundColor: HexColor(backgroundColor),
              centerTitle: false,
              title: Text(_getAppBarTitle()),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      previousTab = currentTab;
                      currentTab = TabItem.profile;
                    });
                  },
                  child: currentUser?.photoURL != null &&
                          currentUser!.photoURL!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            currentUser!.photoURL!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person,
                                  size: 40, color: Colors.white);
                            },
                          ),
                        )
                      : const Icon(Icons.person, size: 40, color: Colors.white),
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
                  currentTab = TabItem.playlistDetail;
                });
              }),
              SearchScreen(
                onCategorySelected: (categoryId) {
                  setState(() {
                    selectedCategoryId = categoryId;
                    currentTab = TabItem.categoryDetail;
                  });
                },
              ),
              LibraryScreen(
                onPlaylistSelected: (playlistId, isUser) {
                  setState(() {
                    selectedPlaylistId = playlistId;
                    isUserPlaylist = isUser;
                    previousTab = currentTab;
                    currentTab = TabItem.playlistDetail;
                  });
                },
              ),
              ProfileView(
                onPlaylistSelected: (playlistId, isUser) {
                  setState(() {
                    selectedPlaylistId = playlistId;
                    isUserPlaylist = isUser;
                    previousTab = currentTab;
                    currentTab = TabItem.playlistDetail;
                  });
                },
                onBack: () {
                  setState(() {
                    currentTab = previousTab ?? TabItem.home;
                  });
                },
              ),
              selectedCategoryId != null
                  ? CategoryDetailView(
                      key: ValueKey(selectedCategoryId),
                      categoryId: selectedCategoryId!,
                      onPlaylistSelected: (playlistId, isUser) {
                        setState(() {
                          selectedPlaylistId = playlistId;
                          previousTab = currentTab;
                          currentTab = TabItem.playlistDetail;
                        });
                      },
                      onBack: () {
                        setState(() {
                          currentTab = TabItem.search;
                        });
                      },
                    )
                  : const SizedBox
                      .shrink(), // Eğer `selectedCategoryId` null ise placeholder widget
              selectedPlaylistId != null
                  ? isUserPlaylist
                      ? UserPlaylistDetailView(
                          key: ValueKey(selectedPlaylistId),
                          playlistId: selectedPlaylistId!,
                          onBack: () {
                            setState(() {
                              currentTab = previousTab ?? TabItem.home;
                            });
                          },
                        )
                      : PlaylistDetailView(
                          key: ValueKey(selectedPlaylistId),
                          playlistId: selectedPlaylistId!,
                          onBack: () {
                            setState(() {
                              currentTab = previousTab ?? TabItem.home;
                            });
                          },
                        )
                  : const SizedBox
                      .shrink(), // Eğer `selectedPlaylistId` null ise placeholder widget
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
