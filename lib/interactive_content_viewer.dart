import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'responsive_utils.dart';

/// Interactive Content Viewer - Displays teacher-uploaded content as interactive experiences
class InteractiveContentViewer extends StatefulWidget {
  final String nickname;
  final String contentId;
  final Map<String, dynamic> contentData;

  const InteractiveContentViewer({
    super.key,
    required this.nickname,
    required this.contentId,
    required this.contentData,
  });

  @override
  State<InteractiveContentViewer> createState() => _InteractiveContentViewerState();
}

class _InteractiveContentViewerState extends State<InteractiveContentViewer>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  int currentSection = 0;
  int score = 0;
  bool isCompleted = false;
  List<String> achievements = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTts();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _setupTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.2);
    await flutterTts.setSpeechRate(0.7);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _confettiController.dispose();
    flutterTts.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9D5),
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
        largeDesktop: _buildLargeDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        _buildHeader(context),
        Positioned(
          top: ResponsiveUtils.getResponsiveIconSize(context, mobile: 80),
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildContentArea(context),
        ),
        if (isCompleted) _buildConfetti(),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Stack(
      children: [
        _buildHeader(context),
        Positioned(
          top: ResponsiveUtils.getResponsiveIconSize(context, mobile: 100),
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildContentArea(context),
        ),
        if (isCompleted) _buildConfetti(),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Stack(
      children: [
        _buildHeader(context),
        Positioned(
          top: ResponsiveUtils.getResponsiveIconSize(context, mobile: 120),
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildContentArea(context),
        ),
        if (isCompleted) _buildConfetti(),
      ],
    );
  }

  Widget _buildLargeDesktopLayout(BuildContext context) {
    return Stack(
      children: [
        _buildHeader(context),
        Positioned(
          top: ResponsiveUtils.getResponsiveIconSize(context, mobile: 140),
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildContentArea(context),
        ),
        if (isCompleted) _buildConfetti(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: ResponsiveUtils.getResponsiveIconSize(context, mobile: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF648BA2), const Color(0xFF3C7E71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Row(
            children: [
              _buildBackButton(context),
              ResponsiveSpacing(mobileSpacing: 16, isVertical: false),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResponsiveText(
                      widget.contentData['title'] ?? 'Interactive Content',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      mobileFontSize: 18,
                      tabletFontSize: 20,
                      desktopFontSize: 22,
                      largeDesktopFontSize: 24,
                    ),
                    ResponsiveText(
                      _getContentTypeDisplay(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      mobileFontSize: 12,
                      tabletFontSize: 14,
                      desktopFontSize: 16,
                      largeDesktopFontSize: 18,
                    ),
                  ],
                ),
              ),
              _buildScoreDisplay(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, mobile: 8)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 8),
          ),
        ),
        child: ResponsiveIcon(
          Icons.arrow_back,
          color: Colors.white,
          mobileSize: 20,
          tabletSize: 22,
          desktopSize: 24,
          largeDesktopSize: 26,
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, mobile: 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveIcon(
            Icons.star,
            color: Colors.amber,
            mobileSize: 16,
            tabletSize: 18,
            desktopSize: 20,
            largeDesktopSize: 22,
          ),
          ResponsiveSpacing(mobileSpacing: 4, isVertical: false),
          ResponsiveText(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 18,
            largeDesktopFontSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: _buildContentByType(context),
        ),
      ),
    );
  }

  Widget _buildContentByType(BuildContext context) {
    final contentType = widget.contentData['type'];
    
    switch (contentType) {
      case 'interactive-lesson':
        return _buildInteractiveLesson(context);
      case 'game-activity':
        return _buildGameActivity(context);
      case 'interactive-assessment':
        return _buildInteractiveAssessment(context);
      default:
        return _buildFallbackContent(context);
    }
  }

  Widget _buildInteractiveLesson(BuildContext context) {
    final lesson = widget.contentData['components']?['lesson'];
    if (lesson == null) return _buildFallbackContent(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLessonIntroduction(context, lesson),
          ResponsiveSpacing(mobileSpacing: 20),
          _buildLessonSections(context, lesson),
          ResponsiveSpacing(mobileSpacing: 20),
          _buildLessonProgress(context, lesson),
        ],
      ),
    );
  }

  Widget _buildLessonIntroduction(BuildContext context, Map<String, dynamic> lesson) {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ResponsiveText(
            lesson['title'] ?? 'Interactive Lesson',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4E69),
            ),
            mobileFontSize: 20,
            tabletFontSize: 22,
            desktopFontSize: 24,
            largeDesktopFontSize: 26,
            textAlign: TextAlign.center,
          ),
          ResponsiveSpacing(mobileSpacing: 12),
          ResponsiveText(
            lesson['introduction'] ?? 'Welcome to this interactive lesson!',
            style: const TextStyle(
              color: Color(0xFF666),
            ),
            mobileFontSize: 16,
            tabletFontSize: 18,
            desktopFontSize: 20,
            largeDesktopFontSize: 22,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonSections(BuildContext context, Map<String, dynamic> lesson) {
    final sections = lesson['sections'] as List<dynamic>? ?? [];
    
    if (sections.isEmpty) {
      return _buildSampleContent(context);
    }

    return Column(
      children: sections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value as Map<String, dynamic>;
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16),
          ),
          child: _buildSectionCard(context, section, index),
        );
      }).toList(),
    );
  }

  Widget _buildSectionCard(BuildContext context, Map<String, dynamic> section, int index) {
    return GestureDetector(
      onTap: () => _onSectionTap(context, section, index),
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: currentSection == index ? _bounceAnimation.value : 1.0,
            child: Container(
              width: double.infinity,
              padding: ResponsiveUtils.getResponsivePadding(context),
              decoration: BoxDecoration(
                color: currentSection == index ? const Color(0xFFE3F2FD) : Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12),
                ),
                border: Border.all(
                  color: currentSection == index ? const Color(0xFF1976D2) : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          ResponsiveUtils.getResponsiveSpacing(context, mobile: 8),
                        ),
                        decoration: BoxDecoration(
                          color: currentSection == index ? const Color(0xFF1976D2) : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 8),
                          ),
                        ),
                        child: ResponsiveText(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          mobileFontSize: 16,
                          tabletFontSize: 18,
                          desktopFontSize: 20,
                          largeDesktopFontSize: 22,
                        ),
                      ),
                      ResponsiveSpacing(mobileSpacing: 12, isVertical: false),
                      Expanded(
                        child: ResponsiveText(
                          section['heading'] ?? section['title'] ?? 'Section ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: currentSection == index ? const Color(0xFF1976D2) : const Color(0xFF4A4E69),
                          ),
                          mobileFontSize: 16,
                          tabletFontSize: 18,
                          desktopFontSize: 20,
                          largeDesktopFontSize: 22,
                        ),
                      ),
                      if (currentSection > index)
                        ResponsiveIcon(
                          Icons.check_circle,
                          color: Colors.green,
                          mobileSize: 20,
                          tabletSize: 22,
                          desktopSize: 24,
                          largeDesktopSize: 26,
                        ),
                    ],
                  ),
                  if (section['content'] != null) ...[
                    ResponsiveSpacing(mobileSpacing: 8),
                    ResponsiveText(
                      section['content'],
                      style: const TextStyle(
                        color: Color(0xFF666),
                      ),
                      mobileFontSize: 14,
                      tabletFontSize: 16,
                      desktopFontSize: 18,
                      largeDesktopFontSize: 20,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSampleContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ResponsiveIcon(
            Icons.school,
            color: const Color(0xFF648BA2),
            mobileSize: 48,
            tabletSize: 56,
            desktopSize: 64,
            largeDesktopSize: 72,
          ),
          ResponsiveSpacing(mobileSpacing: 16),
          ResponsiveText(
            'Interactive Learning Content',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4E69),
            ),
            mobileFontSize: 18,
            tabletFontSize: 20,
            desktopFontSize: 22,
            largeDesktopFontSize: 24,
            textAlign: TextAlign.center,
          ),
          ResponsiveSpacing(mobileSpacing: 12),
          ResponsiveText(
            'This content has been converted from your teacher\'s uploaded material into an interactive learning experience!',
            style: const TextStyle(
              color: Color(0xFF666),
            ),
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 18,
            largeDesktopFontSize: 20,
            textAlign: TextAlign.center,
          ),
          ResponsiveSpacing(mobileSpacing: 20),
          _buildInteractiveButton(
            context,
            'Start Learning',
            Icons.play_arrow,
            () => _onStartLearning(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, mobile: 24),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF648BA2), Color(0xFF3C7E71)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ResponsiveIcon(
              icon,
              color: Colors.white,
              mobileSize: 20,
              tabletSize: 22,
              desktopSize: 24,
              largeDesktopSize: 26,
            ),
            ResponsiveSpacing(mobileSpacing: 8, isVertical: false),
            ResponsiveText(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              mobileFontSize: 16,
              tabletFontSize: 18,
              desktopFontSize: 20,
              largeDesktopFontSize: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonProgress(BuildContext context, Map<String, dynamic> lesson) {
    final progress = lesson['progressTracking'];
    if (progress == null) return const SizedBox.shrink();

    final completed = progress['sectionsCompleted'] ?? 0;
    final total = progress['totalSections'] ?? 1;
    final percentage = (completed / total).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText(
                'Progress',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4E69),
                ),
                mobileFontSize: 16,
                tabletFontSize: 18,
                desktopFontSize: 20,
                largeDesktopFontSize: 22,
              ),
              ResponsiveText(
                '${(percentage * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF648BA2),
                ),
                mobileFontSize: 16,
                tabletFontSize: 18,
                desktopFontSize: 20,
                largeDesktopFontSize: 22,
              ),
            ],
          ),
          ResponsiveSpacing(mobileSpacing: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF648BA2)),
            minHeight: ResponsiveUtils.getResponsiveSpacing(context, mobile: 8),
          ),
          ResponsiveSpacing(mobileSpacing: 8),
          ResponsiveText(
            '$completed of $total sections completed',
            style: const TextStyle(
              color: Color(0xFF666),
            ),
            mobileFontSize: 12,
            tabletFontSize: 14,
            desktopFontSize: 16,
            largeDesktopFontSize: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildGameActivity(BuildContext context) {
    // Implementation for game activities
    return _buildSampleContent(context);
  }

  Widget _buildInteractiveAssessment(BuildContext context) {
    // Implementation for interactive assessments
    return _buildSampleContent(context);
  }

  Widget _buildFallbackContent(BuildContext context) {
    return _buildSampleContent(context);
  }

  Widget _buildConfetti() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: 1.57, // Downward
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        gravity: 0.3,
        colors: const [
          Color(0xFF648BA2),
          Color(0xFF3C7E71),
          Color(0xFF4CAF50),
          Color(0xFFFF9800),
          Color(0xFFE91E63),
        ],
      ),
    );
  }

  String _getContentTypeDisplay() {
    final type = widget.contentData['type'];
    switch (type) {
      case 'interactive-lesson':
        return '🎓 Interactive Lesson';
      case 'game-activity':
        return '🎮 Game Activity';
      case 'interactive-assessment':
        return '📝 Interactive Quiz';
      default:
        return '📚 Learning Content';
    }
  }

  void _onSectionTap(BuildContext context, Map<String, dynamic> section, int index) {
    setState(() {
      currentSection = index;
    });
    
    _bounceController.reset();
    _bounceController.forward();
    
    // Play sound effect
    audioPlayer.play(AssetSource('sound/success.mp3'));
    
    // Speak the content
    if (section['content'] != null) {
      flutterTts.speak(section['content']);
    }
    
    // Add score
    setState(() {
      score += 10;
    });
  }

  void _onStartLearning(BuildContext context) {
    setState(() {
      currentSection = 0;
      score = 0;
    });
    
    _bounceController.reset();
    _bounceController.forward();
    
    // Play sound effect
    audioPlayer.play(AssetSource('sound/start.mp3'));
    
    // Speak introduction
    flutterTts.speak("Let's start learning! Tap on each section to explore the content.");
  }
}
