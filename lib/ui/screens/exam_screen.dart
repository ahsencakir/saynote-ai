import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/services/exam_service.dart';
import '../../logic/note_manager.dart';
import '../../core/constants.dart';
import 'exam_results_screen.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  ExamData? _examData;
  Map<int, String> _userAnswers = {};
  int _currentQuestionIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isExamStarted = false;
  bool _isExamFinished = false;
  ExamResult? _examResult;
  bool _isGeneratingExam = false;

  @override
  void initState() {
    super.initState();
    _generateExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generateExam() async {
    final noteManager = Provider.of<NoteManager>(context, listen: false);
    final noteContent = noteManager.currentNote;

    if (noteContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce not oluşturun')),
      );
      return;
    }

    setState(() => _isGeneratingExam = true);

    try {
      final examData = await ExamService.generateExam(
        noteContent,
        questionCount: 10,
        timeMinutes: 15,
      );

      setState(() {
        _examData = examData;
        _remainingSeconds = examData.timeMinutes * 60;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sınav oluşturulamadı: $e')),
      );
    } finally {
      setState(() => _isGeneratingExam = false);
    }
  }

  void _startExam() {
    setState(() => _isExamStarted = true);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _finishExam();
      }
    });
  }

  void _finishExam() {
    _timer?.cancel();
    final result = ExamService.analyzeExam(_examData!, _userAnswers);

    setState(() {
      _isExamFinished = true;
      _examResult = result;
    });
  }

  void _answerQuestion(String answer) {
    setState(() {
      _userAnswers[_examData!.questions[_currentQuestionIndex].id] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _examData!.questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _finishExam();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınav Simülasyonu'),
        backgroundColor: const Color(AppConstants.primaryBlue),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isGeneratingExam) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sınav hazırlanıyor...'),
          ],
        ),
      );
    }

    if (_examData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Sınav oluşturulamadı'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateExam,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (!_isExamStarted) {
      return _buildExamIntro();
    }

    if (_isExamFinished) {
      return _buildExamResult();
    }

    return _buildExamQuestion();
  }

  Widget _buildExamIntro() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz,
            size: 80,
            color: const Color(AppConstants.primaryBlue),
          ),
          const SizedBox(height: 24),
          Text(
            _examData!.examTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildInfoCard('Soru Sayısı', '${_examData!.questions.length}'),
          const SizedBox(height: 12),
          _buildInfoCard('Süre', '${_examData!.timeMinutes} dakika'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startExam,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sınavı Başlat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamQuestion() {
    final question = _examData!.questions[_currentQuestionIndex];
    final selectedAnswer = _userAnswers[question.id];

    return Column(
      children: [
        // Timer and Progress
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(AppConstants.primaryBlue),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soru ${_currentQuestionIndex + 1}/${_examData!.questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ...question.options.entries.map((option) {
                  final isSelected = selectedAnswer == option.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _answerQuestion(option.key),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? const Color(AppConstants.primaryBlue)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? const Color(AppConstants.primaryBlue)
                                  .withOpacity(0.1)
                              : null,
                        ),
                        child: Text(
                          '${option.key}) ${option.value}',
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? const Color(AppConstants.primaryBlue)
                                : null,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousQuestion,
                    child: const Text('Önceki'),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedAnswer != null
                      ? () {
                          if (_currentQuestionIndex ==
                              _examData!.questions.length - 1) {
                            _finishExam();
                          } else {
                            _nextQuestion();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.primaryBlue),
                  ),
                  child: Text(
                    _currentQuestionIndex == _examData!.questions.length - 1
                        ? 'Sınavı Bitir'
                        : 'Sonraki',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExamResult() {
    if (_examResult == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(AppConstants.primaryBlue),
                  const Color(AppConstants.purple),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Sınav Tamamlandı!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '%${_examResult!.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_examResult!.correctAnswers}/${_examResult!.totalQuestions} doğru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recommendations
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Öneriler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._examResult!.recommendations
                    .map(
                      (rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(rec, style: const TextStyle(fontSize: 16)),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ana Sayfaya Dön'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _examData = null;
                      _userAnswers = {};
                      _currentQuestionIndex = 0;
                      _isExamStarted = false;
                      _isExamFinished = false;
                      _examResult = null;
                    });
                    _generateExam();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.primaryBlue),
                  ),
                  child: const Text(
                    'Yeni Sınav',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ✅ YENİ: Detaylı analiz butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamResultsScreen(
                      examResult: _examResult!,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.analytics),
              label: const Text('Detaylı Analiz ve AI Önerileri'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
