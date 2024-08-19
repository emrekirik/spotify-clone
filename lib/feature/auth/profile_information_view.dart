import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spotifyclone_app/feature/providers/sign_up_notifier.dart';
import 'package:spotifyclone_app/feature/tabs/tab_view.dart';
import 'package:spotifyclone_app/product/constants/color_constants.dart';
import 'package:spotifyclone_app/product/constants/string_constants.dart';
import 'package:spotifyclone_app/product/models/gender_enum.dart';

class ProfileInformationView extends ConsumerWidget {
  ProfileInformationView({super.key});

  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpState = ref.watch(signUpProvider);
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
                "Bize kendinden bahset",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding:const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding:  EdgeInsets.only(bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringConstants.titleName,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(StringConstants.subtitleName),
                      ],
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Adınız",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: HexColor(whiteColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StringConstants.titleBirthday,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        StringConstants.subtitleBirthday,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: signUpState.selectedDate != null
                          ? "${signUpState.selectedDate!.day}/${signUpState.selectedDate!.month}/${signUpState.selectedDate!.year}"
                          : "Gün/Ay/Yıl",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: HexColor(whiteColor),
                        ),
                      ),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (picked != null) {
                        signUpNotifier.setDate(picked);
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StringConstants.titleGender,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        StringConstants.subtitleGender,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              title: const Text(
                                'Erkek',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              leading: Radio<Gender>(
                                value: Gender.male,
                                groupValue: signUpState.selectedGender,
                                onChanged: (Gender? value) {
                                  if (value != null) {
                                    signUpNotifier.setGender(value);
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              title: const Text(
                                'Kadın',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              leading: Radio<Gender>(
                                value: Gender.female,
                                groupValue: signUpState.selectedGender,
                                onChanged: (Gender? value) {
                                  if (value != null) {
                                    signUpNotifier.setGender(value);
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              title: const Text(
                                'Diğer',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              leading: Radio<Gender>(
                                value: Gender.other,
                                groupValue: signUpState.selectedGender,
                                onChanged: (Gender? value) {
                                  if (value != null) {
                                    signUpNotifier.setGender(value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
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
                              signUpNotifier.setName(nameController.text);
                              final message =
                                  await signUpNotifier.registration();
                              if (message != null &&
                                  message.contains('Success')) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const TabView(),
                                  ),
                                );
                              } else if (message != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                  ),
                                );
                              } else {
                                // Bu durum, eğer message null ise bir hata olabilir veya farklı bir durum olabilir
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Bilinmeyen bir hata oluştu.'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              StringConstants.signUpText,
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
