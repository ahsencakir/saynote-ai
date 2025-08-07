import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../logic/note_manager.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/gemini_service.dart';
import '../../core/constants.dart';
import '../widgets/mic_button.dart';
import '../widgets/transcript_box.dart';
import '../widgets/summary_box.dart';
import '../widgets/download_button.dart';
import '../widgets/pdf_upload.dart';
import 'note_editor_screen.dart';
import 'chat_screen.dart';
import 'exam_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  bool _isProcessing = false;
  String _statusMessage = 'Hazır';
  bool _speechInitialized = false;
  bool _showWebInstructions = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();

    // Show web instructions if on web
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showWebInstructions = true;
        });
      });
    }
  }

  Future<void> _initializeSpeech() async {
    try {
      setState(() {
        _statusMessage = 'Ses tanıma başlatılıyor...';
      });

      await _speechService.initialize();

      setState(() {
        _speechInitialized = true;
        _statusMessage = 'Hazır';
      });

      // Listen to status updates
      _speechService.statusStream.listen((status) {
        if (mounted) {
          setState(() {
            _statusMessage = status;
          });
        }
      });

      // Listen to listening state changes
      _speechService.listeningStream.listen((isListening) {
        if (mounted) {
          setState(() {
            _isListening = isListening;
          });
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Ses tanıma hatası: $e';
      });
      _showErrorSnackBar('Ses tanıma başlatılamadı: $e');
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechInitialized) {
      _showErrorSnackBar('Ses tanıma henüz hazır değil');
      return;
    }

    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      setState(() {
        _statusMessage = 'Dinlemeye başlanıyor...';
      });

      await _speechService.startListening(
        onResult: (fullText) {
          if (fullText.isNotEmpty) {
            final noteManager =
                Provider.of<NoteManager>(context, listen: false);
            noteManager.updateTranscriptTemporary(fullText);
            setState(() {
              _statusMessage =
                  'Dinleniyor: "${fullText.length > 50 ? fullText.substring(0, 50) + '...' : fullText}"';
            });
          }
        },
        onFinalResult: (fullText) {
          if (fullText.isNotEmpty) {
            final noteManager =
                Provider.of<NoteManager>(context, listen: false);
            noteManager.updateTranscriptTemporary(fullText);
            setState(() {
              _statusMessage =
                  'Kaydedildi: "${fullText.length > 50 ? fullText.substring(0, 50) + '...' : fullText}"';
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Dinleme hatası: $e';
      });
      _showErrorSnackBar('Dinleme başlatılamadı: $e');
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() {
      _statusMessage = _speechService.currentStatus;
    });
  }

  Future<void> _processWithAI() async {
    final noteManager = Provider.of<NoteManager>(context, listen: false);
    final transcript = noteManager.currentTranscript;

    if (transcript.isEmpty) {
      _showInfoSnackBar('İşlenecek metin bulunamadı');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      setState(() {
        _statusMessage = 'AI ile işleniyor...';
      });

      final summary = await GeminiService.generateNote(transcript);
      noteManager.updateNote(summary);

      setState(() {
        _statusMessage = 'Not hazır!';
      });

      _showSuccessSnackBar('Not AI ile işlendi!');
    } catch (e) {
      setState(() {
        _statusMessage = 'AI işleme hatası: $e';
      });
      _showErrorSnackBar('AI işleme hatası: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _loadSampleText() async {
    const sampleText = """
 SİSTEM YAKLAŞIMI VE SİSTEM ANALİZİ VE TASARIMI
1. GENEL SİSTEM TEORİSİ
1.1. Tanımı ve Amacı

    Genel Sistem Teorisi (GST), disiplinler arası bir yaklaşımla sistemleri ortak ilkelerle açıklamayı amaçlar.

    Biyolojik, sosyal, teknik vb. tüm sistemlerdeki ortak yapıları inceleyerek bütüncül bir analiz çerçevesi sunar.

1.2. Temel Yaklaşımları

    Sistem, sadece parçalarının toplamı değildir; daha büyük bir değeri temsil eder.

    Parçalar arasındaki dinamik ilişkiler sistemi oluşturur.

    Sistemler çevresiyle sürekli etkileşim içindedir.

    Alt sistemler ve üst sistemler arasında hiyerarşik yapı bulunur.

2. SİSTEM KAVRAMI VE ÖZELLİKLERİ
2.1. Sistem Nedir?

    Ortak bir amaç doğrultusunda çalışan, karşılıklı etkileşim içinde bulunan bileşenlerden oluşur.

    Somut (makine, kurum) ya da soyut (fikir, organizasyon) olabilir.

2.2. Sistem Özellikleri
a. Bağımlılıklar

    Bileşenler arasında işbirliği ve iş bölümü vardır.

b. Amaç

    Her sistemin ulaşmak istediği nihai bir hedefi vardır.

c. Çevre

    Sistem dışındaki ama sistemle etkileşimde bulunan unsurlar.

d. Sınırlar

    Sistemi dış çevreden ayıran çizgiler.

    Açık sistemler: çevreyle etkileşimli.

    Kapalı sistemler: çevreden bağımsız.

e. Değişkenler ve Parametreler

    Değişkenler: sistem içindeki bileşenler.

    Parametreler: bu bileşenler arasındaki ilişkileri düzenleyen sabit değerler.

f. Girdi – İşlem – Çıktı

    Girdi: Sisteme dışarıdan gelen bilgi/malzeme.

    İşlem: Girdinin dönüştürülme süreci.

    Çıktı: Sistemin ürettiği sonuç.

g. Geri Bildirim

    Çıktının tekrar girdi olarak kullanılması.

    Sistem denetimi ve iyileştirme sağlar.

h. Şekil Değiştirme ve Eş Sonluluk

    Sistemler zamanla evrilir ve gelişir.

    Aynı sonuca farklı yollarla ulaşılabilir.

i. Hiyerarşi ve Bütünlük

    Alt sistemlerden oluşur.

    Parçalar bütünü etkiler, bütün de parçaları şekillendirir.

3. SİSTEM YAKLAŞIMI
3.1. Tanımı

    Sorunları parçalara ayırarak analiz etme ve çözümleri bütüncül olarak ele alma yöntemidir.

    Teorik ve uygulamalı süreçlerden oluşur.

3.2. Teorik Süreç

    Sistemin analiz edilmesi, ilişkilerin ortaya çıkarılması, hataların ve ihtiyaçların belirlenmesi, yeniden tasarlanması.

3.3. Uygulama Süreci

    Teorik aşamada geliştirilen yeni sistemin kurulması, işletilmesi, değerlendirilmesi.

3.4. Sistem Yaklaşımının Amaçları

    Sorunun tanımlanması

    Girdi ve çıktıların belirlenmesi

    Alternatif çözümler geliştirilmesi

    Sistemin kurulması ve geri bildirimle sürekli geliştirilmesi

4. SİSTEM ANALİZİ VE TASARIMI
4.1. Tanımı

    Bir sistemin bileşenlerinin anlaşılması, sorunlarının belirlenmesi ve bilgi sistemi olarak yeniden yapılandırılmasıdır.

    Yazılım geliştirme ve bilgi sistemleri için kritik bir süreçtir.

4.2. Aşamaları
a. Sistemin Planlanması

    Sistem fikri ortaya atılır.

    Sistem hedefleri, kapsamı ve amacı tanımlanır.

b. Sistemin Analizi

    Mevcut sistemin incelenmesi

    Gerekli işlevlerin belirlenmesi

    Kullanıcı ihtiyaçlarının toplanması

    UML diyagramları (Use Case, Activity, Class) hazırlanır.

c. Sistem Tasarımı

    Analizden elde edilen bilgilerle en uygun çözüm modeli hazırlanır.

    Daha gelişmiş UML diyagramları çizilir (Sequence, Statechart).

    Sistem davranışları ve performansları tasarlanır.

d. Sistemin Uygulanması

    Yazılımın kurulması, test edilmesi, kullanıcıya tanıtılması.

    Pilot uygulama, değerlendirme ve tam uygulama gerçekleştirilir.

e. Sistemin Geliştirilmesi (Desteklenmesi)

    Sistem sürekli olarak güncellenir.

    Değişen ihtiyaçlara uygun hale getirilir.

    Sistemin sürekliliği sağlanır.

5. BİLGİ SİSTEMLERİ
5.1. Tanımı

    Bilginin toplanması, işlenmesi, saklanması, paylaşılması ve analiz edilmesini sağlayan sistemlerdir.

    Donanım, yazılım, insan kaynağı ve süreçlerden oluşur.

5.2. Özellikleri

    Veri tabanı altyapısı vardır.

    Bilgiye hızlı erişim ve analiz mümkündür.

    İnsan, bilgi ve işlem temel bileşenlerdir.

    Otomatik veya yarı otomatik olabilir.

5.3. Bilgi Sistemi Elemanları

    Analist: Sistemin analiz ve tasarımında lider rol oynar.

    Programcı: Yazılımın teknik geliştirmesini yapar.

    Kullanıcı: Sistemi kullanan kişi veya kurumlardır.

    Yönetici: Sistemin işletilmesinden sorumludur.

    Satıcı: Donanım/yazılım sağlayıcıları.

6. AYRINTILI SİSTEM ANALİZİ VE TASARIM MODELİ
6.1. Analiz Aşamaları (Çıktılar: Gereksinim Tanımı, Prototip)

    Sistem planlama

    Fizibilite çalışması

    Gereksinim belirleme

    Genel tasarım

    Kullanıcı onayı

    Prototip oluşturma

6.2. Tasarım ve Uygulama Aşamaları (Çıktılar: Yazılım, Dokümanlar, Eğitim)

    Detaylı tasarım

    Yazılım geliştirme

    Kullanıcı dokümanlarının hazırlanması

    Eğitim verilmesi

    Testler ve uygulama
""";

    setState(() => _isProcessing = true);

    try {
      setState(() {
        _statusMessage = 'Örnek metin AI ile işleniyor...';
      });

      // Önce transcript'e ekle
      final noteManager = Provider.of<NoteManager>(context, listen: false);
      noteManager.addTranscript(sampleText);

      // AI ile işle
      final summary = await GeminiService.generateNote(sampleText);
      noteManager.updateNote(summary);

      setState(() {
        _statusMessage = 'Örnek metin yüklendi ve AI ile işlendi!';
      });

      _showSuccessSnackBar(
          '📝 Örnek metin AI ile işlenerek not oluşturuldu! Artık sınav yapabilir ve sohbet edebilirsiniz.');
    } catch (e) {
      setState(() {
        _statusMessage = 'Örnek metin işleme hatası: $e';
      });
      _showErrorSnackBar('Örnek metin işleme hatası: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _onPdfContentLoaded(String content) async {
    setState(() => _isProcessing = true);

    try {
      setState(() {
        _statusMessage = 'PDF AI ile işleniyor...';
      });

      final summary = await GeminiService.generateNote(content);
      final noteManager = Provider.of<NoteManager>(context, listen: false);
      noteManager.updateNote(summary);

      setState(() {
        _statusMessage = 'PDF işlendi ve not oluşturuldu!';
      });

      _showSuccessSnackBar('PDF içeriği AI ile işlenerek not oluşturuldu!');
    } catch (e) {
      setState(() {
        _statusMessage = 'PDF işleme hatası: $e';
      });
      _showErrorSnackBar('PDF işleme hatası: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _onPdfError(String error) {
    _showErrorSnackBar(error);
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: const Color(AppConstants.warning),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: const Color(AppConstants.success),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: const Color(AppConstants.primaryBlue),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildWebInstructions() {
    if (!kIsWeb || !_showWebInstructions) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppConstants.primaryBlue).withOpacity(0.1),
            const Color(AppConstants.purple).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(AppConstants.primaryBlue).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(AppConstants.primaryBlue).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(AppConstants.primaryBlue),
                        const Color(AppConstants.purple),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Web Kullanımı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(AppConstants.darkGray),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showWebInstructions = false;
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    color: const Color(AppConstants.textGray),
                    size: 24,
                  ),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Mikrofon kullanımı için gereksinimler:',
              style: TextStyle(
                color: const Color(AppConstants.darkGray),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildInstructionItem('Tarayıcınızın mikrofon iznini verin'),
            _buildInstructionItem('HTTPS bağlantısı kullanın'),
            _buildInstructionItem('Chrome, Firefox veya Safari kullanın'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(AppConstants.primaryBlue),
                  const Color(AppConstants.purple),
                ],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(AppConstants.textGray),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    if (_isListening) {
      statusColor = const Color(AppConstants.warning);
      statusIcon = Icons.mic;
      statusTitle = 'Dinleniyor';
    } else if (_isProcessing) {
      statusColor = const Color(AppConstants.orange);
      statusIcon = Icons.psychology;
      statusTitle = 'AI İşliyor';
    } else {
      statusColor = const Color(AppConstants.success);
      statusIcon = Icons.check_circle;
      statusTitle = 'Hazır';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor,
                    statusColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                statusIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusTitle,
                    style: TextStyle(
                      color: const Color(AppConstants.darkGray),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color: const Color(AppConstants.textGray),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // GÜNCELLENMİŞ _buildMainActions FONKSİYONU
  Widget _buildMainActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(AppConstants.shadowColor).withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Örnek Metin Demo Butonu - YENİ EKLENDİ
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade400,
                    Colors.orange.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isProcessing ? null : _loadSampleText,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isProcessing)
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: 12),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        const SizedBox(width: 12),
                        Text(
                          _isProcessing
                              ? '🤖 AI ile İşleniyor...'
                              : '📚 Örnek Metin Yükle (Demo)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Mikrofon Butonu
            MicButton(
              isListening: _isListening,
              isProcessing: _isProcessing,
              onPressed: _speechInitialized ? _toggleListening : null,
            ),

            const SizedBox(height: 32),

            // Veya Ayırıcı
            Row(
              children: [
                Expanded(
                    child:
                        Divider(color: const Color(AppConstants.borderGray))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'VEYA',
                    style: TextStyle(
                      color: const Color(AppConstants.textGray),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(
                    child:
                        Divider(color: const Color(AppConstants.borderGray))),
              ],
            ),

            const SizedBox(height: 32),

            // PDF Yükleme
            PdfUpload(
              onPdfContentLoaded: _onPdfContentLoaded,
              onError: _onPdfError,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFF1F5F9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  'Saynote',
                  style: TextStyle(
                    color: const Color(AppConstants.darkGray),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Not Düzenle - Her zaman aktif
                      Consumer<NoteManager>(
                        builder: (context, noteManager, child) {
                          return IconButton(
                            icon: const Icon(Icons.edit_note),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NoteEditorScreen(
                                    initialContent:
                                        noteManager.currentNote.isNotEmpty
                                            ? noteManager.currentNote
                                            : '',
                                    onSave: (content) async {
                                      if (content.trim().isNotEmpty) {
                                        setState(() => _isProcessing = true);

                                        try {
                                          setState(() {
                                            _statusMessage =
                                                'Metin AI ile analiz ediliyor...';
                                          });

                                          final summary =
                                              await GeminiService.generateNote(
                                                  content);
                                          noteManager.updateNote(summary);

                                          setState(() {
                                            _statusMessage =
                                                'Not AI ile analiz edildi!';
                                          });

                                          _showSuccessSnackBar(
                                              'Metin AI ile analiz edildi ve not oluşturuldu!');
                                        } catch (e) {
                                          setState(() {
                                            _statusMessage =
                                                'AI analiz hatası: $e';
                                          });
                                          _showErrorSnackBar(
                                              'AI analiz hatası: $e');
                                        } finally {
                                          setState(() => _isProcessing = false);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                            tooltip: 'Not Düzenle',
                            color: const Color(AppConstants.primaryBlue),
                          );
                        },
                      ),

                      // AI Sohbet - Her zaman aktif
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(),
                            ),
                          );
                        },
                        tooltip: 'AI Sohbet',
                        color: const Color(AppConstants.purple),
                      ),

                      // Sınav - Sadece not varsa aktif
                      Consumer<NoteManager>(
                        builder: (context, noteManager, child) {
                          final hasContent = noteManager.currentNote.isNotEmpty;
                          return IconButton(
                            icon: const Icon(Icons.quiz),
                            onPressed: hasContent
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ExamScreen(),
                                      ),
                                    );
                                  }
                                : null,
                            tooltip:
                                hasContent ? 'Sınav' : 'Sınav (Not gerekli)',
                            color: hasContent
                                ? const Color(AppConstants.orange)
                                : Colors.grey.withOpacity(0.5),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Web Instructions
                  _buildWebInstructions(),

                  // Status Card
                  _buildStatusCard(),

                  const SizedBox(height: 32),

                  // Main Actions
                  _buildMainActions(),

                  const SizedBox(height: 32),

                  // Content Section
                  Consumer<NoteManager>(
                    builder: (context, noteManager, child) {
                      return Column(
                        children: [
                          // ÖNEMLİ: Canlı Konuşma Kutusu - Her zaman göster
                          TranscriptBox(
                            transcript: noteManager.currentTranscript,
                            onClear: () {
                              // Hem speech service'deki hem noteManager'daki metni temizle
                              _speechService.clearAccumulatedText();
                              noteManager.clearTranscript();
                              setState(() {
                                _statusMessage = 'Tüm metinler temizlendi';
                              });
                            },
                            isListening: _isListening,
                          ),

                          const SizedBox(height: 20),

                          // AI İşleme Butonu - Sadece metin varsa göster
                          if (noteManager.currentTranscript.isNotEmpty &&
                              !_isProcessing)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1),
                                    const Color(0xFF8B5CF6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _processWithAI,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 32),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Text(
                                          '🤖 AI ile Akıllı Not Oluştur',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Not Özeti - AI işleme sonrası
                          if (noteManager.currentNote.isNotEmpty) ...[
                            SummaryBox(
                              note: noteManager.currentNote,
                              onClear: () => noteManager.clearNote(),
                            ),
                            const SizedBox(height: 20),

                            // İndirme Butonu
                            DownloadButton(
                              content: noteManager.currentNote,
                              fileName:
                                  'saynote_${DateTime.now().millisecondsSinceEpoch}.txt',
                            ),
                          ],

                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),

                  // Bottom spacing
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
