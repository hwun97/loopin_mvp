import 'package:flutter/material.dart';
import 'loading_indicator.dart';

/// 비동기 작업 중 로딩 다이얼로그를 띄우는 함수
Future<void> showLoadingDialog(BuildContext context, {String? message}) async {
  debugPrint('[showLoadingDialog] 다이얼로그 띄우기 시작');
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      debugPrint('[showLoadingDialog] 다이얼로그 builder 실행됨');
      return LoadingIndicator(message: message);
    },
  );
  debugPrint('[showLoadingDialog] 다이얼로그 종료됨');
}
