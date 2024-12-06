import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/providers/player_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/feature/playlists/music_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPlaylistDetailView extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final String playlistId;

  const UserPlaylistDetailView(
      {required this.onBack, required this.playlistId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserPlaylistDetailViewState();
}

class _UserPlaylistDetailViewState
    extends ConsumerState<UserPlaylistDetailView> {
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
  void didUpdateWidget(UserPlaylistDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playlistId != widget.playlistId) {
      fetchPlaylistDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _playlist == null
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
                            if (_playlist?['songs'] != null &&
                                _playlist!['songs'].isNotEmpty)
                              SizedBox(
                                width: sizeWidth * 0.6,
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
                                          _playlist?['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          _playlist?['owner'] ?? 'Unknown',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          'Playlist • ${_tracks?.length ?? 0} songs',
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
                                        // if (_tracks != null &&
                                        //     _tracks!.isNotEmpty) {
                                        //   ref
                                        //       .read(playerProvider.notifier)
                                        //       .playMusic(_tracks![0]);
                                        // }
                                      },
                                      backgroundColor:
                                          HexColor(spotifyGreenColor),
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
                          itemCount: _tracks?.length ?? 0,
                          itemBuilder: (context, index) {
                            final track = _tracks![index];
                            return MusicItem(
                                musicTitle: track['is_audius'] == true
                                    ? track['title']
                                    : track['name'],
                                artist:track['is_audius'] == true ? track['artist']: track['artists'][0]['name'],
                                music: _tracks![index],
                                imageUrl: track['is_audius'] == true
                                    ? track['artwork']
                                    : track['album']['images'][0]['url']);
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
