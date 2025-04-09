import 'package:flutter/material.dart';
import 'package:inext_assignment_flutter/screen/generate_screen.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/question_model.dart';
import 'providers/question_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<QuestionModel> questions = await loadQuestionsFromJson();
  runApp(MyApp(questions: questions));
}

class MyApp extends StatelessWidget {
  final List<QuestionModel> questions;
  const MyApp({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => QuestionProvider()..loadQuestions(questions),
        ),
      ],
      child: MaterialApp(
        title: 'Question Paper Generator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

Future<List<QuestionModel>> loadQuestionsFromJson() async {
  final String response = await rootBundle.loadString('assets/data.json');
  final List<dynamic> data = json.decode(response);
  List<QuestionModel> loadedQuestions = [];

  //due to the incorrect way of data present in the given json file,
  // this approach has been used temporarily.
  // After the data is fixed, the normal [fromJson] method can be used
  for (var subject in data) {
    for (var topic in subject['topic']) {
      for (var level in topic['level']) {
        for (var i = 0; i < level['ques'].length; i++) {
          loadedQuestions.add(QuestionModel(
            subject: subject['subject'],
            topic: topic['topicname'],
            difficulty: level['lname'],
            question: level['ques'][i],
            answer: List<int>.from(level['ans'][i]['answer']),
          ));
        }
      }
    }
  }
  return loadedQuestions;
}
