import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'ShapeAssessment.dart'; // Import the assessment page

// A new widget to handle the shape drawing and animation.
class ShapeAnimator extends StatefulWidget {
  final int shapeId;
  final int sideCount;
  final Color color;
  @override
  final Key key;

  const ShapeAnimator({
    required this.key,
    required this.shapeId,
    required this.sideCount,
    this.color = const Color(0xFF648BA2),
  }) : super(key: key);

  @override
  _ShapeAnimatorState createState() => _ShapeAnimatorState();
}

class _ShapeAnimatorState extends State<ShapeAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _highlightedSideIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set a fixed duration for circle (5 seconds) and use sideCount for other shapes
    _controller = AnimationController(
      vsync: this,
      duration:
          widget.sideCount == 0
              ? const Duration(seconds: 5)
              : Duration(seconds: widget.sideCount),
    );

    // The animation progresses from 0.0 to the number of sides or 1.0 for circle
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.sideCount == 0 ? 1.0 : widget.sideCount.toDouble(),
    ).animate(_controller)..addListener(() {
      setState(() {
        // Update the highlighted side index based on animation progress
        _highlightedSideIndex =
            widget.sideCount == 0 ? 0 : _animation.value.floor();
      });
    });

    // Start the animation as soon as the widget is built.
    _controller.forward();
  }

  void replayAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // The custom painter that draws the shape and highlights.
        CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width < 400 ? 150 : 200,
            MediaQuery.of(context).size.width < 400 ? 150 : 200,
          ),
          painter: ShapePainter(
            sideCount: widget.sideCount,
            highlightedSideIndex: _highlightedSideIndex,
            progress: _animation.value,
            color: widget.color,
          ),
        ),
        const SizedBox(height: 24),
        // A counter text that updates with the animation.
        Text(
          // For a circle (0 sides in our logic), don't show a counter.
          widget.sideCount > 0
              ? 'Side: ${_highlightedSideIndex > widget.sideCount ? widget.sideCount : _highlightedSideIndex}'
              : 'I have 1 continuous edge!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: MediaQuery.of(context).size.width < 400 ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A4E69),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        // Replay button
        ElevatedButton(
          onPressed: replayAnimation,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF648BA2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.replay, size: 30, color: Colors.white),
        ),
      ],
    );
  }
}

// The painter class responsible for drawing the shapes.
class ShapePainter extends CustomPainter {
  final int sideCount;
  final int highlightedSideIndex;
  final double progress;
  final Color color;

  ShapePainter({
    required this.sideCount,
    required this.highlightedSideIndex,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Base paint for the shape outline
    final basePaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;

    // Highlight paint for the currently counted side
    final highlightPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round;

    // Circle is a special case
    if (sideCount == 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      // Draw the full circle outline in grey
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, basePaint);
      // Animate the drawing of the circle's circumference
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        highlightPaint,
      );
      return;
    }

    if (sideCount < 3) return; // Cannot draw a shape with less than 3 sides

    final path = Path();
    final angle = (math.pi * 2) / sideCount;

