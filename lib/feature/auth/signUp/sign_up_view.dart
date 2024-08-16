import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/auth/login/sign_in_view.dart';
import 'package:spotifyclone_app/feature/auth/signUp/password_information_viewdart';
import 'package:spotifyclone_app/feature/auth/signUp/sign_up_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/product/constants/string_constants.dart';

class SignUpView extends ConsumerWidget {
  SignUpView({super.key});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpNotifier = ref.read(signUpProvider.notifier);

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
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Dinlemeye başlamak",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            const Text(
              "için kaydol",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                      StringConstants.titleMail,
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: StringConstants.textFieldHintExampleMail,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: HexColor(whiteColor),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                backgroundColor: HexColor(spotifyGreenColor),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18)),
                            onPressed: () async {
                              final message = await signUpNotifier.setEmail(
                                emailController.text,
                              );
                              if (message == null) {
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => PasswodInfermationView()));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              StringConstants.signUpNextButtonTitle,
                              style: TextStyle(
                                  fontSize: 18, color: HexColor(blackColor)),
                            )),
                      ),
                    ),
                  ),
                  const Padding(
                    padding:  EdgeInsets.symmetric(vertical: 30),
                    child: Divider(
                      indent: 25,
                      endIndent: 25,
                    ),
                  ),
                  _SignInCustomButton(
                    title: StringConstants.signUpButtonTitleGoogle,
                    icon: FontAwesomeIcons.google,
                    onPressed: () {},
                  ),
                  _SignInCustomButton(
                    title: StringConstants.signUpButtonTitleFacebook,
                    icon: FontAwesomeIcons.facebook,
                    onPressed: () {},
                  ),
                  _SignInCustomButton(
                    title: StringConstants.signUpButtonTitleApple,
                    icon: FontAwesomeIcons.apple,
                    onPressed: () {},
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CustomText(
                          isUnderlined: false,
                          title: StringConstants.doYouHaveAnAccount,
                          isOppacity: true),
                      const SizedBox(
                        width: 5,
                      ),
                      _CustomText(
                        isUnderlined: true,
                        title: StringConstants.signUpHere,
                        isOppacity: false,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SignInView(),
                          ));
                        },
                      ),
                    ],
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
