import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/feature/tabs/player_notifier.dart';

class MusicItem extends ConsumerWidget {
  final String musicTitle;
  final String artist;
  final dynamic music;
  final String imageUrl;

  const MusicItem({
    super.key,
    required this.musicTitle,
    required this.artist,
    required this.music,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        // width: 50, // Resim genişliği
        // height: 50, // Resim yüksekliği
      ),
      title: Text(
        musicTitle,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        artist,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(
        Icons.more_horiz,
        color: Colors.white,
        size: 20,
      ),
      onTap: () {
        ref.read(playerProvider.notifier).playMusic(music);
      },
    );
  }
}
