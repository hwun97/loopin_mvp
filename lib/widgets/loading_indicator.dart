import 'package:flutter/material.dart';

/// 로딩 상태를 표시하는 다이얼로그 위젯
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF21c3c5)),
          ),
          const SizedBox(height: 16),
          Text(message ?? '처리 중입니다...', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
