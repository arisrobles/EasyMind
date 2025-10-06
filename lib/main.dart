import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'student_landing_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_initialization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize memory retention features
  await AppInitializationService().initializeApp();
  
  runApp(EasyMindApp());
}

class EasyMindApp extends StatelessWidget {
  const EasyMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Color(0xFF648BA2),
      ),
      home: StudentLoginScreen(),
    );
  }
}

class StudentLoginScreen extends StatelessWidget {
  final TextEditingController nicknameController = TextEditingController();

  StudentLoginScreen({super.key});

  // Function to record student login and create/update student profile
  Future<void> _updateStudentLogin(String nickname) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final now = Timestamp.now();

      // Query the students collection to find the student by nickname
      final querySnapshot =
          await firestore
              .collection('students')
              .where('nickname', isEqualTo: nickname)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Student exists - update lastLogin
        final studentDoc = querySnapshot.docs.first;
        await studentDoc.reference.update({'lastLogin': now});
        print('Existing student login updated: $nickname');
      } else {
        // Student doesn't exist - create new student profile
        await firestore.collection('students').add({
          'nickname': nickname,
          'createdAt': now,
          'lastLogin': now,
          'totalLessonsCompleted': 0,
          'totalXP': 0,
          'currentLevel': 1,
          'currentStreak': 0,
          'longestStreak': 0,
          'preferredLearningTime': 'morning',
          'difficultyLevel': 'beginner',
          'isActive': true,
          'profileComplete': false,
          'lastActivity': now,
        });
        print('New student profile created: $nickname');
      }

      // Write to the studentLogins collection with timestamp log
      print('Student Login time set to: $now');
      await firestore.collection('studentLogins').add({
        'nickname': nickname,
        'loginTime': now,
      });
    } catch (e) {
      print('Error recording student login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFE9D5),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(child: Image.asset('assets/logo.png', height: 400)),
          ),
          Positioned(
            top: 450,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'EasyMind',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF648BA2),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          Positioned(
            top: 580,
            left: 0,
            right: 0,
            child: Center(
              child: CustomTextField(
                controller: nicknameController,
                labelText: 'Enter your nickname',
                width: 800,
                height: 120,
              ),
            ),
          ),
          Positioned(
            top: 750,
            left: 0,
            right: 0,
            child: Center(
              child: CustomButton(
                text: 'LOGIN',
                width: 800,
                height: 80,
                onPressed: () {
                  String nickname = nicknameController.text.trim();
                  if (nickname.isNotEmpty) {
                    _updateStudentLogin(nickname).then((_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  StudentLandingPage(nickname: nickname),
                        ),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please enter a nickname",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String labelText;
  final double width;
  final double height;
  final TextEditingController controller;

  const CustomTextField({super.key, 
    required this.labelText,
    required this.controller,
    this.width = 380,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Color(0xFF6EABCF), width: 8),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextField(
          controller: controller,
          style: TextStyle(fontSize: 40, color: Colors.black),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: labelText,
            hintStyle: TextStyle(fontSize: 35, color: Colors.black54),
            contentPadding: EdgeInsets.only(left: 5, top: 30),
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const CustomButton({super.key, 
    required this.text,
    this.width = 380,
    this.height = 60,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF648BA2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
