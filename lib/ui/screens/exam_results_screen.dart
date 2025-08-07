import 'package:flutter/material.dart';
import '../../core/services/exam_service.dart';
import '../../core/services/gemini_service.dart';

class ExamResultsScreen extends StatefulWidget {
  final ExamResult examResult;

  const ExamResultsScreen({super.key, required this.examResult});

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // AI analizleri için state'ler
  String _performanceAnalysis = '';
  String _topicAnalysis = '';
  String _motivationalMessage = '';
  bool _isLoadingAnalysis = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateAllAnalyses();
  }

  Future<void> _generateAllAnalyses() async {
    setState(() => _isLoadingAnalysis = true);

    final result = widget.examResult;
    final wrongQuestions = result.questionResults.where((q) => !q.isCorrect).toList();
    
    try {
      // Paralel olarak tüm analizleri başlat
      final futures = [
        GeminiService.analyzeExamResults(
          totalQuestions: result.totalQuestions,
          correctAnswers: result.correctAnswers,
          wrongAnswers: result.wrongAnswers,
          unansweredQuestions: result.unansweredQuestions,
          wrongQuestionDetails: wrongQuestions.map((q) => {
            'question': q.question,
            'userAnswer': q.userAnswer,
            'correctAnswer': q.correctAnswer,
            'topic': q.topic,
          }).toList(),
        ),
        
        if (result.weakTopics.isNotEmpty)
          GeminiService.analyzeWeakTopics(result.weakTopics),
          
        GeminiService.generateMotivationalMessage(result.percentage),
      ];

      final results = await Future.wait(futures);
      
      setState(() {
        _performanceAnalysis = results[0];
        _topicAnalysis = result.weakTopics.isNotEmpty ? results[1] : '';
        _motivationalMessage = results.last;
        _isLoadingAnalysis = false;
      });
      
    } catch (e) {
      setState(() {
        _performanceAnalysis = 'AI analizi oluşturulamadı: $e';
        _topicAnalysis = '';
        _motivationalMessage = 'Elinden geleni yaptın! 💪';
        _isLoadingAnalysis = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınav Sonuçları'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Özet'),
            Tab(icon: Icon(Icons.error_outline), text: 'Yanlışlar'),
            Tab(icon: Icon(Icons.psychology), text: 'AI Analiz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildWrongAnswersTab(),
          _buildAIAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    final result = widget.examResult;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Başarı kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: result.percentage >= 60 
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
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
                  '%${result.percentage.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${result.correctAnswers} / ${result.totalQuestions} doğru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Detaylar
          _buildStatCard('Doğru Cevaplar', '${result.correctAnswers}', 
              Colors.green, Icons.check_circle),
          _buildStatCard('Yanlış Cevaplar', '${result.wrongAnswers}', 
              Colors.red, Icons.cancel),
          _buildStatCard('Boş Sorular', '${result.unansweredQuestions}', 
              Colors.grey, Icons.help_outline),
        ],
      ),
    );
  }

  Widget _buildWrongAnswersTab() {
    final wrongQuestions = widget.examResult.questionResults
        .where((q) => !q.isCorrect)
        .toList();

    if (wrongQuestions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Tebrikler! Hiç yanlış cevabınız yok!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wrongQuestions.length,
      itemBuilder: (context, index) {
        final question = wrongQuestions[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Soru numarası ve konusu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Soru ${question.questionId}',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        question.topic,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Soru metni
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Cevaplar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.close, color: Colors.red.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sizin Cevabınız: ${question.userAnswer}',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Doğru Cevap: ${question.correctAnswer}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Açıklama
                if (question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, 
                                color: Colors.blue.shade600, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Açıklama:',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          question.explanation,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Motivasyonel mesaj
          if (_motivationalMessage.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.examResult.percentage >= 60
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    _motivationalMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Performans analizi
          _buildAnalysisCard(
            title: '📊 Performans Analizi',
            content: _performanceAnalysis,
            color: Colors.blue,
            icon: Icons.analytics,
          ),
          
          const SizedBox(height: 16),

          // Konu analizi (sadece eksik konular varsa)
          if (widget.examResult.weakTopics.isNotEmpty) ...[
            _buildAnalysisCard(
              title: '📚 Eksik Konular Analizi',
              content: _topicAnalysis,
              color: Colors.purple,
              icon: Icons.school,
            ),
            const SizedBox(height: 20),
          ],

          // Yeni sınav butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Yeni Sınava Başla'),
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
        ],
      ),
    );
  }

  Widget _buildAnalysisCard({
    required String title,
    required String content,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // İçerik
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isLoadingAnalysis
                ? const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('AI analizi hazırlanıyor...'),
                      ],
                    ),
                  )
                : Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}