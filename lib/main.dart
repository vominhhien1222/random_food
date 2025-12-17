import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database/app_database.dart';
import 'screens/main_screen.dart'; // 1. Import màn hình chính chứa Task bar

void main() {
  // Khởi tạo Database
  final database = AppDatabase();

  runApp(
    // Cung cấp database cho toàn bộ App
    Provider<AppDatabase>.value(value: database, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hôm Nay Ăn Gì',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        // Màu nền trắng/xám nhẹ để Card nổi bật hơn
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      // 2. Đổi màn hình khởi động thành MainScreen (có thanh điều hướng)
      home: const MainScreen(),
    );
  }
}
