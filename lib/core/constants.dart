class AppConstants {
  // API Configuration
  static const String geminiModel = 'gemini-2.5-flash';

  // Speech Recognition
  static const String turkishLocale = 'tr_TR';
  static const int listenDuration = 60; // seconds
  static const int pauseDuration = 5; // seconds
  static const int bufferSize = 5; // sentences
  static const int geminiInterval = 20; // seconds

  // UI Constants
  static const double borderRadius = 20.0;
  static const double smallBorderRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const double cardElevation = 8.0;
  static const double smallElevation = 4.0;

  // Modern Color Palette
  static const int primaryBlue = 0xFF6366F1; // Indigo-500
  static const int secondaryBlue = 0xFF4F46E5; // Indigo-600
  static const int accentBlue = 0xFF8B5CF6; // Violet-500
  static const int purple = 0xFF8B5CF6; // Violet-500
  static const int lightPurple = 0xFFA78BFA; // Violet-400
  static const int orange = 0xFFf59E0B; // Amber-500
  static const int lightOrange = 0xFFFBBF24; // Amber-400
  static const int success = 0xFF10B981; // Emerald-500
  static const int warning = 0xFFEF4444; // Red-500

  // Background Colors
  static const int primaryBackground = 0xFFFAFAFA; // Gray-50
  static const int cardBackground = 0xFFFFFFFF; // White
  static const int lightGray = 0xFFF8FAFC; // Slate-50
  static const int borderGray = 0xFFE2E8F0; // Slate-200
  static const int textGray = 0xFF64748B; // Slate-500
  static const int darkGray = 0xFF334155; // Slate-700

  // Gradient Colors
  static const int gradientStart = 0xFF6366F1; // Indigo-500
  static const int gradientEnd = 0xFF8B5CF6; // Violet-500
  static const int gradientOrangeStart = 0xFFf59E0B; // Amber-500
  static const int gradientOrangeEnd = 0xFFEF4444; // Red-500

  // Shadow Colors
  static const int shadowColor = 0xFF1F2937; // Gray-800 with opacity

  // ...existing code...
  static const int borderOrange = 0xFFFED7AA;

  // File Paths
  static const String documentsFolder = 'Documents/Saynote';
  static const String fileExtension = '.txt';

  // Messages
  static const String readyMessage = 'Hazır';
  static const String listeningMessage = 'Dinlemeye başlandı...';
  static const String stoppedMessage = 'Dinleme durduruldu';
  static const String processingMessage = 'AI notu üretiliyor...';
  static const String noteGeneratedMessage = 'Not üretildi';
  static const String pdfSelectingMessage = 'PDF seçiliyor...';
  static const String pdfProcessingMessage = 'PDF işleniyor...';
  static const String pdfProcessedMessage = 'PDF işlendi ve not üretildi';
  static const String dataClearedMessage = 'Veriler temizlendi';

  // Error Messages
  static const String microphonePermissionError = 'Mikrofon izni gerekli';
  static const String microphoneDeniedError = 'Mikrofon izni reddedildi';
  static const String speechInitError = 'Ses tanıma başlatılamadı';
  static const String geminiApiKeyError = 'Gemini API anahtarı bulunamadı';
  static const String geminiApiError = 'Gemini API hatası';
  static const String fileSaveError = 'Dosya kaydetme hatası';
  static const String pdfProcessingError = 'PDF işleme hatası';

  // Prompts
  static const String noteGenerationPrompt = '''
Sen bir eğitim asistanısın. Aşağıdaki konuşma metnini analiz ederek kaliteli bir ders notu oluşturman gerekiyor.

KONUŞMA METNİ:
{text}

GÖREVİN:
Bu metni analiz et ve şu formatta bir not oluştur:

1. **ANA KONU BAŞLIĞI**
   - Konunun genel başlığını belirle

2. **ÖNEMLİ NOKTALAR**
   - Ana fikirleri madde madde listele
   - Kritik bilgileri vurgula
   - Mantıklı bir sıralama yap

3. **ANAHTAR TERİMLER**
   - Önemli kavramları ve terimleri listele
   - Kısa açıklamalar ekle

4. **ÖZET**
   - Konunun kısa bir özetini yaz
   - Ana mesajı vurgula

KURALLAR:
- Türkçe olarak yaz
- Düzenli ve anlaşılır ol
- Gereksiz tekrarları temizle
- Önemli bilgileri vurgula
- Akademik bir dil kullan
- Madde işaretleri kullan
- Kısa ve öz ol

Şimdi bu metni analiz et ve yukarıdaki formatta bir not oluştur.
''';
}
