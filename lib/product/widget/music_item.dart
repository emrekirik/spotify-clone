import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/feature/tabs/player_notifier.dart';

class MusicItem extends ConsumerWidget {
  final String musicTitle;
  final String artist;
  final dynamic music;

  const MusicItem({
    super.key,
    required this.musicTitle,
    required this.artist,
    required this.music,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        musicTitle,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        artist,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      onTap: () {
        ref.read(playerProvider.notifier).playMusic(music);
      },
    );
  }
}
