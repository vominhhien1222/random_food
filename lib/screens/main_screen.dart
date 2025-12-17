import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'list_restaurant_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Biến lưu tab hiện tại (0 là Home, 1 là List)
  int _currentIndex = 0;

  // Danh sách các màn hình
  final List<Widget> _screens = [
    const HomeScreen(),
    const ListRestaurantScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị màn hình tương ứng với tab đang chọn
      body: IndexedStack(index: _currentIndex, children: _screens),

      // THANH ĐIỀU HƯỚNG (TASK BAR)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange, // Màu cam cho tab đang chọn
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'My List', // Quán ruột
            ),
            // Bạn có thể thêm tab Explore ở đây nếu muốn sau này
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
          ],
        ),
      ),
    );
  }
}
