import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final String message;
  const CustomAppbar({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      title: Text(message, style: const TextStyle(color: Colors.white)),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(Icons.settings),
        ),
      ],
    );
  }
}
