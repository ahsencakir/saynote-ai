import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final bool isListening;
  final bool isProcessing;
  final VoidCallback? onPressed;

  const MicButton({
    super.key,
    required this.isListening,
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isDisabled
          ? LinearGradient(
              colors: [Colors.grey.shade300, Colors.grey.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : isListening 
            ? LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : isProcessing
              ? LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        boxShadow: [
          BoxShadow(
            color: (isDisabled 
              ? Colors.grey 
              : isListening 
                ? Colors.red 
                : isProcessing 
                  ? Colors.orange 
                  : Colors.blue).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: isListening ? 2 : 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isProcessing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    isDisabled 
                      ? Icons.mic_off
                      : isListening 
                        ? Icons.stop 
                        : Icons.mic,
                    size: 28,
                    color: Colors.white,
                  ),
                const SizedBox(width: 12),
                Text(
                  isDisabled 
                    ? 'Hazırlanıyor...'
                    : isProcessing 
                      ? 'İşleniyor...'
                      : isListening 
                        ? 'Durdur' 
                        : 'Dinlemeye Başla',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 