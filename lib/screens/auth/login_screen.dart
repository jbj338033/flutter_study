import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:solve/configs/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$API_URL/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['data'] != null) {
        // 토큰 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'accessToken', responseData['data']['accessToken'] as String);
        await prefs.setString(
            'refreshToken', responseData['data']['refreshToken'] as String);

        if (mounted) {
          // 로그인 성공 시 스낵바 표시 후 화면 이동
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인 성공!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );

          // 홈 화면으로 이동
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 로고 아이콘
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  // 타이틀
                  Text(
                    '로그인',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // 사용자명 입력 필드
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: '사용자명',
                      hintText: '사용자명을 입력하세요',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '사용자명을 입력해주세요';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  // 비밀번호 입력 필드
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      hintText: '비밀번호를 입력하세요',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 24),
                  // 로그인 버튼
                  FilledButton(
                    onPressed: _isLoading ? null : _login,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/signup');
                    },
                    child: const Text('계정이 없으신가요? 회원가입'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
