import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/gemini_service.dart';
import '../../logic/note_manager.dart';

class VoiceNoteScreen extends StatefulWidget {
  @override
  _VoiceNoteScreenState createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> {
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _hasRecording = false;
  String _transcribedText = '';

  // Demo metinleri
  final List<Map<String, String>> _demoTexts = [
    {
      'title': 'Türkiye Tarihi',
      'content':
          '''Türkiye Cumhuriyeti tarihi çok önemli bir konudur. Mustafa Kemal Atatürk önderliğinde Kurtuluş Savaşı 1919-1923 yılları arasında gerçekleşti. Bu savaş sonucunda 29 Ekim 1923'te Cumhuriyet ilan edildi.

Atatürk'ün yaptığı inkılaplar şunlardır: Saltanatın kaldırılması 1922, Cumhuriyetin ilanı 1923, Hilafetin kaldırılması 1924, Tekke ve zaviyelerin kapatılması 1925, Şapka İnkılabı 1925, Medeni Kanun 1926, Harf İnkılabı 1928, Soyadı Kanunu 1934.

Bu inkılaplar Türkiye'nin modernleşmesinde çok önemli rol oynadı ve batıya yönelişi sağladı.'''
    },
    {
      'title': 'Fizik - Hareket',
      'content':
          '''Fizik dersinde hareket konusu temel konulardan biridir. Düzgün doğrusal harekette hız sabittir ve ivme sıfırdır. Konum denklemi x = x₀ + v×t şeklindedir.

Düzgün değişken harekette ise ivme sabittir. Hız denklemi v = v₀ + a×t ve konum denklemi x = x₀ + v₀×t + ½×a×t² şeklindedir.

Serbest düşme hareketi özel bir düzgün değişken hareket türüdür. Yerçekimi ivmesi g = 9.8 m/s² değerindedir.'''
    }
  ];

  int _selectedDemoIndex = 0;

  // Ses kayıt başlatma (demo simülasyonu)
  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _hasRecording = false;
    });

    // 3 saniye demo kayıt simülasyonu
    await Future.delayed(const Duration(seconds: 3));

    if (mounted && _isRecording) {
      _stopRecording();
    }
  }

  // Ses kayıt durdurma
  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
      _hasRecording = true;
      _transcribedText = _demoTexts[_selectedDemoIndex]['content']!;
    });
  }

  // Manuel AI analizi fonksiyonu
  Future<void> _processWithAI() async {
    if (_transcribedText.isEmpty) {
      _showSnackBar('Önce ses kaydı yapın veya demo seçin');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // AI ile not oluştur
      final result = await GeminiService.generateNote(_transcribedText);

      // Not manager'a kaydet
      final noteManager = Provider.of<NoteManager>(context, listen: false);
      noteManager.updateNote(result);

      _showSnackBar('Not başarıyla oluşturuldu!');

      // 1.5 saniye bekleyip ana sayfaya git
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Hata: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // SnackBar gösterme (güvenli)
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Demo metni seçme
  void _showDemoSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo Metin Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _demoTexts.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> demo = entry.value;

            return ListTile(
              title: Text(demo['title']!),
              subtitle: Text(
                demo['content']!.substring(0, 50) + '...',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                setState(() {
                  _selectedDemoIndex = index;
                  _transcribedText = demo['content']!;
                  _hasRecording = true;
                  _isRecording = false;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ses Notu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _showDemoSelection,
            child: const Text(
              'DEMO',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Ses kayıt durumu
              Container(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Kayıt ikonu
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : Colors.blue,
                          boxShadow: _isRecording
                              ? [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isRecording
                            ? 'Demo Kayıt Yapılıyor...'
                            : _hasRecording
                                ? 'Kayıt Hazır ✓'
                                : 'Kayıt Başlat veya Demo Seç',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Transkript metni - BÜYÜTÜLDÜ
              if (_transcribedText.isNotEmpty)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.text_snippet,
                                color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Ses Metni (${_demoTexts[_selectedDemoIndex]['title']}):',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _transcribedText,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Boşluk ekle
              if (_transcribedText.isEmpty) const Spacer(),

              // Butonlar
              Column(
                children: [
                  // Kayıt butonu
                  if (!_hasRecording)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isRecording ? null : _startRecording,
                        icon: Icon(
                            _isRecording ? Icons.hourglass_empty : Icons.mic),
                        label: Text(
                          _isRecording ? 'Demo Kaydı...' : 'Kayıt Başlat',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isRecording ? Colors.grey : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                  // AI analiz butonu
                  if (_hasRecording && !_isProcessing) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _processWithAI,
                        icon: const Icon(Icons.smart_toy),
                        label: const Text(
                          'AI ile Not Oluştur',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _hasRecording = false;
                            _transcribedText = '';
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Yeni Kayıt'),
                      ),
                    ),
                  ],

                  // Yükleniyor göstergesi
                  if (_isProcessing)
                    Container(
                      height: 120,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'AI not oluşturuyor...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
