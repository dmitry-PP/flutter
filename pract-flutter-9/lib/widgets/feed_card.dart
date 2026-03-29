import 'dart:io';
import 'package:flutter/material.dart';
import '../models/media_item.dart';

class FeedCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;

  const FeedCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          item.isVideo
              ? Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow_sharp,
                      size: 32,
                      color: Colors.white10,
                    ),
                  ),
                )
              : Image.file(File(item.path), fit: BoxFit.cover),
          if (item.isVideo)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.videocam_sharp,
                size: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
