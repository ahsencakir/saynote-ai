import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/note_manager.dart';
import '../../core/constants.dart';

class NoteEditorScreen extends StatefulWidget {
  final String initialContent;
  final Function(String)? onSave;

  const NoteEditorScreen({
    Key? key,
    this.initialContent = '',
    this.onSave,
  }) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _controller;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _controller.addListener(() {
      setState(() {
        _hasChanges = _controller.text != widget.initialContent;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final content = _controller.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not içeriği boş olamaz'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Eğer onSave callback'i varsa onu çağır
    if (widget.onSave != null) {
      await widget.onSave!(content);
    } else {
      // Varsayılan davranış - NoteManager'a kaydet
      final noteManager = Provider.of<NoteManager>(context, listen: false);
      noteManager.updateNote(content);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Geri dön
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değişiklikleri Kaydet?'),
        content: const Text(
            'Kaydedilmemiş değişiklikler var. Çıkmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await _saveNote();
            },
            child: const Text('Kaydet ve Çıkış'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Not Düzenle'),
          backgroundColor: const Color(AppConstants.primaryBlue),
          foregroundColor: Colors.white,
          actions: [
            // Temizle butonu
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Temizle'),
                    content: const Text(
                        'Tüm metni temizlemek istediğinizden emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _controller.clear();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Temizle'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.clear_all),
              tooltip: 'Metni Temizle',
            ),

            // Kaydet butonu
            IconButton(
              onPressed: _hasChanges ? _saveNote : null,
              icon: Icon(
                Icons.save,
                color: _hasChanges ? Colors.white : Colors.white54,
              ),
              tooltip: 'Kaydet',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Durum çubuğu
              if (_hasChanges)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange.shade100,
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Kaydedilmemiş değişiklikler var',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _saveNote,
                        child: Text(
                          'KAYDET',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Metin editörü
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Notunuzu buraya yazın...\n\n'
                          'İpucu: Yazdığınız metni AI ile analiz ettirebilirsiniz.',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Alt butonlar
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Ana kaydet butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveNote,
                        icon: const Icon(Icons.save),
                        label: Text(
                          widget.onSave != null
                              ? 'AI ile Analiz Et ve Kaydet'
                              : 'Notu Kaydet',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.onSave != null
                              ? Colors.orange
                              : const Color(AppConstants.primaryBlue),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Karakter sayısı
                    Text(
                      '${_controller.text.length} karakter',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: widget.onSave != null
            ? FloatingActionButton.extended(
                onPressed: _saveNote,
                icon: const Icon(Icons.smart_toy),
                label: const Text('AI Analizi'),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              )
            : null,
      ),
    );
  }
}
