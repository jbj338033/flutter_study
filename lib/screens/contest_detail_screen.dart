import 'package:flutter/material.dart';
import 'package:flutter_study/models/contest.dart';
import 'package:intl/intl.dart';

class ContestDetailScreen extends StatelessWidget {
  final ContestResponse contest;

  const ContestDetailScreen({super.key, required this.contest});

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contest.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildDescription(),
            _buildTimeInfo(),
            _buildParticipants(),
            _buildOperators(),
            _buildProblems(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStateConfig(contest.state).color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getStateConfig(contest.state).label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '주최자: ${contest.owner.username}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '생성일: ${_formatDateTime(contest.createdAt)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (contest.createdAt != contest.updatedAt)
            Text(
              '수정일: ${_formatDateTime(contest.updatedAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대회 설명',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contest.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대회 일정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildTimeRow('시작', contest.startAt),
          const SizedBox(height: 4),
          _buildTimeRow('종료', contest.endAt),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, DateTime time) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          _formatDateTime(time),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildParticipants() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '참가자',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '총 ${contest.participants.length}명',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contest.participants
                .map((user) => Chip(
                      label: Text(user.username),
                      backgroundColor: Colors.grey[800],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOperators() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '운영진',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '총 ${contest.operators.length}명',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contest.operators
                .map((user) => Chip(
                      label: Text(user.username),
                      backgroundColor: Colors.blue[800],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProblems() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '문제',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '총 ${contest.problems.length}문제',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contest.problems.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    child: Text('${index + 1}'),
                  ),
                  title: Text(contest.problems[index].title),
                  onTap: () {
                    // TODO: Navigate to problem detail
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
