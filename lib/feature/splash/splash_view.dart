import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/providers/splash_notifier.dart';
import 'package:spotifyclone_app/feature/tabs/tab_view.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashProvider);

    // Veri çekme işlemi tamamlandığında ana ekrana yönlendir
    if (splashState.isLoadingComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TabView()),
        );
      });
    } else {
      // Veri çekme işlemini başlat
    }
    ref.read(splashProvider.notifier).loadData();

    // Yükleme ekranı göster
    return Scaffold(
      backgroundColor: HexColor(backgroundColor),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/app_icon.png',
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}
