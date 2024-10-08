import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/auth/profile_information_view.dart';
import 'package:spotifyclone_app/feature/providers/sign_up_notifier.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/product/constants/string_constants.dart';

class PasswordInformationView extends ConsumerWidget {
  PasswordInformationView({super.key});

  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpNotifier = ref.read(signUpProvider.notifier);
    final isObscured =
        ref.watch(signUpProvider.select((state) => state.isObscured));

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
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Parola oluştur",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
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
                    padding:  EdgeInsets.only(bottom: 10),
                    child: Text(
                      StringConstants.titlePassword,
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: isObscured,
                    controller: passwordController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscured ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          signUpNotifier.toggleObscureText();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: HexColor(whiteColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                backgroundColor: HexColor(spotifyGreenColor),
                                padding: EdgeInsets.symmetric(vertical: 18)),
                            onPressed: () async {
                              final message = await signUpNotifier.setPassword(
                                passwordController.text,
                              );
                              if (message == null) {
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileInformationView()));
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
