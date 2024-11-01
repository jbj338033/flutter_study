import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:solve/configs/api_config.dart';
import 'package:solve/screens/profile/edit_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _selectedYear = DateTime.now().year.toString();
  Map<String, dynamic>? _profileData;
  // 이미지 캐시 무효화를 위한 타임스탬프
  String _imageTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.solve.mcv.kr/users/me'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _profileData = json.decode(utf8.decode(response.bodyBytes))['data'];
          _isLoading = false;
          // 프로필 데이터를 새로 받아올 때마다 타임스탬프 업데이트
          _imageTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로필을 불러오는데 실패했습니다.'),
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
    }
  }

  List<String> _getYearList() {
    if (_profileData == null) return [DateTime.now().year.toString()];

    final createdAt = DateTime.parse(_profileData!['createdAt']);
    final currentYear = DateTime.now().year;
    final years = <String>[];

    for (var year = createdAt.year; year <= currentYear; year++) {
      years.add(year.toString());
    }

    return years.reversed.toList();
  }

  Color _getGrassColor(int? value) {
    if (value == null) return Colors.grey.withOpacity(0.1);

    if (value == 0) return Colors.grey.withOpacity(0.1);
    if (value <= 2) return Colors.green.shade100;
    if (value <= 5) return Colors.green.shade300;
    if (value <= 8) return Colors.green.shade500;
    return Colors.green.shade700;
  }

  Widget _buildGrassGrid() {
    final grass = _profileData?['grass'] as Map<String, dynamic>? ?? {};
    final weeks = <List<DateTime>>[];
    final firstDayOfYear = DateTime(int.parse(_selectedYear), 1, 1);
    var currentDay = firstDayOfYear;

    while (currentDay.weekday != DateTime.sunday) {
      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    while (currentDay.year <= int.parse(_selectedYear)) {
      final week = <DateTime>[];
      for (var i = 0; i < 7; i++) {
        week.add(currentDay);
        currentDay = currentDay.add(const Duration(days: 1));
      }
      weeks.add(week);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: weeks.map((week) {
                return Column(
                  children: week.map((day) {
                    final dateStr = DateFormat('yyyy-MM-dd').format(day);
                    final value = grass[dateStr] as int?;

                    return InkWell(
                      onTap: () => _showDayDetail(context, day, value),
                      child: Tooltip(
                        message: '$dateStr: ${value ?? 0}문제',
                        child: Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: _getGrassColor(value),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayDetail(
      BuildContext context, DateTime date, int? solvedCount) async {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy년 MM월 dd일').format(date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('(E)').format(date),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getGrassColor(solvedCount),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${solvedCount ?? 0}문제 해결',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isToday && _profileData?['solvedToday'] == true)
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('오늘의 문제 해결 완료! 🎉'),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('닫기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: NetworkImage(
                          '$API_URL/avatars/${_profileData!['id']}.webp?t=$_imageTimestamp',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profileData?['username'] ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _profileData?['email'] ?? '',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                profileData: _profileData!,
                              ),
                            ),
                          ).then((_) => _fetchProfile());
                        },
                      ),
                    ],
                  ),

                  if (_profileData?['introduction']?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.format_quote, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '자기소개',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _profileData?['introduction'] ?? '',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 통계 카드들
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  _profileData?['solvedCount']?.toString() ??
                                      '0',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('해결한 문제'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  _profileData?['streak']?.toString() ?? '0',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('현재 연속'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  _profileData?['maxStreak']?.toString() ?? '0',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('최고 연속'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 잔디 그래프
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '문제 풀이 기록',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedYear,
                        items: _getYearList()
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedYear = value);
                          }
                        },
                      ),
                    ],
                  ),
                  _buildGrassGrid(),

                  const SizedBox(height: 16),

                  // 계정 정보
                  ListTile(
                    title: const Text('계정 생성일'),
                    subtitle: Text(
                      DateFormat('yyyy년 MM월 dd일').format(
                        DateTime.parse(_profileData?['createdAt'] ?? ''),
                      ),
                    ),
                  ),

                  if (_profileData?['solvedToday'] == true)
                    const Card(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('오늘의 문제를 해결했습니다! 🎉'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
