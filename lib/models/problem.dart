import 'package:flutter_study/models/base.dart';

class Problem implements JsonConvertible {
  final int id;
  final String title;
  final String content;
  final String input;
  final String output;
  final int memoryLimit;
  final double timeLimit;
  final double correctRate;
  final List<ProblemTestCase> testCases;
  final ProblemAuthor author;
  final ProblemSubmitState? state;

  Problem({
    required this.id,
    required this.title,
    required this.content,
    required this.input,
    required this.output,
    required this.memoryLimit,
    required this.timeLimit,
    required this.correctRate,
    required this.testCases,
    required this.author,
    required this.state,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    return Problem(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      input: json['input'],
      output: json['output'],
      memoryLimit: json['memoryLimit'],
      timeLimit: json['timeLimit'],
      correctRate: json['correctRate'],
      testCases: (json['testCases'] as List<dynamic>)
          .map((testCase) => ProblemTestCase.fromJson(testCase))
          .toList(),
      author: ProblemAuthor.fromJson(json['author']),
      state: json['state'] == null
          ? null
          : ProblemSubmitState.values.firstWhere(
              (e) => e.toString() == 'ProblemSubmitState.${json['state']}'),
    );
  }
}

class ProblemTestCase {
  final int id;
  final String input;
  final String output;

  ProblemTestCase({
    required this.id,
    required this.input,
    required this.output,
  });

  factory ProblemTestCase.fromJson(Map<String, dynamic> json) {
    return ProblemTestCase(
      id: json['id'],
      input: json['input'],
      output: json['output'],
    );
  }
}

class ProblemAuthor {
  final String username;

  ProblemAuthor({required this.username});

  factory ProblemAuthor.fromJson(Map<String, dynamic> json) {
    return ProblemAuthor(username: json['username']);
  }
}

enum ProblemSubmitState {
  ACCEPTED,
  WRONG_ANSWER,
  PRESENTATION_ERROR,
  TIME_LIMIT_EXCEEDED,
  MEMORY_LIMIT_EXCEEDED,
  RUNTIME_ERROR,
  COMPILE_ERROR,
  PENDING,
  JUDGING,
  JUDGING_IN_PROGRESS,
}
