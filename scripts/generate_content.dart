// Generate math_quizzes.json and surveys.json for the Flutter app.
// Run: dart run scripts/generate_content.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  final math = generateMathQuizzes(1000);
  final surveys = generateSurveys(1000);

  final outDir = Directory('assets/content');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  File('assets/content/math_quizzes.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(math),
  );
  File('assets/content/surveys.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(surveys),
  );

  stdout.writeln('Generated ${math.length} math quizzes and ${surveys.length} surveys.');
}

List<Map<String, dynamic>> generateMathQuizzes(int count) {
  final random = Random(42);
  final quizzes = <Map<String, dynamic>>[];

  for (var i = 0; i < count; i++) {
    final start = 100 + random.nextInt(120);
    final step = 70 + random.nextInt(90);
    final numbers = List.generate(7, (j) => start + step * j);
    final answer = numbers.fold<int>(0, (a, b) => a + b);
    quizzes.add({
      'id': 'mq_${(i + 1).toString().padLeft(4, '0')}',
      'numbers': numbers,
      'answer': answer,
      'points': 2,
    });
  }
  return quizzes;
}

List<Map<String, dynamic>> generateSurveys(int count) {
  final pool = _questionPool();
  final random = Random(99);
  final surveys = <Map<String, dynamic>>[];

  for (var i = 0; i < count; i++) {
    final topic = _topics[i % _topics.length];
    final questions = <Map<String, dynamic>>[];
    final used = <int>{};

    while (questions.length < 3) {
      final idx = random.nextInt(pool.length);
      if (used.contains(idx)) continue;
      used.add(idx);
      questions.add(pool[idx]);
    }

    surveys.add({
      'id': 'survey_${(i + 1).toString().padLeft(4, '0')}',
      'title': '$topic ${(i ~/ _topics.length) + 1}',
      'description': '$topic facts quiz',
      'points': 2,
      'questions': questions,
    });
  }
  return surveys;
}

const _topics = [
  'Space Quiz',
  'Science Quiz',
  'Geography Quiz',
  'History Quiz',
  'Sports Quiz',
  'Nature Quiz',
  'Tech Quiz',
  'Health Quiz',
  'Culture Quiz',
  'General Quiz',
];

List<Map<String, dynamic>> _questionPool() {
  return [
    _q('Which planet is known as the Red Planet?', ['Venus', 'Mars', 'Jupiter', 'Saturn'], 1),
    _q('Which is the largest planet in our solar system?', ['Earth', 'Mars', 'Jupiter', 'Neptune'], 2),
    _q('What is the closest star to Earth?', ['Proxima Centauri', 'Sirius', 'The Sun', 'Polaris'], 2),
    _q('How many planets are in our solar system?', ['7', '8', '9', '10'], 1),
    _q('Which gas do plants absorb from the air?', ['Oxygen', 'Nitrogen', 'Carbon dioxide', 'Hydrogen'], 2),
    _q('What is H2O commonly known as?', ['Salt', 'Water', 'Sugar', 'Oil'], 1),
    _q('Which organ pumps blood through the body?', ['Brain', 'Lungs', 'Heart', 'Liver'], 2),
    _q('What is the capital of France?', ['Berlin', 'Madrid', 'Paris', 'Rome'], 2),
    _q('Which continent is Egypt in?', ['Asia', 'Europe', 'Africa', 'South America'], 2),
    _q('Which ocean is the largest?', ['Atlantic', 'Indian', 'Arctic', 'Pacific'], 3),
    _q('Who painted the Mona Lisa?', ['Van Gogh', 'Picasso', 'Da Vinci', 'Rembrandt'], 2),
    _q('In which year did World War II end?', ['1943', '1944', '1945', '1946'], 2),
    _q('Which country hosted the 2016 Summer Olympics?', ['China', 'UK', 'Brazil', 'Russia'], 2),
    _q('How many players are on a soccer team on the field?', ['9', '10', '11', '12'], 2),
    _q('Which sport uses a shuttlecock?', ['Tennis', 'Badminton', 'Golf', 'Cricket'], 1),
    _q('What is the hardest natural substance?', ['Gold', 'Iron', 'Diamond', 'Silver'], 2),
    _q('Which animal is known as the King of the Jungle?', ['Tiger', 'Lion', 'Elephant', 'Bear'], 1),
    _q('What do bees collect from flowers?', ['Water', 'Nectar', 'Leaves', 'Soil'], 1),
    _q('Which device is used to browse the internet?', ['Printer', 'Scanner', 'Computer', 'Speaker'], 2),
    _q('What does CPU stand for?', ['Central Process Unit', 'Central Processing Unit', 'Computer Personal Unit', 'Core Program Utility'], 1),
    _q('How many hours are in a day?', ['12', '24', '48', '60'], 1),
    _q('Which vitamin is produced when skin is exposed to sunlight?', ['Vitamin A', 'Vitamin B', 'Vitamin C', 'Vitamin D'], 3),
    _q('What is the main language spoken in Brazil?', ['Spanish', 'Portuguese', 'French', 'English'], 1),
    _q('Which instrument has black and white keys?', ['Guitar', 'Violin', 'Piano', 'Flute'], 2),
    _q('What is the boiling point of water at sea level in Celsius?', ['50', '90', '100', '120'], 2),
    _q('Which metal is liquid at room temperature?', ['Iron', 'Gold', 'Mercury', 'Copper'], 2),
    _q('What is the smallest prime number?', ['0', '1', '2', '3'], 2),
    _q('Which country is known as the Land of the Rising Sun?', ['China', 'Japan', 'Korea', 'Thailand'], 1),
    _q('What gas do humans need to breathe?', ['Carbon dioxide', 'Oxygen', 'Helium', 'Methane'], 1),
    _q('Which planet has visible rings?', ['Mars', 'Venus', 'Saturn', 'Mercury'], 2),
    _q('What is the largest mammal?', ['Elephant', 'Blue whale', 'Giraffe', 'Hippo'], 1),
    _q('Which color is made by mixing red and blue?', ['Green', 'Orange', 'Purple', 'Yellow'], 2),
    _q('How many sides does a triangle have?', ['2', '3', '4', '5'], 1),
    _q('Which festival is known for pumpkins and costumes?', ['Christmas', 'Halloween', 'Easter', 'New Year'], 1),
    _q('What is the currency of Japan?', ['Won', 'Yuan', 'Yen', 'Rupee'], 2),
    _q('Which sea creature has eight arms?', ['Shark', 'Dolphin', 'Octopus', 'Seal'], 2),
    _q('What is frozen water called?', ['Steam', 'Ice', 'Fog', 'Rain'], 1),
    _q('Which planet is closest to the Sun?', ['Venus', 'Earth', 'Mercury', 'Mars'], 2),
    _q('What is the capital of the United Kingdom?', ['Dublin', 'London', 'Paris', 'Edinburgh'], 1),
    _q('Which sport is played at Wimbledon?', ['Football', 'Tennis', 'Basketball', 'Rugby'], 1),
  ];
}

Map<String, dynamic> _q(String text, List<String> options, int correct) {
  return {
    'text': text,
    'options': options,
    'correct': correct,
  };
}
