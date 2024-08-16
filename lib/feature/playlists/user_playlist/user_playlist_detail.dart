import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/tabs/player_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/product/widget/music_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPlaylistDetail extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final String playlistId;

  const UserPlaylistDetail(
      {required this.onBack, required this.playlistId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserPlaylistDetailState();
}

class _UserPlaylistDetailState extends ConsumerState<UserPlaylistDetail> {
  Map<String, dynamic>? _playlist;
  List<dynamic>? _tracks;

  @override
  void initState() {
    super.initState();
    fetchPlaylistDetails();
  }

  Future<void> fetchPlaylistDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .doc(widget.playlistId)
          .get();

      if (snapshot.exists) {
        setState(() {
          _playlist = snapshot.data() as Map<String, dynamic>?;
          _tracks = _playlist?['songs'] ?? [];
        });
      } else {
        print('Playlist not found');
      }
    } catch (e) {
      print('Failed to fetch playlist details: $e');
    }
  }

  @override
  void didUpdateWidget(UserPlaylistDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playlistId != widget.playlistId) {
      fetchPlaylistDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(backgroundColor),
      appBar: AppBar(
        backgroundColor: HexColor(backgroundColor),
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          _playlist == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_playlist?['songs'] != null &&
                              _playlist!['songs'].isNotEmpty)
                            SizedBox(
                              height: 180,
                              width: 180,
                              child: Image.network(_playlist!['songs'][0]
                                  ['album']['images'][0]['url']),
                            )
                          else
                            Container(
                              height: 180,
                              width: 180,
                              color: Colors.grey,
                              child: const Center(
                                child: Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 100,
                                ),
                              ),
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
                                      _playlist?['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _playlist?['owner'] ?? 'Unknown',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 18),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Playlist • ${_tracks?.length ?? 0} songs',
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
                                    if (_tracks != null &&
                                        _tracks!.isNotEmpty) {
                                      ref
                                          .read(playerProvider.notifier)
                                          .playMusic(_tracks![0]);
                                    }
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
                        itemCount: _tracks?.length ?? 0,
                        itemBuilder: (context, index) {
                          final track = _tracks![index];
                          return MusicItem(
                            musicTitle: track['name'],
                            artist: track['artists'][0]['name'],
                            music: _tracks![index],
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
