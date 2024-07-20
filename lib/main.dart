import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textEditController = TextEditingController();
  String get apikey => const String.fromEnvironment('GEMINI_API_KEY');
  late GenerativeModel model;
  String? selectedValue;
  bool isLoading = false;
  String generatedText = '';
  List<String> selectedArea = [];
  final areas = [
    'Dart',
    'Flutter',
    'Golang',
    'Gemini',
    'AI/ML',
    'Google Cloud',
    'Android',
    'Maps'
  ];

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apikey,
    );
  }

  void generateTopics() async {
    setState(() {
      isLoading = true;
    });
    final prompt =
        'You are an amazing tech speaker that have spoken at over 1000 tech events. You have been task to generate compelling topics with absracts on the following event. Take into account the experience level to the audience which is $selectedValue on ${selectedArea.join(', ')}. Theme: ${_textEditController.text}';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    log(response.text ?? '');
    setState(() {
      generatedText = response.text ?? '';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Talk writer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(25.0),
        children: <Widget>[
          const Text(
            'Select experience level',
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField(
              value: selectedValue,
              decoration: const InputDecoration(
                  hintText: 'Select experience level',
                  border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(
                  value: 'Beginner',
                  child: Text('Beginner'),
                ),
                DropdownMenuItem(
                  value: 'Intermediate',
                  child: Text('Intermediate'),
                ),
                DropdownMenuItem(
                  value: 'Advanced',
                  child: Text('Advanced'),
                ),
                DropdownMenuItem(
                  value: 'Expert',
                  child: Text('Expert'),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  selectedValue = val.toString();
                });
              }),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Select areas of interest',
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 10,
            children: areas
                .map((e) => FilterChip(
                    selected: selectedArea.contains(e),
                    label: Text(e),
                    onSelected: (val) {
                      if (val) {
                        selectedArea.add(e);
                      } else {
                        selectedArea.remove(e);
                      }
                      setState(() {});
                    }))
                .toList(),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _textEditController,
            maxLines: 4,
            decoration: const InputDecoration(
                hintText: 'Enter the event theme here',
                border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 30,
          ),
          if (isLoading) ...{
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(
              height: 15,
            ),
          },
          ElevatedButton(
              onPressed: () {
                if (selectedValue == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please select the experience level'),
                  ));
                  return;
                }

                if (_textEditController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter the event theme'),
                  ));
                  return;
                }

                if (selectedArea.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please select the areas of interest'),
                  ));
                  return;
                }

                generateTopics();
              },
              child: const Text('Generate')),
          const SizedBox(height: 20),
          MarkdownBody(
            data: generatedText,
            selectable: true,
          )
        ],
        
      ),
    );
  }
}
