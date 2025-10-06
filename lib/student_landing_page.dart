import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'review_reminder_widget.dart';
import 'ReadingMaterialsPage.dart';
import 'GamesLandingPage.dart';
import 'unified_analytics_dashboard.dart';
import 'focus_system_demo.dart';
import 'app_initialization_service.dart';
import 'student_profile.dart';

class StudentLandingPage extends StatefulWidget {
  final String nickname;

  const StudentLandingPage({super.key, required this.nickname});

  @override
  _StudentLandingPageState createState() => _StudentLandingPageState();
}

class _StudentLandingPageState extends State<StudentLandingPage> {
  final GlobalKey _readingKey = GlobalKey();
  final GlobalKey _gamesKey = GlobalKey();
  final FlutterTts flutterTts = FlutterTts();

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];
  bool tutorialShown = false;

  @override
  void initState() {
    super.initState();
    _setupTts();
    _initializeMemoryRetention();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkTutorialStatus();
      if (!tutorialShown) {
        _initTargets();
        _showTutorial();
      }
    });
  }

  Future<void> _initializeMemoryRetention() async {
    try {
      await AppInitializationService().initializeUser(widget.nickname);
    } catch (e) {
      print('Error initializing memory retention: $e');
    }
  }

  Future<void> _setupTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.3);
      await flutterTts.setSpeechRate(0.8);

      List<dynamic> voices = await flutterTts.getVoices;
      for (var voice in voices) {
        final name = (voice["name"] ?? "").toLowerCase();
        final locale = (voice["locale"] ?? "").toLowerCase();
        if ((name.contains("female") || name.contains("woman") || name.contains("natural")) &&
            locale.contains("en")) {
          await flutterTts.setVoice({
            "name": voice["name"],
            "locale": voice["locale"],
          });
          break;
        }
      }
    } catch (e) {
      print("TTS setup error: $e");
    }
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    tutorialShown = prefs.getBool('tutorialShown') ?? false;
  }

  void _markTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialShown', true);
    setState(() {
      tutorialShown = true;
    });
  }

  void _initTargets() {
    targets = [
      TargetFocus(
        identify: "Reading",
        keyTarget: _readingKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.black.withOpacity(0.7),
              child: const Text(
                "Click here to access fun reading materials designed for you!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Games",
        keyTarget: _gamesKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.black.withOpacity(0.7),
              child: const Text(
                "Click here to play educational games and test your skills!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  void _showTutorial() {
    if (tutorialShown) return;

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      skipWidget: GestureDetector(
        onTap: () {
          tutorialCoachMark.finish();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          margin: const EdgeInsets.only(bottom: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'SKIP',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onFinish: () => _markTutorialShown(),
      onClickTarget: (target) {},
    );

    tutorialCoachMark.show(context: context);
  }

  Future<void> _speak(String text) async {
    try {
      await flutterTts.speak(text);
    } catch (e) {
      print("TTS error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: Column(
        children: [
          // Responsive Header
          Stack(
            children: [
              ClipPath(
                clipper: TopWaveClipper(),
                child: Container(
                  height: isSmallScreen ? 150 : 200,
                  width: double.infinity,
                  color: const Color(0xFFFBEED9),
                ),
              ),
              Positioned(
                top: isSmallScreen ? 40 : 60,
                left: isSmallScreen ? 20 : 40,
                right: isSmallScreen ? 20 : 40,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${widget.nickname}! 👋',
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 28 : (isSmallScreen ? 32 : 45),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A4E69),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ready to learn and have fun? 🌟',
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
                              color: const Color(0xFF648BA2),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile Icon in Header
                    GestureDetector(
                      onTap: () async {
                        await _speak("My Profile");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentProfile(
                              nickname: widget.nickname,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF648BA2),
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
                child: SingleChildScrollView(
                child: Column(
                  children: [
                      // Review Reminder Widget - Shows lessons due for review
                      ReviewReminderWidget(
                        nickname: widget.nickname,
                        onReviewCompleted: () {
                          setState(() {
                            // Refresh the page when reviews are completed
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Icon-Only Feature Buttons - Wrap Layout (No Overflow)
                      Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildIconOnlyButton(
                            icon: Icons.analytics,
                            emoji: "📊",
                            color: const Color(0xFF648BA2),
                            title: "Analytics Hub",
                            onPressed: () async {
                              await _speak("Analytics Hub");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UnifiedAnalyticsDashboard(
                                    nickname: widget.nickname,
                                  ),
                                ),
                              );
                            },
                            isSmallScreen: isSmallScreen,
                          ),
                          _buildIconOnlyButton(
                            icon: Icons.timer,
                            emoji: "⏰",
                            color: const Color(0xFF9C27B0),
                            title: "Focus System",
                            onPressed: () async {
                              await _speak("Focus System Demo");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FocusSystemDemo(
                                    nickname: widget.nickname,
                                  ),
                                ),
                              );
                            },
                            isSmallScreen: isSmallScreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // Learning Materials Cards - Main Focus
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (isVerySmallScreen) {
                            // Single column for very small screens
                            return Column(
                              children: [
                                CustomCardButton(
                                  key: _readingKey,
                                  imagePath: 'assets/lrn.png',
                                  title: '',
                                  width: double.infinity,
                                  height: 200,
                                  onTap: () async {
                                    await _speak("Learning Materials");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Readingmaterialspage(nickname: widget.nickname)),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomCardButton(
                                  key: _gamesKey,
                                  imagePath: 'assets/games.png',
                                  title: '',
                                  width: double.infinity,
                                  height: 200,
                                  onTap: () async {
                                    await _speak("Educational Games");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GamesLandingPage(nickname: widget.nickname)),
                                    );
                                  },
                                ),
                              ],
                            );
                          } else {
                            // Wrap layout for larger screens
                            return Wrap(
                              spacing: isSmallScreen ? 16 : 20,
                              runSpacing: isSmallScreen ? 16 : 20,
                    alignment: WrapAlignment.center,
                    children: [
                      CustomCardButton(
                        key: _readingKey,
                        imagePath: 'assets/lrn.png',
                        title: '',
                                  width: isSmallScreen ? double.infinity : 300,
                                  height: isSmallScreen ? 250 : 300,
                        onTap: () async {
                          await _speak("Learning Materials");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Readingmaterialspage(nickname: widget.nickname)),
                          );
                        },
                      ),
                      CustomCardButton(
                        key: _gamesKey,
                        imagePath: 'assets/games.png',
                        title: '',
                                  width: isSmallScreen ? double.infinity : 300,
                                  height: isSmallScreen ? 250 : 300,
                        onTap: () async {
                                    await _speak("Educational Games");
                          Navigator.push(
                            context,
                                      MaterialPageRoute(
                                          builder: (context) => GamesLandingPage(nickname: widget.nickname)),
                          );
                        },
                      ),
                    ],
                            );
                          }
                        },
                  ),
                    ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconOnlyButton({
    required IconData icon,
    required String emoji,
    required Color color,
    required VoidCallback onPressed,
    required bool isSmallScreen,
    String? title,
  }) {
    final buttonSize = isSmallScreen ? 80.0 : 90.0; // Increased from 60/70 to 80/90
    final iconSize = isSmallScreen ? 32.0 : 36.0; // Increased from 24/28 to 32/36
    final emojiSize = isSmallScreen ? 28.0 : 32.0; // Increased from 20/24 to 28/32
    final titleSize = isSmallScreen ? 12.0 : 14.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: buttonSize,
          height: buttonSize,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonSize / 2), // Circular button
              ),
              elevation: 10, // Increased elevation for more prominence
              shadowColor: color.withValues(alpha: 0.4), // Slightly more prominent shadow
              padding: EdgeInsets.zero, // Remove default padding
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background emoji
                Text(
                  emoji,
                  style: TextStyle(fontSize: emojiSize),
                ),
                // Foreground icon
                Icon(
                  icon,
                  color: Colors.white,
                  size: iconSize,
                ),
              ],
            ),
          ),
        ),
        if (title != null) ...[
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class CustomCardButton extends StatelessWidget {
  final double width;
  final double height;
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const CustomCardButton({
    super.key,
    required this.width,
    required this.height,
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: const Color(0xFFFFF9E4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: height * 0.8,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 50);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 100);
    var secondEndPoint = Offset(size.width, size.height - 50);

    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
