import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database/app_database.dart';
import 'add_restaurant_screen.dart';

class ListRestaurantScreen extends StatefulWidget {
  const ListRestaurantScreen({super.key});

  @override
  State<ListRestaurantScreen> createState() => _ListRestaurantScreenState();
}

class _ListRestaurantScreenState extends State<ListRestaurantScreen> {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền hơi xám nhẹ cho sang
      appBar: AppBar(
        title: const Text(
          "Quán ruột của tui",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black, // Chữ màu đen
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: database.getAllRestaurants(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;

          if (list.isEmpty) {
            return const Center(
              child: Text(
                "Chưa có quán nào nè, thêm đi!",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              // Ảnh mặc định nếu không có
              const defaultImg =
                  "https://images.unsplash.com/photo-1546069901-ba9599a7e63c";
              final imgUrl =
                  (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  ? item.imageUrl!
                  : defaultImg;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // 1. ẢNH THUMBNAIL (Bo tròn)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imgUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 2. NỘI DUNG (Tên, Mô tả)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description ?? "Không có mô tả",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Hiện thêm địa chỉ nếu có
                            if (item.address != null)
                              Text(
                                "📍 ${item.address}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),

                      // 3. MENU 3 CHẤM
                      PopupMenuButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onSelected: (value) {
                          if (value == 'delete') {
                            database.deleteRestaurant(item.id).then((_) {
                              setState(() {}); // Load lại sau khi xóa
                            });
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Xóa quán này",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // NÚT FAB MÀU CAM (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRestaurantScreen()),
          );
          setState(() {}); // Load lại khi thêm xong
        },
      ),
    );
  }
}
