import 'package:flutter/material.dart';

Widget buildFileImage(String filePath) {
  return Image.network(
    filePath,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => const SizedBox(
      height: 200,
      child: Center(child: Icon(Icons.broken_image, size: 48)),
    ),
  );
}
