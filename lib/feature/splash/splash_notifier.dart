import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/feature/search/search_notifier.dart'; // Diğer Notifier'ların import edilmesi
import 'package:spotifyclone_app/feature/home/home_notifier.dart';
import 'package:spotifyclone_app/feature/library/library_notifier.dart';

class SplashState {
  final bool isLoadingComplete;

  SplashState({required this.isLoadingComplete});

  SplashState copyWith({bool? isLoadingComplete}) {
    return SplashState(
      isLoadingComplete: isLoadingComplete ?? this.isLoadingComplete,
    );
  }
}

class SplashNotifier extends StateNotifier<SplashState> {
  SplashNotifier(this.ref) : super(SplashState(isLoadingComplete: false));

  final Ref ref;

  Future<void> loadData() async {
    // Tüm veri çekme işlemlerini başlatıyoruz
    try {
      await Future.wait([
        ref.read(searchProvider.notifier).fetchCategories(),
        ref.read(homeProvider.notifier).fetchFeaturedPlaylists(),
        ref.read(homeProvider.notifier).fetchMusic(),
        ref.read(libraryProvider.notifier).fetchPlaylists(), // LibraryNotifier'dan veri çekme
      ]);

      // Veri çekme işlemleri tamamlandıktan sonra isLoadingComplete flag'ini true yapıyoruz
      state = state.copyWith(isLoadingComplete: true);
    } catch (e) {
      // Hata yönetimi
      print("Veri çekme hatası: $e");
    }
  }
}

final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>((ref) {
  return SplashNotifier(ref);
});
