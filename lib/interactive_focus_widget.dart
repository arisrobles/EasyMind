import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'attention_focus_system.dart';

/// Interactive Focus Widget - Shows focus progress with animations and encouragement
class InteractiveFocusWidget extends StatefulWidget {
  final String nickname;
  final String moduleName;
  final String lessonType;
  final VoidCallback? onBreakSuggested;
  final VoidCallback? onSessionCompleted;

  const InteractiveFocusWidget({
    super.key,
    required this.nickname,
    required this.moduleName,
    required this.lessonType,
    this.onBreakSuggested,
    this.onSessionCompleted,
  });

  @override
  State<InteractiveFocusWidget> createState() => _InteractiveFocusWidgetState();
}

class _InteractiveFocusWidgetState extends State<InteractiveFocusWidget>
    with TickerProviderStateMixin {
  final AttentionFocusSystem _focusSystem = AttentionFocusSystem();
  final FlutterTts _flutterTts = FlutterTts();
  
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  Timer? _encouragementTimer;
  Timer? _progressTimer;
  
  FocusStatus _currentStatus = FocusStatus.idle;
  Duration? _sessionDuration;
  int _encouragementCount = 0;
  
  // Super fun encouragement messages for kids
  final List<String> _encouragementMessages = [
    "Wow! You're like a superhero! 🦸‍♀️ Keep going!",
    "Amazing! Your brain is getting super strong! 🧠💪",
    "Fantastic! You're learning like magic! ✨🎉",
    "You're a superstar! Shine bright! ⭐🌟",
    "Incredible! You're getting smarter every second! 🚀",
    "Awesome! You're a focus champion! 🏆",
    "Brilliant! Keep up the amazing work! 🌈",
    "You're becoming a genius! So cool! 🎓😎",
    "Super job! You're unstoppable! 💫",
    "Fantastic! You're a learning wizard! 🧙‍♀️",
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _startFocusSession();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(minutes: 15), // Default focus duration
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  void _initializeTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  void _startFocusSession() async {
    await _focusSystem.startFocusSession(
      nickname: widget.nickname,
      moduleName: widget.moduleName,
      lessonType: widget.lessonType,
    );
    
    setState(() {
      _currentStatus = FocusStatus.focused;
    });
    
    _progressController.forward();
    _startEncouragementTimer();
    _startProgressTimer();
  }

  void _startEncouragementTimer() {
    _encouragementTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      if (_currentStatus == FocusStatus.focused) {
        _showEncouragement();
      }
    });
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _sessionDuration = _focusSystem.getSessionDuration();
      });
    });
  }

  void _showEncouragement() {
    if (_encouragementCount < _encouragementMessages.length) {
      final message = _encouragementMessages[_encouragementCount];
      _encouragementCount++;
      
      _flutterTts.speak(message);
      
      // Show encouragement overlay
      _showEncouragementOverlay(message);
    }
  }

  void _showEncouragementOverlay(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.pink.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade200,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Thanks! 😊",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Auto-dismiss after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _endSession() async {
    await _focusSystem.endFocusSession(
      nickname: widget.nickname,
      moduleName: widget.moduleName,
      lessonType: widget.lessonType,
    );
    
    _encouragementTimer?.cancel();
    _progressTimer?.cancel();
    _progressController.stop();
    
    widget.onSessionCompleted?.call();
  }

  @override
  void dispose() {
    _encouragementTimer?.cancel();
    _progressTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getStatusColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25), // More rounded for kids
        border: Border.all(
          color: Colors.white,
          width: 3, // Thick white border for kid appeal
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColors().first.withValues(alpha: 0.4),
            blurRadius: 20, // Bigger shadow for more fun
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildProgressIndicator(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: Colors.white,
                  size: 32,
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
                _getStatusTitle(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _getStatusSubtitle(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Focus Time ⏰",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            Text(
              _formatDuration(_sessionDuration),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          _getProgressText(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _currentStatus == FocusStatus.focused ? _endSession : null,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(
              "Complete Session",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50), // Professional green
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showEncouragement,
            icon: const Icon(Icons.psychology, color: Colors.white),
            label: const Text(
              "Get Motivation",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3), // Professional blue
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getStatusColors() {
    switch (_currentStatus) {
      case FocusStatus.focused:
        return [const Color(0xFF4ECDC4), const Color(0xFF44A08D)]; // Bright teal gradient
      case FocusStatus.onBreak:
        return [const Color(0xFFFFD93D), const Color(0xFFFFB74D)]; // Bright yellow-orange gradient
      case FocusStatus.idle:
        return [const Color(0xFF6BCF7F), const Color(0xFF4CAF50)]; // Bright green gradient
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case FocusStatus.focused:
        return Icons.auto_awesome; // Sparkle icon for focused state
      case FocusStatus.onBreak:
        return Icons.local_pizza; // Pizza icon for break time
      case FocusStatus.idle:
        return Icons.play_circle_filled; // Play icon for idle state
    }
  }

  String _getStatusTitle() {
    switch (_currentStatus) {
      case FocusStatus.focused:
        return "Super Focus Mode! ✨🧠";
      case FocusStatus.onBreak:
        return "Break Time! 🍕🎉";
      case FocusStatus.idle:
        return "Ready to Focus? 🚀";
    }
  }

  String _getStatusSubtitle() {
    switch (_currentStatus) {
      case FocusStatus.focused:
        return "Your brain is working super hard! You're amazing! 🌟";
      case FocusStatus.onBreak:
        return "Time to rest and recharge! You earned it! 🎊";
      case FocusStatus.idle:
        return "Let's start your awesome learning adventure! 🎈";
    }
  }

  String _getProgressText() {
    if (_sessionDuration == null) return "Getting ready... 🎪";
    
    final minutes = _sessionDuration!.inMinutes;
    if (minutes < 5) return "Great start! You're awesome! 🌱⭐";
    if (minutes < 10) return "Amazing focus! You're a star! 🌟✨";
    if (minutes < 15) return "Incredible! Almost there! 🚀🏆";
    return "Fantastic! You're a focus champion! 🎉👑";
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
}

/// Break Reminder Widget - Shows break suggestions and countdown
class BreakReminderWidget extends StatefulWidget {
  final String nickname;
  final VoidCallback? onBreakAccepted;
  final VoidCallback? onBreakDeclined;

  const BreakReminderWidget({
    super.key,
    required this.nickname,
    this.onBreakAccepted,
    this.onBreakDeclined,
  });

  @override
  State<BreakReminderWidget> createState() => _BreakReminderWidgetState();
}

class _BreakReminderWidgetState extends State<BreakReminderWidget>
    with TickerProviderStateMixin {
  final AttentionFocusSystem _focusSystem = AttentionFocusSystem();
  final FlutterTts _flutterTts = FlutterTts();
  
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  Timer? _countdownTimer;
  int _countdownSeconds = 30;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _startCountdown();
  }

  void _initializeAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _bounceController.forward();
  }

  void _initializeTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });
      
      if (_countdownSeconds <= 0) {
        timer.cancel();
        _autoDeclineBreak();
      }
    });
  }

  void _autoDeclineBreak() {
    setState(() {
      _isVisible = false;
    });
    widget.onBreakDeclined?.call();
  }

  void _acceptBreak() async {
    _countdownTimer?.cancel();
    await _focusSystem.endBreak(widget.nickname);
    widget.onBreakAccepted?.call();
  }

  void _declineBreak() {
    _countdownTimer?.cancel();
    widget.onBreakDeclined?.call();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.yellow.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.coffee,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Break Time! ☕",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You've been learning so well!\nLet's take a fun little break! 🌟",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Auto-continue in $_countdownSeconds seconds",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _acceptBreak,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        "Take Break! ☕",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _declineBreak,
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text(
                        "Keep Going! 🚀",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
