import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/playlists/spotify_playlist/playlist_detail_provider.dart';
import 'package:spotifyclone_app/feature/tabs/player_provider.dart';
import 'package:spotifyclone_app/product/constants/color.dart';
import 'package:spotifyclone_app/product/widget/music_item.dart';

class PlaylistDetail extends ConsumerStatefulWidget {
  final String playlistId;
  final VoidCallback onBack;
  const PlaylistDetail(
      {required this.playlistId, required this.onBack, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends ConsumerState<PlaylistDetail> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final playlistNotifier = ref.read(playlistDetailProvider.notifier);
      playlistNotifier.fetchPlaylistDetails(widget.playlistId);
    });
  }

  @override
  void didUpdateWidget(PlaylistDetail oldWidget) {
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

    return Scaffold(
      backgroundColor: HexColor(backgroundColor),
      appBar: AppBar(
        backgroundColor: HexColor(backgroundColor),
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          playlistState.playlist.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 180,
                            width: 180,
                            child: Image.network(
                                playlistState.playlist['images'][0]['url']),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      playlistState.playlist['name'],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      playlistState.playlist['owner']
                                          ['display_name'],
                                      style: const TextStyle(
                                          color: Color.fromARGB(179, 2, 1, 1),
                                          fontSize: 18),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Playlist • ${playlistState.playlist['tracks']['total']} songs',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 100),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    ref.read(playerProvider.notifier).playMusic(
                                        playlistState.tracks[0]['track']);
                                  },
                                  backgroundColor: Colors.green,
                                  shape: const CircleBorder(),
                                  child: const Icon(Icons.play_arrow),
                                ),
                              ),
                            ],
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
                            artist: track['artists'][0]['name'],
                            music: track,
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