    // Calculate the vertices of the polygon
    final vertices = List.generate(sideCount, (i) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      return Offset(x, y);
    });

    // Draw the full shape outline in a light grey color first
    path.moveTo(vertices.first.dx, vertices.first.dy);
    for (int i = 0; i < vertices.length; i++) {
      path.lineTo(
        vertices[(i + 1) % sideCount].dx,
        vertices[(i + 1) % sideCount].dy,
      );
    }
    canvas.drawPath(path, basePaint);

    // Draw the highlighted sides one by one
    for (int i = 0; i < highlightedSideIndex && i < sideCount; i++) {
      final p1 = vertices[i];
      final p2 = vertices[(i + 1) % sideCount];

      double sideProgress = (progress - i).clamp(0.0, 1.0);

      // If it's the currently animating side, draw it partially
      if (i == highlightedSideIndex - 1) {
        canvas.drawLine(p1, Offset.lerp(p1, p2, sideProgress)!, highlightPaint);
      } else {
        // Otherwise, draw the full side
        canvas.drawLine(p1, p2, highlightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint whenever animation values change
  }
}

class ShapesActivityPage extends StatefulWidget {
  final String nickname;
  
  const ShapesActivityPage({super.key, required this.nickname});

  @override
  _ShapesActivityPageState createState() => _ShapesActivityPageState();
}

class _ShapesActivityPageState extends State<ShapesActivityPage> {
  final PageController _pageController = PageController();
  final FlutterTts _flutterTts = FlutterTts();
  int _currentPage = 0;

  // Updated shapes data structure.
  // 'sideCount' is used for the animator. A circle is a special case with 0.
  final List<Map<String, dynamic>> shapes = const [
    {
      'sides': 'I have 4 sides',
      'corners': 'I have 4 corners',
      'name': 'I am a square',
      'sideCount': 4,
    },
    {
      'sides': 'I have 3 sides',
      'corners': 'I have 3 corners',
      'name': 'I am a triangle',
      'sideCount': 3,
    },
    {
      'sides': 'I have 5 sides',
      'corners': 'I have 5 corners',
      'name': 'I am a pentagon',
      'sideCount': 5,
    },
    {
      'sides': 'I have 6 sides',
      'corners': 'I have 6 corners',
      'name': 'I am a hexagon',
      'sideCount': 6,
    },
    {
      'sides': 'I have 8 sides',
      'corners': 'I have 8 corners',
      'name': 'I am an octagon',
      'sideCount': 8,
    },
    {
      'sides': 'I have infinite sides',
      'corners': 'I have no corners',
      'name': 'I am a circle',
      'sideCount': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadProgress();
  }

  // Speak after the first frame is rendered.
  void _speakAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _playShapeSound(_currentPage);
      }
    });
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage = prefs.getInt('shapeIndex') ?? 0;
      _pageController.jumpToPage(_currentPage);
    });
    _speakAfterBuild(); // Speak after loading progress.
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shapeIndex', _currentPage);
  }

  void _playShapeSound(int index) async {
    if (index < 0 || index >= shapes.length) return;
    await _flutterTts.stop();
    final shape = shapes[index];
    final text = '${shape['sides']}. ${shape['corners']}. ${shape['name']}';
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < shapes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _flutterTts.stop();
      _showCompletionDialog();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFFF6DC),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/star.png', height: 150, width: 150),
                    const SizedBox(height: 20),
                    const Text(
                      "What would you like to do next?",
                      style: TextStyle(
                        fontSize: 26,
                        color: Color(0xFF4C4F6B),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setInt('shapeIndex', 0);
                          _pageController.jumpToPage(0);
                          // The onPageChanged will handle the state update and sound
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C4F6B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Restart Module",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShapeAssessment(nickname: widget.nickname),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C7E71),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Take Assessment",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width < 400 ? 12.0 : 16.0,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width < 400 ? 140 : 180,
                  height: MediaQuery.of(context).size.width < 400 ? 50 : 60,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF648BA2),
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width < 400 ? 12 : 16,
                        vertical: MediaQuery.of(context).size.width < 400 ? 10 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: MediaQuery.of(context).size.width < 400 ? 18 : 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width < 400 ? 12.0 : 16.0,
              ),
              child: Text(
                'Instruction: Watch the sides get counted one by one.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: MediaQuery.of(context).size.width < 400 ? 20 : 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A4E69),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: shapes.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _playShapeSound(index);
                  _saveProgress();
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShapePage(
                        shapes[index]['sides']!,
                        shapes[index]['corners']!,
                        shapes[index]['name']!,
                        shapes[index]['sideCount']!,
                        index,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _currentPage > 0 ? _previousPage : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF648BA2),
                              padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.width < 400 ? 12 : 15,
                                horizontal: MediaQuery.of(context).size.width < 400 ? 20 : 30,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Previous',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width < 400 ? 15 : 20),
                          ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF648BA2),
                              padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.width < 400 ? 12 : 15,
                                horizontal: MediaQuery.of(context).size.width < 400 ? 20 : 30,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapePage(
    String sidesText,
    String cornersText,
    String shapeText,
    int sideCount,
    int index,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width < 400 ? screenWidth * 0.85 : screenWidth * 0.7,
          height: MediaQuery.of(context).size.width < 400 ? screenHeight * 0.65 : screenHeight * 0.58,
          padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width < 400 ? 12 : 20,
            MediaQuery.of(context).size.width < 400 ? 8 : 10,
            MediaQuery.of(context).size.width < 400 ? 12 : 20,
            MediaQuery.of(context).size.width < 400 ? 8 : 10,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => _playShapeSound(index),
                  child: Container(
                    width: MediaQuery.of(context).size.width < 400 ? 40 : 50,
                    height: MediaQuery.of(context).size.width < 400 ? 40 : 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.volume_up,
                      size: MediaQuery.of(context).size.width < 400 ? 24 : 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              // The new ShapeAnimator widget replaces the old Image.asset
              ShapeAnimator(
                // Use a ValueKey to ensure the widget rebuilds on page change
                key: ValueKey<int>(_currentPage),
                shapeId: index,
                sideCount: sideCount,
              ),
              const SizedBox(height: 16),
              Text(
                sidesText,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width < 400 ? 24 : 33,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: MediaQuery.of(context).size.width < 400 ? 6 : 8),
              Text(
                cornersText,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width < 400 ? 20 : 28,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: MediaQuery.of(context).size.width < 400 ? 4 : 6),
              Text(
                shapeText,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width < 400 ? 20 : 28,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
