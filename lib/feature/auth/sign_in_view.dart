import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/providers/sign_in_notifier.dart';
import 'package:spotifyclone_app/feature/auth/sign_up_view.dart';
import 'package:spotifyclone_app/feature/providers/sign_up_notifier.dart';
import 'package:spotifyclone_app/feature/tabs/tab_view.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/product/constants/string_constants.dart';

class SignInView extends ConsumerWidget {
  SignInView({super.key});

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signInNotifier = ref.watch(signInProvider.notifier);
    final isObscured =
        ref.watch(signInProvider.select((state) => state.isObscured));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Image.asset(
                'assets/icon/app_icon.png',
                height: 40,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 37),
              child: Text(
                "Spotify'da oturum aç",
                style: TextStyle(fontSize: 35),
              ),
            ),
            _SignInCustomButton(
              title: StringConstants.signInButtonTitleGoogle,
              icon: FontAwesomeIcons.google,
              onPressed: () async {
                final String? result =
                    await ref.read(signUpProvider.notifier).signInWithGoogle();

                if (result == 'Success') {
                  // Başarılı giriş yapıldı, yönlendirme yapıyoruz
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const TabView()), // Ana sayfanıza yönlendirin
                  );
                } else {
                  // Hata mesajını göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result ?? 'Bilinmeyen bir hata oluştu.'),
                    ),
                  );
                }
              },
            ),
            _SignInCustomButton(
              title: StringConstants.signInButtonTitleApple,
              icon: FontAwesomeIcons.apple,
              onPressed: () async {
                final String? result =
                    await ref.read(signUpProvider.notifier).signInWithApple();

                if (result == 'Success') {
                  // Başarılı giriş yapıldı, yönlendirme yapıyoruz
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const TabView()), // Ana sayfanıza yönlendirin
                  );
                } else {
                  // Hata mesajını göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result ?? 'Bilinmeyen bir hata oluştu.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              indent: 25,
              endIndent: 25,
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      StringConstants.textFieldHintTitleMail,
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: StringConstants.textFieldHintTitleMail,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: HexColor(whiteColor),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10, top: 20),
                    child: Text(
                      StringConstants.titlePassword,
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  TextField(
                    obscureText: isObscured,
                    controller: passwordController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscured ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          signInNotifier.toggleObscureText();
                        },
                      ),
                      hintText: StringConstants.titlePassword,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: HexColor(whiteColor),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                backgroundColor: HexColor(spotifyGreenColor),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18)),
                            onPressed: () async {
                              final message = await signInNotifier.login(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              if (message!.contains('Success')) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => const TabView()));
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                ),
                              );
                            },
                            child: Text(
                              StringConstants.signInButtonTitle,
                              style: TextStyle(
                                  fontSize: 18, color: HexColor(blackColor)),
                            )),
                      ),
                    ),
                  ),
                  // _CustomText(
                  //     isOppacity: false,
                  //     isUnderlined: true,
                  //     title: StringConstants.forgotYourPassword),
                  _CustomText(
                      isUnderlined: false,
                      title: StringConstants.dontYouHaveAnAccount,
                      isOppacity: true),
                  _CustomText(
                    isUnderlined: true,
                    title: StringConstants.signUpForSpotify,
                    isOppacity: false,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignUpView(),
                      ));
                    },
                  ),
                  const SizedBox(
                    height: 140,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding _CustomText({
    required bool isUnderlined,
    required String title,
    required bool isOppacity,
    VoidCallback?
        onTap, // Tıklanma özelliği eklemek için bir callback fonksiyonu
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: RichText(
          text: TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 18,
              color: isOppacity ? Colors.white.withOpacity(0.6) : Colors.white,
              decoration:
                  isUnderlined ? TextDecoration.underline : TextDecoration.none,
            ),
            recognizer: isUnderlined && onTap != null
                ? (TapGestureRecognizer()..onTap = onTap)
                : null, // Eğer altı çizili ve onTap varsa, tıklanabilir yap
          ),
        ),
      ),
    );
  }
}

class _SignInCustomButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  const _SignInCustomButton({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
