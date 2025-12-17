import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import '../data/database/app_database.dart';
import '../widgets/map_picker.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addrController = TextEditingController();
  // 1. Thêm controller cho Link Ảnh
  final _imageController = TextEditingController();

  double? _selectedLat;
  double? _selectedLong;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addrController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  // --- API TÌM KIẾM ĐỊA ĐIỂM (Auto-complete) ---
  Future<List<dynamic>> _searchPlace(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&countrycodes=vn',
    );
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'RandomFoodApp_StudentProject'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Lỗi tìm kiếm: $e");
    }
    return [];
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPicker()),
    );
    if (result != null) {
      setState(() {
        _selectedLat = result.latitude;
        _selectedLong = result.longitude;
        if (_addrController.text.isEmpty) {
          _addrController.text = "Vị trí đã ghim trên bản đồ";
        }
      });
    }
  }

  void _saveRestaurant() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên quán!")));
      return;
    }

    final db = Provider.of<AppDatabase>(context, listen: false);

    final newItem = RestaurantsCompanion(
      name: drift.Value(_nameController.text),
      description: drift.Value(_descController.text),
      address: drift.Value(_addrController.text),
      // 2. Lưu Link ảnh vào Database
      imageUrl: drift.Value(_imageController.text),
      latitude: drift.Value(_selectedLat),
      longitude: drift.Value(_selectedLong),
    );

    db.insertRestaurant(newItem).then((_) {
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nhập tên quán (Có gợi ý):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),

              // Gợi ý tên quán & địa chỉ thông minh
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Tên quán (VD: Ba Ghiền...)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return await _searchPlace(pattern);
                },
                itemBuilder: (context, suggestion) {
                  final place = suggestion as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Colors.orange,
                    ),
                    title: Text(
                      place['name'] ?? place['display_name'].split(',')[0],
                    ),
                    subtitle: Text(
                      place['display_name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  final place = suggestion as Map<String, dynamic>;
                  setState(() {
                    _nameController.text =
                        place['name'] ?? place['display_name'].split(',')[0];
                    _addrController.text = place['display_name'];
                    _selectedLat = double.parse(place['lat']);
                    _selectedLong = double.parse(place['lon']);
                  });
                },
                noItemsFoundBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Không tìm thấy, hãy nhập tay nhé!"),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Mô tả (VD: Ngon, rẻ)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _addrController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Địa chỉ (Tự điền hoặc nhập tay)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Ô nhập Link Ảnh
              TextField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: "Link Ảnh (Copy trên mạng dán vô)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  helperText: "Để trống sẽ hiện ảnh mặc định",
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedLat == null
                          ? "Chưa có tọa độ"
                          : "Đã có tọa độ chính xác! ✅",
                      style: TextStyle(
                        color: _selectedLat == null
                            ? Colors.grey
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickLocation,
                    icon: const Icon(Icons.map),
                    label: const Text("Chỉnh lại Map"),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: _saveRestaurant,
                  child: const Text(
                    "LƯU QUÁN",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
