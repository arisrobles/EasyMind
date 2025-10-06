import 'package:flutter/material.dart';
import 'PictureStoryReading.dart'; // Make sure this file exists
import 'SoftLoudSoundsPage.dart'; // Make sure this file exists
import 'TexttoSpeech.dart'; // ✅ Import your TTS + STT file

class CommunicationSkillsPage extends StatelessWidget {
  final String nickname;
  const CommunicationSkillsPage({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Go Back Button
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  height: 50,
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF648BA2),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Let's Start Learning",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4E69),
                ),
              ),
              const SizedBox(height: 16),

              // List of Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildImageCard(
                      context,
                      'assets/story.png',
                      PictureStoryReading(nickname: nickname),
                      'Picture Story Reading',
                    ),
                    _buildImageCard(
                      context,
                      'assets/Sounds.webp',
                      SoftLoudSoundsPage(nickname: nickname),
                      'Soft & Loud Sounds',
                    ),
                    _buildImageCard(
                      context,
                      'assets/communication.png',
                      LearningMaterialsPage(nickname: nickname),
                      'Text to Speech Learning',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Image card builder
  Widget _buildImageCard(
    BuildContext context,
    String imagePath,
    Widget destination,
    String labelText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => destination),
                ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  height: 200,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              labelText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4E69),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
