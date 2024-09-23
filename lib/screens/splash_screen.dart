import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzc_global_app/pages/login_page.dart';
import 'package:fzc_global_app/pages/tabs/tabs_navigation.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';
import 'package:flutter/material.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _checkTokenAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkTokenAndNavigate() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      SecureStorage secureStorage = SecureStorage();
      String token =
          await secureStorage.readSecureData(SecureStorageKeys.userId) ?? "";

      if (token.isNotEmpty) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TabsNavigation()),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Something went wrong please login again!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 238, 4, 16),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: const Text(
            'Global Parts',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Constants.whiteColor,
            ),
          ),
        ),
      ),
    );
  }
}
