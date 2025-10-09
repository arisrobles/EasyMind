import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'functional_academics.dart';
import 'communication_skills.dart';
import 'prevocational_skills.dart';
import 'unified_analytics_dashboard.dart';
import 'responsive_utils.dart';
import 'UploadedMaterialsPage.dart';

class Readingmaterialspage extends StatefulWidget {
  final String nickname;
  
  const Readingmaterialspage({super.key, required this.nickname});

  @override
  State<Readingmaterialspage> createState() => _ReadingmaterialspageState();
}

class _ReadingmaterialspageState extends State<Readingmaterialspage> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    setupTts();
  }

  void setupTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.3); // feminine tone
    await flutterTts.setSpeechRate(0.8); // natural speed

    List<dynamic> voices = await flutterTts.getVoices;
    for (var voice in voices) {
      final name = (voice["name"] ?? "").toLowerCase();
      final locale = (voice["locale"] ?? "").toLowerCase();
      if ((name.contains("female") ||
              name.contains("woman") ||
              name.contains("natural")) &&
          locale.contains("en")) {
        await flutterTts.setVoice({
          "name": voice["name"],
          "locale": voice["locale"],
        });
        break;
      }
    }
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
        ClipPath(
          clipper: TopWaveClipper(),
          child: Container(
            height: ResponsiveUtils.getResponsiveIconSize(context, mobile: 200),
            width: double.infinity,
            color: const Color(0xFFFBEED9),
          ),
        ),
        Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              ResponsiveSpacing(mobileSpacing: 120),
              Expanded(
                child: _buildSubjectGrid(context, crossAxisCount: 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: TopWaveClipper(),
          child: Container(
            height: ResponsiveUtils.getResponsiveIconSize(context, mobile: 220),
            width: double.infinity,
            color: const Color(0xFFFBEED9),
          ),
        ),
        Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              ResponsiveSpacing(mobileSpacing: 140),
              Expanded(
                child: _buildSubjectGrid(context, crossAxisCount: 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: TopWaveClipper(),
          child: Container(
            height: ResponsiveUtils.getResponsiveIconSize(context, mobile: 240),
            width: double.infinity,
            color: const Color(0xFFFBEED9),
          ),
        ),
        Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              ResponsiveSpacing(mobileSpacing: 160),
              Expanded(
                child: _buildSubjectGrid(context, crossAxisCount: 3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeDesktopLayout(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: TopWaveClipper(),
          child: Container(
            height: ResponsiveUtils.getResponsiveIconSize(context, mobile: 260),
            width: double.infinity,
            color: const Color(0xFFFBEED9),
          ),
        ),
        Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              ResponsiveSpacing(mobileSpacing: 180),
              Expanded(
                child: _buildSubjectGrid(context, crossAxisCount: 4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: ResponsiveUtils.getResponsiveIconSize(context, mobile: 50),
          width: ResponsiveUtils.getResponsiveIconSize(context, mobile: 150),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF648BA2),
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.getResponsiveSpacing(context, mobile: 15),
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12),
                ),
              ),
            ),
            child: ResponsiveText(
              'Go Back',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              mobileFontSize: 20,
              tabletFontSize: 22,
              desktopFontSize: 24,
              largeDesktopFontSize: 26,
            ),
          ),
        ),
        ResponsiveSpacing(mobileSpacing: 20, isVertical: false),
        SizedBox(
          height: ResponsiveUtils.getResponsiveIconSize(context, mobile: 50),
          width: ResponsiveUtils.getResponsiveIconSize(context, mobile: 180),
          child: ElevatedButton.icon(
            onPressed: () async {
              await flutterTts.speak("Progress Dashboard");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UnifiedAnalyticsDashboard(
                                    nickname: widget.nickname,
                                  ),
                                ),
                              );
            },
            icon: ResponsiveIcon(
              Icons.analytics,
              color: Colors.white,
              mobileSize: 20,
              tabletSize: 22,
              desktopSize: 24,
              largeDesktopSize: 26,
            ),
            label: ResponsiveText(
              '📊 Progress',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              mobileFontSize: 16,
              tabletFontSize: 18,
              desktopFontSize: 20,
              largeDesktopFontSize: 22,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3C7E71),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectGrid(BuildContext context, {required int crossAxisCount}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          shrinkWrap: ResponsiveUtils.isSmallScreen(context) ? false : true,
          physics: ResponsiveUtils.isSmallScreen(context) 
            ? const AlwaysScrollableScrollPhysics() 
            : const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, mobile: 15),
            mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, mobile: 15),
            childAspectRatio: ResponsiveUtils.isSmallScreen(context) ? 1.0 : 0.85,
          ),
          children: _buildSubjectCards(context),
        );
      },
    );
  }

  List<Widget> _buildSubjectCards(BuildContext context) {
    return [
      _buildSubjectCard(
        context,
        label: "",
        imagePath: 'assets/functional.png',
        onTap: () async {
          await flutterTts.speak("Functional Academics");
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FunctionalAcademicsPage(nickname: widget.nickname),
            ),
          );
        },
      ),
      _buildSubjectCard(
        context,
        label: "",
        imagePath: 'assets/communication.png',
        onTap: () async {
          await flutterTts.speak("Communication Skills");
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunicationSkillsPage(nickname: widget.nickname),
            ),
          );
        },
      ),
      _buildSubjectCard(
        context,
        label: "",
        imagePath: 'assets/prevocational.png',
        onTap: () async {
          await flutterTts.speak("Pre vocational Skills");
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreVocationalSkillsPage(nickname: widget.nickname),
            ),
          );
        },
      ),
      _buildSubjectCard(
        context,
        label: "",
        imagePath: 'assets/app.png',
        onTap: () async {
          await flutterTts.speak("Teacher's Materials");
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadedMaterialsPage(),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildSubjectCard(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, mobile: 16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 20),
                ),
                child: Image.asset(
                  imagePath,
                  height: ResponsiveUtils.isSmallScreen(context) 
                    ? ResponsiveUtils.getResponsiveIconSize(context, mobile: 150)
                    : ResponsiveUtils.getResponsiveIconSize(context, mobile: 200),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            ResponsiveSpacing(mobileSpacing: 8),
            Flexible(
              child: ResponsiveText(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4E69),
                ),
                mobileFontSize: 16,
                tabletFontSize: 18,
                desktopFontSize: 20,
                largeDesktopFontSize: 22,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
