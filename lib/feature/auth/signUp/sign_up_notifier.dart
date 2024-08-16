import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotifyclone_app/product/models/gender_enum.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpState {
  final bool isObscured;
  final String? email;
  final String? password;
  final String? name;
  final String? photoURL;
  final Gender? selectedGender;
  final DateTime? selectedDate;
  final bool isLoading;

  SignUpState(
      {this.email,
      this.password,
      this.name,
      this.selectedGender = Gender.male,
      this.selectedDate,
      this.isLoading = false,
      this.photoURL,
      this.isObscured = true});

  SignUpState copyWith(
      {String? email,
      String? password,
      String? name,
      String? photoURL,
      Gender? selectedGender,
      DateTime? selectedDate,
      bool? isLoading,
      bool? isObscured}) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      isObscured: isObscured ?? this.isObscured,
      photoURL: photoURL ?? this.photoURL,
    );
  }
}

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier({FirebaseAuth? auth}) : super(SignUpState());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registration() async {
    if (state.email == null || state.password == null) {
      return 'Email ve şifre alanları boş olamaz.';
    }
    if (state.name == null || state.name!.isEmpty) {
      return 'İsim alanı boş olamaz.';
    }
    if (state.selectedDate == null) {
      return 'Doğum tarihi boş olamaz.';
    }

    try {
      // Kullanıcıyı Firebase Authentication'a kaydetme
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: state.email!,
        password: state.password!,
      );

      // Kullanıcının displayName'ini güncelleme
      await userCredential.user!.updateProfile(displayName: state.name);

      // Güncellenmiş kullanıcı verilerini almak için reload yapın
      await userCredential.user!.reload();

      // Kullanıcı bilgilerini Firestore'a kaydetme
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid, // userId ekleniyor
        'email': state.email,
        'name': state.name, // Display Name olarak da kullanılan isim
        'photoURL': state.photoURL ?? '', // photoURL ekleniyor
        'gender': state.selectedGender?.toString(),
        'birthdate': state.selectedDate?.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'Geçersiz e-posta formatı.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  // E-posta ayarlama
  Future<String?> setEmail(String email) async {
    if (email.isNotEmpty) {
      state = state.copyWith(email: email);
      return null;
    }
    return 'E-posta alanı boş olamaz';
  }

  // Şifre ayarlama
  Future<String?> setPassword(String password) async {
    if (password.isNotEmpty) {
      state = state.copyWith(password: password);
      return null;
    }
    return 'Şifre alanı boş olamaz';
  }

  // İsim ayarlama
  Future<String?> setName(String name) async {
    if (name.isNotEmpty) {
      state = state.copyWith(name: name);
      return null;
    }
    return 'İsim alanı boş olamaz';
  }
   // Profil fotoğrafı ayarlama
  Future<void> setPhotoURL(String photoURL) async {
    state = state.copyWith(photoURL: photoURL);
  }


  // Cinsiyet seçimi
  void setGender(Gender gender) {
    state = state.copyWith(selectedGender: gender);
  }

  // Doğum tarihi seçimi
  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void toggleObscureText() {
    state = state.copyWith(isObscured: !state.isObscured);
  }
}

final signUpProvider =
    StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
  return SignUpNotifier();
});
