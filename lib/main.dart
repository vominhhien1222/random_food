import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/database/app_database.dart';
import 'screens/list_restaurant_screen.dart'; // Màn hình chúng ta sắp tạo

void main() {
  // 1. Khởi tạo Database
  final database = AppDatabase();

  runApp(
    // 2. Cung cấp database cho toàn bộ App
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
        primarySwatch: Colors.orange, // Màu chủ đạo màu Cam
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
      // Mở màn hình danh sách đầu tiên
      home: const ListRestaurantScreen(),
    );
  }
}
