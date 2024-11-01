import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:solve/configs/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _introController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _introController.text = widget.profileData['introduction'] ?? '';
  }

  @override
  void dispose() {
    _introController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isUploadingImage) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isUploadingImage = true;
      });

      try {
        await _updateAvatar();
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
        }
      }
    }
  }

  Future<void> _updateAvatar() async {
    if (_selectedImage == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('https://api.solve.mcv.kr/users/me/avatar'),
      );

      request.headers['Authorization'] = token!;
      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedImage!.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (mounted) {
          print(widget.profileData['id']);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프로필 이미지가 업데이트되었습니다.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미지 업로드에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // 업로드 실패시 선택된 이미지 초기화
        if (mounted) {
          setState(() {
            _selectedImage = null;
          });
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
        setState(() {
          _selectedImage = null;
        });
      }
    }
  }

  Future<void> _updateIntroduction() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await http.patch(
        Uri.parse('https://api.solve.mcv.kr/users/me'),
        headers: {
          'Authorization': token!,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'introduction': _introController.text,
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('자기소개가 업데이트되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('자기소개 업데이트에 실패했습니다.'),
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

  Future<void> _updatePassword() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await http.patch(
        Uri.parse('https://api.solve.mcv.kr/users/me/password'),
        headers: {
          'Authorization': token!,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('비밀번호가 변경되었습니다.')),
          );
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('비밀번호 변경에 실패했습니다.'),
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다.';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]')
        .hasMatch(value)) {
      return '영문, 숫자, 특수문자를 각각 1개 이상 포함해야 합니다.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 이미지 섹션
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : NetworkImage(
                                '$API_URL/avatars/${widget.profileData['id']}.webp'),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          radius: 18,
                          child: _isUploadingImage
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.camera_alt, size: 18),
                                  color: colorScheme.onPrimary,
                                  onPressed: _pickImage,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 자기소개 섹션
                Text(
                  '자기소개',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _introController,
                  maxLength: 255,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '자기소개를 입력해주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateIntroduction,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('자기소개 수정'),
                  ),
                ),

                const SizedBox(height: 32),

                // 비밀번호 변경 섹션
                Text(
                  '비밀번호 변경',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '현재 비밀번호',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '현재 비밀번호를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '새 비밀번호',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '새 비밀번호 확인',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updatePassword,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('비밀번호 변경'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
