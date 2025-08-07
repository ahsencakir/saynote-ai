# Saynote - AI Destekli Not Asistanı

Saynote, web tarayıcısında çalışan bir Flutter uygulamasıdır. Kullanıcı hem canlı sesle not oluşturabilir, hem de kendi yazdığı ya da yüklediği notları Gemini AI ile analiz ettirebilir.

## 🎯 Özellikler

### 🎙️ Canlı Konuşma → Metne Çevirme
- Mikrofon ile canlı ses kaydı
- Gerçek zamanlı konuşma tanıma
- Türkçe dil desteği
- Otomatik AI analizi

### ✍️ Elle Not Yazma / Düzenleme
- Zengin metin editörü
- Not düzenleme ekranı
- Kaydetme ve temizleme özellikleri

### 📤 Gemini Chat (Etkileşimli AI)
- Notlar hakkında soru sorma
- AI destekli analiz
- Sohbet geçmişi
- Örnek sorular:
  - "Bu notu özetle"
  - "Ana konuları çıkar"
  - "Bu bilgi doğru mu?"
  - "Bu konudan sorular üret"

### 📄 PDF Yükleme ile Not Analizi
- PDF dosyası yükleme
- Otomatik içerik analizi
- AI destekli özet çıkarma

### 💾 Notu Kaydetme
- .txt formatında indirme
- Otomatik dosya adlandırma
- Web tarayıcısında doğrudan indirme

## 🚀 Kurulum

### 1. Gereksinimler
- Flutter SDK 3.2.3 veya üzeri
- Chrome tarayıcısı
- Gemini API anahtarı

### 2. Projeyi Klonlayın
```bash
git clone https://github.com/yourusername/saynote.git
cd saynote
```

### 3. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 4. API Anahtarını Ayarlayın
1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresinden Gemini API anahtarı alın
2. `lib/core/services/gemini_service.dart` dosyasını açın
3. `YOUR_GEMINI_API_KEY_HERE` yerine gerçek API anahtarınızı yazın:

```dart
static const String _apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### 5. Uygulamayı Çalıştırın
```bash
flutter run -d chrome
```

## 📦 Kullanılan Teknolojiler

- **Flutter Web**: UI framework
- **speech_to_text**: Ses tanıma
- **google_generative_ai**: Gemini AI entegrasyonu
- **provider**: State yönetimi
- **universal_html**: Web dosya işlemleri
- **flutter_markdown**: Markdown desteği

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                     # Uygulamanın giriş noktası
├── core/
│   ├── constants.dart            # Sabitler
│   ├── models/
│   │   └── chat_message.dart     # Chat mesaj modeli
│   └── services/
│       ├── speech_service.dart   # Mikrofonla ses → metin
│       ├── gemini_service.dart   # Gemini API çağrıları
│       └── pdf_parser.dart       # PDF içeriğini metne çevirme
├── logic/
│   └── note_manager.dart         # Metin biriktirme, zamanlama
└── ui/
    ├── screens/
    │   ├── home_screen.dart          # Ana ekran
    │   ├── note_editor_screen.dart   # Elle not yazma / düzenleme
    │   └── chat_screen.dart          # Gemini ile etkileşimli chat
    ├── widgets/
    │   ├── mic_button.dart
    │   ├── transcript_box.dart
    │   ├── summary_box.dart
    │   ├── pdf_upload.dart           # PDF yükleyici
    │   ├── chat_bubble.dart          # AI sohbet balonları
    │   └── download_button.dart
    └── styles/
        └── theme.dart
```

## 🧪 Kullanım Senaryoları

### Canlı Dersteyim
1. Mikrofonu açarım
2. Konuşma metne döner
3. Gemini'den konu başlıkları alırım

### Kendi Notumu Yazıyorum
1. Not editörüne kendi notumu girerim
2. AI'ye sorarım: "Bu doğru mu?"

### PDF Yükledim
1. Ders PDF'ini yüklerim
2. "Bu konudan 3 soru çıkar" diye AI'ye yazarım

### Notu İndirdim
1. En sonunda notumu .txt olarak indiririm

## 🔒 Güvenlik

### API Anahtarı Güvenliği
- API anahtarınızı asla GitHub'a yüklemeyin
- Gerçek API anahtarınızı sadece yerel geliştirme ortamında kullanın
- Production ortamında environment variable kullanın

### Önerilen Güvenlik Uygulamaları
1. API anahtarını environment variable olarak saklayın
2. Rate limiting ekleyin
3. Input validation güçlendirin
4. HTTPS kullanın

## 🐛 Bilinen Sorunlar

### Ses Tanıma
- İlk başlatmada bazen geç tanıma
- Uzun konuşmalarda kesinti
- Bazı tarayıcılarda izin sorunu

### AI Servisi
- Bazen timeout hatası
- Uzun metinlerde kesinti
- Rate limit kontrolü eksik
