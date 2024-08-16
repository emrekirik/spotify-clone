import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/tabs/player_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/feature/tabs/music_page.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({
    required this.music,
    required this.stop,
    super.key,
  });

  final dynamic music;
  final bool stop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final playerNotifier = ref.watch(playerProvider.notifier);
    Size deviceSize = MediaQuery.of(context).size;

    return music == null
        ? const SizedBox()
        : GestureDetector(
            onTap: () {
              Navigator.of(context).push(musicPageRoute(music));
            },
            child: AnimatedContainer(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: HexColor(miniPlayerBackgroundColor)),
              duration: const Duration(milliseconds: 500),
              width: deviceSize.width,
              height: 56,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      music['album']['images'][0]['url'],
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              music['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              music['artists'][0]['name'],
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            )
                          ]),
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
                              Icons.pause,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

PageRouteBuilder musicPageRoute(dynamic music) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MusicPage(
      music: music,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end);
      var curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );
      var offsetAnimation = tween.animate(curvedAnimation);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
