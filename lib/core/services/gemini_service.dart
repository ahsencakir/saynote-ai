import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  static const String _apiKey =
      'YOUR_GEMINI_API_KEY_HERE'; // API anahtarınızı buraya ekleyin
  static GenerativeModel? _model;

  // Initialize Gemini model
  static Future<void> initialize() async {
    try {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );
    } catch (e) {
      throw Exception('Gemini API hatası: $e');
    }
  }

  // Generate note from text
  static Future<String> generateNote(String text) async {
    try {
      if (_model == null) {
        await initialize();
      }

      String prompt = '''
Aşağıdaki konuşma metnini düzenli ve anlaşılır bir not haline getir:

KONUŞMA METNİ:
$text

Lütfen şu formatta bir not oluştur:
1. Ana konu başlığı
2. Önemli noktalar (madde madde)
3. Anahtar terimler
4. Özet

Notu Türkçe olarak, düzenli ve anlaşılır şekilde yaz. Gereksiz tekrarları temizle ve önemli bilgileri vurgula.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ?? 'Not üretilemedi.';
    } catch (e) {
      throw Exception('Gemini API hatası: $e');
    }
  }

  // Generate note from PDF content
  static Future<String> analyzePdfContent(String pdfContent) async {
    try {
      if (_model == null) {
        await initialize();
      }

      String prompt = '''
Aşağıdaki PDF içeriğini analiz et ve kaliteli bir ders notu haline getir:

PDF İÇERİĞİ:
$pdfContent

Lütfen şu formatta bir not oluştur:
1. Ana konu başlığı
2. Önemli noktalar (madde madde)
3. Anahtar terimler
4. Özet

Notu Türkçe olarak, düzenli ve anlaşılır şekilde yaz. Gereksiz tekrarları temizle ve önemli bilgileri vurgula.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ?? 'PDF analiz edilemedi.';
    } catch (e) {
      throw Exception('PDF analiz hatası: $e');
    }
  }

  // Chat with note content
  static Future<String> chatWithNote(String noteContent, String userQuestion) async {
    try {
      if (_model == null) {
        await initialize();
      }

      String prompt = '''
Aşağıdaki not içeriği hakkında sorulan soruyu yanıtla:

NOT İÇERİĞİ:
$noteContent

KULLANICI SORUSU:
$userQuestion

Lütfen not içeriğine dayanarak soruyu detaylı ve doğru bir şekilde yanıtla. 
Eğer not içeriğinde yeterli bilgi yoksa, bunu belirt.
Yanıtını Türkçe olarak, anlaşılır ve düzenli bir şekilde ver.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ?? 'Yanıt üretilemedi.';
    } catch (e) {
      throw Exception('Sohbet hatası: $e');
    }
  }

  // ✅ YENİ: Sınav sonucu analizi
  static Future<String> analyzeExamResults({
    required int totalQuestions,
    required int correctAnswers,
    required int wrongAnswers,
    required int unansweredQuestions,
    required List<Map<String, dynamic>> wrongQuestionDetails,
  }) async {
    try {
      if (_model == null) {
        await initialize();
      }

      final percentage = (correctAnswers / totalQuestions * 100).toStringAsFixed(1);
      final wrongTopics = wrongQuestionDetails
          .map((q) => q['topic'] as String)
          .toSet()
          .toList();

      final prompt = '''
      Öğrenci sınavını tamamladı. Sonuçları analiz et ve öneriler sun:

      📊 SINAV SONUÇLARI:
      • Toplam Soru: $totalQuestions
      • Doğru Cevap: $correctAnswers
      • Yanlış Cevap: $wrongAnswers
      • Boş Bırakılan: $unansweredQuestions
      • Başarı Oranı: %$percentage

      ❌ YANLIŞ SORULAR:
      ${wrongQuestionDetails.map((q) => '''
      Soru: ${q['question']}
      Verilen Cevap: ${q['userAnswer']}
      Doğru Cevap: ${q['correctAnswer']}
      Konu: ${q['topic']}
      ''').join('\n---\n')}

      🎯 EKSİK KONULAR: ${wrongTopics.join(', ')}

      Lütfen şunları yap:
      1. 🎭 Performansı değerlendir (olumlu yaklaşımla)
      2. 💪 Güçlü yönlerini belirt
      3. 📚 Eksik konular için özel çalışma önerileri ver
      4. ⭐ Sonraki sınavlar için strateji öner
      5. 🎯 Motivasyon artırıcı tavsiyeler ver

      Türkçe, samimi ve yapıcı bir dille yaz. Emoji kullan. 300-500 kelime arası olsun.
      ''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Analiz oluşturulamadı';
    } catch (e) {
      return 'AI analizi sırasında hata: $e';
    }
  }

  // ✅ YENİ: Yanlış soruların konu analizi
  static Future<String> analyzeWeakTopics(List<String> weakTopics) async {
    try {
      if (_model == null) {
        await initialize();
      }

      final prompt = '''
      Öğrenci bu konularda zorlanıyor: ${weakTopics.join(', ')}

      Bu konular için:
      1. 📖 Hangi temel kavramları tekrar etmeli?
      2. 📚 Hangi kaynaklardan çalışmalı?
      3. 🎯 Nasıl bir çalışma planı izlemeli?
      4. 💡 Pratik örnekler ve ipuçları
      5. 🔗 Konular arası bağlantılar

      Detaylı ve uygulanabilir öneriler ver. Türkçe yazın.
      ''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Konu analizi oluşturulamadı';
    } catch (e) {
      return 'Konu analizi hatası: $e';
    }
  }

  // ✅ YENİ: Motivasyonel mesaj
  static Future<String> generateMotivationalMessage(double percentage) async {
    try {
      if (_model == null) {
        await initialize();
      }

      String performance = percentage >= 80 ? 'harika' : 
                          percentage >= 60 ? 'iyi' : 
                          percentage >= 40 ? 'geliştirilmesi gereken' : 'düşük';

      final prompt = '''
      Öğrenci %$percentage başarı gösterdi. Bu $performance bir performans.
      
      Öğrenciyi motive edecek, cesaretlendirici ama gerçekçi bir mesaj yaz.
      - Başarılıysa tebrik et, devam etmeye teşvik et
      - Başarısızsa moral verici olsun, pes etmesin
      - Gelecek için umut verici ol
      - Türkçe, samimi ve kısa (100-150 kelime)
      - Emoji kullan
      ''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Güzel bir performans! Devam edin! 💪';
    } catch (e) {
      return 'Elinden geleni yaptın! Bir sonrakinde daha iyi olacaksın! 🌟';
    }
  }
}
