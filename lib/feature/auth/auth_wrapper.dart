import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotifyclone_app/feature/auth/sign_in_view.dart';
import 'package:spotifyclone_app/feature/tabs/tab_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kullanıcı oturum açmışsa TabView sayfasına yönlendirin
      return const TabView();
    } else {
      // Kullanıcı oturum açmamışsa SignInView sayfasına yönlendirin
      return SignInView();
    }
  }
}
