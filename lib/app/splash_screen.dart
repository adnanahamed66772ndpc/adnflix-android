import 'package:flutter/material.dart';

import 'theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: netflixDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ADNFLIX',
              style: TextStyle(
                color: netflixRed,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: netflixRed,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
