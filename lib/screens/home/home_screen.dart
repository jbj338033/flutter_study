import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '홈 화면',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                // 로그아웃 처리
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('accessToken');
                await prefs.remove('refreshToken');

                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
