import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  // Biriken metin için
  String _accumulatedText = '';

  // Stream controllers
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningController =
      StreamController<bool>.broadcast();

  // Getters
  Stream<String> get statusStream => _statusController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;
  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;
  String get accumulatedText => _accumulatedText;

  // Initialize
  Future<void> initialize() async {
    try {
      _statusController.add('Ses tanıma başlatılıyor...');

      bool available = await _speechToText.initialize(
        onError: (error) {
          print('Speech error: ${error.errorMsg}');
          _statusController.add('Ses hatası: ${error.errorMsg}');
          _isListening = false;
          _listeningController.add(false);
        },
        onStatus: (status) {
          print('Speech status: $status');
          // SADECE STATUS GÜNCELLEMESİ - RESTART YOK!
          if (status == 'notListening' || status == 'done') {
            _isListening = false;
            _listeningController.add(false);
            _statusController.add('Dinleme durdu');
          } else if (status == 'listening') {
            _statusController.add('Dinleniyor...');
          }
        },
        debugLogging: false,
      );

      if (available) {
        _speechEnabled = true;
        _statusController.add('✅ Ses tanıma hazır');
      } else {
        _speechEnabled = false;
        _statusController.add('❌ Ses tanıma kullanılamıyor');
      }
    } catch (e) {
      print('Initialize error: $e');
      _speechEnabled = false;
      _statusController.add('Başlatma hatası: $e');
    }
  }

  // BASİT start listening - RESTART YOK!
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onFinalResult,
  }) async {
    if (!_speechEnabled) {
      await initialize();
      if (!_speechEnabled) {
        throw Exception('Ses tanıma kullanılamıyor');
      }
    }

    // Eğer dinliyorsa DURDUR ve bekle
    if (_speechToText.isListening) {
      try {
        await _speechToText.stop();
        await Future.delayed(Duration(milliseconds: 2000)); // 2 saniye bekle
      } catch (e) {
        print('Stop error: $e');
      }
    }

    try {
      _isListening = true;
      _listeningController.add(true);
      _statusController.add('Dinleme başlıyor...');

      await _speechToText.listen(
        onResult: (result) {
          String words = result.recognizedWords.trim();

          if (words.isNotEmpty) {
            // Biriken metinle birleştir
            String fullText =
                _accumulatedText.isEmpty ? words : '$_accumulatedText $words';

            // Callback'leri çağır
            onResult(fullText);

            if (result.finalResult) {
              // Final sonucu kaydet
              _accumulatedText = fullText;
              onFinalResult(fullText);
              _statusController.add('Kaydedildi: $words');
            }
          }
        },
        listenFor: Duration(seconds: 30), // 30 saniye dinle
        pauseFor: Duration(seconds: 5), // 5 saniye bekle
        partialResults: true,
        localeId: 'tr_TR',
        cancelOnError: false,
      );
    } catch (e) {
      print('Start error: $e');
      _isListening = false;
      _listeningController.add(false);
      _statusController.add('Dinleme hatası: $e');
      throw Exception('Dinleme başlatılamadı: $e');
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
      _isListening = false;
      _listeningController.add(false);
      _statusController.add('Dinleme durduruldu');
    } catch (e) {
      print('Stop error: $e');
    }
  }

  // Metinleri temizle
  void clearAccumulatedText() {
    _accumulatedText = '';
    _statusController.add('Metin temizlendi');
  }

  // Dispose
  void dispose() {
    try {
      _speechToText.cancel();
      _statusController.close();
      _listeningController.close();
    } catch (e) {
      print('Dispose error: $e');
    }
  }

  String get currentStatus {
    if (_isListening) {
      return '🎤 Dinleniyor';
    } else if (_speechEnabled) {
      return _accumulatedText.isNotEmpty
          ? '⏸️ Duraklatıldı (${_accumulatedText.split(' ').length} kelime)'
          : '✅ Hazır';
    } else {
      return '❌ Kullanılamıyor';
    }
  }

  // Bu fonksiyonu speech service'e ekle:
  Future<void> restartListening({
    required Function(String) onResult,
    required Function(String) onFinalResult,
  }) async {
    await stopListening();
    await Future.delayed(Duration(milliseconds: 1500));
    await startListening(onResult: onResult, onFinalResult: onFinalResult);
  }
}
