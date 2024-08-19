import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/feature/providers/player_notifier.dart';
import 'package:spotifyclone_app/feature/playlists/playlist_add_bottom_sheet.dart';

class MusicPage extends ConsumerWidget {
  final dynamic music;

  const MusicPage({required this.music, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final playerNotifier = ref.read(playerProvider.notifier);
    final sizeWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 125, 23, 23),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/icon/down-arrow.png',
            color: Colors.white,
            height: 30,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          music['album']['name'],
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.white,
            ),
            onSelected: (String result) {
              if (result == 'add_to_library') {
                //kitaplığa ekle işlemi burada yapılacak
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0))),
                  builder: (context) => PlaylistAddBottomSheet(music: music),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'add_to_library',
                child: Text('Kitaplığa ekle'),
              )
            ],
          )
        ],
      ),
      body: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 60,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0), // Yuvarlatma miktarı
              child: Image.network(
                music['album']['images'][0]['url'],
                fit: BoxFit.cover,
                width: sizeWidth * 0.85,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      music['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      music['artists'][0]['name'],
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
            Slider(
              value: playerState.currentPosition.inSeconds.toDouble(),
              min: 0.0,
              max: playerState.duration.inSeconds.toDouble(),
              onChanged: (double value) {
                final position = Duration(seconds: value.toInt());
                playerNotifier.seek(position);
              },
              activeColor: Colors.white,
              inactiveColor: Colors.white54,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(playerState.currentPosition),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    _formatDuration(playerState.duration),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () async {
                    if (playerState.isPlaying) {
                      await playerNotifier.pauseMusic();
                    } else {
                      await playerNotifier.playMusic(music);
                    }
                  },
                  icon: playerState.isPlaying
                      ? const Icon(
                          Icons.pause_circle_filled,
                          color: Colors.white,
                          size: 90,
                        )
                      : const Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 90,
                        ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () async {},
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
