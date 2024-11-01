import 'package:solve/models/base.dart';

class ProblemResponse implements JsonConvertible {
  final int id;
  final String title;
  final String content;
  final String input;
  final String output;
  final int memoryLimit;
  final double timeLimit;
  final double correctRate;
  final List<ProblemTestCaseResponse> testCases;
  final ProblemAuthorResponse author;
  final ProblemSubmitState? state;

  ProblemResponse({
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

  factory ProblemResponse.fromJson(Map<String, dynamic> json) {
    return ProblemResponse(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      input: json['input'],
      output: json['output'],
      memoryLimit: json['memoryLimit'],
      timeLimit: json['timeLimit'],
      correctRate: json['correctRate'],
      testCases: (json['testCases'] as List<dynamic>)
          .map((testCase) => ProblemTestCaseResponse.fromJson(testCase))
          .toList(),
      author: ProblemAuthorResponse.fromJson(json['author']),
      state: json['state'] == null
          ? null
          : ProblemSubmitState.values.firstWhere(
              (e) => e.toString() == 'ProblemSubmitState.${json['state']}'),
    );
  }
}

class ProblemTestCaseResponse implements JsonConvertible {
  final int id;
  final String input;
  final String output;

  ProblemTestCaseResponse({
    required this.id,
    required this.input,
    required this.output,
  });

  factory ProblemTestCaseResponse.fromJson(Map<String, dynamic> json) {
    return ProblemTestCaseResponse(
      id: json['id'],
      input: json['input'],
      output: json['output'],
    );
  }
}

class ProblemAuthorResponse implements JsonConvertible {
  final String username;

  ProblemAuthorResponse({required this.username});

  factory ProblemAuthorResponse.fromJson(Map<String, dynamic> json) {
    return ProblemAuthorResponse(username: json['username']);
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
