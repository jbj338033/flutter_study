import 'package:flutter/material.dart';

class ContestResponse {
  final int id;
  final String title;
  final String description;
  final DateTime startAt;
  final DateTime endAt;
  final ContestOwnerResponse owner;
  final ContestState state;
  final List<ContestOperatorResponse> operators;
  final List<ContestParticipantResponse> participants;
  final List<ContestProblem> problems;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContestResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.owner,
    required this.state,
    required this.operators,
    required this.participants,
    required this.problems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContestResponse.fromJson(Map<String, dynamic> json) {
    return ContestResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      owner:
          ContestOwnerResponse.fromJson(json['owner'] as Map<String, dynamic>),
      state: ContestState.values
          .firstWhere((e) => e.toString() == 'ContestState.${json['state']}'),
      operators: (json['operators'] as List)
          .map((e) =>
              ContestOperatorResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      participants: (json['participants'] as List)
          .map((e) =>
              ContestParticipantResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      problems: (json['problems'] as List)
          .map((e) => ContestProblem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ContestParticipantResponse {
  final String username;

  ContestParticipantResponse({required this.username});

  factory ContestParticipantResponse.fromJson(Map<String, dynamic> json) {
    return ContestParticipantResponse(username: json['username'] as String);
  }
}

class ContestOwnerResponse {
  final String username;

  ContestOwnerResponse({required this.username});

  factory ContestOwnerResponse.fromJson(Map<String, dynamic> json) {
    return ContestOwnerResponse(username: json['username'] as String);
  }
}

class ContestOperatorResponse {
  final String username;

  ContestOperatorResponse({required this.username});

  factory ContestOperatorResponse.fromJson(Map<String, dynamic> json) {
    return ContestOperatorResponse(username: json['username'] as String);
  }
}

class ContestProblem {
  final String title;

  ContestProblem({required this.title});

  factory ContestProblem.fromJson(Map<String, dynamic> json) {
    return ContestProblem(title: json['title'] as String);
  }
}

enum ContestState {
  UPCOMING,
  ONGOING,
  ENDED,
}

class ContestStateConfig {
  final Color color;
  final IconData icon;
  final String label;

  ContestStateConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}
