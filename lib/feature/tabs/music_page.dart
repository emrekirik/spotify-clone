import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/feature/tabs/player_notifier.dart';
import 'package:spotifyclone_app/product/widget/playlist_add_bottom_sheet.dart';


class MusicPage extends ConsumerWidget {
  final dynamic music;

  const MusicPage({required this.music, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final playerNotifier = ref.read(playerProvider.notifier);

    return Scaffold(
      backgroundColor: HexColor(miniPlayerBackgroundColor),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_downward, color: Colors.white),
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
              Icons.more_vert,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              music['album']['images'][0]['url'],
              fit: BoxFit.cover,
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
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
              style: const TextStyle(color: Colors.white70, fontSize: 20),
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
                      size: 64,
                    )
                  : const Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 64,
                    ),
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
