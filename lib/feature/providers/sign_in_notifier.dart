import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInState {
  final bool isLoading;
  final bool isObscured;

  SignInState({
    this.isLoading = false,
    this.isObscured = true,
  });

  SignInState copyWith({
    String? errorMessage,
    bool? isLoading,
    bool? isObscured,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      isObscured: isObscured ?? this.isObscured,
    );
  }
}

class SignInNotifier extends StateNotifier<SignInState> {
  final FirebaseAuth _auth;

  SignInNotifier({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(SignInState());

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (email.isEmpty || password.isEmpty) {
        return 'E-posta ya da şifre alanı boş bırakılamaz';
      } else {
        if (e.code == 'user-not-found') {
          return 'Bu e-posta için kullanıcı bulunamadı.';
        } else if (e.code == 'wrong-password') {
          return 'Bu kullanıcı için yanlış şifre girildi.';
        } else if (e.code == 'invalid-email') {
          return 'Geçersiz e-posta formatı.';
        } else if (e.code == 'invalid-credential') {
          return 'Sağlanan kimlik bilgileri geçersiz';
        } else if (e.code == 'wrong-password') {
          return 'Girilen şifre yanlış';
        } else {
          return e.message;
        }
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void toggleObscureText() {
    state = state.copyWith(isObscured: !state.isObscured);
  }
}

final signInProvider =
    StateNotifierProvider<SignInNotifier, SignInState>((ref) {
  return SignInNotifier();
});
