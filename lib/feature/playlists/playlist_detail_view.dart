import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/providers/playlist_detail_notifier.dart';
import 'package:spotifyclone_app/feature/providers/player_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/feature/playlists/music_item.dart';

class PlaylistDetailView extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final String playlistId;

  const PlaylistDetailView(
      {required this.onBack, required this.playlistId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaylistDetailViewState();
}

class _PlaylistDetailViewState extends ConsumerState<PlaylistDetailView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final playlistNotifier = ref.read(playlistDetailProvider.notifier);
      playlistNotifier.fetchPlaylistDetails(widget.playlistId);
    });
  }

  @override
  void didUpdateWidget(PlaylistDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playlistId != widget.playlistId) {
      Future.microtask(
        () {
          final playlistNotifier = ref.read(playlistDetailProvider.notifier);
          playlistNotifier.clearPlaylist();
          playlistNotifier.fetchPlaylistDetails(widget.playlistId);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistDetailProvider);
    final sizeWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 125, 23, 23),
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          playlistState.playlist.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 125, 23, 23),
                        HexColor(backgroundColor),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 125, 23, 23),
                        HexColor(backgroundColor),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: sizeWidth * 0.6,
                              child: Image.network(
                                  playlistState.playlist['images'][0]['url']),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          playlistState.playlist['name'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Playlist • ${playlistState.playlist['tracks']['total']} songs',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: FloatingActionButton(
                                      onPressed: () {
                                        // ref
                                        //     .read(playerProvider.notifier)
                                        //     .playMusic(playlistState.tracks[0]
                                        //         ['track']);
                                      },
                                      backgroundColor: HexColor(spotifyGreenColor),
                                      shape: const CircleBorder(),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: playlistState.tracks.length,
                          itemBuilder: (context, index) {
                            final track = playlistState.tracks[index]['track'];
                            return MusicItem(
                                musicTitle: track['name'],
                                artist: track['artists'][0]['name'] ?? '',
                                music: track,
                                imageUrl: track['album']['images'][0]['url']);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
