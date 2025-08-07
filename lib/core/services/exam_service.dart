import 'dart:convert';
import 'gemini_service.dart';

class ExamData {
  final String examTitle;
  final int timeMinutes;
  final List<Question> questions;

  ExamData({
    required this.examTitle,
    required this.timeMinutes,
    required this.questions,
  });
}

class Question {
  final int id;
  final String question;
  final Map<String, String> options;
  final String correctAnswer;
  final String topic;
  final String explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.topic = 'Genel',
    this.explanation = '',
  });
}

class ExamResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredQuestions;
  final double score;
  final double percentage;
  final List<String> recommendations;
  final List<QuestionResult> questionResults;
  final List<String> weakTopics;

  ExamResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    this.unansweredQuestions = 0,
    required this.score,
    required this.percentage,
    required this.recommendations,
    this.questionResults = const [],
    this.weakTopics = const [],
  });
}

class QuestionResult {
  final int questionId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String topic;
  final String explanation;

  QuestionResult({
    required this.questionId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.topic = 'Genel',
    this.explanation = '',
  });
}

class ExamService {
  static Future<ExamData> generateExam(
    String noteContent, {
    int questionCount = 10,
    int timeMinutes = 15,
    String difficulty = 'orta',
  }) async {
    try {
      final prompt = """
Bu not içeriğine göre $questionCount adet $difficulty seviyesinde çoktan seçmeli soru hazırla.

Not İçeriği:
$noteContent

SADECE JSON formatında döndür, başka metin ekleme:
{
  "examTitle": "Not Konusu Sınavı",
  "timeMinutes": $timeMinutes,
  "questions": [
    {
      "id": 1,
      "question": "Soru metni",
      "options": {
        "A": "Seçenek 1",
        "B": "Seçenek 2",
        "C": "Seçenek 3",
        "D": "Seçenek 4"
      },
      "correctAnswer": "A",
      "explanation": "Cevap açıklaması"
    }
  ]
}
""";

      final response = await GeminiService.generateNote(prompt);
      print('AI Response: $response');

      // JSON temizleme
      String cleanResponse = response.trim();

      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse =
            cleanResponse.substring(0, cleanResponse.lastIndexOf('```'));
      }

      int jsonStart = cleanResponse.indexOf('{');
      int jsonEnd = cleanResponse.lastIndexOf('}');

      if (jsonStart != -1 && jsonEnd != -1) {
        cleanResponse = cleanResponse.substring(jsonStart, jsonEnd + 1);
      }

      cleanResponse = cleanResponse.trim();
      print('Clean Response: $cleanResponse');

      final jsonData = json.decode(cleanResponse);

      return ExamData(
        examTitle: jsonData['examTitle'] ?? 'Sınav',
        timeMinutes: jsonData['timeMinutes'] ?? timeMinutes,
        questions: (jsonData['questions'] as List)
            .map((q) => Question(
                  id: q['id'],
                  question: q['question'],
                  options: Map<String, String>.from(q['options']),
                  correctAnswer: q['correctAnswer'],
                  explanation: q['explanation'] ?? '',
                ))
            .toList(),
      );
    } catch (e) {
      print('Exam generation error: $e');

      return ExamData(
        examTitle: 'Demo Sınavı',
        timeMinutes: timeMinutes,
        questions: [
          Question(
            id: 1,
            question: 'Bu bir demo sorudur. Hangi seçenek doğrudur?',
            options: {
              'A': 'Seçenek A',
              'B': 'Seçenek B',
              'C': 'Doğru seçenek',
              'D': 'Seçenek D'
            },
            correctAnswer: 'C',
            explanation: 'C seçeneği doğru cevaptır.',
          ),
        ],
      );
    }
  }

  static ExamResult analyzeExam(ExamData examData, Map<int, String> userAnswers) {
    int correctCount = 0;
    int wrongCount = 0;
    int unansweredCount = 0;
    List<QuestionResult> questionResults = [];
    Set<String> weakTopicsSet = <String>{};

    for (var question in examData.questions) {
      final userAnswer = userAnswers[question.id];
      final isCorrect = userAnswer == question.correctAnswer;
      final isUnanswered = userAnswer == null || userAnswer.isEmpty;
      
      if (isUnanswered) {
        unansweredCount++;
      } else if (isCorrect) {
        correctCount++;
      } else {
        wrongCount++;
        weakTopicsSet.add(question.topic);
      }

      questionResults.add(QuestionResult(
        questionId: question.id,
        question: question.question,
        userAnswer: userAnswer ?? '',
        correctAnswer: question.correctAnswer,
        isCorrect: isCorrect && !isUnanswered,
        topic: question.topic,
        explanation: question.explanation,
      ));
    }

    final double percentage = (correctCount / examData.questions.length) * 100;
    final double score = percentage;

    List<String> recommendations = [];
    if (percentage >= 80) {
      recommendations.add('Harika performans! Devam edin.');
    } else if (percentage >= 60) {
      recommendations.add('İyi bir performans. Eksik konuları tekrar edin.');
    } else {
      recommendations.add('Daha fazla çalışma gerekiyor. Temel konuları tekrar edin.');
    }

    return ExamResult(
      totalQuestions: examData.questions.length,
      correctAnswers: correctCount,
      wrongAnswers: wrongCount,
      unansweredQuestions: unansweredCount,
      score: score,
      percentage: percentage,
      recommendations: recommendations,
      questionResults: questionResults,
      weakTopics: weakTopicsSet.toList(),
    );
  }
}
