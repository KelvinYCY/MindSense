import 'dart:async'; // For Timer
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _logoOpacity = 0.0;
  double _buttonOpacity = 0.0;
  double _logoPadding = 100.0;
  double _buttonPadding = 50.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  // Start animations with a slight delay
  Future<void> _startAnimation() async {
    // Delay and then animate the logo
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _logoOpacity = 1.0;
      _logoPadding = 0.0;
    });

    // Delay and then animate the button
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _buttonOpacity = 1.0;
      _buttonPadding = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo with Hero widget for smoother transition
            Hero(
              tag: 'logo',
              child: AnimatedOpacity(
                opacity: _logoOpacity,
                duration: const Duration(seconds: 1),
                child: AnimatedPadding(
                  padding: EdgeInsets.only(top: _logoPadding),
                  duration: const Duration(seconds: 1),
                  child: Image.asset('assets/mindsense_logo.png', height: 150),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Animated button
            AnimatedOpacity(
              opacity: _buttonOpacity,
              duration: const Duration(seconds: 1),
              child: AnimatedPadding(
                padding: EdgeInsets.only(top: _buttonPadding),
                duration: const Duration(seconds: 1),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/user-login'); // Redirect to login
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
