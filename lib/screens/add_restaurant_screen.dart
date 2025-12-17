import 'package:drift/drift.dart' as drift; // Đổi tên để tránh trùng lặp
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database/app_database.dart';
import '../widgets/map_picker.dart'; // Import bản đồ vừa tạo

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  // Biến lưu tọa độ sau khi chọn
  double? _selectedLat;
  double? _selectedLong;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Hàm mở bản đồ
  Future<void> _pickLocation() async {
    // Chuyển sang màn hình bản đồ và chờ kết quả trả về
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPicker()),
    );

    // Nếu người dùng có chọn và bấm nút
    if (result != null) {
      setState(() {
        _selectedLat = result.latitude;
        _selectedLong = result.longitude;
      });
    }
  }

  // Hàm lưu vào Database
  void _saveRestaurant() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên quán!")));
      return;
    }

    final db = Provider.of<AppDatabase>(context, listen: false);

    // Tạo dữ liệu để insert (Dùng RestaurantsCompanion)
    final newItem = RestaurantsCompanion(
      name: drift.Value(_nameController.text),
      description: drift.Value(_descController.text),
      latitude: drift.Value(_selectedLat),
      longitude: drift.Value(_selectedLong),
    );

    // Gọi hàm insert
    db.insertRestaurant(newItem).then((_) {
      // Lưu xong thì quay về trang trước
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã thêm quán mới!")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Quán Mới")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ô nhập tên
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Tên quán (VD: Cơm Tấm)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),

            // Ô nhập mô tả
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Mô tả (VD: Ngon, rẻ)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),

            // Khu vực hiển thị trạng thái Vị trí
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedLat == null
                        ? "Chưa chọn vị trí"
                        : "Đã chọn: ${_selectedLat!.toStringAsFixed(4)}, ${_selectedLong!.toStringAsFixed(4)}",
                    style: TextStyle(
                      color: _selectedLat == null ? Colors.grey : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.map),
                  label: const Text("Chọn trên Map"),
                ),
              ],
            ),
            const Spacer(),

            // Nút Lưu to đùng
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: _saveRestaurant,
                child: const Text(
                  "LƯU QUÁN",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
