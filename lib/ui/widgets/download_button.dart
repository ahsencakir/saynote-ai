import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

class DownloadButton extends StatelessWidget {
  final String content;
  final String fileName;

  const DownloadButton({
    super.key,
    required this.content,
    required this.fileName,
  });

  void _downloadFile() {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _downloadFile,
      icon: const Icon(Icons.download),
      label: const Text('Notu İndir'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    );
  }
} 