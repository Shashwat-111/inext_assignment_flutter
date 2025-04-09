class QuestionModel {
  final String subject;
  final String topic;
  final String difficulty;
  final String question;
  final List<int> answer;

  QuestionModel({
    required this.subject,
    required this.topic,
    required this.difficulty,
    required this.question,
    required this.answer,
  });


  @override
  String toString() {
    return 'Subject: $subject, Topic: $topic, Difficulty: $difficulty, Question: $question';
  }

}
