import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../auth/controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure the controller is ready so the auth listener can route
    AuthController.instance;
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    AuthController.instance.checkAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_w51pcehl.json', // Example Event Lottie
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.event, size: 100, color: Colors.blue);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'EventMate',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
