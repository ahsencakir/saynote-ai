import 'package:flutter/foundation.dart';

class NoteManager extends ChangeNotifier {
  String _currentTranscript = '';
  String _currentNote = '';

  String get currentTranscript => _currentTranscript;
  String get currentNote => _currentNote;

  // Sürekli güncelleme (canlı konuşma + biriken)
  void updateTranscriptTemporary(String text) {
    _currentTranscript = text.trim();
    notifyListeners();
  }

  // Final sonuç (sürekli biriktirme)
  void addTranscript(String text) {
    _currentTranscript = text.trim();
    notifyListeners();
  }

  // Not güncelleme
  void updateNote(String note) {
    _currentNote = note;
    notifyListeners();
  }

  // Transcript temizle
  void clearTranscript() {
    _currentTranscript = '';
    notifyListeners();
  }

  // Not temizle
  void clearNote() {
    _currentNote = '';
    notifyListeners();
  }
}
