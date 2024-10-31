import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_study/models/contest.dart';
import 'package:flutter_study/screens/contest_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ContestListScreen extends StatefulWidget {
  const ContestListScreen({super.key});

  @override
  State<ContestListScreen> createState() => _ContestListScreenState();
}

class _ContestListScreenState extends State<ContestListScreen> {
  final List<ContestResponse> _contests = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchContests();
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
        _fetchContests(isLoadMore: true);
      }
    }
  }

  Future<void> _fetchContests({bool isLoadMore = false}) async {
    if (_isLoadingMore || (_isLoading && isLoadMore)) return;

    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.solve.mcv.kr/contests?page=$_page&size=$_pageSize'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
      );

      if (response.statusCode == 200) {
        final responseData =
            json.decode(utf8.decode(response.bodyBytes))['data'];

        if (responseData != null) {
          final List<ContestResponse> newContests =
              (responseData['content'] as List)
                  .map((item) =>
                      ContestResponse.fromJson(item as Map<String, dynamic>))
                  .toList();

          if (mounted) {
            setState(() {
              _page++;
              _hasMore = !(responseData['last'] as bool);
              _contests.addAll(newContests);
            });
          }
        }
      } else {
        if (mounted) _showSnackBar('대회 목록을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      print('Error fetching contests: $e');
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

  ContestStateConfig _getStateConfig(ContestState state) {
    switch (state) {
      case ContestState.UPCOMING:
        return ContestStateConfig(
          color: Colors.blue,
          icon: Icons.schedule,
          label: '예정',
        );
      case ContestState.ONGOING:
        return ContestStateConfig(
          color: Colors.green,
          icon: Icons.play_arrow,
          label: '진행중',
        );
      case ContestState.ENDED:
        return ContestStateConfig(
          color: Colors.red,
          icon: Icons.stop,
          label: '종료',
        );
      default:
        return ContestStateConfig(
          color: Colors.grey,
          icon: Icons.help,
          label: '알 수 없음',
        );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('대회 목록')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _page = 0;
                  _contests.clear();
                  _hasMore = true;
                });
                await _fetchContests();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _contests.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _contests.length && _hasMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _buildContestCard(_contests[index]);
                },
              ),
            ),
    );
  }

  Widget _buildContestCard(ContestResponse contest) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContestDetailScreen(contest: contest),
            ),
          );
        },
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
                      contest.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStateConfig(contest.state).color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStateConfig(contest.state).label,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                contest.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                '주최자: ${contest.owner.username}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '시작: ${_formatDateTime(contest.startAt)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                '종료: ${_formatDateTime(contest.endAt)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '참가자: ${contest.participants.length}명',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.assignment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '문제: ${contest.problems.length}개',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
