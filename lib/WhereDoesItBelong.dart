import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'adaptive_assessment_system.dart';
import 'memory_retention_system.dart';
import 'gamification_system.dart';

class WhereDoesItBelongGame extends StatelessWidget {
  final String nickname;
  const WhereDoesItBelongGame({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    return WhereGameScreen(nickname: nickname);
  }
}

class WhereGameScreen extends StatefulWidget {
  final String nickname;
  const WhereGameScreen({super.key, required this.nickname});

  @override
  State<WhereGameScreen> createState() => _WhereGameScreenState();
}

class _WhereGameScreenState extends State<WhereGameScreen> {
  final List<Map<String, String>> items = [
    {'image': 'assets/spoon.png', 'category': 'Kitchen'},
    {'image': 'assets/fork.png', 'category': 'Kitchen'},
    {'image': 'assets/plate.png', 'category': 'Kitchen'},
    {'image': 'assets/cup.png', 'category': 'Kitchen'},
    {'image': 'assets/toothbrush.png', 'category': 'Bathroom'},
    {'image': 'assets/soap.png', 'category': 'Bathroom'},
    {'image': 'assets/towel.png', 'category': 'Bathroom'},
    {'image': 'assets/pillow.png', 'category': 'Bedroom'},
    {'image': 'assets/blanket.png', 'category': 'Bedroom'},
    {'image': 'assets/lamp.png', 'category': 'Bedroom'},
  ];

  final Map<String, List<String>> acceptedItems = {
    'Kitchen': [],
    'Bathroom': [],
    'Bedroom': [],
  };

  late ConfettiController _confettiController;
  
  // Adaptive Assessment System
  bool _useAdaptiveMode = true;
  String _currentDifficulty = 'beginner';
  final GamificationSystem _gamificationSystem = GamificationSystem();
  GamificationResult? _lastReward;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _initializeAdaptiveMode();
  }

  void handleAccept(String category, String imagePath) {
    setState(() {
      acceptedItems[category]?.add(imagePath);
      items.removeWhere(
          (item) => item['image'] == imagePath && item['category'] == category);
    });

    if (items.isEmpty) {
      _confettiController.play();
      
      // Save to adaptive assessment and memory retention when game is complete
      _saveToAdaptiveAssessment();
      _saveToMemoryRetention();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple],
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.06),
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
                            elevation: 3,
                          ),
                          onPressed: () {
                            try {
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
                ],
              ),
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Where Does It Belong?",
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
              Container(
                height: screenHeight * 0.3,
                child: Wrap(
                  spacing: screenWidth * 0.04,
                  runSpacing: screenWidth * 0.04,
                  alignment: WrapAlignment.center,
                  children: items.map((item) {
                    return Draggable<Map<String, String>>(
                      data: item,
                      feedback: Image.asset(
                        item['image']!,
                        width: screenWidth * 0.25,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: screenWidth * 0.25,
                            height: screenWidth * 0.25,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                      childWhenDragging: SizedBox(
                        width: screenWidth * 0.25,
                        height: screenWidth * 0.25,
                      ),
                      child: Image.asset(
                        item['image']!,
                        width: screenWidth * 0.25,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: screenWidth * 0.25,
                            height: screenWidth * 0.25,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                height: screenHeight * 0.4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: ['Kitchen', 'Bathroom', 'Bedroom'].map((category) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                        child: DragTarget<Map<String, String>>(
                          builder: (context, candidateData, rejectedData) => Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: screenWidth * 0.02,
                                    runSpacing: screenWidth * 0.02,
                                    children: acceptedItems[category]!
                                        .map((img) => Image.asset(
                                              img,
                                              width: screenWidth * 0.2,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: screenWidth * 0.2,
                                                  height: screenWidth * 0.2,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.image,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                            ))
                                        .toList(),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.05,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onWillAcceptWithDetails: (data) => true,
                          onAcceptWithDetails: (data) {
                            final itemData = data.data;
                            if (itemData['category'] == category) {
                              handleAccept(category, itemData['image']!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Oops! That item does not belong there.',
                                    style: TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
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
        _currentDifficulty = await AdaptiveAssessmentSystem.getCurrentLevel(
          widget.nickname,
          AssessmentType.dailyTasks.value, // Using dailyTasks as closest category
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
      // Calculate performance based on correct categorizations
      final totalItems = items.length;
      final correctItems = acceptedItems.values.fold<int>(0, (sum, list) => sum + list.length);
      final performance = correctItems / totalItems;
      
      await AdaptiveAssessmentSystem.saveAssessmentResult(
        nickname: widget.nickname,
        assessmentType: AssessmentType.dailyTasks.value,
        moduleName: "Categorization Game",
        totalQuestions: totalItems,
        correctAnswers: correctItems,
        timeSpent: const Duration(minutes: 4),
        attemptedQuestions: items.map((item) => item['image']!).toList(),
        correctQuestions: acceptedItems.values.expand((list) => list).toList(),
      );
      
      // Award XP based on performance
      final isPerfect = correctItems == totalItems;
      final isGood = correctItems >= totalItems * 0.7;
      
      _lastReward = await _gamificationSystem.awardXP(
        nickname: widget.nickname,
        activity: isPerfect ? 'perfect_categorization' : (isGood ? 'good_categorization' : 'categorization_practice'),
        metadata: {
          'module': 'whereDoesItBelong',
          'score': correctItems,
          'total': totalItems,
          'perfect': isPerfect,
        },
      );
      
      print('Adaptive assessment saved for WhereDoesItBelong game');
    } catch (e) {
      print('Error saving adaptive assessment: $e');
    }
  }

  Future<void> _saveToMemoryRetention() async {
    try {
      final retentionSystem = MemoryRetentionSystem();
      final correctItems = acceptedItems.values.fold<int>(0, (sum, list) => sum + list.length);
      final totalItems = items.length;
      
      await retentionSystem.saveLessonCompletion(
        nickname: widget.nickname,
        moduleName: "Categorization",
        lessonType: "WhereDoesItBelong Game",
        score: correctItems,
        totalQuestions: totalItems,
        passed: correctItems >= totalItems * 0.7,
      );
    } catch (e) {
      print('Error saving to memory retention: $e');
    }
  }
}
