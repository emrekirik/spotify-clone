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
  List<dynamic> _musicList = []; // Şarkı listesi
  int _currentTrackIndex = 0;

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
      print("Aynı şarkıyı tekrar çalıyor.");
      _player.seek(state.currentPosition);
      _player.play();
    } else if (track['stream_url'] != null) {
      await _player.setUrl(track['stream_url']);
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

  Future<void> stopMusic() async {
    await _player.stop();
    state = PlayerState(
      isPlaying: false,
      currentTrack: null,
      currentPosition: Duration.zero,
      duration: Duration.zero,
    );
  }

  void setMusicList(List<dynamic> musicList) {
    _musicList = musicList;
    _currentTrackIndex = 0; // Liste her ayarlandığında başlangıçtan başla
  }

// Getter for currentTrack
  dynamic get currentTrack => state.currentTrack;

  void playNextTrack() async {
    print("Mevcut şarkı: ${_musicList[_currentTrackIndex]['title']}");
    print("Stream URL: ${_musicList[_currentTrackIndex]['stream_url']}");
    print(_currentTrackIndex);
    if (_musicList.isNotEmpty && _currentTrackIndex + 1 < _musicList.length) {
      _currentTrackIndex++;
      await playMusic(_musicList[_currentTrackIndex]);
    } else {
      print("Son şarkıya ulaşıldı.");
    }
  }

  void playPreviousTrack() async {
    if (_musicList.isNotEmpty && _currentTrackIndex - 1 >= 0) {
      _currentTrackIndex--;
      await playMusic(_musicList[_currentTrackIndex]);
    } else {
      print("İlk şarkıya ulaşıldı.");
    }
  }

  @override
  void dispose() {
    _player.stop();
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
final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});
