import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/database/app_database.dart';
import 'add_restaurant_screen.dart'; // Màn hình thêm quán (sẽ tạo ở bước sau)

class ListRestaurantScreen extends StatefulWidget {
  const ListRestaurantScreen({super.key});

  @override
  State<ListRestaurantScreen> createState() => _ListRestaurantScreenState();
}

class _ListRestaurantScreenState extends State<ListRestaurantScreen> {
  @override
  Widget build(BuildContext context) {
    // Lấy database từ Provider
    final database = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh Sách Quán Ngon"),
        backgroundColor: Colors.orangeAccent,
      ),
      // FutureBuilder giúp chờ database load dữ liệu xong mới hiện lên
      body: FutureBuilder<List<Restaurant>>(
        future: database.getAllRestaurants(),
        builder: (context, snapshot) {
          // 1. Đang load...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Có lỗi
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          final list = snapshot.data ?? [];

          // 3. Danh sách rỗng
          if (list.isEmpty) {
            return const Center(
              child: Text(
                "Chưa có quán nào.\nBấm nút + để thêm nhé!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // 4. Có dữ liệu -> Hiển thị list
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.restaurant, color: Colors.white),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item.description ?? "Không có mô tả"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Xử lý xóa quán
                      database.deleteRestaurant(item.id).then((_) {
                        setState(() {}); // Load lại danh sách sau khi xóa
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      // Nút thêm mới (+)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Chuyển sang màn hình thêm quán
          // await: Chờ thêm xong quay về thì load lại danh sách
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRestaurantScreen()),
          );
          setState(() {}); // Load lại data khi quay về
        },
      ),
    );
  }
}
