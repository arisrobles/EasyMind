import 'package:flutter/material.dart';
import 'shapes_activity_page.dart'; // Existing activity
import 'daily_tasks_module.dart'; // ← Placeholder for the new module page

class PreVocationalSkillsPage extends StatelessWidget {
  final String nickname;
  const PreVocationalSkillsPage({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 400 ? 12.0 : 20.0,
            vertical: MediaQuery.of(context).size.width < 400 ? 20.0 : 30.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  height: MediaQuery.of(context).size.width < 400 ? 50 : 60,
                  width: MediaQuery.of(context).size.width < 400 ? 140 : 180,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF648BA2),
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width < 400 ? 12 : 15,
                        horizontal: MediaQuery.of(context).size.width < 400 ? 16 : 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400 ? 20 : 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Enhanced title with emoji - responsive design
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 400 ? 12 : 20,
                  vertical: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF648BA2),
                      const Color(0xFF648BA2).withOpacity(0.8),
                      const Color(0xFF648BA2).withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF648BA2).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "🔧 ",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400 ? 24 : 32,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "Pre-Vocational Skills",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 400 ? 20 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: MediaQuery.of(context).size.width < 400 ? 0.8 : 1.2,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      " 🛠️",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400 ? 24 : 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: [
                    _buildImageCard(
                      context,
                      'assets/measuring.png',
                      labelText: 'Shapes Activity',
                      destination: ShapesActivityPage(nickname: nickname),
                    ),
                    _buildImageCard(
                      context,
                      'assets/daily.png',
                      labelText: 'Daily Tasks',
                      destination:
                          DailyTasksModulePage(nickname: nickname),
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

  Widget _buildImageCard(
    BuildContext context,
    String imagePath, {
    String? labelText,
    Widget? destination,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      destination ??
                      Scaffold(
                        appBar: AppBar(title: const Text("Coming Soon")),
                        body: const Center(
                          child: Text("Content will be added here."),
                        ),
                      ),
            ),
          );
        },
        child: Container(
          height: 220, // Increased height to accommodate label
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image section
              Expanded(
                flex: 3, // 3/4 of the space for image
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain, // Changed from cover to contain for full visibility
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image not found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Label section
              if (labelText != null) ...[
                Expanded(
                  flex: 1, // 1/4 of the space for label
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF648BA2),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        labelText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
