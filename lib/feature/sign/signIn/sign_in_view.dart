import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/product/constants/string_constants.dart';

class SignInView extends ConsumerWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 100),
              child: Image.asset(
                'assets/icon/app_icon.png',
                height: 40,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 37),
              child: Text(
                "Spotify'da oturum aç",
                style: TextStyle(fontSize: 35),
              ),
            ),
            _SignInCustomButton(
              title: StringConstants.signInButtonTitleGoogle,
              icon: FontAwesomeIcons.google,
              onPressed: () {},
            ),
            _SignInCustomButton(
              title: StringConstants.signInButtonTitleFacebook,
              icon: FontAwesomeIcons.facebook,
              onPressed: () {},
            ),
            _SignInCustomButton(
              title: StringConstants.signInButtonTitleApple,
              icon: FontAwesomeIcons.apple,
              onPressed: () {},
            ),
            SizedBox(
              height: 30,
            ),
            Divider(
              indent: 25,
              endIndent: 25,
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      StringConstants.textFieldHintTitleMail,
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: StringConstants.textFieldHintTitleMail,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: HexColor(whiteColor),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 20),
                    child: Text(
                      StringConstants.textFieldHintTitlePassword,
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: () {}, icon: Icon(Icons.visibility_off)),
                      hintText: StringConstants.textFieldHintTitlePassword,
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
                                padding: EdgeInsets.symmetric(vertical: 18)),
                            onPressed: () {},
                            child: Text(
                              StringConstants.signInButtonTitle,
                              style: TextStyle(
                                  fontSize: 18, color: HexColor(blackColor)),
                            )),
                      ),
                    ),
                  ),
                  _CustomText(
                      isOppacity: false,
                      isUnderlined: true,
                      title: StringConstants.forgotYourPassword),
                  _CustomText(
                      isUnderlined: false,
                      title: StringConstants.dontYouHaveAnAccount,
                      isOppacity: true),
                  _CustomText(
                      isUnderlined: true,
                      title: StringConstants.signUpForSpotify,
                      isOppacity: false),
                  SizedBox(
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

  Padding _CustomText(
      {required bool isUnderlined,
      required String title,
      required bool isOppacity}) {
    return Padding(
      padding: EdgeInsets.only(top: 40),
      child: Center(
        child: RichText(
          text: TextSpan(
            text: title,
            style: TextStyle(
                fontSize: 18,
                color:
                    isOppacity ? Colors.white.withOpacity(0.6) : Colors.white,
                decoration: isUnderlined
                    ? TextDecoration.underline
                    : TextDecoration.none),
            recognizer: TapGestureRecognizer()..onTap = () {},
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
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
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
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
