import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_study/models/page.dart';
import 'package:flutter_study/models/problem.dart';
import 'package:flutter_study/screens/problem_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProblemStateConfig {
  final Color color;
  final IconData icon;
  final String label;

  ProblemStateConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}

class ProblemListScreen extends StatefulWidget {
  const ProblemListScreen({super.key});

  @override
  State<ProblemListScreen> createState() => _ProblemListScreenState();
}

class _ProblemListScreenState extends State<ProblemListScreen> {
  final List<Problem> _problems = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProblems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _fetchProblems(isLoadMore: true);
      }
    }
  }

  Future<void> _fetchProblems({bool isLoadMore = false}) async {
    if (_isLoadingMore || (_isLoading && isLoadMore)) return;

    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await http.get(
          Uri.parse(
              'https://api.solve.mcv.kr/problems?page=$_page&size=$_pageSize'),
          headers: {
            "Content-Type": "application/json; charset=utf-8",
            if (token != null) "Authorization": "Bearer $token"
          });

      if (response.statusCode == 200) {
        final responseData =
            json.decode(utf8.decode(response.bodyBytes))['data'];
        if (responseData != null) {
          final data = PageResponse.fromJson(
            responseData as Map<String, dynamic>,
            Problem.fromJson,
          );

          if (mounted) {
            setState(() {
              _page++;
              _hasMore = !data.last;
              _problems.addAll(data.content);
            });
          }
        }
      } else {
        if (mounted) _showSnackBar('문제 목록을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      print('Error fetching problems: $e');
      if (mounted) _showSnackBar('오류가 발생했습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _navigateToProblemDetail(Problem problem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProblemDetailScreen(problem: problem),
      ),
    );
  }

  ProblemStateConfig _getStateConfig(ProblemSubmitState state) {
    switch (state) {
      case ProblemSubmitState.ACCEPTED:
        return ProblemStateConfig(
          color: Colors.green,
          icon: Icons.check_circle,
          label: '맞았습니다',
        );
      case ProblemSubmitState.WRONG_ANSWER:
        return ProblemStateConfig(
          color: Colors.red,
          icon: Icons.close,
          label: '틀렸습니다',
        );
      case ProblemSubmitState.PRESENTATION_ERROR:
        return ProblemStateConfig(
          color: Colors.orange,
          icon: Icons.format_shapes,
          label: '출력 형식',
        );
      case ProblemSubmitState.TIME_LIMIT_EXCEEDED:
        return ProblemStateConfig(
          color: Colors.amber[700]!,
          icon: Icons.timer_off,
          label: '시간 초과',
        );
      case ProblemSubmitState.MEMORY_LIMIT_EXCEEDED:
        return ProblemStateConfig(
          color: Colors.purple,
          icon: Icons.memory,
          label: '메모리 초과',
        );
      case ProblemSubmitState.RUNTIME_ERROR:
        return ProblemStateConfig(
          color: Colors.red[700]!,
          icon: Icons.error,
          label: '런타임 에러',
        );
      case ProblemSubmitState.COMPILE_ERROR:
        return ProblemStateConfig(
          color: Colors.blue[700]!,
          icon: Icons.code_off,
          label: '컴파일 에러',
        );
      case ProblemSubmitState.PENDING:
        return ProblemStateConfig(
          color: Colors.grey[600]!,
          icon: Icons.hourglass_empty,
          label: '대기 중',
        );
      case ProblemSubmitState.JUDGING:
      case ProblemSubmitState.JUDGING_IN_PROGRESS:
        return ProblemStateConfig(
          color: Colors.blue,
          icon: Icons.sync,
          label: '채점 중',
        );
      default:
        return ProblemStateConfig(
          color: Colors.grey,
          icon: Icons.help_outline,
          label: '알 수 없음',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('문제 목록')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _page = 0;
                  _problems.clear();
                  _hasMore = true;
                });
                await _fetchProblems();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _problems.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _problems.length && _hasMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _buildProblemCard(_problems[index]);
                },
              ),
            ),
    );
  }

  Widget _buildProblemCard(Problem problem) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToProblemDetail(problem),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      problem.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (problem.state != null) ...[
                    const SizedBox(width: 8),
                    _buildStateChip(problem.state!),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '작성자: ${problem.author.username}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                '정답률: ${problem.correctRate}%',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateChip(ProblemSubmitState state) {
    final stateConfig = _getStateConfig(state);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: stateConfig.color.withOpacity(0.1),
        border: Border.all(color: stateConfig.color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            stateConfig.icon,
            size: 16,
            color: stateConfig.color,
          ),
          const SizedBox(width: 4),
          Text(
            stateConfig.label,
            style: TextStyle(
              color: stateConfig.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
