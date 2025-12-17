import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../data/database/app_database.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Danh sách kết quả tìm kiếm (Để hiện Marker)
  List<dynamic> _searchResults = [];

  // Trạng thái đang tải
  bool _isLoading = false;

  // Tọa độ mặc định (TP.HCM)
  LatLng _center = const LatLng(10.7769, 106.7009);

  // --- HÀM TÌM KIẾM ONLINE ---
  Future<void> _searchOnline() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    // Gọi API OpenStreetMap (Tìm quán ở Việt Nam)
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=20&countrycodes=vn',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'RandomFoodApp_StudentProject'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data;
        });

        // Nếu có kết quả, di chuyển map tới kết quả đầu tiên
        if (data.isNotEmpty) {
          final first = data[0];
          final lat = double.parse(first['lat']);
          final lon = double.parse(first['lon']);
          _mapController.move(LatLng(lat, lon), 14.0);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi mạng: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- HÀM LƯU QUÁN VÀO DB ---
  void _saveToMyList(Map<String, dynamic> place) {
    final db = Provider.of<AppDatabase>(context, listen: false);

    final name = place['name'] ?? place['display_name'].split(',')[0];
    final address = place['display_name'];
    final lat = double.parse(place['lat']);
    final lon = double.parse(place['lon']);

    final newItem = RestaurantsCompanion(
      name: drift.Value(name),
      address: drift.Value(address),
      latitude: drift.Value(lat),
      longitude: drift.Value(lon),
      description: const drift.Value("Tìm thấy từ Explore"),
    );

    db.insertRestaurant(newItem).then((_) {
      Navigator.pop(context); // Đóng cái bảng thông tin lại
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã lưu vào danh sách quán ruột! 🎉"),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // --- HIỆN THÔNG TIN KHI BẤM MARKER ---
  void _showPlaceDetail(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final name = place['name'] ?? place['display_name'].split(',')[0];
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.store, color: Colors.orange, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                "📍 ${place['display_name']}",
                style: const TextStyle(color: Colors.grey),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _saveToMyList(place),
                  icon: const Icon(Icons.add_circle),
                  label: const Text(
                    "LƯU VÀO DANH SÁCH CỦA TUI",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BẢN ĐỒ NỀN
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _center, initialZoom: 13.0),
            children: [
              TileLayer(
                urlTemplate:
                    'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.random_food',
              ),
              // Lớp hiển thị Marker kết quả
              MarkerLayer(
                markers: _searchResults.map((place) {
                  final lat = double.parse(place['lat']);
                  final lon = double.parse(place['lon']);
                  return Marker(
                    point: LatLng(lat, lon),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showPlaceDetail(place),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. THANH TÌM KIẾM (Nổi bên trên)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchOnline(),
                  decoration: InputDecoration(
                    hintText: "Tìm quán mới (VD: Bún bò, Katinat...)",
                    border: InputBorder.none,
                    icon: const Icon(Icons.search, color: Colors.orange),
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _searchOnline,
                          ),
                  ),
                ),
              ),
            ),
          ),

          // 3. NÚT ĐỊNH VỊ LẠI
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
              onPressed: () {
                _mapController.move(_center, 13.0);
              },
            ),
          ),
        ],
      ),
    );
  }
}
