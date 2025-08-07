import 'package:flutter/material.dart';

class TranscriptBox extends StatelessWidget {
  final String transcript;
  final VoidCallback onClear;
  final bool isListening;

  const TranscriptBox({
    super.key,
    required this.transcript,
    required this.onClear,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isListening ? Colors.orange : Colors.grey.shade300,
          width: isListening ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isListening ? Colors.orange : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isListening ? Icons.mic : Icons.text_fields,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isListening ? '🎤 Canlı Konuşma' : '📝 Konuşma Metni',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (transcript.isNotEmpty)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear),
                    tooltip: 'Temizle',
                    color: Colors.red,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Metin İçeriği
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isListening
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isListening
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.grey.shade200,
                ),
              ),
              child: transcript.isEmpty
                  ? Text(
                      isListening
                          ? '🎤 Konuşmaya başlayın...'
                          : '📝 Henüz metin yok. Mikrofon butonuna basın.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isListening)
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'CANLI',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        if (isListening) const SizedBox(height: 8),
                        SelectableText(
                          transcript,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: isListening
                                ? Colors.orange.shade800
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
            ),

            // İstatistikler
            if (transcript.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Kelime sayısı
                    Row(
                      children: [
                        Icon(
                          Icons.text_fields,
                          size: 18,
                          color: Colors.blue.shade700, // ✅ Daha koyu mavi
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${transcript.split(' ').length} kelime',
                          style: const TextStyle(
                            fontSize: 15, // ✅ Biraz daha büyük
                            fontWeight: FontWeight.w700, // ✅ Daha kalın
                            color: Colors.black87, // ✅ Koyu siyah
                          ),
                        ),
                      ],
                    ),

                    // Ayırıcı çizgi
                    Container(
                      width: 2,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),

                    // Karakter sayısı
                    Row(
                      children: [
                        Icon(
                          Icons.keyboard,
                          size: 18,
                          color: Colors.green.shade700, // ✅ Daha koyu yeşil
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${transcript.length} karakter',
                          style: const TextStyle(
                            fontSize: 15, // ✅ Biraz daha büyük
                            fontWeight: FontWeight.w700, // ✅ Daha kalın
                            color: Colors.black87, // ✅ Koyu siyah
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
