import 'package:flutter/material.dart';

class SourceUnavailable extends StatelessWidget {
  final String sourceName;
  final VoidCallback onRetry;
  final VoidCallback onChangeSource;

  const SourceUnavailable({
    super.key,
    required this.sourceName,
    required this.onRetry,
    required this.onChangeSource,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.usb_off, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'External drive disconnected',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sourceName,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: onChangeSource,
                child: const Text('Change Source'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ],
      ),
    );
  }
}
