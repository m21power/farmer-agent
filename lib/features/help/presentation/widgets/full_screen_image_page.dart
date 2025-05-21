import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final dynamic image;
  const FullScreenImagePage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    print(image);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: image is String
            ? (image.startsWith('http')
                ? Image.network(image, fit: BoxFit.contain)
                : Image.asset(image, fit: BoxFit.contain))
            : Image.file(image, fit: BoxFit.contain),
      ),
    );
  }
}
