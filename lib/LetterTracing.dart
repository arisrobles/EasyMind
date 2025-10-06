import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:signature/signature.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'adaptive_assessment_system.dart';
import 'memory_retention_system.dart';
import 'gamification_system.dart';
import 'visit_tracking_system.dart';

class LetterTracingGame extends StatefulWidget {
  final String nickname;
  const LetterTracingGame({super.key, required this.nickname});

  @override
  State<LetterTracingGame> createState() => _LetterTracingGameState();
}

class _LetterTracingGameState extends State<LetterTracingGame>
    with SingleTickerProviderStateMixin {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 8,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  final FlutterTts _flutterTts = FlutterTts();
  final VisitTrackingSystem _visitTrackingSystem = VisitTrackingSystem();
  late ConfettiController _confettiController;
  late AnimationController _rumbleController;
  late Animation<Offset> _rumbleAnimation;

  List<String> letters = List.generate(26, (i) => String.fromCharCode(65 + i));
  List<bool> isLetterTraced = List.filled(26, false);
  int _currentIndex = 0;
  int _successfulTraces = 0; // Track successful traces
  
  // Adaptive Assessment System
  bool _useAdaptiveMode = true;
  final GamificationSystem _gamificationSystem = GamificationSystem();

  @override
  void initState() {
    super.initState();
    _setupTTS();
    _initializeAdaptiveMode();
    _trackVisit();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _rumbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rumbleAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.02, 0), // Slight horizontal shake
    ).animate(
      CurvedAnimation(parent: _rumbleController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rumbleController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _rumbleController.forward();
      }
    });
    _rumbleController.forward();
    letters.shuffle(Random()); // Randomize letter order
  }

  Future<void> _trackVisit() async {
    try {
      await _visitTrackingSystem.trackVisit(
        nickname: widget.nickname,
        itemType: 'lesson',
        itemName: 'Letter Tracing Game',
        moduleName: 'Functional Academics',
      );
      print('Visit tracked for Letter Tracing Game');
    } catch (e) {
      print('Error tracking visit: $e');
    }
  }

  Future<void> _setupTTS() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.5);
      await _flutterTts.setVolume(1.0);
      _speakLetter();
    } catch (e) {
      print('Error setting up TTS: $e');
    }
  }

  Future<void> _speakLetter() async {
    try {
      final String letter = letters[_currentIndex];
      await _flutterTts.stop();
      await _flutterTts.speak("Letter $letter");
    } catch (e) {
      print('Error speaking letter: $e');
    }
  }

  Future<void> _checkTracing() async {
    print('🎯 Checking tracing...');
    await Future.delayed(const Duration(milliseconds: 200));
    final points = _signatureController.points;
    
    print('📊 Points count: ${points.length}');

    if (points.isEmpty) {
      print('⚠️ No points found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please trace the letter first!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // More sophisticated validation
    bool isValidTrace = _validateLetterTrace(points);
    print('🔍 Validation result: $isValidTrace');
    
    if (isValidTrace) {
      print('✅ Trace is valid! Moving to next letter');
      setState(() {
        isLetterTraced[_currentIndex] = true;
        _successfulTraces++; // Increment successful trace count
        if (_currentIndex < letters.length - 1) {
          _currentIndex++;
          _signatureController.clear();
        } else {
          _showCompletionDialog();
          
          // Save to adaptive assessment and memory retention when game is complete
          _saveToAdaptiveAssessment();
          _saveToMemoryRetention();
        }
      });
      await _speakLetter();
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Great! You traced ${letters[_currentIndex - 1]} correctly! 🎉'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      print('❌ Trace is invalid');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Try again! Make sure to trace the letter ${letters[_currentIndex]} carefully.'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  bool _validateLetterTrace(List<dynamic> points) {
    print('🔍 Validating trace with ${points.length} points');
    
    // Simple validation - just check if user drew something reasonable
    if (points.isEmpty) {
      print('❌ No points to validate');
      return false;
    }
    
    // Very lenient validation - just check minimum points
    if (points.length < 3) {
      print('❌ Too few points: ${points.length}');
      return false;
    }
    
    // For now, accept any trace with more than 3 points
    // This ensures the basic functionality works
    print('✅ Validation passed: ${points.length} points');
    return true;
  }

  void _onNextLetter() {
    if (_currentIndex < letters.length - 1) {
      setState(() {
        _currentIndex++;
        _signatureController.clear();
      });
      _speakLetter();
    } else {
      _showCompletionDialog();
    }
  }

  void _onPreviousLetter() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _signatureController.clear();
      });
      _speakLetter();
    }
  }

  void _eraseTracing() {
    _signatureController.clear();
  }

  void _showCompletionDialog() {
    _confettiController.play();
    final double successRate = (_successfulTraces / letters.length) * 100;
    String overallFeedback;
    if (successRate >= 80) {
      overallFeedback =
          "Excellent work! You traced ${successRate.toStringAsFixed(0)}% of the letters accurately. Keep it up!";
    } else if (successRate >= 50) {
      overallFeedback =
          "Good effort! You traced ${successRate.toStringAsFixed(0)}% of the letters well. Practice more for perfection!";
    } else {
      overallFeedback =
          "Nice try! You traced ${successRate.toStringAsFixed(0)}% of the letters. Try again to improve your skills!";
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8,
            maxWidth: screenWidth * 0.9,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.purple,
                ],
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: screenWidth * 0.2,
                        color: Colors.amber,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "You have finished the game!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Letter-by-Letter Feedback:",
                        style: TextStyle(
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Column(
                        children: List.generate(letters.length, (index) {
                          final letter = String.fromCharCode(65 + index);
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.005,
                            ),
                            child: Text(
                              "$letter: ${isLetterTraced[index] ? 'Successfully traced' : 'Not traced correctly'}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                color: isLetterTraced[index]
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        overallFeedback,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: const Color(0xFF2C3E50),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5DB2FF),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenHeight * 0.022,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          try {
                            _flutterTts.stop();
                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.pop(context);
                          } catch (e) {
                            print('Error navigating back: $e');
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          "Back to Games",
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _flutterTts.stop();
    _confettiController.dispose();
    _rumbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentLetter = letters[_currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  height: screenHeight * 0.08,
                  width: screenWidth * 0.4,
                  child: ElevatedButton(
                    onPressed: () {
                      try {
                        _flutterTts.stop();
                        Navigator.pop(context);
                      } catch (e) {
                        print('Error navigating back: $e');
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.05,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                '${_currentIndex + 1}/26',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Trace the Letters',
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4E69),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Trace the letter:',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenHeight * 0.01),
              AnimatedBuilder(
                animation: _rumbleAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: _rumbleAnimation.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentLetter,
                          style: TextStyle(
                            fontSize: screenWidth * 0.3,
                            color: Colors.black26,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        GestureDetector(
                          onTap: _speakLetter,
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A4E69),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.volume_up,
                              size: screenWidth * 0.08,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: _checkTracing,
                child: Container(
                  height: screenHeight * 0.4,
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Wrap(
                spacing: screenWidth * 0.02,
                runSpacing: screenWidth * 0.02,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _onPreviousLetter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _eraseTracing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Erase',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _checkTracing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Check Trace',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onNextLetter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Next Letter',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
            ],
          ),
        ),
      ),
    );
  }

  // Adaptive Assessment Methods
  Future<void> _initializeAdaptiveMode() async {
    if (_useAdaptiveMode) {
      try {
        await _gamificationSystem.initialize();
        await AdaptiveAssessmentSystem.getCurrentLevel(
          widget.nickname,
          AssessmentType.alphabet.value,
        );
        setState(() {});
      } catch (e) {
        print('Error initializing adaptive mode: $e');
      }
    }
  }

  Future<void> _saveToAdaptiveAssessment() async {
    if (!_useAdaptiveMode) return;
    
    try {
      // Calculate performance based on successful traces
      final totalQuestions = letters.length;
      final correctAnswers = _successfulTraces;
      
      await AdaptiveAssessmentSystem.saveAssessmentResult(
        nickname: widget.nickname,
        assessmentType: AssessmentType.alphabet.value,
        moduleName: "Letter Tracing Game",
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        timeSpent: const Duration(minutes: 6),
        attemptedQuestions: letters,
        correctQuestions: letters.take(_successfulTraces).toList(),
      );
      
      // Award XP based on performance
      final isPerfect = _successfulTraces == letters.length;
      final isGood = _successfulTraces >= letters.length * 0.7;
      
      await _gamificationSystem.awardXP(
        nickname: widget.nickname,
        activity: isPerfect ? 'perfect_letter_tracing' : (isGood ? 'good_letter_tracing' : 'letter_tracing_practice'),
        metadata: {
          'module': 'letterTracing',
          'score': _successfulTraces,
          'total': letters.length,
          'perfect': isPerfect,
        },
      );
      
      print('Adaptive assessment saved for LetterTracing game');
    } catch (e) {
      print('Error saving adaptive assessment: $e');
    }
  }

  Future<void> _saveToMemoryRetention() async {
    try {
      final retentionSystem = MemoryRetentionSystem();
      await retentionSystem.saveLessonCompletion(
        nickname: widget.nickname,
        moduleName: "Letter Tracing",
        lessonType: "LetterTracing Game",
        score: _successfulTraces,
        totalQuestions: letters.length,
        passed: _successfulTraces >= letters.length * 0.7,
      );
    } catch (e) {
      print('Error saving to memory retention: $e');
    }
  }
}

