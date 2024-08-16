import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotifyclone_app/feature/library/library_notifier.dart';

class ProfileView extends ConsumerStatefulWidget {
  final Function(String, bool) onPlaylistSelected;
  final VoidCallback onBack;
  const ProfileView(
      {required this.onBack, required this.onPlaylistSelected, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  User? currentUser; // currentUser nesnesi
  String? newPhotoURL;

  final ImagePicker _picker = ImagePicker(); // ImagePicker nesnesi
  File? _imageFile; // Seçilen fotoğraf dosyası
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile(); // Kullanıcı profil verilerini yükleme
    Future.microtask(() => ref.read(libraryProvider.notifier).fetchPlaylists());
  }

  // FirebaseAuth'tan currentUser'ı çek
  void _loadCurrentUserProfile() {
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser; // currentUser'ı yükle
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final fileSize = await pickedFile.length();
        if (fileSize > 5 * 1024 * 1024) {
          // 5 MB limit
          print('Dosya çok büyük. Lütfen daha küçük bir dosya seçin.');
          return;
        }

        setState(() {
          _isUploading = true; // Yükleme başlıyor
        });

        _imageFile = File(pickedFile.path);
        String fileName =
            'profile_pictures/${currentUser!.uid}.jpg'; // JPEG formatı
        UploadTask uploadTask =
            FirebaseStorage.instance.ref().child(fileName).putFile(_imageFile!);

        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();

        await updateProfilePhotoURL(downloadURL);
      }
    } catch (e, stackTrace) {
      print('Fotoğraf seçilirken hata oluştu: $e');
      print('Hata Yığını: $stackTrace');
    } finally {
      setState(() {
        _isUploading = false; // Yükleme tamamlandı
      });
    }
  }

  Future<void> updateProfilePhotoURL(String newPhotoURL) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Auth'daki profile photo'yu güncelle
        await user.updateProfile(photoURL: newPhotoURL);
        await user.reload();
        User? updatedUser = FirebaseAuth.instance.currentUser;

        // Firestore'daki kullanıcı dökümanını güncelle
        await FirebaseFirestore.instance
            .collection('users') // Koleksiyon adınızı girin
            .doc(user.uid)
            .update({'photoURL': newPhotoURL});

        setState(() {
          currentUser = updatedUser;
        });

        print('Profil fotoğrafı güncellendi: ${updatedUser?.photoURL}');
      }
    } catch (e) {
      print('Profil güncellenirken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    String? displayName = currentUser?.displayName ?? 'User';
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: widget.onBack,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: kToolbarHeight + 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey.shade700, Colors.black],
                  ),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap:
                          _pickAndUploadImage, // Profil fotoğrafına tıklanınca fotoğraf seç
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: currentUser?.photoURL != null
                                ? NetworkImage(currentUser!.photoURL!)
                                : null,
                            child:
                                currentUser?.photoURL == null && !_isUploading
                                    ? const Icon(Icons.person, size: 60)
                                    : null,
                          ),
                          if (_isUploading)
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Çalma Listeleri",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: libraryState.playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = libraryState.playlists[index];
                            return _buildPlaylistItem(playlist);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Çalma listesi öğesi oluşturma
  Widget _buildPlaylistItem(Map<String, dynamic> playlist) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Image.network(
          playlist['songs'][0]['album']['images'][0]['url'],
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.music_note, size: 100, color: Colors.grey);
          },
        ),
        title: Text(
          playlist['name'],
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () {
          widget.onPlaylistSelected(playlist['id'], true);
        },
      ),
    );
  }
}
