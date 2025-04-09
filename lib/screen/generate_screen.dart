import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/question_provider.dart';
import '../service/pdf_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, List<String>> subjectTopics = {
    'science': ['plants', 'animals'],
    'history': ['ancient', 'medieval'],
  };

  //default values of the options.
  String selectedSubject = 'science';
  String selectedTopic = 'plants';
  int easy = 40;
  int medium = 30;
  int hard = 30;
  bool isMcq = false;
  int totalQuestions = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('Question Paper Generator'),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Subject & Topic', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ///subject and topic selection row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: subjectTopics.keys.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.toUpperCase()),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedSubject = val!;
                          selectedTopic = subjectTopics[val]!.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedTopic,
                      decoration: const InputDecoration(
                        labelText: 'Topic',
                        border: OutlineInputBorder(),
                      ),
                      items: subjectTopics[selectedSubject]!.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.toUpperCase()),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedTopic = val!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Paper Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: totalQuestions.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Questions',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    totalQuestions = int.tryParse(value) ?? 10;
                  });
                },
              ),
              const SizedBox(height: 20),

              const Text('Difficulty Split (%)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              buildSlider('Easy', easy, (val) {
                setState(() {
                  easy = val;
                  autoAdjustSliders();
                });
              }),
              buildSlider('Medium', medium, (val) {
                setState(() {
                  medium = val;
                  autoAdjustSliders();
                });
              }),
              buildSlider('Hard', hard, (val) {
                setState(() {
                  hard = val;
                  autoAdjustSliders();
                });
              }),

              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('MCQ Pattern?'),
                value: isMcq,
                onChanged: (value) {
                  setState(() {
                    isMcq = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    var provider = Provider.of<QuestionProvider>(context, listen: false);
                    var questions = provider.generatePaper(
                      subject: selectedSubject,
                      topic: selectedTopic,
                      easyPercent: easy,
                      mediumPercent: medium,
                      hardPercent: hard,
                      isMcq: isMcq,
                      totalQuestions: totalQuestions,
                    );
                    await PdfService.generatePdf(questions);
                  },
                  child: const Text('Generate PDF'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSlider(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value%', style: const TextStyle(fontSize: 16)),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          label: '$value%',
          onChanged: (double val) {
            onChanged(val.round());
          },
        ),
      ],
    );
  }

  ///this is to prevent user from selecting a percentage greater than 100
  void autoAdjustSliders() {
    int total = easy + medium + hard;
    if (total > 100) {
      int overflow = total - 100;
      if (hard >= overflow) {
        hard -= overflow;
      } else if (medium >= overflow) {
        medium -= overflow;
      } else if (easy >= overflow) {
        easy -= overflow;
      }
    }
  }
}
