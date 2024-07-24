import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

// Defining the state
class PlayerState {
  final bool isPlaying;
  final dynamic currentTrack;
  final Duration currentPosition;
  final Duration duration;

  PlayerState({
    required this.isPlaying,
    required this.currentTrack,
    required this.currentPosition,
    required this.duration,
  });
}

// Creating a StateNotifier for PlayerState
class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayer _player = AudioPlayer();

  PlayerNotifier()
      : super(PlayerState(
          isPlaying: false,
          currentTrack: null,
          currentPosition: Duration.zero,
          duration: Duration.zero,
        )) {
    _player.positionStream.listen((position) {
      state = PlayerState(
        isPlaying: state.isPlaying,
        currentTrack: state.currentTrack,
        currentPosition: position,
        duration: state.duration,
      );
    });

    _player.durationStream.listen((duration) {
      state = PlayerState(
        isPlaying: state.isPlaying,
        currentTrack: state.currentTrack,
        currentPosition: state.currentPosition,
        duration: duration ?? Duration.zero,
      );
    });
  }

  Future<void> playMusic(dynamic track) async {
    if (state.currentTrack == track && state.currentPosition > Duration.zero) {
      _player.seek(state.currentPosition);
      _player.play();
    } else if (track['preview_url'] != null) {
      await _player.setUrl(track['preview_url']);
      _player.play();
    }

    state = PlayerState(
      isPlaying: true,
      currentTrack: track,
      currentPosition: state.currentPosition,
      duration: state.duration,
    );
  }

  Future<void> pauseMusic() async {
    await _player.pause();
    state = PlayerState(
      isPlaying: false,
      currentTrack: state.currentTrack,
      currentPosition: state.currentPosition,
      duration: state.duration,
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    state = PlayerState(
      isPlaying: state.isPlaying,
      currentTrack: state.currentTrack,
      currentPosition: position,
      duration: state.duration,
    );
  }
}

// Creating a provider for PlayerNotifier
final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});
