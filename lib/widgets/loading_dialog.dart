import 'package:flutter/material.dart';

Future<void> showLoadingDialog(BuildContext context, {String? message}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (_) => WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF21c3c5)),
                  const SizedBox(height: 16),
                  Text(
                    message ?? "처리 중...",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}
