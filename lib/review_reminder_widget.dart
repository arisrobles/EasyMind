import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'memory_retention_system.dart';

/// Review Reminder Widget - Shows visual reminders for lessons due for review
class ReviewReminderWidget extends StatefulWidget {
  final String nickname;
  final VoidCallback? onReviewCompleted;

  const ReviewReminderWidget({
    super.key,
    required this.nickname,
    this.onReviewCompleted,
  });

  @override
  State<ReviewReminderWidget> createState() => _ReviewReminderWidgetState();
}

class _ReviewReminderWidgetState extends State<ReviewReminderWidget>
    with TickerProviderStateMixin {
  final MemoryRetentionSystem _retentionSystem = MemoryRetentionSystem();
  final FlutterTts _flutterTts = FlutterTts();
  
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<Map<String, dynamic>> _lessonsDue = [];
  bool _isLoading = true;
  int _currentLessonIndex = 0;
  bool _showInAppReminder = false;
  String _reminderMessage = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTTS();
    _loadLessonsDue();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  Future<void> _setupTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.setPitch(1.2);
  }

  Future<void> _loadLessonsDue() async {
    try {
      final lessons = await _retentionSystem.getLessonsDueForReview(widget.nickname);
      await _checkInAppReminders();
      
      setState(() {
        _lessonsDue = lessons;
        _isLoading = false;
      });
      
      if (lessons.isNotEmpty) {
        await _speakReminder();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading lessons due: $e');
    }
  }

  Future<void> _checkInAppReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      
      // Check if it's time for any scheduled reminder
      final morningReminder = prefs.getString('${widget.nickname}_next_morning_reminder');
      final afternoonReminder = prefs.getString('${widget.nickname}_next_afternoon_reminder');
      final eveningReminder = prefs.getString('${widget.nickname}_next_evening_reminder');
      
      List<String> reminders = [];
      
      if (morningReminder != null) {
        final reminderTime = DateTime.parse(morningReminder);
        if (now.isAfter(reminderTime) && now.difference(reminderTime).inHours < 2) {
          reminders.add('🌟 Good morning! Time for some fun learning!');
        }
      }
      
      if (afternoonReminder != null) {
        final reminderTime = DateTime.parse(afternoonReminder);
        if (now.isAfter(reminderTime) && now.difference(reminderTime).inHours < 2) {
          reminders.add('🎮 Afternoon learning time! You\'re doing amazing!');
        }
      }
      
      if (eveningReminder != null) {
        final reminderTime = DateTime.parse(eveningReminder);
        if (now.isAfter(reminderTime) && now.difference(reminderTime).inHours < 2) {
          reminders.add('✨ Evening practice time! You\'re so smart!');
        }
      }
      
      if (reminders.isNotEmpty) {
        setState(() {
          _showInAppReminder = true;
          _reminderMessage = reminders.first;
        });
        
        // Clear the reminder after showing
        await prefs.remove('${widget.nickname}_next_morning_reminder');
        await prefs.remove('${widget.nickname}_next_afternoon_reminder');
        await prefs.remove('${widget.nickname}_next_evening_reminder');
      }
    } catch (e) {
      print('Error checking in-app reminders: $e');
    }
  }

  Future<void> _speakReminder() async {
    if (_lessonsDue.isNotEmpty) {
      final lesson = _lessonsDue[_currentLessonIndex];
      final moduleName = lesson['moduleName'] ?? 'Unknown';
      await _flutterTts.speak(
        "Hey there! 🌟 It's time to play and remember! Let's have fun with $moduleName again! You're doing amazing! 🎉"
      );
    }
  }

  Future<void> _startReview() async {
    if (_lessonsDue.isEmpty) return;
    
    final lesson = _lessonsDue[_currentLessonIndex];
    final moduleName = lesson['moduleName'] ?? '';
    final lessonType = lesson['lessonType'] ?? '';
    
    // Navigate to appropriate review based on module
    await _navigateToReview(moduleName, lessonType);
  }

  Future<void> _navigateToReview(String moduleName, String lessonType) async {
    // This would navigate to the appropriate review/assessment page
    // For now, we'll simulate a review completion
    await _flutterTts.speak("Awesome! Let's have fun reviewing $moduleName! You're such a smart learner! 🌟");
    
    // Simulate review completion (in real implementation, this would be after actual review)
    await _retentionSystem.updateLessonAfterReview(
      lessonId: _lessonsDue[_currentLessonIndex]['id'],
      correct: true, // This would be determined by actual review performance
      nickname: widget.nickname,
    );
    
    // Move to next lesson or complete
    if (_currentLessonIndex < _lessonsDue.length - 1) {
      setState(() {
        _currentLessonIndex++;
      });
      await _speakReminder();
    } else {
      await _flutterTts.speak("Wow! You're incredible! 🌟 You've finished all your fun practice for today! You're becoming so smart! 🎉");
      widget.onReviewCompleted?.call();
    }
  }

  Future<void> _skipReview() async {
    if (_lessonsDue.isEmpty) return;
    
    await _flutterTts.speak("No worries! We can play this game later! You're still doing great! 😊");
    
    // Move to next lesson
    if (_currentLessonIndex < _lessonsDue.length - 1) {
      setState(() {
        _currentLessonIndex++;
      });
      await _speakReminder();
    } else {
      widget.onReviewCompleted?.call();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF648BA2)),
        ),
      );
    }

    // Show in-app reminder if available
    if (_showInAppReminder) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade100,
              Colors.yellow.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.amber.shade300,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.shade200,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.red.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    _reminderMessage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showInAppReminder = false;
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.orange.shade600),
                ),
              ],
            ),
            const SizedBox(height: 15),
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 600;
                final isVerySmallScreen = screenWidth < 400;
                
                return Container(
                  width: double.infinity,
                  height: isSmallScreen ? 55 : 65,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(25),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _showInAppReminder = false;
                        });
                        // Navigate to review dashboard or games
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade300,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Let's Learn! 🎮",
                              style: TextStyle(
                                fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black26,
                                    blurRadius: 2,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '🌟',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    if (_lessonsDue.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "You're Amazing! 🌟",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "No fun games need practice right now! You're doing fantastic! 🎉",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentLesson = _lessonsDue[_currentLessonIndex];
    final moduleName = currentLesson['moduleName'] ?? 'Unknown';
    final masteryLevel = currentLesson['masteryLevel'] ?? 0;
    final reviewCount = currentLesson['reviewCount'] ?? 0;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade100,
              Colors.yellow.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.orange.shade300,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade200,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with pulsing icon
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade400, Colors.pink.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Let's Play & Remember! 🎮✨",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Time to have fun with $moduleName again! You're getting so smart! 🌟",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Progress indicators
            Row(
              children: [
                Expanded(
                  child: _buildProgressIndicator(
                    "Smart Level 🌟",
                    masteryLevel,
                    6,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildProgressIndicator(
                    "Fun Practice 🎯",
                    reviewCount,
                    10,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Lesson counter
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Text(
                  "Game ${_currentLessonIndex + 1} of ${_lessonsDue.length} 🎮",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 600;
                final isVerySmallScreen = screenWidth < 400;
                
                return Column(
                  children: [
                    // Let's Play Button
                    Container(
                      width: double.infinity,
                      height: isSmallScreen ? 55 : 65,
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(25),
                        child: InkWell(
                          onTap: _startReview,
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.shade300,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Let's Play! 🎮",
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      const Shadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '✨',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 12 : 15),
                    
                    // Maybe Later Button
                    Container(
                      width: double.infinity,
                      height: isSmallScreen ? 50 : 60,
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(25),
                        child: InkWell(
                          onTap: _skipReview,
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.orange.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.shade100,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.schedule,
                                    color: Colors.orange.shade600,
                                    size: isSmallScreen ? 18 : 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Maybe Later 😊",
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String label, int current, int max, Color color) {
    final progress = current / max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4E69),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "$current/$max",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
